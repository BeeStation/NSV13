/obj/item/rcl
	name = "rapid cable layer"
	desc = "A device used to rapidly deploy cables. It has screws on the side which can be removed to slide off the cables. Do not use without insulation!"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcl-0"
	item_state = "rcl-0"
	var/obj/item/stack/cable_coil/loaded
	opacity = FALSE
	force = 5 //Plastic is soft
	throwforce = 5
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	var/max_amount = 90
	actions_types = list(/datum/action/item_action/rcl_col,/datum/action/item_action/rcl_gui,)
	var/list/colors = list("red", "yellow", "green", "blue", "pink", "orange", "cyan", "white")
	var/current_color_index = 1
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	var/direction_one = 1
	var/direction_two = 2
	var/wiring_choice

/obj/item/rcl/Initialize()
	. = ..()
	update_icon()

/obj/item/rcl/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W

		if(!loaded)
			if(!user.transferItemToLoc(W, src))
				to_chat(user, "<span class='warning'>[src] is stuck to your hand!</span>")
				return
			else
				loaded = W //W.loc is src at this point.
				loaded.max_amount = max_amount //We store a lot.
				return

		if(loaded.amount < max_amount)
			var/transfer_amount = min(max_amount - loaded.amount, C.amount)
			C.use(transfer_amount)
			loaded.amount += transfer_amount
		else
			return
		update_icon()
		to_chat(user, "<span class='notice'>You add the cables to [src]. It now contains [loaded.amount].</span>")
	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(!loaded)
			return
		to_chat(user, "<span class='notice'>You loosen the securing screws on the side, allowing you to lower the guiding edge and retrieve the wires.</span>")
		while(loaded.amount > 30) //There are only two kinds of situations: "nodiff" (60,90), or "diff" (31-59, 61-89)
			var/diff = loaded.amount % 30
			if(diff)
				loaded.use(diff)
				new /obj/item/stack/cable_coil(get_turf(user), diff)
			else
				loaded.use(30)
				new /obj/item/stack/cable_coil(get_turf(user), 30)
		loaded.max_amount = initial(loaded.max_amount)
		if(!user.put_in_hands(loaded))
			loaded.forceMove(get_turf(user))

		loaded = null
		update_icon()
	else
		..()

/obj/item/rcl/proc/generate_choices(mob/user)
	var/list/wiredirs = list("1-2","5-10","1-4","2-4","4-8","2-8","1-8", "6-9")
	for(var/icondir in wiredirs)
		var/cablesuffix = icondir
		var/image/img = image(icon = 'icons/mob/radial.dmi', icon_state = "cable_[cablesuffix]")
		img.color = GLOB.cable_colors[colors[current_color_index]]
		wiredirs[icondir] = img
	return wiredirs

//setting of choice
/obj/item/rcl/attack_self(mob/user)
	. = ..()
	var/list/choices = generate_choices(user)
	wiring_choice = show_radial_menu(user, src, choices, radius = 42, require_near = TRUE)
	direction_one = wiring_choice[1]
	direction_two = wiring_choice[3]
	direction_one = text2num(direction_one)
	direction_two = text2num(direction_two)

// Actual deployment of wiring
/obj/item/rcl/afterattack(atom/target, mob/user)
	. = ..()
	loaded.place_turf_dir(target,user,direction_two, direction_one)

/obj/item/rcl/attack(mob/living/M, mob/living/user)
	return

/obj/item/rcl/examine(mob/user)
	. = ..()
	if(loaded)
		. += "<span class='info'>It contains [loaded.amount]/[max_amount] cables.</span>"

/obj/item/rcl/Destroy()
	QDEL_NULL(loaded)
	return ..()

/obj/item/rcl/update_icon()
	if(!loaded)
		icon_state = "rcl-0"
		item_state = "rcl-0"
		return
	switch(loaded.amount)
		if(61 to INFINITY)
			icon_state = "rcl-30"
			item_state = "rcl"
		if(31 to 60)
			icon_state = "rcl-20"
			item_state = "rcl"
		if(1 to 30)
			icon_state = "rcl-10"
			item_state = "rcl"
		else
			icon_state = "rcl-0"
			item_state = "rcl-0"

/obj/item/rcl/proc/is_empty(mob/user, loud = 1)
	update_icon()
	if(!loaded || !loaded.amount)
		if(loud)
			to_chat(user, "<span class='notice'>The last of the cables unreel from [src].</span>")
		if(loaded)
			QDEL_NULL(loaded)
			loaded = null
		return TRUE
	return FALSE

/obj/item/rcl/pre_loaded/Initialize() //Comes preloaded with cable, for testing stuff
	. = ..()
	loaded = new()
	loaded.max_amount = max_amount
	loaded.amount = max_amount
	update_icon()

/obj/item/rcl/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/rcl_col))
		current_color_index++;
		if (current_color_index > colors.len)
			current_color_index = 1
		var/cwname = colors[current_color_index]
		to_chat(user, "Color changed to [cwname]!")
		if(loaded)
			loaded.item_color= colors[current_color_index]
	if(istype(action, /datum/action/item_action/rcl_gui))
		attack_self(user)
