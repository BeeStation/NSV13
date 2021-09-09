/obj/item/storage/box/damage_control
	name = "Damage Control Kit"
	desc = "A kit containing supplies for repairing small breaches."
	icon = 'nsv13/icons/obj/storage.dmi'
	icon_state = "squadbox"
	illustration = "dc_kit"

/obj/item/storage/box/squad_kit
	name = "Squad Kit"
	desc = "An impossibly small box that contains a squad loadout."
	icon = 'nsv13/icons/obj/storage.dmi'
	icon_state = "squadbox"
	illustration = "pilot_kit"

/obj/item/storage/box/damage_control/PopulateContents()
	for(var/I = 0; I < 3; I++)
		new /obj/item/grenade/chem_grenade/smart_metal_foam(src)
	for(var/I = 0; I < 5; I++)
		new /obj/item/inflatable(src)
	new /obj/item/sealant(src)
	new /obj/item/crowbar(src)

/obj/machinery/squad_vendor
	name = "Squad Vendor"
	desc = "A machine which can dispense equipment to squads. <i>Kits taken from this machine must be returned before you can get a new one.</i>"
	icon = 'nsv13/icons/obj/computers.dmi'
	icon_state = "squadvend"
	anchored = TRUE
	density = TRUE
	obj_integrity = 500
	max_integrity = 500 //Tough nut to crack, due to how it'll spit out a crap load of squad gear like a goddamned pinata.
	resistance_flags = ACID_PROOF | FIRE_PROOF
	req_one_access = list(ACCESS_HOP, ACCESS_HOS)
	var/static/list/loans = list() //List of mobs who have taken a kit without returning it. To get a new kit, you have to return the old one.
	var/static/list/loans_info = list()
	var/static/list/loadouts = list()
	var/static/list/requires_weapons_clearance = list(/obj/item/ammo_box, /obj/item/gun)

/obj/machinery/squad_vendor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SquadVendor")
		ui.open()

/obj/machinery/squad_vendor/ui_data(mob/user)
	var/list/data = list()
	data["user_name"] = (user) ? compose_rank(user)+user.name : "Unassigned"
	data["already_loaned"] = (user in loans)
	var/mob/living/carbon/human/H = user
	var/datum/squad/squad = ishuman(H) ? H?.squad : null
	var/list/kits = list()
	for(var/datum/squad_loadout/S in loadouts)
		if(!squad || !(LAZYFIND(S.allowed_ranks, H.squad_role)))
			continue
		var/list/kit = list()
		kit["name"] = S.name
		kit["desc"] = S.desc
		kit["id"] = "\ref[S]"
		kits[++kits.len] = kit
	data["kits"] = kits
	return data

/obj/machinery/squad_vendor/ui_act(action, params)
	if(..())
		return
	var/datum/squad_loadout/S = locate(params["item_id"])
	var/mob/living/carbon/human/H = usr
	if(!istype(H) || !H.squad)
		return FALSE
	switch(action)
		if("vend")
			if(!S)
				return FALSE
			if(!H.squad)
				return FALSE
			var/obj/item/storage/box/squad_kit/box = new(get_turf(src))
			var/loaned_amount = 0 //How much gear have we loaned them?
			for(var/path in S.items)
				var/obj/item/I = new path(src)
				if(!H.squad.weapons_clearance)
					for(var/disallowed in requires_weapons_clearance)
						if(istype(I, disallowed))
							qdel(I)
							continue //They don't have the clearance for that one :)
				I.forceMove(box)
			//If they don't have weapons clearance, don't expect them to return guns that they don't get vended.
			if(H.squad.weapons_clearance)
				loaned_amount = S.must_return.len
			else
				loaned_amount = S.must_return.len - requires_weapons_clearance.len
			playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
			loans += H
			loans_info[H] = list(S, loaned_amount)
			return TRUE
		if("return_gear")
			if(!loans_info[usr])
				return FALSE
			var/list/L = loans_info[H]
			var/datum/squad_loadout/loan = L[1]
			var/loan_amount = L[2]
			var/obj/item/storage/backpack/bag = H.get_item_by_slot(ITEM_SLOT_BACK)
			var/list/nicked = list()
			for(var/atom/movable/AM in bag)
				if(LAZYFIND(loan.must_return, AM.type))
					nicked += AM
			if(nicked.len < loan_amount)
				playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
				to_chat(H, "<span class='warning'>You still have [loan_amount - nicked.len] more item(s) to return....</span>")
				return FALSE
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
			say("Items returned. Have a secure day.")
			for(var/atom/movable/AM in nicked)
				AM.forceMove(src)
				qdel(AM)
			loans -= H
			loans_info[H] = null
			return TRUE

/obj/machinery/squad_vendor/Initialize()
	. = ..()
	if(!loadouts.len)
		for(var/instance in subtypesof(/datum/squad_loadout))
			loadouts += new instance

/datum/squad_loadout
	var/name = "Parent"
	var/desc = "A standardised equipment set for Blue Phalanx marines. This set is designed for use in pressurized areas, it comes with lightweight armour to protect the wearer from most hazards."
	var/list/items = list(/obj/item/clothing/under/ship/marine, /obj/item/clothing/suit/ship/squad, /obj/item/clothing/head/helmet/ship/squad, /obj/item/ammo_box/magazine/pistolm9mm/glock/lethal, /obj/item/gun/ballistic/automatic/pistol/glock)
	var/list/must_return = list()
	var/list/allowed_ranks = list(SQUAD_MARINE, SQUAD_SERGEANT)

/datum/squad_loadout/marine
	name = "Squad Marine (Standard)"

/datum/squad_loadout/space
	name = "Squad Marine (Hazardous Environment)"
	desc = "For hazardous, low pressure environments. This kit contains a reinforced skinsuit which, while slow, will protect marines from the elements."
	items = list(/obj/item/clothing/under/ship/marine, /obj/item/clothing/suit/ship/squad/space, /obj/item/clothing/head/helmet/ship/squad/space, /obj/item/ammo_box/magazine/pistolm9mm/glock/lethal, /obj/item/gun/ballistic/automatic/pistol/glock)

/datum/squad_loadout/New()
	. = ..()
	if(!must_return.len)
		must_return = items

/datum/squad_loadout/leader
	name = "Squad Leader (Standard)"
	desc = "For hazardous, low pressure environments. This kit contains a reinforced skinsuit which, while slow, will protect marines from the elements."
	items = list(/obj/item/clothing/under/ship/marine, /obj/item/megaphone, /obj/item/clothing/suit/ship/squad, /obj/item/clothing/head/helmet/ship/squad/leader, /obj/item/ammo_box/magazine/pistolm9mm/glock/lethal, /obj/item/gun/ballistic/automatic/pistol/glock)
	allowed_ranks = list(SQUAD_LEAD)

/datum/squad_loadout/leader/space
	name = "Squad Leader (Hazardous Environment)"
	desc = "For hazardous, low pressure environments. This kit contains a reinforced skinsuit which, while slow, will protect marines from the elements."
	items = list(/obj/item/clothing/under/ship/marine, /obj/item/megaphone, /obj/item/clothing/suit/ship/squad/space, /obj/item/clothing/head/helmet/ship/squad/space, /obj/item/ammo_box/magazine/pistolm9mm/glock/lethal, /obj/item/gun/ballistic/automatic/pistol/glock)

/datum/squad_loadout/engineer
	name = "Squad Engineer (Standard)"
	desc = "This kit contains everything a squad engineer needs to effect repairs in non-hazardous environments. Recommended only for planetside operations where speed is necessary."
	items = list(/obj/item/clothing/under/ship/marine/engineer, /obj/item/storage/belt/utility/full, /obj/item/storage/box/damage_control, /obj/item/clothing/glasses/welding, /obj/item/clothing/suit/ship/squad, /obj/item/clothing/head/helmet/ship/squad, /obj/item/ammo_box/magazine/pistolm9mm/glock/lethal, /obj/item/gun/ballistic/automatic/pistol/glock)
	allowed_ranks = list(SQUAD_ENGI)

/datum/squad_loadout/engineer/space
	name = "Squad Engineer (Hazardous Environment)"
	desc = "For hazardous, low pressure environments. This kit contains everything a squad engineer needs to effect repairs in the heat of battle, no matter the condition of the ship they're on."
	items = list(/obj/item/clothing/under/ship/marine/engineer, /obj/item/storage/belt/utility/full, /obj/item/storage/box/damage_control, /obj/item/clothing/glasses/welding, /obj/item/clothing/suit/ship/squad/space,/obj/item/clothing/head/helmet/ship/squad/space, /obj/item/ammo_box/magazine/pistolm9mm/glock/lethal, /obj/item/gun/ballistic/automatic/pistol/glock)

/datum/squad_loadout/medic
	name = "Squad Medic (Standard)"
	desc = "A kit containing battlefield medical equipment and light squad armour."
	items = list(/obj/item/clothing/under/ship/marine/medic, /obj/item/storage/firstaid/regular, /obj/item/reagent_containers/medspray/sterilizine, /obj/item/reagent_containers/medspray/styptic, /obj/item/clothing/suit/ship/squad, /obj/item/clothing/head/helmet/ship/squad, /obj/item/ammo_box/magazine/pistolm9mm/glock/lethal, /obj/item/gun/ballistic/automatic/pistol/glock)
	allowed_ranks = list(SQUAD_MEDIC)

/datum/squad_loadout/medic/space
	name = "Squad Medic (Hazardous Environment)"
	desc = "For hazardous, low pressure environments. This kit contains specialist equipment for treating common battlefield injuries."
	items = list(/obj/item/clothing/under/ship/marine/medic, /obj/item/storage/firstaid/regular, /obj/item/reagent_containers/medspray/sterilizine, /obj/item/reagent_containers/medspray/styptic, /obj/item/storage/firstaid/o2, /obj/item/clothing/suit/ship/squad/space, /obj/item/clothing/head/helmet/ship/squad/space, /obj/item/ammo_box/magazine/pistolm9mm/glock/lethal, /obj/item/gun/ballistic/automatic/pistol/glock)
