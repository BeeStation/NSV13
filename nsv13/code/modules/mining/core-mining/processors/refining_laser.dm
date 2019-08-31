///Raises titanium, bananium and bluespace crystals, but reacts badly to uranium
/obj/machinery/rock_processor/refining_laser
	name = "refining laser"
	desc = "Shoots concetrated particle beams into the rock, strengthening the bonds of specific high-end materials."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rock_cleaner"
	process_flag = MINING_PROCESSOR_BEAMING
	signal_to_send = COMSIG_COMPONENT_LASERPROCESS
	ore_coefficients = list(/datum/material/titanium = 1.75, /datum/material/bananium = 1.75, /datum/material/bluespace = 1.75, /datum/material/uranium = 0)
 
/obj/machinery/rock_processor/refining_laser/update_icon()
	cut_overlays()

	if(on)
		add_overlay(mutable_appearance('icons/obj/watercloset.dmi', "rock_cleaner_fire", ABOVE_MOB_LAYER))
		icon_state = "rock_cleaner_on"
	else
		icon_state = "rock_cleaner"

///Fire lasers randomly if theres diamonds in there
/obj/machinery/rock_processor/refining_laser/refine_rock(var/obj/item/rock/R)
	. = ..()
	if(!R.has_material(/datum/material/diamond))
		return
	var/turf/our_turf = get_turf(src)
	for(var/i in 1 to 9)
		var/obj/item/projectile/P = new /obj/item/projectile/beam(our_turf)
		P.fire(rand(1, 360))
