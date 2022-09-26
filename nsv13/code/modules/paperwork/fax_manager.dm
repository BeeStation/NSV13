GLOBAL_DATUM_INIT(fax_manager, /datum/fax_manager, new)

/**
 * Fax Request Manager
 *
 * In its functionality it is similar to the usual Request Manager, but respectively for faxes.
 * This manager allows you to send faxes on behalf of certain virtual faxes to all existing faxes,
 * as well as receive faxes in their name from the players.
 */
/datum/fax_manager
	/// A list that contains faxes from players and other related information. You can view the filling of its fields in the procedure receive_request.
	var/list/requests = list()
	//var/icon/img = null
	//var/photo_file

/datum/fax_manager/Destroy(force, ...)
	QDEL_LIST(requests)
	return ..()

/datum/fax_manager/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FaxManager")
		ui.open()

/datum/fax_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/fax_manager/ui_static_data(mob/user)
	var/list/data = list()
	//Record additional faxes on a separate list
	data["additional_faxes"] = GLOB.additional_faxes_list + GLOB.syndicate_faxes_list
	return data

/datum/fax_manager/ui_data(mob/user)
	var/list/data = list()
	//Record a list of all existing faxes.
	for(var/obj/machinery/fax/FAX in GLOB.machines)
		var/list/fax_data = list()
		fax_data["fax_name"] = FAX.fax_name
		fax_data["fax_id"] = FAX.fax_id
		fax_data["syndicate_network"] = FAX.syndicate_network
		data["faxes"] += list(fax_data)
	for(var/list/REQUEST in requests)
		var/list/request = list()
		//var/photo_ID = null
		//if(REQUEST["img"] != null)
		//	var/tattletail = "tmp_photo"+REQUEST["id_message"]+".png"
		//	user << browse_rsc(REQUEST["img"], tattletail)
		//	photo_ID = tattletail
		request["id_message"] = REQUEST["id_message"]
		request["time"] = REQUEST["time"]
		var/mob/sender = REQUEST["sender"]
		request["sender_name"] = sender.name
		request["sender_fax_id"] = REQUEST["sender_fax_id"]
		request["sender_fax_name"] = REQUEST["sender_fax_name"]
		request["receiver_fax_name"] = REQUEST["receiver_fax_name"]
		//request["photo"] = photo_ID
		data["requests"] += list(request)
	return data

/datum/fax_manager/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/datum/admins/admin_datum = GLOB.admin_datums[usr.ckey]

	switch(action)
		if("send")
			for(var/obj/machinery/fax/FAX in GLOB.machines)
				if(FAX.fax_id == params["fax_id"])
					var/obj/item/paper/paper = new()
					paper.setText(params["message"])
					FAX.receive(paper, params["fax_name"])
					return TRUE
		if("flw_fax")
			for(var/obj/machinery/fax/FAX in GLOB.machines)
				if(FAX.fax_id == params["fax_id"])
					admin_datum.admin_follow(FAX)
					return TRUE
		if("read_message")
			var/list/REQUEST = get_request(params["id_message"])
			var/obj/item/paper/request/paper = REQUEST["paper"]
			paper.ui_interact(usr)
			return TRUE
		if("flw")
			var/list/REQUEST = get_request(params["id_message"])
			admin_datum.admin_follow(REQUEST["sender"])
			return TRUE
		if("pp")
			var/list/REQUEST = get_request(params["id_message"])
			usr.client.holder.show_player_panel(REQUEST["sender"])
			return TRUE
		if("vv")
			var/list/REQUEST = get_request(params["id_message"])
			usr.client.debug_variables(REQUEST["sender"])
			return TRUE
		if("sm")
			var/list/REQUEST = get_request(params["id_message"])
			usr.client.cmd_admin_subtle_message(REQUEST["sender"])
			return TRUE
		if("logs")
			var/list/REQUEST = get_request(params["id_message"])
			if(!ismob(REQUEST["sender"]))
				to_chat(usr, "This can only be used on instances of type /mob.")
				return TRUE
			show_individual_logging_panel(REQUEST["sender"], null, null)
			return TRUE
		if("smite")
			var/list/REQUEST = get_request(params["id_message"])
			if(!check_rights(R_FUN))
				to_chat(usr, "Insufficient permissions to smite, you require +FUN")
				return TRUE
			var/mob/living/carbon/human/H = REQUEST["sender"]
			if (!H || !istype(H))
				to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
				return TRUE
			usr.client.smite(H)
			return TRUE

/datum/fax_manager/proc/get_request(id_message)
	for(var/list/REQUEST in requests)
		if(REQUEST["id_message"] == id_message)
			return REQUEST

/datum/fax_manager/proc/receive_request(mob/sender, obj/machinery/fax/sender_fax, receiver_fax_name, obj/item/recieve, receiver_color)
	var/list/request = list()
	request["id_message"] = requests.len
	request["time"] = gameTimestamp()
	request["sender"] = sender
	request["sender_fax_id"] = sender_fax.fax_id
	request["sender_fax_name"] = sender_fax.fax_name
	request["receiver_fax_name"] = receiver_fax_name
	if(istype(recieve, /obj/item/paper))
		var/obj/item/paper/paper = recieve
		var/obj/item/paper/request/message = new()
		message.copy_properties(paper)
		request["paper"] = message
	//if(picture)
	//	request["img"] = picture.picture_image
	//	request["photo_file"] = save_photo(picture.picture_image)
	requests += list(request)
	var/msg = "<span class='adminnotice'><b><font color=[receiver_color]>[sanitize(receiver_fax_name)] fax</font> received a message from [sanitize(sender_fax.fax_name)][ADMIN_JMP(sender_fax)]/[ADMIN_FULLMONTY(sender)]</b></span>"
	to_chat(GLOB.admins, msg)
	for(var/client/admin in GLOB.admins)
		if((admin.prefs.chat_toggles & CHAT_PRAYER) && (admin.prefs.toggles & SOUND_PRAYERS))
			SEND_SOUND(admin, sound('sound/items/poster_being_created.ogg'))

/*
/datum/fax_manager/proc/save_photo(icon/photo)
	var/photo_file = copytext_char(md5("\icon[photo]"), 1, 6)
	if(!fexists("[GLOB.log_directory]/photos/[photo_file].png"))
		//Clean up repeated frames
		var/icon/clean = new /icon()
		clean.Insert(photo, "", SOUTH, 1, 0)
		fcopy(clean, "[GLOB.log_directory]/photos/[photo_file].png")
	return photo_file
*/
// A special piece of paper for the administrator that will open the interface no matter what.
/obj/item/paper/request/ui_status()
	return UI_INTERACTIVE

// I'm sure there's a better way to transfer it, I just couldn't find it
/obj/item/paper/request/proc/copy_properties(obj/item/paper/paper)
	info = paper.info
	color = paper.color
	stamps = paper.stamps
	stamped = paper.stamped.Copy()
	form_fields = paper.form_fields.Copy()
	field_counter = paper.field_counter
