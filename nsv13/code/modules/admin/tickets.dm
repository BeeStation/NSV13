/client/proc/show_tickets() //Creates a verb for admins to open up the ui
	set category = "Admin"
	set name = "Show tickets"
	set desc = "Shows all active support tickets"
	var/datum/admin_ticket_handler/ticketUI  = new(usr)//create the datum
	ticketUI.ui_interact(usr)//datum has a tgui component, here we open the window

/datum/admin_help
	var/client/administrator = null

/datum/admin_ticket_handler
	var/client/holder = null
	var/datum/admin_help/viewing = null
	var/screen = "home"
	var/last_screen = "home"

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
force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)//ui_interact is called when the client verb is called.

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(screen != last_screen)
		ui.close()
		qdel(ui)
		ui = null
		last_screen = screen
	if(!ui)
		var/window = (screen == "home") ? "admintickets" : "adminticketview"
		ui = new(user, src, ui_key, window, "Ticket Viewer", 560, 600, master_ui, state)
		ui.open()

/datum/admin_ticket_handler/ui_data(mob/user)
	var/list/data = list()
	var/list/ours = list()
	var/list/unclaimed = list()
	var/list/resolved = list()
	var/list/logs = list()
	for(var/datum/admin_help/AH in GLOB.ahelp_tickets.active_tickets)
		if(AH.administrator != holder)
			var/list/info = list()
			info["id"] = AH.id
			info["title"] = AH.name
			info["initiator"] = AH.initiator_key_name
			info["antag_status"] = (AH.initiator.mob.mind && AH.initiator.mob.mind.special_role) ? AH.initiator.mob.mind?.special_role : "Non-antag"
			unclaimed["[AH.id]"] = info
		else //If we own the ticket, otherwise, split it up.
			var/list/info = list()
			info["id"] = AH.id
			info["title"] = AH.name
			info["initiator"] = AH.initiator_key_name
			info["antag_status"] = (AH.initiator.mob.mind && AH.initiator.mob.mind.special_role) ? AH.initiator.mob.mind?.special_role : "Non-antag"
			ours["[AH.id]"] = info
	for(var/datum/admin_help/AH in GLOB.ahelp_tickets.resolved_tickets)
		var/list/info = list()
		info["id"] = AH.id
		info["title"] = AH.name
		info["initiator"] = AH.initiator_key_name
		info["antag_status"] = (AH.initiator.mob.mind && AH.initiator.mob.mind.special_role) ? AH.initiator.mob.mind?.special_role : "Non-antag"
		resolved["[AH.id]"] = info
	if(viewing)
		var/list/info = list()
		info["id"] = viewing.id
		info["title"] = viewing.name
		info["initiator"] = viewing.initiator_key_name
		info["antag_status"] = (viewing.initiator.mob.mind && viewing.initiator.mob.mind.special_role) ? viewing.initiator.mob.mind?.special_role : "Non-antag"
		data["currentInfo"] = info
		var/count = 0
		var/flipflop = FALSE
		for(var/X in viewing._interactions)
			var/colour = flipflop ? "black" : "grey"
			if(findtext(X,"Resolved by"))
				colour = "green"
			else if(findtext(X,"Rejected by"))
				colour = "red"
			else if(findtext(X, "Marked as IC issue by"))
				colour = "Average"
			logs["[count]"] += list("line"=X, "colour"=colour)
			flipflop = !flipflop
			count ++







	data["log"] = logs
	data["screen"] = screen
	data["unclaimed"] = unclaimed
	data["resolved"] = resolved
	return data

/datum/admin_ticket_handler/ui_act(action, params)
	if(..())
		return
	to_chat(world, action)
	switch(action)
		if("view")
			var/desiredID = text2num(params["id"])
			var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(desiredID)
			if(!AH)
				return FALSE
			viewing = AH
			screen = "viewTicket"
		if("back")
			viewing = null
			screen = "home"
		if("re-class")
			var/choice = alert("What do you want to do with this ticket?","Ticket reclassification","IC issue","Mentor issue", "Cancel")
			if(choice == "Cancel")
				return
			var/act = (choice == "Mentor issue") ? "mhelp" : "icissue"
			if(act)
				viewing.Action(act)
				return
	if(viewing)
		viewing.Action(action)