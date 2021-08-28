/mob/living/carbon/human/ai_boarder/zombie
	faction = list("zombie")
	grade = "c_z"
	outfit = /datum/outfit/assistant_ship
	can_kite = FALSE
	is_merciful = FALSE
	is_area_specific = FALSE
	taunts = list(
		"Braaaaains...",
		"Hnngg...",
		"Urghhhhh..."
	)
	call_lines = list(
		"Braaaaains...",
		"Hnngg...",
		"Urghhhhh..."
	)
	response_lines = list(
		"Braaaaains...",
		"Hnngg...",
		"Urghhhhh..."
	)

/mob/living/carbon/human/ai_boarder/zombie/Initialize()
	. = ..()
	set_species(/datum/species/zombie/infectious)
