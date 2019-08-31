///Raises iron, lowering sediment, silver and gold
/obj/machinery/rock_processor/ironizer
	name = "ironizer"
	desc = "This machine turns some of the sediment into iron, also effects some other materials though."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rock_cleaner"
	process_flag = MINING_PROCESSOR_IRONIZING
	signal_to_send = COMSIG_COMPONENT_IRONIZINGPROCESS
	ore_coefficients = list(/datum/material/iron = 1.5, /datum/material/sand = 0.75, /datum/material/silver = 0.25, /datum/material/gold = 0.25)
 
/obj/machinery/rock_processor/ironizer/update_icon()
	cut_overlays()

	if(on)
		add_overlay(mutable_appearance('icons/obj/watercloset.dmi', "rock_cleaner_fire", ABOVE_MOB_LAYER))
		icon_state = "rock_cleaner_on"
	else
		icon_state = "rock_cleaner"