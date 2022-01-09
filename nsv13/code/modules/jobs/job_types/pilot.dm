/datum/job/pilot
	title = "Pilot"
	flag = PILOT
	department_head = list("Master At Arms")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	supervisors = "the Master At Arms"
	selection_color = "#ffd1a2"
	chat_color = "#2681a5"
	exp_requirements = 60
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_MUNITIONS

	outfit = /datum/outfit/job/pilot

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE, ACCESS_COMBAT_PILOT, ACCESS_TRANSPORT_PILOT, ACCESS_HANGAR)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MUNITIONS, ACCESS_COMBAT_PILOT, ACCESS_TRANSPORT_PILOT, ACCESS_HANGAR)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MUN
	mind_traits = list(TRAIT_MUNITIONS_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_PILOT
	departments = DEPARTMENT_MUNITIONS

//FIXME: boarding
/*
/datum/job/pilot/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()

	if(H && H.client && H.client.prefs)
		var/role = H.client.prefs.preferred_pilot_role
		var/obj/item/card/id/W = H.wear_id
		switch(role)
			if(PILOT_COMBAT)
				W.access |= list(ACCESS_COMBAT_PILOT)
			if(PILOT_TRANSPORT)
				W.access |= list(ACCESS_TRANSPORT_PILOT)
*/

/datum/outfit/job/pilot
	name = "Pilot"
	jobtype = /datum/job/pilot

	head = null
	glasses = null
	gloves = null
	uniform = /obj/item/clothing/under/ship/marine
	ears = /obj/item/radio/headset/munitions/pilot
	shoes = /obj/item/clothing/shoes/jackboots

	backpack = /obj/item/storage/backpack/munitions
	satchel = /obj/item/storage/backpack/satchel/munitions
	duffelbag = /obj/item/storage/backpack/duffelbag/munitions

/datum/outfit/job/pilot/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(visualsOnly)
		head = /obj/item/clothing/head/helmet/transport_pilot
		glasses = /obj/item/clothing/glasses/sunglasses
		uniform = /obj/item/clothing/under/ship/pilot/transport
		gloves = /obj/item/clothing/gloves/color/brown

/datum/job/pilot/after_spawn(mob/living/carbon/human/H, mob/M, latejoin)
	. = ..()

	if(M && M.client && M.client.prefs)
		var/role = M.client.prefs.preferred_pilot_role
		switch(role)
			if(PILOT_COMBAT)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/beret/ship/pilot(H), ITEM_SLOT_HEAD)
				H.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black(H), ITEM_SLOT_GLOVES)
				var/obj/item/storage/backpack/bag = H.get_item_by_slot(ITEM_SLOT_BACK)
				new /obj/item/clothing/under/ship/pilot(bag, src)

			if(PILOT_TRANSPORT)
				H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(H), ITEM_SLOT_EYES)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/transport_pilot(H), ITEM_SLOT_HEAD)
				H.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/brown(H), ITEM_SLOT_GLOVES)
				var/obj/item/storage/backpack/bag = H.get_item_by_slot(ITEM_SLOT_BACK)
				new /obj/item/clothing/under/ship/pilot/transport(bag, src)

/obj/effect/landmark/start/pilot
	name = "Pilot"
	icon_state = "Pilot"
