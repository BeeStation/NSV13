/datum/job/munitions_tech
	title = "Munitions Technician"
	flag = MUNITIONSTECH
	department_head = list("Master At Arms")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Master At Arms"
	selection_color = "#ffeeee"

	outfit = /datum/outfit/job/munitions_tech

	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_MECH_SECURITY, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM) //temp
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_MECH_SECURITY, ACCESS_MINERAL_STOREROOM) //temp
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_MUNITIONS_TECHNICIAN
	display_rank = "LCPL" //nsv13 - Displays the player's actual rank alongside their name, such as GSGT Sergei Koralev

/datum/outfit/job/munitions_tech
	name = "Munitions Technician"
	jobtype = /datum/job/munitions_tech

	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset_sec/alt //placeholder
	uniform = /obj/item/clothing/under/rank/cargotech //placeholder
	suit = /obj/item/clothing/suit/hazardvest
	gloves = /obj/item/clothing/gloves/color/brown //placeholder
	l_hand = /obj/item/pda/cargo //placeholder
