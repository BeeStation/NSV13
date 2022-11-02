/mob/living/carbon/human/ai_boarder/ert
	faction = list("neutral", "Nanotrasen", "nanotrasenprivate")
	taunts = list(
		"Code 401 in progress, requesting immediate assistance",
		"Stay down, scum",
		"You can't outrun the law",
		"For the corp!",
		"Anti-corporate activities will NOT be tolerated!"
	)
	outfit = /datum/outfit/ert/security
	knpc_traits = KNPC_IS_MARTIAL_ARTIST | KNPC_IS_DODGER | KNPC_IS_MERCIFUL | KNPC_IS_AREA_SPECIFIC

/mob/living/carbon/human/ai_boarder/ert/commander
	outfit = /datum/outfit/ert/commander

/mob/living/carbon/human/ai_boarder/ert/engineer
	outfit = /datum/outfit/ert/engineer

/mob/living/carbon/human/ai_boarder/ert/medic
	outfit = /datum/outfit/ert/medic

/mob/living/carbon/human/ai_boarder/ert/deathsquad
	//Kill everything that isn't blue
	faction = list("Nanotrasen", "nanotrasenprivate")
	outfit = /datum/outfit/death_commando

/mob/living/carbon/human/ai_boarder/assistant
	outfit = /datum/outfit/job/assistant
	faction = list("neutral", "Nanotrasen")

/mob/living/carbon/human/ai_boarder/ert/deathsquad/commander
	outfit = /datum/outfit/death_commando/officer

/mob/living/carbon/human/ai_boarder/ert/deathsquad/doomguy
	name = "The oncoming storm"
	outfit = /datum/outfit/death_commando/doomguy
