//Syndie boarders
/mob/living/carbon/human/ai_boarder/syndicate //PARENT - DO NOT USE
	faction = list("Syndicate")
	taunts = list(
		"DEATH TO NANOTRASEN!!",
		"FOR ABASSI!",
		"Eat this!",
		"Weakling!",
		"You're going home in a coffin kid!",
		"Engaging the enemy!"
	)
	call_lines = list(
		"Enemy spotted! Need backup in",
		"OPFOR sighted in",
		"Requesting Support to"
	)
	response_lines = list(
		"Copy that, en route.",
		"On my way!",
		"Loud and clear, coming!",
		"Ooh rah!"
	)
	outfit = /datum/outfit/syndicate

/mob/living/carbon/human/ai_boarder/syndicate/pistol
	outfit = /datum/outfit/syndicate/knpc_pistol
	knpc_traits = KNPC_IS_MARTIAL_ARTIST | KNPC_IS_DODGER | KNPC_IS_MERCIFUL | KNPC_IS_AREA_SPECIFIC

/mob/living/carbon/human/ai_boarder/syndicate/smg
	outfit = /datum/outfit/syndicate/knpc_smg
	knpc_traits = KNPC_IS_MARTIAL_ARTIST | KNPC_IS_DODGER | KNPC_IS_MERCIFUL | KNPC_IS_AREA_SPECIFIC

/mob/living/carbon/human/ai_boarder/syndicate/shotgun
	outfit = /datum/outfit/syndicate/knpc_shotgun
	knpc_traits = KNPC_IS_MARTIAL_ARTIST | KNPC_IS_DODGER | KNPC_IS_MERCIFUL | KNPC_IS_AREA_SPECIFIC
