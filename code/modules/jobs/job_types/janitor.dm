/datum/job/janitor
	title = "Janitor"
	flag = JANITOR
	department_head = list("Executive Officer")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 1
	supervisors = "the Executive Officer"
	selection_color = "#bbe291"

	outfit = /datum/outfit/job/janitor

	access = list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_JANITOR
	display_rank = "CRW" //nsv13 - Displays the player's actual rank alongside their name, such as GSGT Sergei Koralev

/datum/outfit/job/janitor
	name = "Janitor"
	jobtype = /datum/job/janitor

	id = /obj/item/card/id/job/serv
	belt = /obj/item/pda/janitor
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/janitor
	backpack_contents = list(/obj/item/modular_computer/tablet/preset/advanced=1)
