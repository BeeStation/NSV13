//Syndie boarders
/mob/living/carbon/human/ai_boarder/syndicate //PARENT - DO NOT USE
	faction = list("Syndicate")
	taunts = list(
		"ŚMIERĆ NANOTRASENOWI!!",
		"ZA ABASSI!",
		"Żryj to!",
		"Słabeusze!",
		"Wracasz do domu w trumnie, dzieciaku!",
		"Walczę z przeciwnikiem!"
	)
	call_lines = list(
		"Przeciwnik dostrzeżony! Potrzebne wsparcie w",
		"OPFOR spostrzeżony w",
		"Wzywam wsparcie do"
	)
	response_lines = list(
		"Przyjąłem, w drodze.",
		"Jestem w drodze!",
		"Głośno i wyraźnie, nadciągam!",
		"Ura!"
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
