/*				ENGINEERING OBJECTIVES				*/

/datum/objective/crew/integrity //ported from old Hippie
	explanation_text = "Ensure the station's integrity rating is at least (Something broke, yell on GitHub)% when the shift ends."
	jobs = "chiefengineer,stationengineer"

/datum/objective/crew/integrity/New()
	. = ..()
	target_amount = rand(60,95)
	update_explanation_text()

/datum/objective/crew/integrity/update_explanation_text()
	. = ..()
	explanation_text = "Ensure the station's integrity rating is at least [target_amount]% when the shift ends."

/datum/objective/crew/integrity/check_completion()
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	var/station_integrity = min(PERCENT(GLOB.start_state.score(end_state)), 100)
	if(!SSticker.mode.station_was_nuked && station_integrity >= target_amount)
		return TRUE
	else
		return FALSE

/datum/objective/crew/poly
	explanation_text = "Make sure Poly keeps his headset, and stays alive until the end of the shift."
	jobs = "chiefengineer"

/datum/objective/crew/poly/check_completion()
	for(var/mob/living/simple_animal/parrot/Poly/dumbbird in GLOB.mob_list)
		if(!(dumbbird.stat == DEAD) && dumbbird.ears)
			if(istype(dumbbird.ears, /obj/item/radio/headset))
				return TRUE
	return FALSE

/datum/objective/crew/meltdown
	explanation_text = "Make sure that the engine does not meltdown while you are on the job."
	jobs = "chiefengineer,stationengineer,atmospherictechnician"
	var/meltdown = FALSE

/datum/objective/crew/meltdown/check_completion()
	if(meltdown)
		return FALSE
	return TRUE

/datum/objective/crew/power_generation
	explanation_text = "Maintain production of x MW in the engine until the end of the shift."
	jobs = "chiefengineer,stationengineer,atmospherictechnician"

/datum/objective/crew/power_generation/New()
	. = ..()
	var/base_target_power = 13000000
	target_percent = rand(60,90)
	target_amount = base_target_power * target_percent
	update_explanation_text()

/datum/objective/crew/power_generation/update_explanation_text()
	. = ..()
	explanation_text = "Maintain production of [target_amount] Watts in an engine until the end of the shift."

/datum/objective/crew/power_generation/check_completion()
	for(var/obj/machinery/atmospherics/components/binary/stormdrive_reactor/C in GLOB.machines)
		if(C.last_power_produced >= target_amount)
			return TRUE
	for(var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/C in GLOB.machines)
		if(C.last_power_produced >= target_amount)
			return TRUE
	return FALSE
