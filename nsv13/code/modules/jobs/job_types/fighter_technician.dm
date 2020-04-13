/datum/job/fighter_tech
	title = "Fighter Technician"
	flag = FIGHTER_TECHNICIAN
	department_head = list("Master At Arms")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Master At Arms"
	selection_color = "#d692a3"
	exp_type_department = EXP_TYPE_MUNITIONS

	outfit = /datum/outfit/job/fighter_tech

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM, ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE, ACCESS_FIGHTER) //temp
	minimal_access = list(ACCESS_MINERAL_STOREROOM, ACCESS_CONSTRUCTION, ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE) //temp
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_FIGHTER_TECHNICIAN

/datum/outfit/job/fighter_tech
	name = "Fighter Technician"
	jobtype = /datum/job/fighter_tech

	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset/headset_sec/alt/munitions_tech
	uniform = /obj/item/clothing/under/rank/munitions_tech
	suit = /obj/item/clothing/suit/hazardvest
	head = /obj/item/clothing/head/soft/yellow
	gloves = /obj/item/clothing/gloves/color/brown
	l_pocket = /obj/item/pda

/obj/effect/landmark/start/fighter_tech
	name = "Fighter Technician"
	icon_state = "Fighter Technician"