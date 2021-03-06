var/list/shuttle_landmarks = list()
var/area/map_base_area

//making this separate from /obj/effect/landmark until that mess can be dealt with
/obj/effect/shuttle_landmark
	name = "Nav Point"
	icon = 'icons/effects/effects.dmi'
	icon_state = "energynet"
	anchored = 1
	unacidable = 1
	simulated = 0
	invisibility = 101

	var/landmark_tag
	//ID of the controller on the dock side
	var/datum/computer/file/embedded_program/docking/docking_controller
	//ID of controller used for this landmark for shuttles with multiple ones.
	var/list/special_dock_targets

	//when the shuttle leaves this landmark, it will leave behind the base area
	//also used to determine if the shuttle can arrive here without obstruction
	var/area/base_area
	//Will also leave this type of turf behind if set.
	var/turf/base_turf

/obj/effect/shuttle_landmark/New()
	tag = landmark_tag //since tags cannot be set at compile time
	for(var/thing in all_areas)
		var/area/A = thing
		if((ispath(base_area) && A.type == base_area))
			base_area = A
			break
	if(!base_area || ispath(base_area))
		if(!map_base_area)
			for(var/thing in all_areas)
				var/area/A = thing
				if(A.type == using_map.base_area)
					map_base_area = A
					break
		base_area = map_base_area

	name = name + " ([x],[y])"
	shuttle_landmarks += src
	..()

/obj/effect/shuttle_landmark/Destroy()
	shuttle_landmarks -= src
	. = ..()
/obj/effect/shuttle_landmark/Initialize()
	if(docking_controller)
		var/docking_tag = docking_controller
		docking_controller = locate(docking_tag)
		if(!istype(docking_controller))
			log_debug("Could not find docking controller for shuttle waypoint '[name]', docking tag was '[docking_tag]'.")

/obj/effect/shuttle_landmark/proc/is_valid(var/datum/shuttle/shuttle)
	if(shuttle.current_location == src)
		return FALSE
	for(var/area/A in shuttle.shuttle_area)
		var/list/translation = get_turf_translation(get_turf(shuttle.current_location), get_turf(src), A.contents)
		if(check_collision(translation))
			return FALSE
	return TRUE

/obj/effect/shuttle_landmark/proc/check_collision(var/list/turf_translation)
	for(var/source in turf_translation)
		var/turf/target = turf_translation[source]
		if(!target)
			return TRUE //collides with edge of map
		if(target.loc != base_area)
			return TRUE //collides with another area
	return FALSE

//Self-naming/numbering ones.
/obj/effect/shuttle_landmark/automatic
	name = "Navpoint"
	landmark_tag = "navpoint"
	var/shuttle_restricted //name of the shuttle, null for generic waypoint

/obj/effect/shuttle_landmark/automatic/New()
	tag = landmark_tag+"-[x]-[y]"
	..()

/obj/effect/shuttle_landmark/automatic/Initialize()
	. = ..()
	if(!using_map.use_overmap)
		return
	var/obj/effect/overmap/O = map_sectors["[z]"]
	if(!istype(O))
		return
	if(shuttle_restricted)
		O.restricted_waypoints += src
	else
		O.generic_waypoints  += src

/obj/item/device/spaceflare
	name = "digital flare"
	desc = "Burst transmitter used to broadcast all needed information for shuttle navigation systems. Has a flare attached for marking the spot where you probably shouldn't be standing."
	icon_state = "bluflare"
	light_color = "#3728FF"
	var/active

/obj/item/device/spaceflare/attack_self(var/mob/user)
	if(!active)
		visible_message("<span class='notice'>[user] pulls the cord, activating the [src].</span>")
		activate()

/obj/item/device/spaceflare/proc/activate()
	if(active)
		return
	active = 1
	var/turf/T = get_turf(src)
	var/obj/effect/shuttle_landmark/automatic/mark = new(T)
	mark.name = "Beacon signal ([T.x],[T.y])"
	if(ismob(loc))
		var/mob/M = loc
		M.drop_from_inventory(src,T)
	anchored = 1
	T.hotspot_expose(1500, 5)
	update_icon()

/obj/item/device/spaceflare/update_icon()
	if(active)
		icon_state = "bluflare_on"
		set_light(l_range = 6, l_power = 3)
