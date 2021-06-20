/datum/job/air_traffic_controller
	title = "Air Traffic Controller"
	flag = AIR_TRAFFIC_CONTROLLER
	department_head = list("Master At Arms")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Master At Arms"
	selection_color = "#d692a3"
	chat_color = "#2681a5"
	exp_requirements = 30
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_MUNITIONS

	outfit = /datum/outfit/job/air_traffic_controller

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE, ACCESS_FIGHTER) //temp
	minimal_access = list(ACCESS_MUNITIONS) //temp
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MUN
	mind_traits = list(TRAIT_MUNITIONS_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_AIR_TRAFFIC_CONTROLLER
	display_rank = "SGT" //nsv13 - Displays the player's actual rank alongside their name, such as GSGT Sergei Koralev

/datum/outfit/job/air_traffic_controller
	name = "Air Traffic Controller"
	jobtype = /datum/job/air_traffic_controller

	ears = /obj/item/radio/headset/munitions/atc
	uniform = /obj/item/clothing/under/ship/officer
	suit = /obj/item/clothing/suit/hazardvest
	head = /obj/item/clothing/head/beret/ship/pilot
	gloves = /obj/item/clothing/gloves/color/brown
	shoes = /obj/item/clothing/shoes/jackboots
	r_pocket = /obj/item/flashlight/atc_wavy_sticks

	backpack = /obj/item/storage/backpack/munitions
	satchel = /obj/item/storage/backpack/satchel/munitions
	duffelbag = /obj/item/storage/backpack/duffelbag/munitions

/obj/effect/landmark/start/air_traffic_controller
	name = "Air Traffic Controller"
	icon_state = "Air Traffic Controller"
