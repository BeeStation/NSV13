// LOOC ported from Citadel, styling in stylesheet.dm and browseroutput.css

//GLOBAL_VAR_INIT(looc_allowed, 1) //commenting this out might break something but w/e, replaced by one in global config by nsv13

/client/verb/looc(msg as text)
    set name = "LOOC"
    set desc = "Local OOC, seen only by those in view."
    set category = "OOC"

    if(GLOB.say_disabled)    //This is here to try to identify lag problems
        to_chat(usr, "<span class='danger'> Speech is currently admin-disabled.</span>")
        return

    if(!mob)        return
    if(!mob.ckey)   return

    msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
    var/raw_msg = msg

    if(!msg)
        return

    if(!(prefs.chat_toggles & CHAT_LOOC)) //nsv13 - toggles -> chat_toggles, CHAT_OOC -> CHAT_LOOC
        to_chat(src, "<span class='danger'>You have LOOC muted.</span>")
        return

    if(is_banned_from(mob.ckey, "OOC"))
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
        if(handle_spam_prevention(msg,MUTE_LOOC)) //nsv13 - MUTE_OOC -> MUTE_LOOC
            return
        if(findtext(msg, "byond://"))
            to_chat(src, "<B>Advertising other servers is not allowed.</B>")
            log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
            return
        if(mob.stat)
            to_chat(src, "<span class='danger'>You cannot salt in LOOC while unconscious or dead.</span>")
            return
        if(istype(mob, /mob/dead))
            to_chat(src, "<span class='danger'>You cannot use LOOC while ghosting.</span>")
            return

        if(OOC_FILTER_CHECK(raw_msg))
            to_chat(src, "<span class='warning'>That message contained a word prohibited in OOC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ooc_chat'>\"[raw_msg]\"</span></span>")
            return

    msg = emoji_parse(msg)

    mob.log_talk(raw_msg, LOG_OOC, tag="LOOC")

    var/list/heard = hearers(7, get_top_level_mob(src.mob))

	//NSV13 - AI QoL - Start
	//so the ai can post looc text
    if(istype(mob, /mob/living/silicon/ai))
        var/mob/living/silicon/ai/ai = mob
        heard = hearers(7, get_top_level_mob(ai.eyeobj))
	//so the ai can see looc text
    for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
        if(ai.client && !(ai in heard) && (ai.eyeobj in heard))
            heard += ai
	//NSV13 - AI QoL - Stop

    for(var/mob/M as() in heard)
        if(!M.client)
            continue
        var/client/C = M.client
        if (C in GLOB.admins)
            continue //they are handled after that

        if (isobserver(M))
            continue //Also handled later.

        if(C.prefs.chat_toggles & CHAT_LOOC) //nsv13 - toggles -> chat_toggles, CHAT_OOC -> CHAT_LOOC
//            var/display_name = src.key
//            if(holder)
//                if(holder.fakekey)
//                    if(C.holder)
//                        display_name = "[holder.fakekey]/([src.key])"
//                else
//                    display_name = holder.fakekey
            to_chat(C,"<span class='looc'><span class='prefix'>LOOC:</span> <EM>[src.mob.name]:</EM> <span class='message'>[msg]</span></span>")

    for(var/client/C in GLOB.admins)
        if(C.prefs.chat_toggles & CHAT_LOOC) //nsv13 - toggles -> chat_toggles, CHAT_OOC -> CHAT_LOOC
            var/prefix = "(R)LOOC"
            if (C.mob in heard)
                prefix = "LOOC"
            to_chat(C,"<span class='looc'>[ADMIN_FLW(usr)]<span class='prefix'>[prefix]:</span> <EM>[src.key]/[src.mob.name]:</EM> <span class='message'>[msg]</span></span>")

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

/mob/proc/update_flavor_text()
	set src in usr

	if(usr != src)
		usr << "No."
	var/msg = sanitize(input(usr,"Set the flavor text in your 'examine' verb. Can also be used for OOC notes about your character.","Flavour Text",html_decode(flavour_text)) as message|null)

	if(msg)
		msg = copytext(msg, 1, MAX_MESSAGE_LEN)
		msg = html_encode(msg)

		flavour_text = msg

/mob/proc/warn_flavor_changed()
	if(flavour_text && flavour_text != "") // don't spam people that don't use it!
		src << "<h2 class='alert'>OOC Warning:</h2>"
		src << "<span class='alert'>Your flavor text is likely out of date! <a href='byond://?src=\ref[src];flavor_change=1'>Change</a></span>"

/mob/proc/print_flavor_text()
	if(flavour_text && flavour_text != "")
		var/msg = replacetext(flavour_text, "\n", " ")
		if(length(msg) <= 100)
			return "<span class='notice'>[msg]</span>"
		else
			return "<span class='notice'>[copytext(msg, 1, 97)]... <a href=\"byond://?src=\ref[src];flavor_more=1\">More...</span></a>"

//Needed for LOOC and flavour text

/mob/proc/get_top_level_mob()
    if(istype(src.loc,/mob)&&src.loc!=src)
        var/mob/M=src.loc
        return M.get_top_level_mob()
    return src

/proc/get_top_level_mob(var/mob/S)
    if(istype(S.loc,/mob)&&S.loc!=S)
        var/mob/M=S.loc
        return M.get_top_level_mob()
    return S
