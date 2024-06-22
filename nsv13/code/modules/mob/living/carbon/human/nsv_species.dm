//Modular File for NSV species stuff

///The species-level version of bodytemperature stabilization.
/datum/species/proc/natural_bodytemperature_stabilization(mob/living/carbon/human/human_holder)
	if(HAS_TRAIT(human_holder, TRAIT_COLDBLOODED))
		ectotherm_thermogenesis(human_holder) //Man I love the word "thermogenesis". Such a magic term for what is essentially just "makes heat".
		return 0
	var/body_temperature_difference = BODYTEMP_NORMAL - human_holder.bodytemperature
	switch(human_holder.bodytemperature)
		if(-INFINITY to BODYTEMP_COLD_DAMAGE_LIMIT) //Cold damage limit is 50 below the default, the temperature where you start to feel effects.
			return max((body_temperature_difference * human_holder.metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)
		if(BODYTEMP_COLD_DAMAGE_LIMIT to BODYTEMP_NORMAL)
			return max(body_temperature_difference * human_holder.metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR, min(body_temperature_difference, BODYTEMP_AUTORECOVERY_MINIMUM/4))
		if(BODYTEMP_NORMAL to BODYTEMP_HEAT_DAMAGE_LIMIT) // Heat damage limit is 50 above the default, the temperature where you start to feel effects.
			return min(body_temperature_difference * human_holder.metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR, max(body_temperature_difference, -BODYTEMP_AUTORECOVERY_MINIMUM/4))
		if(BODYTEMP_HEAT_DAMAGE_LIMIT to INFINITY)
			return min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM)	//We're dealing with negative numbers

/**
 * A proc for coldblooded species' means of limited thermal control. Also known as "vibrating your muscles".
 * * Returns: Amount of kelvin adjustment performed, or ECTOTHERM_NO_THERMOGENESIS_NEEDED (-1) if we are fine.
**/
/datum/species/proc/ectotherm_thermogenesis(mob/living/carbon/human/human_holder, use_temp_diff_range_check = TRUE)
	var/temperature_differential = BODYTEMP_NORMAL - human_holder.bodytemperature
	if(temperature_differential <= 0 || (use_temp_diff_range_check && temperature_differential < ECTOTHERM_THERMOGENESIS_MIN_COLDNESS))
		return ECTOTHERM_NO_THERMOGENESIS_NEEDED
	var/adjustment = 0
	if(temperature_differential < ECTOTHERM_THERMOGENESIS_CRIT_COLDNESS)
		if(human_holder.nutrition < ECTOTHERM_THERMOGENESIS_NUTRITION_USE * human_holder.metabolism_efficiency)
			return 0
		adjustment = round(CLAMP(temperature_differential / ECTOTHERM_RECOVERY_DIVISOR * human_holder.metabolism_efficiency, ECTOTHERM_MIN_RECOVERY * human_holder.metabolism_efficiency, ECTOTHERM_MAX_RECOVERY * human_holder.metabolism_efficiency), 0.1)
		human_holder.adjust_nutrition(-ECTOTHERM_THERMOGENESIS_NUTRITION_USE * human_holder.metabolism_efficiency)
	else
		if(human_holder.nutrition < ECTOTHERM_MAJOR_THERMOGENESIS_NUTRITION_USE * human_holder.metabolism_efficiency)
			return 0
		adjustment = round(CLAMP(temperature_differential / ECTOTHERM_RECOVERY_DIVISOR * human_holder.metabolism_efficiency, ECTOTHERM_MIN_RECOVERY * human_holder.metabolism_efficiency, ECTOTHERM_MAX_RECOVERY * human_holder.metabolism_efficiency * ECTOTHERM_CRIT_COLD_MAX_RECOVERY_MOD), 0.1)
		human_holder.adjust_nutrition(-ECTOTHERM_MAJOR_THERMOGENESIS_NUTRITION_USE * human_holder.metabolism_efficiency)
	human_holder.adjust_bodytemperature(adjustment)
	return adjustment
