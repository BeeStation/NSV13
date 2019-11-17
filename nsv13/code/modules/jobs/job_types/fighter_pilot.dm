/datum/job/fighter_pilot
	title = "Fighter Pilot"
	flag = FIGHTER_PILOT
	department_head = list("Master At Arms")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	supervisors = "the CAG"
	selection_color = "#ffeeee"

	outfit = /datum/outfit/job/fighter_pilot

	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_MECH_SECURITY, ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS, ACCESS_MUNITIONS) //temp
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_MECH_SECURITY, ACCESS_WEAPONS, ACCESS_MUNITIONS) //temp
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_FIGHTER_PILOT
	display_rank = "CPL" //nsv13 - Displays the player's actual rank alongside their name, such as GSGT Sergei Koralev
//add support for callsigns here

/obj/item/encryptionkey/pilot
	name = "air traffic control radio encryption key"
	icon_state = "sec_cypherkey"
	channels = list(RADIO_CHANNEL_ATC = 1, RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_SUPPLY = 1)
	independent = TRUE

/obj/item/radio/headset/headset_sec/alt/pilot
	name = "pilot radio headset"
	desc = "A headset capable of accessing the Nanotrasen blue channel via a special DRADIS satellite uplink, allowing fighter pilots to communicate from anywhere inside of Nanotrasen's airspace. Use :q to access the air traffic control frequency."
	icon_state = "sec_headset"
	keyslot = new /obj/item/encryptionkey/pilot

/datum/outfit/job/fighter_pilot
	name = "Fighter Pilot"
	jobtype = /datum/job/fighter_pilot

	belt = /obj/item/pda/security
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
	icon_state = "fighter_pilot"

/datum/job/cag //"Commander Air Group" AKA chief fighter pilot
	title = "CAG"
	flag = CAG
	department_head = list("Master At Arms")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Master At Arms"
	selection_color = "#ffeeee"

	outfit = /datum/outfit/job/cag

	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_MECH_SECURITY, ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS, ACCESS_MUNITIONS) //temp
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_MECH_SECURITY, ACCESS_WEAPONS, ACCESS_MUNITIONS) //temp
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_CAG
	display_rank = "SGT" //nsv13 - Displays the player's actual rank alongside their name, such as GSGT Sergei Koralev

/datum/outfit/job/cag
	name = "CAG"
	jobtype = /datum/job/cag

	belt = /obj/item/pda/security
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
	name = "CAG"
	icon_state = "CAG"

/obj/machinery/suit_storage_unit/pilot
	suit_type = /obj/item/clothing/suit/space/hardsuit/pilot
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double