/datum/species/dullahan
	speech_sound = "human"
	gendered_speech = TRUE

/datum/species/dullahan/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	if(myhead)
		if(isobj(myhead.loc))
			var/obj/O = myhead.loc
			O.speech_sound = speech_sound
			if(gendered_speech)
				O.speech_sound += H.gender
