/*
Marine & all their unique stuff!
*/
/datum/job/assistant
	title = "Midshipman"
	flag = ASSISTANT
	display_rank = "MID"
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "your squad leader and all other military crew during peacetime"
	selection_color = "#c2d5ee"
	chat_color = "#c2d5ee"
	access = list()			//See /datum/job/Marine/get_access()
	minimal_access = list()	//See /datum/job/Marine/get_access()
	outfit = /datum/outfit/job/assistant //Nsv13 - Marine resprite
	antag_rep = 7
	paycheck = PAYCHECK_ASSISTANT // Get a job. Job reassignment changes your paycheck now. Get over it.
	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	departments = DEPARTMENT_SERVICE

/datum/reagent/colorful_reagent/powder
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/colorful_reagent/powder/on_mob_life(mob/living/carbon/M)
	if(M.mind && HAS_TRAIT(M.mind, TRAIT_MARINE_METABOLISM))
		M.heal_bodypart_damage(1,1, 0)
		. = 1
	..()

/datum/job/assistant/get_access()
	if(CONFIG_GET(flag/assistants_have_maint_access) || !CONFIG_GET(flag/jobs_have_minimal_access)) //Config has Marine maint access set
		. = ..()
		. |= list(ACCESS_MAINT_TUNNELS)
	else
		return ..()

/datum/outfit/job/assistant
	name = "Midshipman"
	jobtype = /datum/job/assistant
	uniform = /obj/item/clothing/under/ship/marine
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/beret/durathread

//Sprite courtesy of TGMC!
/obj/item/clothing/under/ship/marine
	name = "combat jumpsuit"
	desc = "A cheaply made uniform worn by general combat officers."
	icon_state = "marine"
	item_color = "marine"
	item_state = "bl_suit"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30)
	can_adjust = TRUE

/obj/item/clothing/under/ship/marine/engineer
	name = "squad engineer uniform"
	desc = "A cheaply made and uncomfortable uniform worn by squad engineers."
	icon_state = "marine_engineer"
	item_color = "marine_engineer"

/obj/item/clothing/under/ship/marine/medic
	name = "squad medic uniform"
	desc = "A cheaply made and uncomfortable uniform worn by squad medics. It has a conspicuous blue cross on the back. Shooting its bearer may constitute a war crime."
	icon_state = "marine_medic"
	item_color = "marine_medic"
