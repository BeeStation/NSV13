/obj/item/circuitboard/computer/squad_manager
	name = "circuit board (squad management computer)"
	build_path = /obj/machinery/computer/squad_manager

/obj/machinery/computer/squad_manager
	name = "Squad Management Computer"
	desc = "A console which allows you to manage the ship's squads and assign people to different squads."
	icon_screen = "squadconsole"
	req_one_access = ACCESS_HEADS
	circuit = /obj/item/circuitboard/computer/squad_manager

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

/obj/machinery/computer/squad_manager/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SquadManager", name, 600, 800, master_ui, state)
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
			S.broadcast(orders, usr)
		if("retask")
			var/newTask = input(usr, "Re-task [S] to what?", "Squad Setup") as null|anything in SQUAD_TYPES
			if(!newTask)
				return
			S.retask(newTask)
		if("standingorders")
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
							member.squad += member
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