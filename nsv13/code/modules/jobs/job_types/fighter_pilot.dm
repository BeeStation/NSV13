/datum/job/fighter_pilot
	title = "Fighter Pilot"
	flag = FIGHTER_PILOT
	department_head = list("Master At Arms")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	supervisors = "the Flight Leader"
	selection_color = "#d692a3"
	exp_requirements = 60
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_MUNITIONS

	outfit = /datum/outfit/job/fighter_pilot

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MUNITIONS) //temp
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MUNITIONS) //temp
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_FIGHTER_PILOT
//add support for callsigns here

/datum/outfit/job/fighter_pilot
	name = "Fighter Pilot"
	jobtype = /datum/job/fighter_pilot

	ears = /obj/item/radio/headset/headset_sec/alt/pilot
	uniform = /obj/item/clothing/under/ship/pilot
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/beret/ship/pilot

/datum/outfit/job/fighter_pilot/flight_ready
	name = "Fighter Pilot - Flight Ready"
	jobtype = /datum/job/fighter_pilot
	suit = /obj/item/clothing/suit/space/hardsuit/pilot //placeholder
	mask = /obj/item/clothing/mask/breath //placeholder
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double

/obj/effect/landmark/start/fighter_pilot
	name = "Fighter Pilot"
	icon_state = "Fighter Pilot"

/datum/job/cag //"Commander Air Group" AKA chief fighter pilot - We can't have nice things
	title = "Flight Leader"
	flag = CAG
	department_head = list("Master At Arms")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Master At Arms"
	selection_color = "#d692a3"
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_MUNITIONS

	outfit = /datum/outfit/job/cag

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MUNITIONS) //temp
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MUNITIONS) //temp
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_CAG

/datum/outfit/job/cag
	name = "Flight Leader"
	jobtype = /datum/job/cag

	ears = /obj/item/radio/headset/headset_sec/alt/pilot
	uniform = /obj/item/clothing/under/ship/pilot
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/beret/ship/cag
	glasses = /obj/item/clothing/glasses/sunglasses
	suit = /obj/item/clothing/suit/jacket //Bomber jacket

/datum/outfit/job/fighter_pilot/flight_ready
	name = "Fighter Pilot - Flight Ready"
	jobtype = /datum/job/fighter_pilot
	suit = /obj/item/clothing/suit/space/hardsuit/pilot //placeholder
	mask = /obj/item/clothing/mask/breath //placeholder
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double

/obj/effect/landmark/start/cag
	name = "Flight Leader"
	icon_state = "CAG"