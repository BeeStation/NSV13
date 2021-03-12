/*
Syndicate will eventually become a subtype of the regular comms console with a new TGUI for that aswell, but for now we'll keep it seperate
Keep in mind you'll have to change all typepaths to use computer/communications instead of computer/syndiecommunications

/obj/machinery/computer/communications
	name = "communications console"
	desc = "A console used for high-priority announcements and emergencies."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_BLUE
	circuit = /obj/item/circuitboard/computer/communications

	req_access = list(ACCESS_HEADS) //Who can log in?

	var/list/comm_message/messages = list() //CC messages to us
	var/datum/comm_message/currmsg //Currently viewed message
	var/datum/comm_message/aicurrmsg 

	var/message_cooldown = 0 //Time since last announcement
	var/ai_message_cooldown = 0

	var/tmp_alertlevel = 0 //Alert level

	var/stat_msg1 //Custom status display
	var/stat_msg2 

	var/authenticated = null //Who is logged in

	var/syndie = 0
*/

//Syndicate communications console
/obj/machinery/computer/syndiecommunications
	name = "communications console"
	desc = "A console used for high-priority announcements and emergencies."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = LIGHT_COLOR_RED
	circuit = /obj/item/circuitboard/computer/syndiecommunications

	req_access = list(ACCESS_SYNDICATE)

	var/list/comm_message/messages = list()
	var/datum/comm_message/currmsg

	var/message_cooldown = 0
	var/tmp_alertlevel = 0

	var/stat_msg1
	var/stat_msg2

	var/authenticated = null
	var/auth_id = "Error"

	var/syndie = 1

/obj/machinery/computer/syndiecommunications/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui && syndie)
		ui = new(user, src, ui_key, "SyndieCommunications", "[name]", 400, 600, master_ui, state)
		ui.open()
	else if(!ui)
		ui = new(user, src, ui_key, "Communications", "[name]", 400, 600, master_ui, state)
		ui.open()

/obj/machinery/computer/syndiecommunications/ui_data(mob/user)
	var/list/data = list()
	data["authenticated"] = authenticated
	if(authenticated)
		data["auth_id"] = auth_id
	return data

/obj/machinery/computer/syndiecommunications/ui_static_data(mob/user)
	var/list/data = list()
	

/obj/machinery/computer/syndiecommunications/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	switch(action)
		if("login")
			var/mob/M = usr
			var/obj/item/card/id/I = M.get_idcard(TRUE)

			if(I && istype(I))
				if(check_access(I))
					authenticated = 1
					auth_id = "[I.registered_name] ([I.assignment])"
					if((20 in I.access))
						authenticated = 2
					playsound(src, 'sound/machines/terminal_on.ogg', 50, 0)
		if("logout")
			authenticated = 0
			playsound(src, 'sound/machines/terminal_off.ogg', 50, 0)