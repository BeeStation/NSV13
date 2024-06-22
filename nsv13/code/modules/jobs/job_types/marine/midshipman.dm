/*
Marine & all their unique stuff!
*/
/datum/job/assistant
	title = JOB_NAME_ASSISTANT
	flag = ASSISTANT
	display_rank = "MID"
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "your squad leader and all other military crew during peacetime"
	selection_color = "#c2d5ee"
	chat_color = "#c2d5ee"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	outfit = /datum/outfit/job/assistant //Nsv13 - Marine resprite
	antag_rep = 7
	paycheck = PAYCHECK_ASSISTANT // Get a job. Job reassignment changes your paycheck now. Get over it.
	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	departments = DEPARTMENT_BITFLAG_SERVICE
	rpg_title = "Lout"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)

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
	name = JOB_NAME_ASSISTANT
	jobtype = /datum/job/assistant
	uniform = /obj/item/clothing/under/ship/marine
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/beret/durathread
	id = /obj/item/card/id/job/assistant

//Sprite courtesy of TGMC!
/obj/item/clothing/under/ship/marine
	name = "combat jumpsuit"
	desc = "A cheaply made uniform worn by general combat officers."
	icon_state = "marine"
	item_state = "bl_suit"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30)
	can_adjust = TRUE

/obj/item/clothing/under/ship/marine/engineer
	name = "squad engineer uniform"
	desc = "A cheaply made and uncomfortable uniform worn by squad engineers."
	icon_state = "marine_engineer"

/obj/item/clothing/under/ship/marine/medic
	name = "squad medic uniform"
	desc = "A cheaply made and uncomfortable uniform worn by squad medics. It has a conspicuous blue cross on the back. Shooting its bearer may constitute a war crime."
	icon_state = "marine_medic"

/datum/job/assistant/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()
	// Assign department
	var/department = M?.client?.prefs?.active_character?.preferred_security_department
	if(department == "None")
		to_chat(M, "<b>You have not been assigned to any department. Help in any way you can!</b>")
		return
	else if(!(department in GLOB.available_depts))
		department = pick(GLOB.available_depts)

	var/ears = null
	var/accessory = null
	var/list/dep_access = null
	switch(department)
		if(SEC_DEPT_SUPPLY)
			ears = /obj/item/radio/headset/headset_cargo
			dep_access = list(ACCESS_MAILSORTING, ACCESS_CARGO)
			accessory = /obj/item/clothing/accessory/armband/cargo
		if(SEC_DEPT_ENGINEERING)
			ears = /obj/item/radio/headset/headset_eng
			dep_access = list(ACCESS_CONSTRUCTION, ACCESS_ENGINE, ACCESS_AUX_BASE)
			accessory = /obj/item/clothing/accessory/armband/engine
		if(SEC_DEPT_MEDICAL)
			ears = /obj/item/radio/headset/headset_med
			dep_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_CLONING)
			accessory =  /obj/item/clothing/accessory/armband/medblue
		if(SEC_DEPT_SCIENCE)
			ears = /obj/item/radio/headset/headset_sci
			dep_access = list(ACCESS_RESEARCH)
			accessory = /obj/item/clothing/accessory/armband/science
		if(SEC_DEPT_MUNITIONS)
			ears = /obj/item/radio/headset/munitions/munitions_tech
			dep_access = list(ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE)
			accessory = /obj/item/clothing/accessory/armband/munitions

	if(accessory)
		var/obj/item/clothing/under/U = H.w_uniform
		U.attach_accessory(new accessory)
	if(ears)
		if(H.ears)
			qdel(H.ears)
		H.equip_to_slot_or_del(new ears(H), ITEM_SLOT_EARS)

	var/obj/item/card/id/W = H.wear_id
	W.access |= dep_access

	to_chat(M, "<b>You have been assigned to [department]!</b>")
