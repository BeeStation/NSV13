/datum/job/master_at_arms
	title = JOB_NAME_MASTERATARMS
	flag = MASTER_AT_ARMS
	auto_deadmin_role_flags = PREFTOGGLE_DEADMIN_POSITION_HEAD
	department_head = list(JOB_NAME_CAPTAIN)
	department_flag = ENGSEC
	head_announce = list("Munitions")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Captain"
	selection_color = "#ffbc79"
	chat_color = "#ff7f00"
	minimal_player_age = 7
	exp_requirements = 1200
	exp_type = EXP_TYPE_MUNITIONS
	exp_type_department = EXP_TYPE_MUNITIONS

	outfit = /datum/outfit/job/master_at_arms

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_HEADS, ACCESS_EVA, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM, ACCESS_MUNITIONS, ACCESS_MAA, ACCESS_MUNITIONS_STORAGE, ACCESS_COMBAT_PILOT, ACCESS_TRANSPORT_PILOT, ACCESS_RC_ANNOUNCE, ACCESS_HANGAR)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_HEADS, ACCESS_EVA, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM, ACCESS_MUNITIONS, ACCESS_MAA, ACCESS_MUNITIONS_STORAGE, ACCESS_COMBAT_PILOT, ACCESS_TRANSPORT_PILOT, ACCESS_RC_ANNOUNCE, ACCESS_HANGAR)
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_MUN
	mind_traits = list(TRAIT_MUNITIONS_METABOLISM)
	display_order = JOB_DISPLAY_ORDER_MASTER_AT_ARMS
	display_rank = "WO" //nsv13 - Displays the player's actual rank alongside their name, such as GSGT Sergei Koralev
	departments = DEPARTMENT_BITFLAG_COMMAND | DEPARTMENT_BITFLAG_MUNITIONS
	rpg_title = "Combustion Sage"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)

/datum/job/master_at_arms/get_access()
	var/list/L = list()
	L = ..() | check_config_for_sec_maint()
	return L

/datum/outfit/job/master_at_arms
	name = JOB_NAME_MASTERATARMS
	jobtype = /datum/job/master_at_arms

	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset/heads/master_at_arms
	uniform = /obj/item/clothing/under/rank/master_at_arms
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/ship/maa_jacket
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/ship/maa_hat
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	id = /obj/item/card/id/job/master_at_arms
	l_pocket = /obj/item/pda
	backpack_contents = list(/obj/item/melee/classic_baton/telescopic=1)

	backpack = /obj/item/storage/backpack/munitions
	satchel = /obj/item/storage/backpack/satchel/munitions
	duffelbag = /obj/item/storage/backpack/duffelbag/munitions
	box = /obj/item/storage/box/security

	pda_slot = ITEM_SLOT_LPOCKET

/obj/effect/landmark/start/master_at_arms
	name = JOB_NAME_MASTERATARMS
	icon_state = "Master At Arms"
