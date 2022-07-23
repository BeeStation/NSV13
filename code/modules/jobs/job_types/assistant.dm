/*
Assistant
*/
/datum/job/assistant
	title = "Midshipman" //Nsv13 - Crayon eaters
	flag = ASSISTANT
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	chat_color = "#bdbdbd"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	outfit = /datum/outfit/job/assistant_ship //Nsv13 - Assistant resprite
	antag_rep = 7
	paycheck = PAYCHECK_ASSISTANT // Get a job. Job reassignment changes your paycheck now. Get over it.
	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	departments = DEPARTMENT_SERVICE

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)
/datum/job/assistant/get_access()
	if(CONFIG_GET(flag/assistants_have_maint_access) || !CONFIG_GET(flag/jobs_have_minimal_access)) //Config has assistant maint access set
		. = ..()
		. |= list(ACCESS_MAINT_TUNNELS)
	else
		return ..()

/datum/outfit/job/assistant
	name = "Midshipman" //Nsv13 - Crayon eaters
	jobtype = /datum/job/assistant
/* NSV13 - no skirts
/datum/outfit/job/assistant/pre_equip(mob/living/carbon/human/H)
	..()
	if (CONFIG_GET(flag/grey_assistants))
		if(H.jumpsuit_style == PREF_SUIT)
			uniform = /obj/item/clothing/under/color/grey
		else
			uniform = /obj/item/clothing/under/skirt/color/grey
	else
		if(H.jumpsuit_style == PREF_SUIT)
			uniform = /obj/item/clothing/under/color/random
		else
			uniform = /obj/item/clothing/under/skirt/color/random
*/

/datum/job/assistant/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()
	// Assign department
	var/department
	if(M && M.client && M.client.prefs)
		department = M.client.prefs.prefered_security_department
		if(!LAZYLEN(GLOB.available_depts) || department == "None")
			return
		else if(department in GLOB.available_depts)
			LAZYREMOVE(GLOB.available_depts, department)
		else
			department = pick_n_take(GLOB.available_depts)

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
		H.equip_to_slot_or_del(new ears(H),ITEM_SLOT_EARS)

	var/obj/item/card/id/W = H.wear_id
	W.access |= dep_access


	if(department)
		to_chat(M, "<b>You have been assigned to [department]!</b>")

	else
		to_chat(M, "<b>You have not been assigned to any department. Help in any way you can!</b>") //NSV13 end

