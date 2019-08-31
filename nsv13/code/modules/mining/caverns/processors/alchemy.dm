///Raises gold silver and bananium, lowering  iron titanium and diamond.
/obj/machinery/rock_processor/alchemy
	name = "alchemy"
	desc = "Uses bluespace science to raise the amount of gold and silver in a rock, seems to take a toll on some others though."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rock_cleaner"
	process_flag = MINING_PROCESSOR_ALCHEMIZING
	signal_to_send = COMSIG_COMPONENT_ALCHEMYPROCESS
	ore_coefficients = list(/datum/material/iron = 0.25, /datum/material/sand = 0.75, /datum/material/silver = 1.5, /datum/material/gold = 1.5,\
	/datum/material/titanium = 0.25, /datum/material/diamond = 0.25, /datum/material/bananium = 1.5,)
 
/obj/machinery/rock_processor/alchemy/update_icon()
	cut_overlays()

	if(on)
		add_overlay(mutable_appearance('icons/obj/watercloset.dmi', "rock_cleaner_fire", ABOVE_MOB_LAYER))
		icon_state = "rock_cleaner_on"
	else
		icon_state = "rock_cleaner"