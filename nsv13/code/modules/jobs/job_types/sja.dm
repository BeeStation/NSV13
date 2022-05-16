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
	minimal_player_age = 2
	exp_requirements = 60
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/staffjudgeadvocate

	access = list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_SEC_RECORDS, ACCESS_FORENSICS_LOCKERS, ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_MORGUE, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_HYDROPONICS, ACCESS_LAWYER, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING)
	minimal_access = list(ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_MORGUE, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_HYDROPONICS, ACCESS_LAWYER, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING)
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
	uniform = /obj/item/clothing/under/ship/officer
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/beret/durathread
	l_hand = /obj/item/book/manual/wiki/sop/catalogue
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/clothing/accessory/lawyers_badge

	chameleon_extras = /obj/item/stamp/law

/datum/outfit/job/staffjudgeadvocate/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
