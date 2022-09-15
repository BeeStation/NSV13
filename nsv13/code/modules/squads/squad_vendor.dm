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
	var/static/list/loans_info = list()
	var/static/list/loadouts = list()
	var/static/list/requires_weapons_clearance = list(/obj/item/ammo_box, /obj/item/gun)

/obj/machinery/squad_vendor/Initialize(mapload)
	. = ..()
	if(!length(loadouts))
		for(var/instance in subtypesof(/datum/squad_loadout))
			loadouts += new instance

/obj/machinery/squad_vendor/attackby(obj/item/I, mob/living/user, params)
	return return_item(user, I) || ..()

/obj/machinery/squad_vendor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SquadVendor")
		ui.open()

/obj/machinery/squad_vendor/ui_data(mob/user)
	var/list/data = list()
	data["user_name"] = (user) ? compose_rank(user)+user.name : "Unassigned"
	data["already_loaned"] = (user in loans_info)
	var/mob/living/carbon/human/H = user
	var/datum/squad/squad = ishuman(H) ? H?.squad : null
	var/list/kits = list()
	for(var/datum/squad_loadout/S in loadouts)
		if(!squad || !(LAZYFIND(S.allowed_roles, H.squad.role)))
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
	var/datum/squad_loadout/loadout = locate(params["item_id"])
	var/mob/living/carbon/human/H = usr
	if(!istype(H) || !H.squad)
		return FALSE
	switch(action)
		if("vend")
			if(!loadout)
				return FALSE
			if(!H.squad)
				return FALSE
			var/obj/item/storage/box/squad_kit/box = new(get_turf(src))
			var/list/must_return = loadout.items.Copy()
			//If they don't have weapons clearance, don't expect them to return guns that they don't get vended.
			if(!H.squad.weapons_clearance)
				for(var/banned in requires_weapons_clearance)
					for(var/path in must_return)
						if(ispath(path, banned))
							must_return -= path
			for(var/path in must_return)
				var/obj/item/I = new path(src)
				I.forceMove(box)
			playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
			loans_info[H] = must_return
			return TRUE
		if("return_gear")
			if(!loans_info[H])
				return FALSE
			var/list/must_return = loans_info[H]
			var/obj/item/storage/backpack/bag = H.get_item_by_slot(ITEM_SLOT_BACK)
			for(var/atom/movable/AM in bag)
				return_item(usr, AM, quiet=TRUE) // Don't spam them, we'll handle the notification ourselves
			notify(H)
			if(length(must_return))
				return FALSE
			loans_info -= H
			return TRUE
		if("pay_fine")
			if(!loans_info[H])
				return FALSE
			var/list/must_return = loans_info[H]
			var/total = length(must_return) * 300
			if(alert(usr, "You will be charged [total] credits.", "Lost Item Fine", "OK", "Cancel") == "OK")
				// Why the fuck is there no proc for this
				var/obj/item/card/id/C = H.get_idcard(TRUE)
				if(!C)
					say("No ID card found.")
					return
				else if (!C.registered_account)
					say("No bank account found.")
					return
				var/datum/bank_account/account = C.registered_account
				if(!account.adjust_money(-total))
					say("You do not possess the funds for this.")
					return
				// Success!
				loans_info -= H
				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
				say("Fee processed. Have a secure day.")
				ui_update()
				return TRUE

/obj/machinery/squad_vendor/proc/return_item(mob/living/user, obj/item/I, quiet=FALSE)
	var/list/must_return = loans_info[user]
	if(length(must_return) && LAZYFIND(must_return, I.type))
		I.forceMove(src)
		LAZYREMOVE(must_return, I.type)
		qdel(I)
		if(!quiet)
			notify(user)
		if(!length(must_return))
			loans_info -= user
		ui_update()
		return TRUE
	if(istype(I, /obj/item/storage/box/squad_kit))
		if(length(I.contents))
			for(var/obj/item/thing in I.contents)
				return_item(user, thing, quiet=TRUE)
			if(!quiet)
				notify(user)
		if(!length(I.contents)) // This is two blocks so I can only tell them about returned items if there were items to return
			I.forceMove(src)
			qdel(I)
			if(!quiet)
				say("Thank you for recycling.")
		else if(!quiet)
			to_chat(user, "<span class='warning'>The box must be empty to be returned.</span>")
		ui_update()
		return TRUE

/obj/machinery/squad_vendor/proc/notify(mob/living/user)
	var/list/must_return = loans_info[user]
	if(length(must_return))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		to_chat(user, "<span class='warning'>You still have [length(must_return)] more item(s) to return.</span>")
	else
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
		say("Items returned. Have a secure day.")

/datum/squad_loadout
	var/name = "Parent"
	var/desc = "A standardised equipment set for Blue Phalanx marines. This set is designed for use in pressurized areas, it comes with lightweight armour to protect the wearer from most hazards."
	var/list/items = list(/obj/item/clothing/under/ship/marine, /obj/item/clothing/suit/ship/squad, /obj/item/clothing/head/helmet/ship/squad, /obj/item/ammo_box/magazine/glock/lethal, /obj/item/gun/ballistic/automatic/pistol/glock)
	var/leader_only = FALSE
	var/list/allowed_roles = SQUAD_TYPES

/datum/squad_loadout/marine
	name = "Squad Marine (Standard)"

/datum/squad_loadout/space
	name = "Squad Marine (Hazardous Environment)"
	desc = "For hazardous, low pressure environments. This kit contains a reinforced skinsuit which, while slow, will protect marines from the elements."
	items = list(/obj/item/clothing/under/ship/marine, /obj/item/clothing/suit/ship/squad/space, /obj/item/clothing/head/helmet/ship/squad/space, /obj/item/ammo_box/magazine/glock/lethal, /obj/item/gun/ballistic/automatic/pistol/glock)

/datum/squad_loadout/leader
	name = "Squad Leader (Standard)"
	desc = "For hazardous, low pressure environments. This kit contains a reinforced skinsuit which, while slow, will protect marines from the elements."
	items = list(/obj/item/clothing/under/ship/marine, /obj/item/megaphone, /obj/item/clothing/suit/ship/squad, /obj/item/clothing/head/helmet/ship/squad/leader, /obj/item/ammo_box/magazine/glock/lethal, /obj/item/gun/ballistic/automatic/pistol/glock)
	leader_only = TRUE

/datum/squad_loadout/leader/space
	name = "Squad Leader (Hazardous Environment)"
	desc = "For hazardous, low pressure environments. This kit contains a reinforced skinsuit which, while slow, will protect marines from the elements."
	items = list(/obj/item/clothing/under/ship/marine, /obj/item/megaphone, /obj/item/clothing/suit/ship/squad/space, /obj/item/clothing/head/helmet/ship/squad/space, /obj/item/ammo_box/magazine/glock/lethal, /obj/item/gun/ballistic/automatic/pistol/glock)

/datum/squad_loadout/engineer
	name = "Squad Engineer (Standard)"
	desc = "This kit contains everything a squad engineer needs to effect repairs in non-hazardous environments. Recommended only for planetside operations where speed is necessary."
	items = list(/obj/item/clothing/under/ship/marine/engineer, /obj/item/storage/belt/utility/full, /obj/item/storage/box/damage_control, /obj/item/clothing/glasses/welding, /obj/item/clothing/suit/ship/squad, /obj/item/clothing/head/helmet/ship/squad, /obj/item/ammo_box/magazine/glock/lethal, /obj/item/gun/ballistic/automatic/pistol/glock)
	allowed_roles = list(DC_SQUAD, MUNITIONS_SUPPORT, COMBAT_AIR_PATROL)

/datum/squad_loadout/engineer/space
	name = "Squad Engineer (Hazardous Environment)"
	desc = "For hazardous, low pressure environments. This kit contains everything a squad engineer needs to effect repairs in the heat of battle, no matter the condition of the ship they're on."
	items = list(/obj/item/clothing/under/ship/marine/engineer, /obj/item/storage/belt/utility/full, /obj/item/storage/box/damage_control, /obj/item/clothing/glasses/welding, /obj/item/clothing/suit/ship/squad/space,/obj/item/clothing/head/helmet/ship/squad/space, /obj/item/ammo_box/magazine/glock/lethal, /obj/item/gun/ballistic/automatic/pistol/glock)

/datum/squad_loadout/medic
	name = "Squad Medic (Standard)"
	desc = "A kit containing battlefield medical equipment and light squad armour."
	items = list(/obj/item/clothing/under/ship/marine/medic, /obj/item/storage/firstaid/regular, /obj/item/reagent_containers/medspray/sterilizine, /obj/item/reagent_containers/medspray/styptic, /obj/item/clothing/suit/ship/squad, /obj/item/clothing/head/helmet/ship/squad, /obj/item/ammo_box/magazine/glock/lethal, /obj/item/gun/ballistic/automatic/pistol/glock)
	allowed_roles = list(MEDICAL_SQUAD)

/datum/squad_loadout/medic/space
	name = "Squad Medic (Hazardous Environment)"
	desc = "For hazardous, low pressure environments. This kit contains specialist equipment for treating common battlefield injuries."
	items = list(/obj/item/clothing/under/ship/marine/medic, /obj/item/storage/firstaid/regular, /obj/item/reagent_containers/medspray/sterilizine, /obj/item/reagent_containers/medspray/styptic, /obj/item/storage/firstaid/o2, /obj/item/clothing/suit/ship/squad/space, /obj/item/clothing/head/helmet/ship/squad/space, /obj/item/ammo_box/magazine/glock/lethal, /obj/item/gun/ballistic/automatic/pistol/glock)
