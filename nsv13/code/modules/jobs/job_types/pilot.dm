/datum/job/pilot
	title = "Pilot"
	flag = PILOT
	department_head = list("Master At Arms")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	supervisors = "the Master At Arms"
	selection_color = "#d692a3"
	chat_color = "#2681a5"
	exp_requirements = 60
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_MUNITIONS

	outfit = /datum/outfit/job/pilot

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE, ACCESS_COMBAT_PILOT, ACCESS_TRANSPORT_PILOT)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MUNITIONS)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MUN
	mind_traits = list(TRAIT_MUNITIONS_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_PILOT

/datum/job/pilot/get_access()
	. = ..()

	if(H && H.client && H.client.prefs)
		var/role = H.client.prefs.preferred_pilot_role
		switch(role)
			if(PILOT_COMBAT)
				. |= list(ACCESS_COMBAT_PILOT)
			if(PILOT_TRANSPORT)
				. |= list(ACCESS_TRANSPORT_PILOT)

/datum/outfit/job/pilot
	name = "Pilot"
	jobtype = /datum/job/pilot

	ears = /obj/item/radio/headset/munitions/pilot
	shoes = /obj/item/clothing/shoes/jackboots

	backpack = /obj/item/storage/backpack/munitions
	satchel = /obj/item/storage/backpack/satchel/munitions
	duffelbag = /obj/item/storage/backpack/duffelbag/munitions

/datum/outfit/job/pilot/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()

	if(H && H.client && H.client.prefs)
		var/role = H.client.prefs.preferred_pilot_role
		switch(role)
			if(PILOT_COMBAT)
				head = /obj/item/clothing/head/beret/ship/pilot
				uniform = /obj/item/clothing/under/ship/pilot
				gloves = /obj/item/clothing/gloves/color/black

			if(PILOT_TRANSPORT)
				head =
				uniform = /obj/item/clothing/under/ship/pilot/transport
				gloves = /obj/item/clothing/gloves/color/brown

/obj/effect/landmark/start/pilot
	name = "Pilot"
	icon_state = "Pilot"
