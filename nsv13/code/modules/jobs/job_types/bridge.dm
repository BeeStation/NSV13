/datum/job/bridge
	title = JOB_NAME_BRIDGESTAFF
	flag = BRIDGE_OFFICER
	auto_deadmin_role_flags = PREFTOGGLE_DEADMIN_POSITION_SECURITY
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "The executive officer"
	selection_color = "#ddddff"
	req_admin_notify = 1
	minimal_player_age = 2
	exp_requirements = 900
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/bridge

	access = list(ACCESS_HEADS, ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH)
	minimal_access = list(ACCESS_HEADS, ACCESS_MAINT_TUNNELS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MUN

	display_order = JOB_DISPLAY_ORDER_BRIDGE_OFFICER
	departments = DEPARTMENT_BITFLAG_MUNITIONS | DEPARTMENT_BITFLAG_COMMAND
	rpg_title = "Farseer"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)

/datum/outfit/job/bridge
	name = JOB_NAME_BRIDGESTAFF
	jobtype = /datum/job/bridge

	id = /obj/item/card/id/job/bridge_staff
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	ears = /obj/item/radio/headset/headset_bridge
	uniform = /obj/item/clothing/under/ship/officer
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/beret/durathread

/obj/effect/landmark/start/bridge
	name = JOB_NAME_BRIDGESTAFF
	icon_state = "Bridge Staff"
