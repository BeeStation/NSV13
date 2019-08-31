///Raises gold silver and bananium, lowering  iron titanium and diamond.
/obj/machinery/rock_processor/electrifier
	name = "tesla plasma stabilizer"
	desc = "Uses tesla-magnified magnetic field to stabilize plasma ores."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rock_cleaner"
	process_flag = MINING_PROCESSOR_ELECTRIFYING
	signal_to_send = COMSIG_COMPONENT_ELECTIRIFYPROCESS
	ore_coefficients = list(/datum/material/plasma = 1.5, /datum/material/titanium = 0.5, /datum/material/bluespace = 0)
 
/obj/machinery/rock_processor/electrifier/update_icon()
	cut_overlays()

	if(on)
		add_overlay(mutable_appearance('icons/obj/watercloset.dmi', "rock_cleaner_fire", ABOVE_MOB_LAYER))
		icon_state = "rock_cleaner_on"
	else
		icon_state = "rock_cleaner"
	
///Tesla zap if theres titanium in the rock
/obj/machinery/rock_processor/purifier/refine_rock(var/obj/item/rock/R)
	. = ..()
	if(!R.has_material(/datum/material/titanium))
		return
	tesla_zap(src, 7, 8000)