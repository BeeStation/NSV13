/datum/job/munitions_tech
	title = "Munitions Technician"
	flag = MUNITIONS_TECHNICIAN
	department_head = list("Master At Arms")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	supervisors = "the Master At Arms"
	selection_color = "#d692a3"
	exp_type_department = EXP_TYPE_MUNITIONS

	outfit = /datum/outfit/job/munitions_tech

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM, ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE) //temp
	minimal_access = list(ACCESS_MINERAL_STOREROOM, ACCESS_CONSTRUCTION, ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE) //temp
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_MUNITIONS_TECHNICIAN

/datum/outfit/job/munitions_tech
	name = "Munitions Technician"
	jobtype = /datum/job/munitions_tech

	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset/munitions/munitions_tech
	uniform = /obj/item/clothing/under/rank/munitions_tech
	suit = /obj/item/clothing/suit/ship/munitions_jacket
	head = /obj/item/clothing/head/helmet/decktech
	gloves = /obj/item/clothing/gloves/color/brown
	l_pocket = /obj/item/pda

	backpack = /obj/item/storage/backpack/munitions
	satchel = /obj/item/storage/backpack/satchel/munitions
	duffelbag = /obj/item/storage/backpack/duffelbag/munitions

/obj/effect/landmark/start/munitions_tech
	name = "Munitions Technician"
	icon_state = "Munitions Technician"
