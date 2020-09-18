//Fluff components that are only used in building.
/obj/item/fighter_component/avionics
	name = "Fighter Avionics"
	desc = "Avionics for a fighter"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "avionics"
	tier = null //Cannot be upgraded.

/obj/item/fighter_component/apu
	name = "Fighter Auxiliary Power Unit"
	desc = "An Auxiliary Power Unit for a fighter"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "apu"

/obj/item/fighter_component/targeting_sensor
	name = "Fighter Targeting Sensors"
	icon = 'icons/obj/crates.dmi'
	icon_state = "weaponcrate"
	tier = null //Cannot be upgraded.

/obj/structure/fighter_chassis
	name = "Light Fighter Chassis"
	desc = "The begginings of a Su-818 Rapier, just add parts, manual labour, and several military grade tools!"
	icon = 'nsv13/icons/overmap/nanotrasen/fighter_construction.dmi'
	icon_state = "fighter"
	pixel_x = -32
	pixel_y = -12
	anchored = FALSE
	density = TRUE
	var/output_path = /obj/structure/overmap/fighter
