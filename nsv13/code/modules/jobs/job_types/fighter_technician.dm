/datum/job/deck_tech
	title = "Deck Technician"
	flag = DECK_TECHNICIAN
	department_head = list("Master At Arms")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Master At Arms"
	selection_color = "#d692a3"
	chat_color = "#2681a5"
	exp_type_department = EXP_TYPE_MUNITIONS

	outfit = /datum/outfit/job/deck_tech

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM, ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE, ACCESS_FIGHTER) //temp
	minimal_access = list(ACCESS_MINERAL_STOREROOM, ACCESS_CONSTRUCTION, ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE) //temp
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MUN
	mind_traits = list(TRAIT_MUNITIONS_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_DECK_TECHNICIAN

/datum/outfit/job/deck_tech
	name = "Deck Technician"
	jobtype = /datum/job/deck_tech

	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset/munitions/munitions_tech
	uniform = /obj/item/clothing/under/ship/decktech
	suit = /obj/item/clothing/suit/hazardvest
	head = /obj/item/clothing/head/helmet/decktech
	gloves = /obj/item/clothing/gloves/color/brown
	l_pocket = /obj/item/pda

	backpack = /obj/item/storage/backpack/munitions
	satchel = /obj/item/storage/backpack/satchel/munitions
	duffelbag = /obj/item/storage/backpack/duffelbag/munitions

/obj/effect/landmark/start/deck_tech
	name = "Deck Technician"
	icon_state = "Deck Technician"
