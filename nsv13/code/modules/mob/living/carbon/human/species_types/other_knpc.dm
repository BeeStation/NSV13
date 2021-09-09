/mob/living/carbon/human/ai_boarder/zombie
	faction = list("zombie")
	outfit = /datum/outfit/assistant_ship
	knpc_traits = KNPC_IS_DOOR_BASHER
	difficulty_override = TRUE
	move_delay = 10
	action_delay = 10
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
