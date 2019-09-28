/client/verb/looc(msg as text)
	set name = "LOOC"
	set category = "OOC"
	set desc = "Local OOC, seen only by those in view."

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)
		return

	if(IsGuestKey(key))
		to_chat(src, "<span class='warning'>Guests may not use OOC.</span>")
		return

	if(istype(mob, /mob/dead/observer))
		if(!holder)
			to_chat(src, "<span class='warning'>Ghosts cannot use LOOC.</span>")
			return

	if(isliving(mob))
		var/mob/living/L = mob
		if(L.health < 0)
			to_chat(src, "<span class='warning'>LOOC doesn't work while you're in crit.</span>")
			return

		if(L.stat != CONSCIOUS)
			to_chat(src, "<span class='warning>Nice try.</span>")
			return

	if(!holder)
		if(!GLOB.looc_allowed)
			to_chat(src, "<span class='danger'>LOOC is globally muted.</span>")
			return
		if(!GLOB.dlooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>LOOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='danger'>You cannot use LOOC (muted).</span>")
			return

	if(is_banned_from(ckey, "OOC"))
		to_chat(src, "<span class='danger'>You have been banned from LOOC.</span>")
		return

	if(QDELETED(src))
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	var/raw_msg = msg

	if(!msg)
		return

	msg = emoji_parse(msg)

	if((copytext(msg, 1, 2) in list(".",";",":","#")) || (findtext(lowertext(copytext(msg, 1, 5)), "say")))
		if(alert("Your message \"[raw_msg]\" looks like it was meant for in game communication, say it in LOOC?", "Meant for LOOC?", "No", "Yes") != "Yes")
			return

	if(!(prefs.chat_toggles & CHAT_LOOC))
		to_chat(src, "<span class='danger'>You have LOOC muted.</span>")
		return


	mob.log_talk(raw_msg, LOG_LOOC)
	mob.log_message("[key]: [raw_msg]", INDIVIDUAL_LOOC_LOG)


	var/list/clients_to_hear = list()
	var/turf/looc_source = get_turf(mob.get_looc_source())
	var/list/stuff_that_hears = list()
	for(var/mob/M in get_hear(7, looc_source))
		stuff_that_hears += M

	for(var/mob/M in stuff_that_hears)
		if((((M.client_mobs_in_contents) && (M.client_mobs_in_contents.len <= 0)) || !M.client_mobs_in_contents))
			continue

		if(M.client && M.client.prefs.chat_toggles & CHAT_LOOC)
			clients_to_hear += M.client

		for(var/mob/mob in M.client_mobs_in_contents)
			if(mob.client && mob.client.prefs && mob.client.prefs.chat_toggles & CHAT_LOOC)
				clients_to_hear += mob.client

	var/message_admin = "<span class='looc'>LOOC: [ADMIN_LOOKUPFLW(mob)]: [msg]</span>"
	var/message_admin_remote = "<span class='looc'><font color='black'>(R)</font>LOOC: [ADMIN_LOOKUPFLW(mob)]: [msg]</span>"
	var/message_regular
	if(isobserver(mob)) //if you're a spooky ghost
		var/key_to_print = mob.key
		if(holder && holder.fakekey)
			key_to_print = holder.fakekey //stealthminning

		message_regular = "<span class='looc'>LOOC: [key_to_print]: [msg]</span>"
	else
		message_regular = "<span class='looc'>LOOC: [mob.name]: [msg]</span>"

	for(var/T in GLOB.clients)
		var/client/C = T
		if(C in GLOB.admins)
			if(C in clients_to_hear)
				to_chat(C, message_admin)
			else
				to_chat(C, message_admin_remote)

		else if(C in clients_to_hear)
			to_chat(C, message_regular)

/mob/proc/get_looc_source()
	return src

/mob/living/silicon/ai/get_looc_source()
	if(eyeobj)
		return eyeobj

	return src

/proc/toggle_looc(toggle = null)
	if(toggle != null) //if we're specifically en/disabling ooc
		if(toggle != GLOB.looc_allowed)
			GLOB.looc_allowed = toggle
		else
			return
	else //otherwise just toggle it
		GLOB.looc_allowed = !GLOB.looc_allowed
	to_chat(world, "<B>The LOOC channel has been globally [GLOB.looc_allowed ? "enabled" : "disabled"].</B>")

/proc/toggle_dlooc(toggle = null)
	if(toggle != null)
		if(toggle != GLOB.dlooc_allowed)
			GLOB.dlooc_allowed = toggle
		else
			return
	else
		GLOB.dlooc_allowed = !GLOB.dlooc_allowed

/client/proc/get_looc()
	var/msg = input(src, null, "looc \"text\"") as text|null
	looc(msg)