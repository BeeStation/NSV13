///Lowers sediment, raises everything else
/obj/machinery/rock_processor/rock_cleaner
	name = "rock cleaner"
	desc = "Cleans sediment off of rocks, exposing more of the valuable minerals. Be careful not to rinse out volatile materials such as plasma."
	icon_state = "rock_cleaner"
	process_flag = MINING_PROCESSOR_RINSING
	signal_to_send = COMSIG_COMPONENT_RINSE_ACT
	ore_coefficients = list(/datum/material/iron = 1.25, /datum/material/sand = 0.5, /datum/material/plasma = 1.25, /datum/material/silver = 1.25, /datum/material/gold = 1.25, /datum/material/uranium = 1.25,\
	/datum/material/titanium = 1.25, /datum/material/diamond = 1.25, /datum/material/bananium = 1.25, /datum/material/bluespace = 1.25)


/obj/machinery/rock_processor/rock_cleaner/update_icon()
	cut_overlays()

	if(on)
		add_overlay(mutable_appearance('icons/obj/watercloset.dmi', "rock_cleaner_water", ABOVE_MOB_LAYER))
		icon_state = "rock_cleaner_on"
	else
		icon_state = "rock_cleaner"





