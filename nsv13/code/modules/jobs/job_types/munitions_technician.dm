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

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM, ACCESS_MUNITIONS) //temp
	minimal_access = list(ACCESS_MINERAL_STOREROOM, ACCESS_CONSTRUCTION, ACCESS_MUNITIONS) //temp
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_MUNITIONS_TECHNICIAN
	display_rank = "SPC" //nsv13 - Displays the player's actual rank alongside their name, such as GSGT Sergei Koralev

/datum/outfit/job/munitions_tech
	name = "Munitions Technician"
	jobtype = /datum/job/munitions_tech

	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset/headset_sec/alt/munitions_tech
	uniform = /obj/item/clothing/under/rank/munitions_tech
	suit = /obj/item/clothing/suit/hazardvest
	head = /obj/item/clothing/head/soft/yellow
	gloves = /obj/item/clothing/gloves/color/brown
	l_pocket = /obj/item/pda/cargo

/obj/item/clothing/under/rank/munitions_tech
	name = "camouflage fatigues"
	desc = "A green military camouflage uniform worn by specialists."
	icon_state = "camogreen"
	item_state = "g_suit"
	item_color = "camogreen"
	can_adjust = FALSE

/obj/effect/landmark/start/munitions_tech
	name = "Munitions Technician"
	icon_state = "munitions_tech"

/obj/item/encryptionkey/munitions_tech
	name = "munitions department encryption key"
	icon_state = "sec_cypherkey"
	channels = list(RADIO_CHANNEL_MUNITIONS = 1, RADIO_CHANNEL_SUPPLY = 1)
	independent = TRUE

/obj/item/radio/headset/headset_sec/alt/munitions_tech
	name = "munitions technician radio headset"
	desc = "Use :w to access the department frequency. Use :u to access the supply frequency."
	icon_state = "sec_headset"
	keyslot = new /obj/item/encryptionkey/munitions_tech