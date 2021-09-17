/mob/living/carbon/human/ai_boarder/zombie
	faction = list("zombie")
	outfit = list (
		/datum/outfit/job/assistant,
		/datum/outfit/job/cargo_tech,
		/datum/outfit/job/cook,
		/datum/outfit/job/scientist,
		/datum/outfit/job/miner,
		/datum/outfit/job/atmos,
		/datum/outfit/job/gimmick/barber,
		/datum/outfit/job/janitor,
		/datum/outfit/job/doctor,
		/datum/outfit/job/security,
		/datum/outfit/job/bridge,
		/datum/outfit/job/munitions_tech
	)
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
