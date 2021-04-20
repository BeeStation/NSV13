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
	chat_color = "#2681a5"
	exp_requirements = 60
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_MUNITIONS

	outfit = /datum/outfit/job/fighter_pilot

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE, ACCESS_FIGHTER) //temp
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MUNITIONS, ACCESS_FIGHTER) //temp
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MUN
	mind_traits = list(TRAIT_MUNITIONS_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_FIGHTER_PILOT

/datum/outfit/job/fighter_pilot
	name = "Fighter Pilot"
	jobtype = /datum/job/fighter_pilot

	ears = /obj/item/radio/headset/munitions/pilot
	uniform = /obj/item/clothing/under/ship/pilot
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/beret/ship/pilot

	backpack = /obj/item/storage/backpack/munitions
	satchel = /obj/item/storage/backpack/satchel/munitions
	duffelbag = /obj/item/storage/backpack/duffelbag/munitions

/datum/outfit/job/fighter_pilot/flight_ready
	name = "Fighter Pilot - Flight Ready"
	jobtype = /datum/job/fighter_pilot
	suit = /obj/item/clothing/suit/space/hardsuit/pilot //placeholder
	mask = /obj/item/clothing/mask/breath //placeholder
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double

/obj/effect/landmark/start/fighter_pilot
	name = "Fighter Pilot"
	icon_state = "Fighter Pilot"

/datum/job/flight_leader //chief fighter pilot - We can't have nice things
	title = "Flight Leader"
	flag = FLIGHT_LEADER
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

	outfit = /datum/outfit/job/flight_leader

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE, ACCESS_FIGHTER, ACCESS_FL) //temp
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MUNITIONS, ACCESS_FIGHTER, ACCESS_FL) //temp
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MUN
	mind_traits = list(TRAIT_MUNITIONS_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_FLIGHT_LEADER

/datum/outfit/job/flight_leader
	name = "Flight Leader"
	jobtype = /datum/job/flight_leader

	ears = /obj/item/radio/headset/munitions/pilot
	uniform = /obj/item/clothing/under/ship/pilot
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/beret/ship/flight_leader
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	suit = /obj/item/clothing/suit/jacket //Bomber jacket

	backpack = /obj/item/storage/backpack/munitions
	satchel = /obj/item/storage/backpack/satchel/munitions
	duffelbag = /obj/item/storage/backpack/duffelbag/munitions

/datum/outfit/job/fighter_pilot/flight_ready
	name = "Fighter Pilot - Flight Ready"
	jobtype = /datum/job/fighter_pilot
	suit = /obj/item/clothing/suit/space/hardsuit/pilot //placeholder
	mask = /obj/item/clothing/mask/breath //placeholder
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double

/obj/effect/landmark/start/flight_leader
	name = "Flight Leader"
	icon_state = "Flight Leader"
