/datum/ai_controller/monkey/angry/slow
	movement_delay = 1 SECONDS

/mob/living/carbon/human/species/felinid/npc
	ai_controller = /datum/ai_controller/monkey/angry/slow

/mob/living/carbon/human/species/felinid/npc/Initialize(mapload)
	. = ..()
	randomize_human(src)
	equipOutfit(/datum/outfit/job/assistant)
	dna.species.start_wagging_tail(src)

/mob/living/carbon/human/ai_boarder/assistant/felinid
	taunts = list(
		"Tee hee!~ UwU",
		"Nya. I'm youw boawderw. Pwepawe to be pawned!",
		"Hiss!"
	)
	call_lines = list(
		"I nyeed backuwp!",
		"Fwends, come hewe!"
	)
	response_lines = list(
		"Nya~? What's ovew hewe?",
		"Be wight thewe! =^.^="
	)

	faction = list("Syndicate","Pirate")

/mob/living/carbon/human/ai_boarder/assistant/felinid/Initialize(mapload)
	. = ..()
	set_species(/datum/species/human/felinid)
	randomize_human(src)
	dna.species.start_wagging_tail(src)
