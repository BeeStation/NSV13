/datum/job/deck_tech
	title = JOB_NAME_DECKTECHNICIAN
	flag = DECK_TECHNICIAN
	department_head = list(JOB_NAME_MASTERATARMS)
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Master At Arms"
	selection_color = "#ffd1a2"
	chat_color = "#2681a5"
	exp_type_department = EXP_TYPE_MUNITIONS

	outfit = /datum/outfit/job/deck_tech

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM, ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE, ACCESS_HANGAR) //temp
	minimal_access = list(ACCESS_MINERAL_STOREROOM, ACCESS_CONSTRUCTION, ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE, ACCESS_HANGAR) //temp
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MUN
	mind_traits = list(TRAIT_MUNITIONS_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_DECK_TECHNICIAN
	departments = DEPARTMENT_MUNITIONS

/datum/outfit/job/deck_tech
	name = JOB_NAME_DECKTECHNICIAN
	jobtype = /datum/job/deck_tech

	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset/munitions/munitions_tech
	uniform = /obj/item/clothing/under/ship/decktech
	suit = /obj/item/clothing/suit/hazardvest
	head = /obj/item/clothing/head/helmet/decktech
	gloves = /obj/item/clothing/gloves/color/brown
	id = /obj/item/card/id/deck_technician
	l_pocket = /obj/item/modular_computer/tablet/pda/munition

	backpack = /obj/item/storage/backpack/munitions
	satchel = /obj/item/storage/backpack/satchel/munitions
	duffelbag = /obj/item/storage/backpack/duffelbag/munitions

/obj/effect/landmark/start/deck_tech
	name = JOB_NAME_DECKTECHNICIAN
	icon_state = "Deck Technician"
