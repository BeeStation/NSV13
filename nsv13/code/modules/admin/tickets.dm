/client
	var/datum/admin_ticket_handler/ticket_panel = null

/client/proc/show_tickets() //Creates a verb for admins to open up the ui
	set category = "Tickets"
	set name = "Show tickets"
	set desc = "Shows all active support tickets"
	ticket_panel  = new(usr)//create the datum
	ticket_panel.ui_interact(usr)//datum has a tgui component, here we open the window

/client/proc/view_ticket(datum/admin_help/AH)
	if(!ticket_panel)
		ticket_panel  = new(usr)
	ticket_panel.ui_interact(usr)
	ticket_panel.screen = "viewTicket"

/datum/admin_ticket_handler
	var/client/holder = null
	var/screen = "home"
	var/list/screens = list()
	var/last_screen = "home"
	var/show_resolved = FALSE
	var/datum/tgui/home = null

/datum/admin_ticket_handler/New(H)
	if (istype(H,/client))
		var/client/C = H
		holder = C //if its a client, assign it to holder
	else
		var/mob/M = H
		holder = M.client //if its a mob, assign the mob's client to holder
	if(!holder)
		message_admins("Invalid ticket panel created with no client attached. Aborting.")
		return

/datum/admin_ticket_handler/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, \
force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.mentor_state)//ui_interact is called when the client verb is called.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui || QDELETED(ui))
		ui = new(user, src, ui_key, "admintickets", "Ticket Viewer", 520, 600, master_ui, state)
		home = ui
		ui.open()

/datum/admin_ticket_handler/ui_data(mob/user)
	usr = user
	var/list/data = list()
	var/list/ours = list()
	var/list/unclaimed = list()
	var/list/resolved = list()
	var/list/active = list()
	var/list/mentor = list()
	if(!holder.is_mentor())//If you're not at least a mentor. You shouldn't be able to see this at all... Admins are by default counted as mentors
		return
	for(var/datum/admin_help/AH in GLOB.ahelp_tickets.all_tickets)
	{
		var/list/info = list()
		info["id"] = "[AH.id] ([capitalize(AH.tier)])"
		info["title"] = AH.name
		info["initiator"] = AH.initiator_key_name
		info["antag_status"] = (AH.initiator.mob.mind && AH.initiator.mob.mind.special_role) ? AH.initiator.mob.mind?.special_role : "Non-antag"
		info["ours"] = (AH.administrator == holder) ? TRUE : FALSE
		info["open"] = (AH.state == AHELP_ACTIVE)
		info["isAdmin"] = check_rights(R_ADMIN, 0)
		if(info["open"])
			if(AH.administrator)
				if(AH.administrator == holder)
					ours["[AH.id]"] = info
				if(!check_rights(R_ADMIN, 0)) //Double check that they're..y'know, allowed to see this one.
					if(AH.tier == "mentor") //If theyre a mentor, and this is a mentor ticket, let them see it. Otherwise, it's an admin ticket, that they shouldn't be able to see.
						active["[AH.id]"] = info
						continue
				else
					active["[AH.id]"] = info
			else
				if(AH.tier == "mentor")
					mentor["[AH.id]"] = info
					continue
				if(!check_rights(R_ADMIN, 0)) //Double check that they're..y'know, allowed to see this one.
					continue
				unclaimed["[AH.id]"] = info
		else if(show_resolved)
			resolved["[AH.id]"] = info
	}
	data["show_resolved"] = show_resolved
	data["screen"] = screen
	data["unclaimed"] = unclaimed
	data["resolved"] = resolved
	data["mentor"] = mentor
	data["ours"] = ours
	data["active"] = active
	return data

/datum/admin_help/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, \
force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.mentor_state)//ui_interact is called when the client verb is called.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "adminticketview", "Ticket Viewer", 520, 600, master_ui, state)
		ui.open()

/datum/admin_help/ui_data(mob/user)
	usr = user
	var/list/data = list()
	var/client/C = (istype(user, /client)) ? user : user.client
	data["id"] = "[id] ([capitalize(tier)])"
	data["title"] = name
	data["initiator"] = initiator_key_name
	data["ours"] = (administrator == C) ? TRUE : FALSE
	data["open"] = (state == AHELP_ACTIVE)
	data["isAdmin"] = check_rights(R_ADMIN, 0)
	var/count = 0
	var/flipflop = FALSE
	var/list/logs = list()
	for(var/X in _interactions)
	{
		var/colour = flipflop ? "black" : "#696969"
		if(findtext(X,"Resolved by"))
			colour = "green"
		else if(findtext(X, "Rejected by"))
			colour = "red"
		else if(findtext(X, "Closed by"))
			colour = "red"
		else if(findtext(X, "Marked as IC issue by"))
			colour = "Average"
		logs["[count]"] += list("line"=X, "colour"=colour)
		flipflop = !flipflop
		count ++
	}
	data["logs"] = logs
	return data

/datum/admin_help/ui_act(action, params)
	if(..())
		return
	try_action(action, usr)

/datum/admin_help/proc/toggle_claim(client/C)
	if(administrator && administrator == C)
		administrator = null
		message_admins("[key_name(usr)] has un-claimed ticket #[id]")
		return
	administrator = C
	message_admins("[key_name(usr)] has claimed ticket #[id]")
	return

/mob/proc/mentor_me() //Simple bodge fix to get mentor status when you're deadminned for testing purposes. Why didn't we have this before urgh.
	var/client/C = client
	if(!C.mentor_datum)
		new /datum/mentors(C.ckey)
	C.mentor_datum.owner = C
	C.add_mentor_verbs()


/datum/admin_help/proc/try_action(action, client/user)
	var/client/C = (istype(usr, /client.)) ? usr : usr.client
	if(!C.is_mentor())//Admins are by default counted as mentors
		return
	switch(action)
		if("re-class")
			var/choice = alert("What do you want to do with this ticket?","Ticket reclassification","IC issue","[(tier == "admin") ? "Mentor issue" : "Admin issue"]", "Cancel")
			if(choice == "Cancel")
				return
			var/act = (choice == "Mentor issue" || choice == "Admin issue") ? "mhelp" : "icissue"
			Action(act)
			return
		if("resolve")
			if(state != AHELP_ACTIVE)
				Action("reopen")
				return
			else
				Action("resolve")
				return
		if("flw")
			var/atom/movable/AM = initiator.mob
			var/can_ghost = TRUE
			if(!isobserver(C.mob))
				can_ghost = C.admin_ghost()

			if(!can_ghost)
				return
			var/mob/dead/observer/A = C.mob
			A.ManualFollow(AM)
		if("pp")
			C.holder.show_player_panel(initiator.mob)
			return
		if("vv")
			C.debug_variables(initiator.mob)
			return
		if("sm")
			C.cmd_admin_subtle_message(initiator.mob)
			return
	Action(action)

/datum/admin_ticket_handler/ui_act(action, params)
	if(..())
		return
	if(!holder.is_mentor())//Admins are by default counted as mentors
		return
	var/desiredID = text2num(params["id"])
	var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(desiredID)
	var/act = action
	switch(action)
		if("view")
			AH.ui_interact(usr)
			return
		if("toggle_resolved")
			show_resolved = !show_resolved
			return
	AH.try_action(act, holder)