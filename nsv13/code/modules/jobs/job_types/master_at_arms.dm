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
	supervisors = "the Captain"
	selection_color = "#cc8899"
	minimal_player_age = 7
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_MUNITIONS

	outfit = /datum/outfit/job/master_at_arms

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_HEADS, ACCESS_EVA, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM, ACCESS_MUNITIONS, ACCESS_MAA, ACCESS_RC_ANNOUNCE) //NSV13 - Added ACCESS_MUNITIONS
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_HEADS, ACCESS_EVA, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM, ACCESS_MUNITIONS, ACCESS_MAA, ACCESS_RC_ANNOUNCE) // See /datum/job/warden/get_access()
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

	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset/headset_sec/alt/master_at_arms
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

/obj/item/encryptionkey/master_at_arms
	name = "master at arms radio encryption key"
	icon_state = "sec_cypherkey"
	channels = list(RADIO_CHANNEL_MUNITIONS = 1, RADIO_CHANNEL_SUPPLY = 1, RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_ATC = 1)
	independent = TRUE

/obj/item/radio/headset/headset_sec/alt/master_at_arms
	name = "master at arms radio headset"
	desc = "Use :w to access the department frequency. Use :u to access the supply frequency. Use :c to access the command frequency. Use :q to access the ATC frequency."
	icon_state = "sec_headset"
	keyslot = new /obj/item/encryptionkey/munitions_tech

/obj/effect/landmark/start/master_at_arms
	name = "Master At Arms"
	icon_state = "Master At Arms"