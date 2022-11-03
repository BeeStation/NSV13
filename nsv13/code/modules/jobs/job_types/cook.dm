/datum/job/cook/datum/job/after_spawn(mob/living/carbon/human/H, visualsOnly = FALSE, announce = TRUE, latejoin = FALSE, datum/outfit/outfit_override = null, client/preference_source)
	. = ..()
	H.mind?.teach_crafting_recipe(/datum/crafting_recipe/hungrypowder)
