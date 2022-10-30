/obj/item/wargame_projector
	name = "holographic projector"
	desc = "A handy-dandy holographic projector developed by Nanotrasen Naval Command for playing wargames with, this one seems broken."
	icon = 'nsv13/icons/obj/wargame.dmi'
	icon_state = "projector"
	item_state = "electronic"
	force = 0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	item_flags = NOBLUDGEON

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
		"Orange" = COLOR_LIGHT_ORANGE,
		"Yellow" = COLOR_VIVID_YELLOW,
		"Green" = COLOR_VIBRANT_LIME,
		"Blue" = COLOR_BLUE_LIGHT,
		"Pink" = COLOR_FADED_PINK,
		"White" = COLOR_WHITE,
		"Gray" = COLOR_GRAY,
		"Brown" = COLOR_BROWN,
		"Ice" = COLOR_BLUE_GRAY,
	)
	/// Will hold the choices for radial menu use, populated on init
	var/list/radial_choices = list()
	/// A names to path list for the projections filled out by populate_radial_choice_lists() on init
	var/list/projection_names_to_path = list()
