/*
Marine & all their unique stuff!
*/
/datum/job/marine
	title = "Marine"
	flag = ASSISTANT
	display_rank = "PFC"
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	chat_color = "#bdbdbd"
	access = list()			//See /datum/job/Marine/get_access()
	minimal_access = list()	//See /datum/job/Marine/get_access()
	outfit = /datum/outfit/job/marine //Nsv13 - Marine resprite
	antag_rep = 7
	paycheck = PAYCHECK_ASSISTANT // Get a job. Job reassignment changes your paycheck now. Get over it.
	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	mind_traits = list(TRAIT_MARINE_METABOLISM)

/datum/reagent/colorful_reagent/powder
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/colorful_reagent/powder/on_mob_life(mob/living/carbon/M)
	if(M.mind && HAS_TRAIT(M.mind, TRAIT_MARINE_METABOLISM))
		M.heal_bodypart_damage(1,1, 0)
		. = 1
	..()

/datum/job/marine/get_access()
	if(CONFIG_GET(flag/assistants_have_maint_access) || !CONFIG_GET(flag/jobs_have_minimal_access)) //Config has Marine maint access set
		. = ..()
		. |= list(ACCESS_MAINT_TUNNELS)
	else
		return ..()

/datum/outfit/job/marine
	name = "Marine"
	jobtype = /datum/job/marine
	uniform = /obj/item/clothing/under/ship/marine
	shoes = /obj/item/clothing/shoes/jackboots

//Sprite courtesy of TGMC!
/obj/item/clothing/under/ship/marine
	name = "marine uniform"
	desc = "A cheaply made uniform worn by the ship's PMCs."
	icon_state = "marine"
	item_color = "marine"
	item_state = "bl_suit"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30)
	can_adjust = TRUE

/obj/item/clothing/under/ship/marine/engineer
	name = "marine engineer uniform"
	desc = "A cheaply made and uncomfortable uniform worn by squad engineers."
	icon_state = "marine_engineer"
	item_color = "marine_engineer"

/obj/item/clothing/under/ship/marine/medic
	name = "marine medic uniform"
	desc = "A cheaply made and uncomfortable uniform worn by squad medics. It has a conspicuous blue cross on the back."
	icon_state = "marine_medic"
	item_color = "marine_medic"
