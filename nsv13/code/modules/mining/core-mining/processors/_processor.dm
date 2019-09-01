/obj/machinery/rock_processor
	name = "rock burner"
	desc = "Burns rocks with high temperature flames."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rock_cleaner"
	layer = ABOVE_MOB_LAYER
	var/process_flag = MINING_PROCESSOR_BURNING
	var/signal_to_send = COMSIG_COMPONENT_BURNPROCESS
	var/ore_coefficients = list(/datum/material/iron = 1, /datum/material/sand = 1, /datum/material/plasma = 1, /datum/material/silver = 1, /datum/material/gold = 1, /datum/material/uranium = 1,\
	/datum/material/titanium = 1, /datum/material/diamond = 1, /datum/material/bananium = 1, /datum/material/bluespace = 1)
	var/on = FALSE

/obj/machinery/rock_processor/Initialize()
	. = ..()
	
	var/list/temp_list = list()

	for(var/i in ore_coefficients)
		temp_list[getmaterialref(i)] = ore_coefficients[i]
	
	ore_coefficients = temp_list

	

/obj/machinery/rock_processor/attack_hand(mob/living/user)
	. = ..()
	on = !on
	update_icon()

//On crossed, send our machines signal and then process the rock
/obj/machinery/rock_processor/Crossed(atom/movable/AM)
	. = ..()
	if(!on)//If we're not on we dont do shit
		return
	SEND_SIGNAL(AM, signal_to_send)
	if(!istype(AM, /obj/item/rock))
		return FALSE
	if(!AM.custom_materials?.len)
		return FALSE

	var/obj/item/rock/R = AM

	if(R.used_processors & process_flag) //Already washed
		return FALSE

	R.used_processors |= process_flag

	refine_rock(R)


/obj/machinery/rock_processor/proc/refine_rock(var/obj/item/rock/R)
	var/temp_ore_list = list()

	for(var/i in R.custom_materials)
		var/coefficient = ore_coefficients[i] || 1 //To prevent multiplying by null
		temp_ore_list[i] = R.custom_materials[i] *= coefficient
		
	R.set_custom_materials(temp_ore_list)

	return TRUE