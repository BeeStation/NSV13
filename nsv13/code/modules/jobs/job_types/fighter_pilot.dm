/datum/job/fighter_pilot
	title = "Fighter Pilot"
	flag = FIGHTER_PILOT
	department_head = list("Master At Arms")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Master At Arms"
	selection_color = "#ffeeee"

	outfit = /datum/outfit/job/fighter_pilot

	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_MECH_SECURITY, ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS) //temp
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_MECH_SECURITY, ACCESS_WEAPONS) //temp
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_FIGHTER_PILOT
	display_rank = "CPL" //nsv13 - Displays the player's actual rank alongside their name, such as GSGT Sergei Koralev
//add support for callsigns here


/datum/outfit/job/fighter_pilot
	name = "Fighter Pilot"
	jobtype = /datum/job/fighter_pilot

	belt = /obj/item/pda/security //placeholder
	ears = /obj/item/radio/headset/headset_sec/alt //placeholder
	uniform = /obj/item/clothing/under/assistantformal //let's be real - placeholder
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black //placeholder
	head = /obj/item/clothing/head/HoS/beret //placeholder
	//l_pocket = <KEYS GO HERE>

/datum/outfit/job/fighter_pilot_flight_ready
	name = "Fighter Pilot - Flight Ready"
	jobtype = /datum/job/fighter_pilot

	belt = /obj/item/pda/security //placeholder
	ears = /obj/item/radio/headset/headset_sec/alt //placeholder
	uniform = /obj/item/clothing/under/assistantformal //let's be real - placeholder
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/space //placeholder
	gloves = /obj/item/clothing/gloves/color/black //placeholder
	head = /obj/item/clothing/head/helmet/space //placeholder
	mask = /obj/item/clothing/mask/breath //placeholder
	//l_pocket = <KEYS GO HERE>
	r_pocket = /obj/item/tank/internals/emergency_oxygen
