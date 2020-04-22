/client
	var/datum/admin_ticket_handler/ticket_panel = null

/client/proc/show_tickets() //Creates a verb for admins to open up the ui
	set category = "Admin"
	set name = "Show tickets"
	set desc = "Shows all active support tickets"
	ticket_panel  = new(usr)//create the datum
	ticket_panel.ui_interact(usr)//datum has a tgui component, here we open the window

/client/proc/view_ticket(datum/admin_help/AH)
	if(!ticket_panel)
		ticket_panel  = new(usr)
	ticket_panel.viewing = AH
	ticket_panel.ui_interact(usr)
	ticket_panel.screen = "viewTicket"

/datum/admin_ticket_handler
	var/client/holder = null
	var/datum/admin_help/viewing = null
	var/screen = "home"
	var/last_screen = "home"
	var/show_resolved = FALSE

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
	if(screen != last_screen)
		ui.close()
		qdel(ui)
		ui = null
		last_screen = screen
	if(!ui)
		var/window = (screen == "home") ? "admintickets" : "adminticketview"
		ui = new(user, src, ui_key, window, "Ticket Viewer", 510, 600, master_ui, state)
		ui.open()

/datum/admin_ticket_handler/ui_data(mob/user)
	usr = user
	var/list/data = list()
	var/list/ours = list()
	var/list/unclaimed = list()
	var/list/resolved = list()
	var/list/mentor = list()
	var/list/logs = list()
	if(!holder.is_mentor())//If you're not at least a mentor. You shouldn't be able to see this at all... Admins are by default counted as mentors
		return
	for(var/datum/admin_help/AH in GLOB.ahelp_tickets.active_tickets)
		if(AH.administrator != holder)
			var/list/info = list()
			info["id"] = AH.id
			info["title"] = AH.name
			info["initiator"] = AH.initiator_key_name
			info["antag_status"] = (AH.initiator.mob.mind && AH.initiator.mob.mind.special_role) ? AH.initiator.mob.mind?.special_role : "Non-antag"
			info["ours"] = FALSE
			info["open"] = TRUE
			if(AH.tier == "mentor")
				mentor["[AH.id]"] = info
				continue
			if(!check_rights(R_ADMIN)) //Double check that they're..y'know, allowed to see this one.
				continue
			else
				unclaimed["[AH.id]"] = info
		else //If we own the ticket, otherwise, split it up.
			var/list/info = list()
			info["id"] = AH.id
			info["title"] = AH.name
			info["initiator"] = AH.initiator_key_name
			info["antag_status"] = (AH.initiator.mob.mind && AH.initiator.mob.mind.special_role) ? AH.initiator.mob.mind?.special_role : "Non-antag"
			info["ours"] = TRUE
			info["open"] = TRUE
			ours["[AH.id]"] = info
	if(show_resolved)
		for(var/datum/admin_help/AH in GLOB.ahelp_tickets.closed_tickets)
			var/list/info = list()
			info["id"] = AH.id
			info["title"] = AH.name
			info["initiator"] = AH.initiator_key_name
			info["antag_status"] = (AH.initiator.mob.mind && AH.initiator.mob.mind.special_role) ? AH.initiator.mob.mind?.special_role : "Non-antag"
			info["ours"] = FALSE
			info["open"] = FALSE
			if(AH.tier != "mentor")
				if(!check_rights(R_ADMIN)) //Double check that they're..y'know, allowed to see this one.
					continue
			resolved["[AH.id]"] = info
	if(viewing)
		var/list/info = list()
		info["id"] = viewing.id
		info["title"] = viewing.name
		info["initiator"] = viewing.initiator_key_name
		info["antag_status"] = (viewing.initiator.mob.mind && viewing.initiator.mob.mind.special_role) ? viewing.initiator.mob.mind?.special_role : "Non-antag"
		data["currentInfo"] = info
		data["open"] = (viewing.state == AHELP_ACTIVE) ? TRUE : FALSE
		var/count = 0
		var/flipflop = FALSE
		for(var/X in viewing._interactions)
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
	data["show_resolved"] = show_resolved
	data["log"] = logs
	data["screen"] = screen
	data["unclaimed"] = unclaimed
	data["resolved"] = resolved
	data["mentor"] = mentor
	data["ours"] = ours
	return data

/datum/admin_ticket_handler/ui_act(action, params)
	if(..())
		return
	if(!holder.is_mentor())//Admins are by default counted as mentors
		return
	var/desiredID = text2num(params["id"])
	var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(desiredID)
	if(!AH)
		AH = viewing
	var/act = action
	switch(action)
		if("view")
			viewing = AH
			screen = "viewTicket"
			return
		if("back")
			viewing = null
			screen = "home"
			return
		if("re-class")
			var/choice = alert("What do you want to do with this ticket?","Ticket reclassification","IC issue","Mentor issue", "Cancel")
			if(choice == "Cancel")
				return
			act = (choice == "Mentor issue") ? "mhelp" : "icissue"
		if("resolve")
			if(AH.state != AHELP_ACTIVE)
				AH.Action("reopen")
				return
		if("flw")
			var/atom/movable/AM = AH.initiator.mob
			var/client/C = holder
			var/can_ghost = TRUE
			if(!isobserver(holder.mob))
				can_ghost = C.admin_ghost()

			if(!can_ghost)
				return
			var/mob/dead/observer/A = C.mob
			A.ManualFollow(AM)
		if("pp")
			holder.holder.show_player_panel(AH.initiator.mob)
			return
		if("vv")
			holder.debug_variables(AH.initiator.mob)
			return
		if("sm")
			holder.cmd_admin_subtle_message(AH.initiator.mob)
			return
		if("claim")
			if(AH.administrator && AH.administrator == holder)
				AH.administrator = null
				message_admins("[key_name(holder)] has un-claimed ticket #[AH.id]")
				return
			AH.administrator = holder
			message_admins("[key_name(holder)] has claimed ticket #[AH.id]")
			return
		if("toggle_resolved")
			show_resolved = !show_resolved

	if(act)
		if(AH)
			AH.Action(act)
		else
			viewing.Action(act)
	ui_interact(holder)