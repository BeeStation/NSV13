///NSV13 living life() stuff file. Modularization.

#define GRAB_TEMP_EXCHANGE_MIN_DIFF 1 //If we have less than 1K difference in temp, why are we even bothering? (Might also do some weird stuff at very low differences due to decimal precision)

///If grabbing aggressively (or above), exchanges temperature with the target (taking into account insulation and all that stuff we hate dealing with).
/mob/living/proc/handle_temperature_exchange()

//I'm not bothering adjusting for all the weird edge cases carbons that are not-quite-human code have, so only /human to /human does this.
/mob/living/carbon/human/handle_temperature_exchange()
	if(!pulling || !ishuman(pulling))
		return
	var/mob/living/carbon/human/pulled_human = pulling
	if(grab_state < GRAB_AGGRESSIVE) //Handholding is not enough to share body heat.
		return
	var/tempdiff = pulled_human.bodytemperature - bodytemperature
	if(abs(tempdiff) < GRAB_TEMP_EXCHANGE_MIN_DIFF)
		return //Why are we still here..
	var/thermoconductivity = 1
	//We ALWAYS handle the bodytemp adjustment as a cooling action, not as a heating one. If this is too effective, it could be handled as heating instead. (cold temp adjustments allow more oomph by default)
	if(tempdiff > 0) //Pulled is hotter than us. Cool pulled, heat us by diff.
		//Averaging insulation of both targets, UNLESS either of the two has full thermal protection to the vector.
		var/self_thermoprotect = get_heat_protection(pulled_human.bodytemperature)
		var/pulled_thermoprotect = pulled_human.get_cold_protection(bodytemperature)
		if(self_thermoprotect >= 1 || pulled_thermoprotect >= 1)
			return //Full insulation.
		thermoconductivity -= ((self_thermoprotect + pulled_thermoprotect) / 2) //Non-full protection, average for simplicity and to preserve effectiveness.
		var/true_adjustment = min(thermoconductivity * tempdiff / BODYTEMP_COLD_DIVISOR, -BODYTEMP_COOLING_MAX)
		//Aaand equalize.
		adjust_bodytemperature(true_adjustment)
		pulled_human.adjust_bodytemperature(-true_adjustment)
		. = true_adjustment //This return value isn't used but someone might use it. Plus, traceability.
	else if(tempdiff < 0) //We are hotter than pulled. Cool us, transfer lost heat to them.
		tempdiff = -tempdiff //This was negative. I don't want that.
		//Averaging insulation of both targets again, this time the other way around because we are hotter.
		var/self_thermoprotect = get_cold_protection(pulled_human.bodytemperature)
		var/pulled_thermoprotect = pulled_human.get_heat_protection(bodytemperature)
		if(self_thermoprotect >= 1 || pulled_thermoprotect >= 1)
			return //Full insulation
		thermoconductivity -= ((self_thermoprotect + pulled_thermoprotect) / 2) //Bit copypasty I know but I really don't feel like making an omni-case instead.
		var/true_adjustment = min(thermoconductivity * tempdiff / BODYTEMP_COLD_DIVISOR, -BODYTEMP_COOLING_MAX)
		//And equalize, the other way around this time.
		adjust_bodytemperature(-true_adjustment)
		pulled_human.adjust_bodytemperature(true_adjustment)
		. = true_adjustment

#undef GRAB_TEMP_EXCHANGE_MIN_DIFF
