
/mob/living/carbon/set_species(datum/species/mrace, icon_update = TRUE, pref_load = TRUE)
	. = ..()
	if(mrace && has_dna())
		if(ishuman(src))
			speech_sound = ""
			if(dna.species.speech_sound)
				speech_sound = dna.species.speech_sound
				if(dna.species.gendered_speech)
					speech_sound += gender

/mob/living/carbon/updateappearance(icon_update=1, mutcolor_update=0, mutations_overlay_update=0)
	..()
	speech_sound = ""
	if(dna.species.speech_sound)
		speech_sound = dna.species.speech_sound
		if(dna.species.gendered_speech)
			speech_sound += gender
