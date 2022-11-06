/datum/job/air_traffic_controller
	title = JOB_NAME_AIRTRAFFICCONTROLLER
	flag = AIR_TRAFFIC_CONTROLLER
	department_head = list(JOB_NAME_MASTERATARMS)
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Master At Arms"
	selection_color = "#ffd1a2"
	chat_color = "#2681a5"
	exp_requirements = 600
	exp_type = EXP_TYPE_MUNITIONS
	exp_type_department = EXP_TYPE_MUNITIONS

	outfit = /datum/outfit/job/air_traffic_controller

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE, ACCESS_HANGAR)
	minimal_access = list(ACCESS_MUNITIONS, ACCESS_HANGAR)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MUN
	mind_traits = list(TRAIT_MUNITIONS_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_AIR_TRAFFIC_CONTROLLER
	display_rank = "SGT" //nsv13 - Displays the player's actual rank alongside their name, such as GSGT Sergei Koralev
	departments = DEPARTMENT_BITFLAG_MUNITIONS
	rpg_title = "Signalman"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)

/datum/outfit/job/air_traffic_controller
	name = JOB_NAME_AIRTRAFFICCONTROLLER
	jobtype = /datum/job/air_traffic_controller

	ears = /obj/item/radio/headset/munitions/atc
	uniform = /obj/item/clothing/under/ship/officer
	suit = /obj/item/clothing/suit/hazardvest
	head = /obj/item/clothing/head/beret/ship/pilot
	gloves = /obj/item/clothing/gloves/color/brown
	shoes = /obj/item/clothing/shoes/jackboots
	id = /obj/item/card/id/job/air_traffic_controller
	r_pocket = /obj/item/flashlight/atc_wavy_sticks

	backpack = /obj/item/storage/backpack/munitions
	satchel = /obj/item/storage/backpack/satchel/munitions
	duffelbag = /obj/item/storage/backpack/duffelbag/munitions

/obj/effect/landmark/start/air_traffic_controller
	name = JOB_NAME_AIRTRAFFICCONTROLLER
	icon_state = "Air Traffic Controller"
