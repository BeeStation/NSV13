/datum/job/master_at_arms
	title = "Master At Arms"
	flag = MASTER_AT_ARMS
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("Captain")
	department_flag = ENGSEC
	head_announce = list("Munitions")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#cc8899"
	minimal_player_age = 7
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_MUNITIONS

	outfit = /datum/outfit/job/master_at_arms

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_HEADS, ACCESS_EVA, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM, ACCESS_MUNITIONS) //NSV13 - Added ACCESS_MUNITIONS
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_HEADS, ACCESS_EVA, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM, ACCESS_MUNITIONS) // See /datum/job/warden/get_access()
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC

	display_order = JOB_DISPLAY_ORDER_MASTER_AT_ARMS
	display_rank = "WO" //nsv13 - Displays the player's actual rank alongside their name, such as GSGT Sergei Koralev

/datum/job/masteratarms/get_access()
	var/list/L = list()
	L = ..() | check_config_for_sec_maint()
	return L

/datum/outfit/job/master_at_arms
	name = "Master At Arms"
	jobtype = /datum/job/master_at_arms

	ears = /obj/item/radio/headset/headset_sec/alt/pilot
	uniform = /obj/item/clothing/under/syndicate/tacticool
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/hazardvest
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/soft
	glasses = /obj/item/clothing/glasses/sunglasses

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/security

/obj/machinery/telecomms/server/presets/munitions //TELECOMMS HELL
	id = "Munitions Server"
	freq_listening = list(FREQ_MUNITIONS)
	autolinkers = list("munitions")
