/obj/item/reagent_containers/pill/dopamine
	name = "dopamine pill"
	desc = "Used to improve mood and mental state."
	icon_state = "pill17"
	list_reagents = list(/datum/reagent/medicine/dopamine = 50)
	rename_with_volume = TRUE

/datum/reagent/medicine/dopamine
	name = "Dopamine"
	description = "Efficiently restores mood and mental state."
	color = "#DCDCFF"

/datum/reagent/medicine/dopamine/on_mob_life(mob/living/carbon/C)
	if ( !GLOB.crew_transfer_risa ) {
		priority_announce("[station_name()] has successfully returned to Outpost 45 for resupply and crew transfer, excellent work crew.", "Naval Command")
		GLOB.crew_transfer_risa = TRUE
		SSticker.mode.check_finished()
	}
	..()

/datum/chemical_reaction/dopamine
	name = "dopamine"
	id = /datum/reagent/medicine/dopamine
	results = list(/datum/reagent/medicine/dopamine = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/silicon = 1, /datum/reagent/water = 1)
	mix_message = "The solution slightly bubbles, becoming thicker."
