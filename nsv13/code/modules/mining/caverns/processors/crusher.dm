///Raises diamond and bluespace but destroys the rest
/obj/machinery/rock_processor/crusher
	name = "crusher"
	desc = "This machine crushes rocks, leaving behind only the extremely strong materials inside like diamonds and bluespace crystals."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rock_cleaner"
	process_flag = MINING_PROCESSOR_CRUSHING
	signal_to_send = COMSIG_COMPONENT_CRUSHERPROCESS
	ore_coefficients = list(/datum/material/iron = 0, /datum/material/sand = 0, /datum/material/plasma = 0, /datum/material/silver = 0, /datum/material/gold = 0, /datum/material/uranium = 0,\
	/datum/material/titanium = 0, /datum/material/diamond = 1.5 , /datum/material/bananium = 0, /datum/material/bluespace = 1.5)
 
/obj/machinery/rock_processor/crusher/update_icon()
	cut_overlays()

	if(on)
		add_overlay(mutable_appearance('icons/obj/watercloset.dmi', "rock_cleaner_fire", ABOVE_MOB_LAYER))
		icon_state = "rock_cleaner_on"
	else
		icon_state = "rock_cleaner"

