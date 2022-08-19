/datum/job/staffjudgeadvocate
	title = "Staff Judge Advocate"
	flag = LAWYER
	department_head = list("Executive Officer")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1		//defaults to one, don't need more normally
	spawn_positions = 1
	supervisors = "the Executive Officer"
	selection_color = "#dddddd"
	chat_color = "#C07D7D"
	minimal_player_age = 14
	exp_requirements = 900
	exp_type = EXP_TYPE_SECURITY
	exp_type_department = EXP_TYPE_SECURITY

	outfit = /datum/outfit/job/staffjudgeadvocate
	access = list(ACCESS_HEADS, ACCESS_BRIG, ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS, ACCESS_FORENSICS_LOCKERS)
	minimal_access = list(ACCESS_HEADS, ACCESS_BRIG, ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS, ACCESS_FORENSICS_LOCKERS)
	
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CIV
	mind_traits = list()

	display_order = JOB_DISPLAY_ORDER_LAWYER
	departments = DEPARTMENT_SERVICE

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman //they dont have one.
	)

/datum/outfit/job/staffjudgeadvocate
	name = "Staff Judge Advocate"
	jobtype = /datum/job/staffjudgeadvocate

	belt = /obj/item/pda/lawyer
	ears = /obj/item/radio/headset/headset_srvsec
	uniform = /obj/item/clothing/under/suit/black
	neck = /obj/item/clothing/neck/tie/black
	accessory = /obj/item/clothing/accessory/lawyers_badge
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/book/manual/wiki/sop/catalogue
	l_pocket = /obj/item/laser_pointer

	chameleon_extras = /obj/item/stamp/law

/datum/outfit/job/staffjudgeadvocate/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
