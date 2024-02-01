/mob/living/carbon/monkey
	speech_sound = "monkey"

/mob/living/carbon/monkey/IsAdvancedToolUser() // AQ EDIT
	if(HAS_TRAIT(src, TRAIT_DISCOORDINATED)) //Obtainable with Brain trauma
		return FALSE
	return TRUE //Something about an infinite amount of monkeys on typewriters writing Shakespeare...

/datum/species/teratoma
	speech_sound = "monkey"
