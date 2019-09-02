///Raises all materials but releases toxic gas
/obj/machinery/rock_processor/purifier
	name = "purifier"
	desc = "This machine uses high pressure air to blow off the sand from rocks. This does release harmful toxins however."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rock_cleaner"
	process_flag = MINING_PROCESSOR_PURIFYING
	signal_to_send = COMSIG_COMPONENT_PURIFYPROCESS
	ore_coefficients = list(/datum/material/iron = 2, /datum/material/sand = 0.75, /datum/material/plasma = 2, /datum/material/silver = 2, /datum/material/gold = 2, /datum/material/uranium = 2,\
	/datum/material/titanium = 2, /datum/material/diamond = 2, /datum/material/bananium = 2, /datum/material/bluespace = 2)
 
/obj/machinery/rock_processor/purifier/update_icon()
	cut_overlays()

	if(on)
		add_overlay(mutable_appearance('icons/obj/watercloset.dmi', "rock_cleaner_fire", ABOVE_MOB_LAYER))
		icon_state = "rock_cleaner_on"
	else
		icon_state = "rock_cleaner"

///Spawn miasma if a rock goes through
/obj/machinery/rock_processor/purifier/refine_rock(var/obj/item/rock/R)
	. = ..()
	var/turf/our_turf = get_turf(src)
	our_turf.atmos_spawn_air("miasma=500")
