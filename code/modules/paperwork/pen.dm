/* Pens!
 * Contains:
 *		Pens
 *		Sleepy Pens
 *		Parapens
 */


/*
 * Pens
 */
/obj/item/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	matter = list(MATERIAL_STEEL = 10)
	var/colour = "black"	//what colour the ink is!


/obj/item/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"

/obj/item/pen/multi
	desc = "It's a pen with multiple colors of ink!"
	var/selectedColor = 1
	var/colors = list("black","blue","red")

/obj/item/pen/multi/attack_self(mob/user)
	if(++selectedColor > 3)
		selectedColor = 1

	colour = colors[selectedColor]

	if(colour == "black")
		icon_state = "pen"
	else
		icon_state = "pen_[colour]"

	user << "<span class='notice'>Changed color to '[colour].'</span>"

/obj/item/pen/invisible
	desc = "It's an invisble pen marker."
	icon_state = "pen"
	colour = "white"


/obj/item/pen/attack(var/mob/M, var/mob/user)
	if(!ismob(M))
		return
	user << "<span class='warning'>You stab [M] with the pen.</span>"
//	M << "\red You feel a tiny prick!" //That's a whole lot of meta!
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stabbed with [name]  by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to stab [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) Used the [name] to stab [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	return

/*
 * Reagent pens
 */

/obj/item/pen/reagent
	flags = OPENCONTAINER
	slot_flags = SLOT_BELT


/obj/item/pen/reagent/New()
	..()
	create_reagents(30)

/obj/item/pen/reagent/attack(mob/living/M, mob/user, var/target_zone)

	if(!istype(M))
		return

	. = ..()

	if(M.can_inject(user, target_zone))
		if(reagents.total_volume)
			if(M.reagents)
				var/contained_reagents = reagents.get_reagents()
				var/trans = reagents.trans_to_mob(M, 30, CHEM_BLOOD)
				admin_inject_log(user, M, src, contained_reagents, trans)

/*
 * Sleepy Pens
 */
/obj/item/pen/reagent/sleepy
	desc = "It's a black ink pen with a sharp point and a carefully engraved \"Waffle Co.\"."


/obj/item/pen/reagent/sleepy/New()
	..()
	reagents.add_reagent(REAGENT_CHLORALHYDRATE, 22)	//Used to be 100 sleep toxin//30 Chloral seems to be fatal, reducing it to 22./N


/*
 * Parapens
 */
/obj/item/pen/reagent/paralysis


/obj/item/pen/reagent/paralysis/New()
	..()
	reagents.add_reagent(REAGENT_BYPHODINE, 10)
	reagents.add_reagent(REAGENT_CRYPTOBIOLIN, 15)

/*
 * Chameleon pen
 */
/obj/item/pen/chameleon
	var/signature = ""

/obj/item/pen/chameleon/attack_self(var/mob/user)
	/*
	// Limit signatures to official crew members
	var/personnel_list[] = list()
	for(var/datum/data/record/t in data_core.locked) //Look in data core locked.
		personnel_list.Add(t.fields["name"])
	personnel_list.Add("Anonymous")

	var/new_signature = input("Enter new signature pattern.", "New Signature") as null|anything in personnel_list
	if(new_signature)
		signature = new_signature
	*/
	signature = sanitize(input("Enter new signature. Leave blank for 'Anonymous'", "New Signature", signature))

/obj/item/pen/proc/get_signature(var/mob/user)
	return (user && user.real_name) ? user.real_name : "Anonymous"

/obj/item/pen/chameleon/get_signature(var/mob/user)
	return signature ? signature : "Anonymous"

/obj/item/pen/chameleon/verb/set_colour()
	set name = "Change Pen Colour"
	set category = "Object"

	var/list/possible_colours = list ("Yellow", "Green", "Pink", "Blue", "Orange", "Cyan", "Red", "Invisible", "Black")
	var/selected_type = input("Pick new colour.", "Pen Colour", null, null) as null|anything in possible_colours

	if(selected_type)
		switch(selected_type)
			if("Yellow")
				colour = COLOR_YELLOW
			if("Green")
				colour = COLOR_LIME
			if("Pink")
				colour = COLOR_PINK
			if("Blue")
				colour = COLOR_BLUE
			if("Orange")
				colour = COLOR_ORANGE
			if("Cyan")
				colour = COLOR_CYAN
			if("Red")
				colour = COLOR_RED
			if("Invisible")
				colour = COLOR_WHITE
			else
				colour = COLOR_BLACK
		usr << "<span class='info'>You select the [lowertext(selected_type)] ink container.</span>"


/*
 * Crayons
 */

/obj/item/pen/crayon
	name = "crayon"
	desc = "A colourful crayon. Please refrain from eating it or putting it in your nose."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonred"
	w_class = 1.0
	attack_verb = list("attacked", "coloured")
	colour = "#FF0000" //RGB
	var/shadeColour = "#220000" //RGB
	var/uses = 30 //0 for unlimited uses
	var/instant = 0
	var/colourName = "red" //for updateIcon purposes

	New()
		name = "[colourName] crayon"
		..()
