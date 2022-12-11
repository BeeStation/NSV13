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

/obj/machinery/computer/squad_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SquadManager")
		ui.open()

/obj/machinery/computer/squad_manager/ui_data(mob/user)
	var/list/data = list()
	var/list/squads_info = list()
	for(var/datum/squad/S in GLOB.squad_manager.squads)
		var/list/squad_info = list()
		squad_info["squad_leader_name"] = "[(S.leader) ? "[compose_rank(S.leader)] [S.leader.name]" : "Unassigned"]"
		squad_info["squad_leader_id"] = S.leader ? "\ref[S.leader]" : null
		squad_info["hidden"] = S.hidden
		squad_info["weapons_clearance"] = S.weapons_clearance
		squad_info["desc"] = S.desc
		squad_info["name"] = S.name
		squad_info["role"] = S.role
		squad_info["primary_objective"] = S.primary_objective
		squad_info["secondary_objective"] = S.secondary_objective
		squad_info["access_enabled"] = S.access_enabled
		squad_info["id"] = "\ref[S]"
		//Get info about members...
		var/list/members_info = list()
		for(var/mob/living/M in S.members)
			var/list/member_info = list()
			member_info["name"] = "[compose_rank(M)] [M.real_name]"
			member_info["id"] = "\ref[M]"
			members_info[++members_info.len] = member_info
		squad_info["members"] = members_info
		squads_info[++squads_info.len] = squad_info
	data["squads_info"] = squads_info
	return data

/obj/machinery/computer/squad_manager/ui_act(action, params)
	if(..())
		return
	var/datum/squad/S = locate(params["squad_id"])
	var/mob/living/carbon/human/M = locate(params["id"])
	switch(action)
		if("message")
			if(!S)
				return FALSE
			var/orders = stripped_input(usr, message="Send a squad-wide message to [S].", max_length=MAX_BROADCAST_LEN)
			if(!orders || length(orders) <= 0)
				return
			log_say("[S]: [usr] transmitted: [orders]")
			S.broadcast(S,orders)
		if("primary_objective")
			if(!S)
				return FALSE
			var/orders = input(usr, "Choose squad role:", "Squad Setup") as null|anything in SQUAD_TYPES
			if(!orders || length(orders) <= 0)
				return
			log_say("[S]: [usr] set primary objective: [orders]")
			S.retask(orders)
			for(var/mob/living/L in S.members)
				to_chat(L, "<span class='sciradio'>[S.primary_objective]</span>")
			ui_update()
		if("secondary_objective")
			if(!S)
				return FALSE
			var/orders = stripped_input(usr, message="Set secondary objective:", max_length=MAX_BROADCAST_LEN, default=S.secondary_objective)
			if(!orders || length(orders) <= 0)
				return
			log_say("[S]: [usr] set secondary objective: [orders]")
			S.secondary_objective = orders
			for(var/mob/living/L in S.members)
				to_chat(L, "<span class='sciradio'>Secondary squad objective: [S.secondary_objective]</span>")
			ui_update()
		if("toggle_access")
			if(!S)
				return FALSE
			S.access_enabled = !S.access_enabled
			log_game("[S]: [usr] set squad's elevated access to [S.access_enabled]")
			S.broadcast(S,"[S.access_enabled ? "Elevated squad access granted." : "Elevated squad access rescinded"]", list('nsv13/sound/effects/notice2.ogg'))
			ui_update()
		if("set_leader")
			if(!M)
				return FALSE
			M.squad.set_leader(M)
			ui_update()
		if("demote_leader")
			if(!M)
				return FALSE
			M.squad.unset_leader(M) // There is a check for whether they're the leader or not, it'll be fine
			ui_update()
		if("transfer")
			if(!M)
				return FALSE
			var/datum/squad/newSquad = input(usr, "Transfer [M]:", "Squad Setup") as null|anything in GLOB.squad_manager.squads
			if(newSquad)
				log_game("[newSquad]: [usr] reassigned [M] to [newSquad]")
				if(M.squad)
					M.squad.remove_member(M)
				newSquad.add_member(M)
			ui_update()
		if("toggle_hidden")
			if(!S)
				return FALSE
			S.hidden = !S.hidden
			ui_update()
		//WE HAVE YOU SURROUNDED, SURRENDER YOUR NERF GUNS
		if("toggle_beararms")
			if(!S)
				return FALSE
			S.weapons_clearance = !S.weapons_clearance
			ui_update()
		if("print_pass")
			if(!S || world.time < next_major_action)
				return FALSE
			next_major_action = world.time + 5 SECONDS //Lower the spam a bit...
			new /obj/item/clothing/neck/squad(get_turf(src), S)
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)


/////// MOD COMP MONITORING PROGRAM ///////

/datum/computer_file/program/squad_manager
	filename = "squadmanager"
	filedesc = "Squad Management"
	ui_header = "ntnrc_idle.gif"
	program_icon_state = "ntnrc_idle"
	extended_desc = "A program to allow you to manage the ship's squads while on the go!"
	requires_ntnet = TRUE
	transfer_access = ACCESS_HOP
	category = PROGRAM_CATEGORY_CREW
	network_destination = "squad management"
	size = 2
	tgui_id = "NtosSquadManager"
	var/next_major_action = 0

/datum/computer_file/program/squad_manager/ui_data()
	var/list/data = get_header_data()
	var/list/squads_info = list()
	for(var/datum/squad/S in GLOB.squad_manager.squads)
		var/list/squad_info = list()
		squad_info["squad_leader_name"] = "[(S.leader) ? "[S.leader.compose_rank()] [S.leader.name]" : "Unassigned"]"
		squad_info["squad_leader_id"] = S.leader ? "\ref[S.leader]" : null
		squad_info["hidden"] = S.hidden
		squad_info["weapons_clearance"] = S.weapons_clearance
		squad_info["desc"] = S.desc
		squad_info["name"] = S.name
		squad_info["role"] = S.role
		squad_info["primary_objective"] = S.primary_objective
		squad_info["secondary_objective"] = S.secondary_objective
		squad_info["access_enabled"] = S.access_enabled
		squad_info["id"] = "\ref[S]"
		//Get info about members...
		var/list/members_info = list()
		for(var/mob/living/M in S.members)
			var/list/member_info = list()
			member_info["name"] = "[M.compose_rank()] [M.real_name]"
			member_info["id"] = "\ref[M]"
			members_info[++members_info.len] = member_info
		squad_info["members"] = members_info
		squads_info[++squads_info.len] = squad_info
	data["squads_info"] = squads_info
	return data

/datum/computer_file/program/squad_manager/ui_act(action, params)
	if(..())
		return TRUE

	var/datum/squad/S = locate(params["squad_id"])
	var/mob/living/carbon/human/M = locate(params["id"])
	switch(action)
		if("message")
			if(!S)
				return FALSE
			var/orders = stripped_input(usr, message="Send a squad-wide message to [S].", max_length=MAX_BROADCAST_LEN)
			if(!orders || length(orders) <= 0)
				return
			log_say("[S]: [usr] transmitted: [orders]")
			S.broadcast(S,orders)
		if("primary_objective")
			if(!S)
				return FALSE
			var/orders = input(usr, "Choose squad role:", "Squad Setup") as null|anything in SQUAD_TYPES
			if(!orders || length(orders) <= 0)
				return
			log_say("[S]: [usr] set primary objective: [orders]")
			S.retask(orders)
			for(var/mob/living/L in S.members)
				to_chat(L, "<span class='sciradio'>[S.primary_objective]</span>")
			ui_update()
		if("secondary_objective")
			if(!S)
				return FALSE
			var/orders = stripped_input(usr, message="Set secondary objective:", max_length=MAX_BROADCAST_LEN, default=S.secondary_objective)
			if(!orders || length(orders) <= 0)
				return
			log_say("[S]: [usr] set secondary objective: [orders]")
			S.secondary_objective = orders
			for(var/mob/living/L in S.members)
				to_chat(L, "<span class='sciradio'>Secondary squad objective: [S.secondary_objective]</span>")
			ui_update()
		if("toggle_access")
			if(!S)
				return FALSE
			S.access_enabled = !S.access_enabled
			log_game("[S]: [usr] set squad's elevated access to [S.access_enabled]")
			S.broadcast(S,"[S.access_enabled ? "Elevated squad access granted." : "Elevated squad access rescinded."]", list('nsv13/sound/effects/notice2.ogg'))
			ui_update()
		if("set_leader")
			if(!M)
				return FALSE
			M.squad.set_leader(M)
			ui_update()
		if("demote_leader")
			if(!M)
				return FALSE
			M.squad.unset_leader(M) // There is a check for whether they're the leader or not, it'll be fine
			ui_update()
		if("transfer")
			if(!M)
				return FALSE
			var/datum/squad/newSquad = input(usr, "Transfer [M]:", "Squad Setup") as null|anything in GLOB.squad_manager.squads
			if(newSquad)
				log_game("[newSquad]: [usr] reassigned [M] to [newSquad]")
				if(M.squad)
					M.squad.remove_member(M)
				newSquad.add_member(M)
			ui_update()
		if("toggle_hidden")
			if(!S)
				return FALSE
			S.hidden = !S.hidden
			ui_update()
		//WE HAVE YOU SURROUNDED, SURRENDER YOUR NERF GUNS
		if("toggle_beararms")
			if(!S)
				return FALSE
			S.weapons_clearance = !S.weapons_clearance
			ui_update()
		if("print_pass")
			if(!S || world.time < next_major_action)
				return FALSE
			next_major_action = world.time + 5 SECONDS //Lower the spam a bit...
			new /obj/item/clothing/neck/squad(get_turf(computer), S)
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
