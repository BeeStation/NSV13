// LOOC ported from Citadel, styling in stylesheet.dm and browseroutput.css

//GLOBAL_VAR_INIT(looc_allowed, 1) //commenting this out might break something but w/e, replaced by one in global config by nsv13

/client/verb/looc(msg as text)
	set name = "LOOC"
	set desc = "Local OOC, seen only by those in view."
	set category = "OOC"

	if(GLOB.say_disabled)    //This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'> Speech is currently admin-disabled.</span>")
		return

	if(!mob?.ckey)
		return

	msg = trim(sanitize(msg), MAX_MESSAGE_LEN)
	if(!length(msg))
		return

	var/raw_msg = msg

	if(!(prefs.chat_toggles & CHAT_LOOC)) //nsv13 - toggles -> chat_toggles, CHAT_OOC -> CHAT_LOOC
		to_chat(src, "<span class='danger'>You have LOOC muted.</span>")
		return

	if(is_banned_from(mob.ckey, BAN_OOC))
		to_chat(src, "<span class='danger'>You have been banned from OOC and LOOC.</span>")
		return

	if(!holder)
		if(!GLOB.looc_allowed) //nsv13 - ooc_allowed -> looc_allowed
			to_chat(src, "<span class='danger'>LOOC is globally muted.</span>")
			return
		if(!GLOB.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>LOOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_LOOC) //nsv13 - MUTE_OOC -> MUTE_LOOC
			to_chat(src, "<span class='danger'>You cannot use LOOC (muted).</span>")
			return
		if(handle_spam_prevention(msg, MUTE_LOOC)) //nsv13 - MUTE_OOC -> MUTE_LOOC
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<span class='bold danger'>Advertising other servers is not allowed.</span>")
			log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
			return
		if(mob.stat)
			to_chat(src, "<span class='danger'>You cannot salt in LOOC while unconscious or dead.</span>")
			return
		if(isdead(mob))
			to_chat(src, "<span class='danger'>You cannot use LOOC while ghosting.</span>")
			return

		if(OOC_FILTER_CHECK(raw_msg))
			to_chat(src, "<span class='warning'>That message contained a word prohibited in OOC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ooc_chat'>\"[raw_msg]\"</span></span>")
			return

	msg = emoji_parse(msg)

	mob.log_talk(raw_msg, LOG_OOC, tag="LOOC")

	// Search everything in the view for anything that might be a mob, or contain a mob.
	var/list/client/targets = list()
	var/list/turf/in_view = list()
	//NSV13 - AI QoL - Start
	//so the ai can post looc text
	if(istype(mob, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/ai = mob
		for(var/turf/viewed_turf in view(get_turf(ai.eyeobj)))
			in_view[viewed_turf] = TRUE
	else
		for(var/turf/viewed_turf in view(get_turf(mob)))
			in_view[viewed_turf] = TRUE
	//NSV13 - AI QoL - Stop
	for(var/client/client in GLOB.clients)
		if(!client.mob || !(client.prefs.chat_toggles & CHAT_LOOC) || (client in GLOB.admins)) //nsv13 - toggles -> chat_toggles, CHAT_OOC -> CHAT_LOOC
			continue
		//NSV13 - LOOC AI Stuff - Start
		if(istype(client.mob, /mob/living/silicon/ai))
			var/mob/living/silicon/ai/ai = client.mob
			if(in_view[get_turf(ai.eyeobj)])
				targets |= client
				to_chat(client, "<span class='looc'><span class='prefix'>LOOC:</span> <EM><span class='name'>[mob.name]</span>:</EM> <span class='message'>[msg]</span></span>", avoid_highlighting = (client == src))
		else if(in_view[get_turf(client.mob)]) //NSV13 - LOOC AI Stuff - Stop
			targets |= client
			to_chat(client, "<span class='looc'><span class='prefix'>LOOC:</span> <EM><span class='name'>[mob.name]</span>:</EM> <span class='message'>[msg]</span></span>", avoid_highlighting = (client == src))

	for(var/client/client in GLOB.admins)
		if(!(client.prefs.chat_toggles & CHAT_LOOC)) //nsv13 - toggles -> chat_toggles, CHAT_OOC -> CHAT_LOOC
			continue
		var/prefix = "[(client in targets) ? "" : "(R)"]LOOC"
		to_chat(client, "<span class='looc'><span class='prefix'>[prefix]:</span> <EM>[ADMIN_LOOKUPFLW(mob)]:</EM> <span class='message'>[msg]</span></span>", avoid_highlighting = (client == src))

/proc/toggle_looc(toggle = null) //nsv13 - adds a toggle for looc
	if(toggle != null) //if we're specifically en/disabling looc
		if(toggle != GLOB.looc_allowed)
			GLOB.looc_allowed = toggle
		else
			return
	else //otherwise just toggle it
		GLOB.looc_allowed = !GLOB.looc_allowed

/proc/log_looc(text)
	if (CONFIG_GET(flag/log_ooc))
		WRITE_FILE(GLOB.world_game_log, "\[[time_stamp()]]LOOC: [text]")

////////////////////FLAVOUR TEXT NSV13////////////////////
/mob
	var/flavour_text = ""
//NSV13 - flavour text - Don't think this thing actually does anything - END
