/datum/job/bridge
	title = "Bridge Officer"
	flag = BRIDGE_OFFICER
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list("Executive Officer")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "The executive officer"
	selection_color = "#ddddff"
	req_admin_notify = 1
	minimal_player_age = 2


	outfit = /datum/outfit/job/bridge

	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_WEAPONS,ACCESS_HEADS, ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION, ACCESS_CARGO, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_WEAPONS,ACCESS_HEADS, ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION, ACCESS_CARGO, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

	display_order = JOB_DISPLAY_ORDER_BRIDGE_OFFICER
	display_rank = "SGT" //nsv13 - Displays the player's actual rank alongside their name, such as GSGT Sergei Koralev

/datum/outfit/job/bridge
	name = "Bridge officer"
	jobtype = /datum/job/bridge

	id = /obj/item/card/id/silver
	glasses = /obj/item/clothing/glasses/sunglasses
	ears = /obj/item/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/ship/officer
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/beret/durathread

/obj/effect/landmark/start/bridge
	name = "Bridge Officer"
	icon_state = "Bridge Officer"