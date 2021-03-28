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
	message_admins( "on_mob_life" )
	message_admins( "[src]" )
	if ( !GLOB.crew_transfer_risa ) {
		priority_announce("[station_name()] has successfully returned to Outpost 45 for resupply and crew transfer, excellent work crew.", "Naval Command")
		GLOB.crew_transfer_risa = TRUE
		SSticker.mode.check_finished()
	}
	..()
