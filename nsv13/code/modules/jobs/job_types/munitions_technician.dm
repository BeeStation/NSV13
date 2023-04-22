/datum/job/munitions_tech
	title = JOB_NAME_MUNITIONSTECHNICIAN
	flag = MUNITIONS_TECHNICIAN
	department_head = list(JOB_NAME_MASTERATARMS)
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 8
	spawn_positions = 8
	supervisors = "the Master At Arms"
	selection_color = "#ffd1a2"
	chat_color = "#ff7f00"
	exp_type_department = EXP_TYPE_MUNITIONS

	outfit = /datum/outfit/job/munitions_tech

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM, ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE, ACCESS_HANGAR)
	minimal_access = list(ACCESS_MINERAL_STOREROOM, ACCESS_CONSTRUCTION, ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE, ACCESS_HANGAR)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MUN
	mind_traits = list(TRAIT_MUNITIONS_METABOLISM)
	display_order = JOB_DISPLAY_ORDER_MUNITIONS_TECHNICIAN
	departments = DEPARTMENT_BITFLAG_MUNITIONS
	rpg_title = "Combustion Journeyman"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)

/datum/outfit/job/munitions_tech
	name = JOB_NAME_MUNITIONSTECHNICIAN
	jobtype = /datum/job/munitions_tech

	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset/munitions/munitions_tech
	uniform = /obj/item/clothing/under/rank/munitions_tech
	suit = /obj/item/clothing/suit/ship/munitions_jacket
	head = /obj/item/clothing/head/helmet/decktech
	gloves = /obj/item/clothing/gloves/color/brown
	id = /obj/item/card/id/job/munitions_technician
	l_pocket = /obj/item/modular_computer/tablet/pda/munition

	backpack = /obj/item/storage/backpack/munitions
	satchel = /obj/item/storage/backpack/satchel/munitions
	duffelbag = /obj/item/storage/backpack/duffelbag/munitions

/obj/effect/landmark/start/munitions_tech
	name = JOB_NAME_MUNITIONSTECHNICIAN
	icon_state = "Munitions Technician"
