/obj/item/circuitboard/computer/squad_manager
	name = "circuit board (squad management computer)"
	build_path = /obj/machinery/computer/squad_manager

/obj/machinery/computer/squad_manager
	name = "Squad Management Computer"
	desc = "A console which allows you to manage the ship's squads and assign people to different squads."
	icon_screen = "squadconsole"
	req_one_access = ACCESS_HEADS
	circuit = /obj/item/circuitboard/computer/squad_manager
	var/next_major_action = 0 //To stop the infinite BOOOP spam.

/obj/machinery/computer/squad_manager/attackby(obj/item/W, mob/user, params)
	if(istype(W , /obj/item/clothing/suit/ship/squad))
		W.forceMove(src)
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
		return FALSE
	if(istype(W, /obj/item/clothing/head/ship/squad))
		W.forceMove(src)
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
		return FALSE
	if(istype(W, /obj/item/squad_pager))
		W.forceMove(src)
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
		return FALSE
	if(istype(W, /obj/item/clothing/neck/squad))
		W.forceMove(src)
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
		return FALSE
	. = ..()

/obj/machinery/computer/squad_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SquadManager")
		ui.open()

/obj/machinery/computer/squad_manager/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	var/datum/squad/S = locate(params["id"])
	var/mob/living/carbon/human/member = locate(params["member_id"])
	var/obj/item/I = locate(params["item_id"])
	switch(action)
		if("message")
			var/orders = stripped_input(usr, message="Send a squad-wide message to [S].", max_length=MAX_BROADCAST_LEN)
			if(!orders || length(orders) <= 0)
				return
			S.broadcast(S,orders)
		if("retask")
			if(world.time < next_major_action)
				to_chat(usr, "<span class='warning'>Comms circuits recharging.</span>")
				return
			next_major_action = world.time + 10 SECONDS
			var/newTask = input(usr, "Re-task [S] to what?", "Squad Setup") as null|anything in SQUAD_TYPES
			if(!newTask)
				return
			S.retask(newTask)
		if("standingorders")
			if(world.time < next_major_action)
				to_chat(usr, "<span class='warning'>Comms circuits recharging.</span>")
				return
			next_major_action = world.time + 10 SECONDS
			var/orders = stripped_input(usr, message="What are your orders? (Limit is [MAX_BROADCAST_LEN] characters)", max_length=MAX_BROADCAST_LEN)
			if(!orders || length(orders) <= 0)
				return
			S.set_orders(orders)
		if("reassign")
			if(member)
				var/answer = alert(usr, "Modify [member]'s rank, or re-assign them?",name,"Modify Rank","Reassign")
				if(answer == "Reassign")
					var/datum/squad/newSquad = input(usr, "Re-assign [member]:", "Squad Setup") as null|anything in GLOB.squad_manager.squads
					if(newSquad)
						if(member.squad)
							member.squad -= member
						newSquad += member
				if(answer == "Modify Rank")
					if(member == member.squad.leader)
						if(alert("Demote [member]?",name,"Yes","No") == "Yes")
							member.squad.unset_leader(member)
					else
						if(alert("Promote [member]?",name,"Yes","No") == "Yes")
							member.squad.unset_leader() //Clear the current leader.
							member.squad.set_leader(member)
		if("eject")
			I.forceMove(get_turf(src))
		if("repaint")
			var/datum/squad/newSquad = input(usr, "What squad would you like to assign to this item?:", "Squad Setup") as null|anything in GLOB.squad_manager.squads
			if(newSquad)
				if(istype(I , /obj/item/clothing/suit/ship/squad))
					var/obj/item/clothing/suit/ship/squad/SS = I
					SS.apply_squad(newSquad) //Repaint the item!
					playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
					return
				if(istype(I, /obj/item/clothing/head/ship/squad))
					var/obj/item/clothing/head/ship/squad/SS = I
					SS.apply_squad(newSquad) //Repaint the item!
					playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
					return
				if(istype(I, /obj/item/squad_pager))
					var/obj/item/squad_pager/SS = I
					SS.apply_squad(newSquad) //Repaint the item!
					playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
					return
				if(istype(I, /obj/item/clothing/neck/squad))
					var/obj/item/squad_pager/SS = I
					SS.apply_squad(newSquad) //Repaint the item!
					playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
					return
				say("ERROR: [I] cannot be painted by this machine.") //I don't know how you did this. But go away.

/obj/machinery/computer/squad_manager/ui_data(mob/user)
	var/list/data = list()
	var/list/squads_info = list()
	var/list/items_info = list()
	for(var/atom/movable/AM in contents)
		var/list/info = list()
		info["name"] = AM.name
		info["id"] = "\ref[AM]"
		items_info[++items_info.len] = info
	data["items_info"] = items_info
	for(var/datum/squad/S in GLOB.squad_manager.squads)
		var/list/squad_info = list()
		var/list/members_info = list()
		squad_info["name"] = S.name
		squad_info["id"] = "\ref[S]"
		squad_info["squad_type"] = S.squad_type
		squad_info["orders"] = S.orders
		for(var/mob/M in S.members)
			var/list/member_info = list()
			member_info["name"] = M.name
			member_info["id"] = "\ref[M]"
			member_info["isLead"] = S.leader == M
			members_info[++members_info.len] = member_info
		squad_info["members_info"] = members_info
		squads_info[++squads_info.len] = squad_info
	data["squads_info"] = squads_info
	return data

/obj/item/storage/box/squad_kit
	name = "Squad equipment kit"
	desc = "A kit containing everything a squaddie would need to get started."
	icon = 'nsv13/icons/obj/storage.dmi'
	icon_state = "squadbox"
	w_class = 3
	var/squad_type = null
	var/datum/squad/squad = null
	var/list/must_return = list() //Items that you MUST return to the kit before you can hand it back in. To prevent people from just stealing all the guns from sec kits.

/obj/item/storage/box/squad_kit/proc/apply_squad(datum/squad/newSquad)
	if(!newSquad)
		return
	for(var/obj/item/I in contents)
		if(istype(I , /obj/item/clothing/suit/ship/squad))
			var/obj/item/clothing/suit/ship/squad/SS = I
			SS.apply_squad(newSquad) //Repaint the item!
		if(istype(I, /obj/item/clothing/head/ship/squad))
			var/obj/item/clothing/head/ship/squad/SS = I
			SS.apply_squad(newSquad) //Repaint the item!
		if(istype(I, /obj/item/squad_pager))
			var/obj/item/squad_pager/SS = I
			SS.apply_squad(newSquad) //Repaint the item!
		if(istype(I, /obj/item/clothing/neck/squad))
			var/obj/item/squad_pager/SS = I
			SS.apply_squad(newSquad) //Repaint the item!

/obj/item/storage/box/squad_kit/proc/can_return()
	var/list/remaining = must_return.Copy()
	for(var/atom/movable/AM in contents)
		for(var/requisiteType in remaining)
			if(istype(AM, requisiteType))
				remaining -= requisiteType
	return !remaining.len

/obj/item/storage/box/squad_kit/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.max_combined_w_class = 21
	STR.max_items = 10

/obj/item/storage/box/squad_kit/Initialize(mapload, datum/squad/squad)
	. = ..()
	src.squad = squad

/obj/item/storage/box/squad_kit/dc
	name = "Damage Control Kit"
	desc = "A kit containing supplies for repairing small breaches."
	squad_type = DC_SQUAD
	illustration = "dc_kit"
	must_return = list(/obj/item/sealant, /obj/item/crowbar) //Gotta give back the sealant and crowbar. The rest are consumables.

/obj/item/storage/box/squad_kit/dc/PopulateContents()
	for(var/I = 0; I < 2; I++){
		new /obj/item/grenade/chem_grenade/smart_metal_foam(src)
	}
	for(var/I = 0; I < 5; I++){
		new /obj/item/inflatable(src)
	}
	new /obj/item/sealant(src)
	new /obj/item/crowbar(src)

/obj/item/storage/box/squad_kit/med
	name = "Paramedical Squad Kit"
	desc = "A kit containing supplies for assisting medical with triage, and keeping people alive long enough to get surgery."
	squad_type = MEDICAL_SQUAD
	illustration = "med_kit"
	must_return = list(/obj/item/clothing/glasses/hud/health) //Everything else is consumable.

/obj/item/storage/box/squad_kit/med/PopulateContents()
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/stack/medical/gauze(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/reagent_containers/hypospray/medipen(src)
	new /obj/item/reagent_containers/hypospray/medipen(src)
	new /obj/item/reagent_containers/hypospray/medipen/dexalin(src)
	new /obj/item/reagent_containers/hypospray/medipen/dexalin(src)
	new /obj/item/roller(src)
	new /obj/item/roller(src)

/obj/item/storage/box/squad_kit/fireteam
	name = "Security Fireteam Kit"
	desc = "A kit containing supplies for combat."
	squad_type = SECURITY_SQUAD
	illustration = "sec_kit"
	must_return = list(/obj/item/gun/ballistic/automatic/pistol/glock, /obj/item/club) //We don't care if they don't give the ammo back.

/obj/item/storage/box/squad_kit/fireteam/PopulateContents()
	new /obj/item/clothing/suit/ship/squad(src, squad)
	new /obj/item/clothing/head/ship/squad(src, squad)
	new /obj/item/gun/ballistic/automatic/pistol/glock(src)
	new /obj/item/ammo_box/magazine/pistolm9mm/glock/lethal(src)
	new /obj/item/ammo_box/magazine/pistolm9mm/glock/lethal(src)
	new /obj/item/club(src)

/obj/item/storage/box/squad_kit/pilot //Contains bits to help you not die in a fighter.
	name = "Airman Kit"
	desc = "A kit containing supplies to get you into the air, and probably back again in one piece."
	squad_type = COMBAT_AIR_PATROL
	illustration = "pilot_kit"
	must_return = list(/obj/item/clothing/suit/space/hardsuit/pilot) //Everything else is consumable.

/obj/item/storage/box/squad_kit/pilot/PopulateContents()
	new /obj/item/clothing/suit/space/hardsuit/pilot(src)
	new /obj/item/tank/internals/emergency_oxygen/double(src)

/obj/item/storage/box/squad_kit/mt //Contains bits to ensure that the MTs don't bully you during GQ.
	name = "Munitions Support Kit"
	desc = "A kit containing supplies to mark you as a munitions support crewman to the MTs, so they don't kick you out of their workplace."
	squad_type = MUNITIONS_SUPPORT
	illustration = "mt_kit"
	must_return = list(/obj/item/clothing/suit/hazardvest, /obj/item/clothing/head/helmet/decktech)

/obj/item/storage/box/squad_kit/mt/PopulateContents()
	new /obj/item/clothing/suit/hazardvest(src)
	new /obj/item/clothing/head/helmet/decktech(src)

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
	var/list/loaned = list() //List of mobs who have taken a kit without returning it. To get a new kit, you have to return the old one.

/obj/machinery/squad_vendor/Initialize()
	. = ..()
	for(var/I = 0; I < 15; I++){
		new /obj/item/storage/box/squad_kit/dc(src)
	}
	for(var/I = 0; I < 15; I++){
		new /obj/item/storage/box/squad_kit/med(src)
	}
	for(var/I = 0; I < 15; I++){
		new /obj/item/storage/box/squad_kit/fireteam(src)
	}
	for(var/I = 0; I < 15; I++){
		new /obj/item/storage/box/squad_kit/pilot(src)
	}
	for(var/I = 0; I < 15; I++){
		new /obj/item/storage/box/squad_kit/mt(src)
	}

/obj/machinery/squad_vendor/attackby(obj/item/W, mob/user, params)
	if(istype(W , /obj/item/storage/box/squad_kit))
		var/obj/item/storage/box/squad_kit/SK = W
		if(!SK.can_return())
			to_chat(user, "<span class='warning'>You can't return [SK] without putting back all of the items that it initially came with. (Consumable items need not be returned)</span>")
			return
		W.forceMove(src)
		var/datum/component/storage/S = W.GetComponent(/datum/component/storage)
		S.close_all() //To stop you from being able to yoink stuff out of the box from inside the vendor, thus cheating the system entirely.
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
		say("[W] has been returned, thank you for your cooperation.")
		release_loan(user)
		return FALSE
	. = ..()
/obj/machinery/squad_vendor/proc/release_loan(mob/user)
	for(var/I = 1; I <= loaned.len; I++){
		var/list/L = loaned[I]
		var/mob/M = L["mob"]
		if(M == user)
			loaned.Cut(I, ++I)
			return TRUE
	}
	return FALSE

/obj/machinery/squad_vendor/ui_interact(mob/user, datum/tgui/ui)
	if(GLOB.security_level < SEC_LEVEL_RED && ishuman(user))
		say("Error. Squad equipment only unlocks during general quarters or above.")
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SquadVendor")
		ui.open()

/obj/machinery/squad_vendor/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	var/obj/item/storage/box/squad_kit/B = locate(params["item_id"])
	var/mob/living/carbon/human/bob = locate(params["member_id"])
	var/mob/living/carbon/human/user = usr
	switch(action)
		if("eject")
			for(var/list/L in loaned)
				var/mob/M = L["mob"]
				if(M == usr)
					to_chat(usr, "<span class='warning'>You have not yet returned your previously loaned kit! You may not borow any further Nanotrasen property until your other loaned kit is returned.</span>") //Get out of debt kid.
					return
			B.forceMove(get_turf(src))
			to_chat(usr, "<span class='warning'>Equipment loan successful. Ensure that all corporate property is returned to this vendor in its original box when you have finished with it.</span>")
			var/itemContents = ""
			for(var/atom/movable/AM in B.contents)
				itemContents += AM.name+";"
			playsound(src, 'sound/machines/machine_vend.ogg', 100, 0)
			flick("squadvend_vend", src)
			var/dangerous = istype(B, /obj/item/storage/box/squad_kit/fireteam)
			loaned += list(list("mob"=usr, "itemName"=B.name, "itemContents"=itemContents, "dangerous"=dangerous))
			B.apply_squad(user.squad)
		if("releaseLoan")
			release_loan(bob)
	return

//TODO: allow the operator to release people from their loan, and let them take another kit. In case they genuinely lost their item.

/obj/machinery/squad_vendor/ui_data(mob/user)
	var/list/data = list()
	var/list/categories = list()
	var/mob/living/carbon/human/H = user
	data["debug"] = FALSE
	data["loaned_info"] = null
	if(allowed(user)) //XO or HOS access lets you check what's on loan.
		data["debug"] = TRUE
		var/list/loaned_info = list()
		for(var/list/L in loaned)
			var/mob/living/carbon/human/M = L["mob"]
			var/list/info = list()
			info["name"] = M.name
			info["squad"] = M.squad?.name || "No squad"
			info["id"] = "\ref[M]"
			info["itemName"] = L["itemName"]
			info["itemContents"] = L["itemContents"]
			info["dangerous"] = L["dangerous"]
			loaned_info[++loaned_info.len] = info
		data["loaned_info"] = loaned_info
	for(var/obj/item/storage/box/squad_kit/SK in contents)
		if(!istype(SK))
			continue
		if(!ishuman(H) || !H.squad)
			continue
		if(SK.squad_type != H.squad.squad_type) //No guns for DC boys.
			continue
		var/list/info = list()
		info["name"] = SK.name
		info["id"] = "\ref[SK]"
		categories[++categories.len] = info
	data["categories"] = categories
	return data
