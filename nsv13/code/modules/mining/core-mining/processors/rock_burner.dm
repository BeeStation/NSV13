///Lowers sediment, raises everything else
/obj/machinery/rock_processor/rock_burner
	name = "rock burner"
	desc = "Burns rocks with high temperature flames."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rock_cleaner"
	process_flag = MINING_PROCESSOR_BURNING
	signal_to_send = COMSIG_COMPONENT_BURNPROCESS
	ore_coefficients = list(/datum/material/iron = 1.25, /datum/material/sand = 0.75, /datum/material/plasma = 0, /datum/material/silver = 1.25, /datum/material/gold = 1.25, /datum/material/uranium = 1.25,\
	/datum/material/titanium = 1.25, /datum/material/diamond = 1.25, /datum/material/bananium = 1.25, /datum/material/bluespace = 1.25)
 
/obj/machinery/rock_processor/rock_burner/update_icon()
	cut_overlays()

	if(on)
		add_overlay(mutable_appearance('icons/obj/watercloset.dmi', "rock_cleaner_fire", ABOVE_MOB_LAYER))
		icon_state = "rock_cleaner_on"
	else
		icon_state = "rock_cleaner"