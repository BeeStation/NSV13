/obj/item/wargame_projector
	name = "holographic projector"
	desc = "A handy-dandy holographic projector developed by Nanotrasen Naval Command for playing wargames with, this one seems broken."
	icon = 'nsv13/icons/obj/wargame.dmi'
	icon_state = "projector"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	force = 0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	item_flags = NOBLUDGEON
	greyscale_config = /datum/greyscale_config/wargame_hologram_projector
	greyscale_colors = COLOR_WHITE
	/// All of the signs this projector is maintaining
	var/list/projections
	/// The maximum number of projections this can support
	var/max_signs = 1
	/// The color to give holograms when created
	var/holosign_color = COLOR_WHITE
	/// The type of hologram to spawn on click
	var/holosign_type = /obj/structure/wargame_hologram
	/// A list containing all of the possible holosigns this can choose from
	var/list/holosign_options = list(
		/obj/structure/wargame_hologram,
	)
	/// Contains all of the colors that the holograms can be changed to spawn as
	var/static/list/color_options = list(
		"Red" = COLOR_RED_LIGHT,
		"Orange" = COLOR_PALE_ORANGE,
		"Yellow" = COLOR_YELLOW,
		"Green" = COLOR_LIME,
		"Blue" = COLOR_BLUE_LIGHT,
		"Pink" = COLOR_PINK,
		"White" = COLOR_WHITE,
		"Gray" = COLOR_GRAY,
		"Brown" = COLOR_BROWN,
		"Ice" = COLOR_BLUE_GRAY,
	)
	/// Will hold the choices for radial menu use, populated on init
	var/list/radial_choices = list()
	/// A names to path list for the projections filled out by populate_radial_choice_lists() on init
	var/list/projection_names_to_path = list()

/obj/item/wargame_projector/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/openspace_item_click_handler)
	set_greyscale(holosign_color)
	populate_radial_choice_lists()

/obj/item/wargame_projector/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	afterattack(target, user, proximity_flag, click_parameters)

/obj/item/wargame_projector/examine(mob/user)
	. = ..()
	if(projections)
		. += "<span class='notice'>It is currently maintaining <b>[projections.len]/[max_signs]</b> projections.</span>"
	. += "<span class='notice'>Use the projector <b>in hand</b> to change what type of hologram it creates.</span>"
	. += "<span class='notice'><b>Alt clicking</b> the projector will let you change the color of the next hologram it makes.</span>"
	. += "<span class='warning'><b>Control clicking</b> the projector will allow you to clear all active holograms.</span>"

/obj/item/wargame_projector/proc/populate_radial_choice_lists()
	if(!length(radial_choices) || !length(projection_names_to_path))
		for(var/obj/structure/wargame_hologram/hologram as anything in holosign_options)
			projection_names_to_path[initial(hologram.name)] = hologram
			radial_choices[initial(hologram.name)] = image(icon = initial(hologram.icon), icon_state = initial(hologram.icon_state))

/obj/item/wargame_projector/proc/select_hologram(mob/user)
	var/picked_choice = show_radial_menu(
		user,
		src,
		radial_choices,
		require_near = TRUE,
		tooltips = TRUE,
		)

	if(isnull(picked_choice))
		return

	holosign_type = projection_names_to_path[picked_choice]

/obj/item/wargame_projector/attack_self(mob/user)
	select_hologram(user)

/obj/item/wargame_projector/AltClick(mob/user)
	var/selected_color = tgui_input_list(user, "Select a color", "Color Selection", color_options)
	if(isnull(selected_color))
		balloon_alert(user, "no color change")
		return
	var/color_to_set_to = color_options[selected_color]
	holosign_color = color_to_set_to
	balloon_alert(user, "color changed")
	set_greyscale(holosign_color)


/obj/item/wargame_projector/CtrlClick(mob/user)
	if(alert(usr,"Clear all currently active holograms?", "Hologram Removal", "Yes", "No") == "Yes")
		for(var/hologram as anything in projections)
			qdel(hologram)

/// Can we place a hologram at the target location?
/obj/item/wargame_projector/proc/check_can_place_hologram(atom/target, mob/user, proximity_flag, team)
	if(!proximity_flag)
		return FALSE
	if(!check_allowed_items(target, not_inside = TRUE))
		return FALSE
	var/turf/target_turf = get_turf(target)
	if(is_blocked_turf(target_turf))
		return FALSE
	if(LAZYLEN(projections) >= max_signs)
		balloon_alert(user, "max capacity!")
		return FALSE
	return TRUE

/// Spawn a hologram with pixel offset based on where the user clicked
/obj/item/wargame_projector/proc/create_hologram(atom/target, mob/user, click_parameters)
	var/obj/target_holosign = new holosign_type(get_turf(target), src)

	var/list/modifiers = params2list(click_parameters)
	var/click_x
	var/click_y

	if(LAZYACCESS(modifiers, ICON_X) && LAZYACCESS(modifiers, ICON_Y))
		click_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(world.icon_size/2), world.icon_size/2)
		click_y = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(world.icon_size/2), world.icon_size/2)

	target_holosign.pixel_x = click_x
	target_holosign.pixel_y = click_y

	target_holosign.color = holosign_color

	playsound(loc, 'sound/machines/click.ogg', 20, TRUE)

/obj/item/wargame_projector/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target, /obj/structure/wargame_hologram))
		qdel(target)
		return
	if(!check_can_place_hologram(target, user, proximity_flag, 1))
		return
	create_hologram(target, user, click_parameters)

/obj/item/wargame_projector/attack(mob/living/carbon/human/M, mob/user) //Jesse what the fuck is happening with that var, I'm scared to change it from M
	return

/obj/item/wargame_projector/Destroy()
	QDEL_LAZYLIST(projections)
	. = ..()

/*
Actual projector types, split between the 'categories' of things they can project
*/

/obj/item/wargame_projector/ships
	name = "holographic unit projector"
	desc = "A handy-dandy holographic projector developed by Nanotrasen Naval Command for playing wargames with, this one creates markers for 'units'."
	max_signs = 30
	holosign_color = COLOR_BLUE_LIGHT
	holosign_type = /obj/structure/wargame_hologram/ship_marker
	holosign_options = list(
		/obj/structure/wargame_hologram/unidentified,
		/obj/structure/wargame_hologram/missile_warning,
		/obj/structure/wargame_hologram/strike_craft,
		/obj/structure/wargame_hologram/strike_craft/wing,
		/obj/structure/wargame_hologram/ship_marker,
		/obj/structure/wargame_hologram/ship_marker/medium,
		/obj/structure/wargame_hologram/ship_marker/large,
		/obj/structure/wargame_hologram/ship_marker/large/alternate,
		/obj/structure/wargame_hologram/probe,
		/obj/structure/wargame_hologram/stationary_structure,
		/obj/structure/wargame_hologram/stationary_structure/platform,
	)

/obj/item/wargame_projector/ships/red
	holosign_color = COLOR_RED_LIGHT

/obj/item/wargame_projector/terrain
	name = "holographic terrain projector"
	desc = "A handy-dandy holographic projector developed by Nanotrasen Naval Command for playing wargames with, this one creates markers for space 'terrain'."
	max_signs = 30
	holosign_color = COLOR_GRAY
	holosign_type = /obj/structure/wargame_hologram/asteroid
	// Some things, like stations, probes, and unidentified contacts, can be in the terrain one just because I can see situations where that's desired
	holosign_options = list(
		/obj/structure/wargame_hologram/unidentified,
		/obj/structure/wargame_hologram/dust,
		/obj/structure/wargame_hologram/asteroid,
		/obj/structure/wargame_hologram/asteroid/large,
		/obj/structure/wargame_hologram/asteroid/cluster,
		/obj/structure/wargame_hologram/planet,
		/obj/structure/wargame_hologram/probe,
		/obj/structure/wargame_hologram/stationary_structure,
		/obj/structure/wargame_hologram/stationary_structure/platform,
	)
