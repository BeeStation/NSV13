/proc/gq_announce(message, sound='nsv13/sound/effects/ship/action_stations.ogg')
	if(!message)
		return

	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.can_hear())
			to_chat(M, "<span class='big bold'><font color = red>[html_encode("Attention:")]</font color><BR>[html_encode(message)]</span><BR>")
			if(M.client.prefs.toggles & PREFTOGGLE_SOUND_ANNOUNCEMENTS)
				SEND_SOUND(M, sound(sound))

/area
	var/redalert = FALSE //General quarters active?

/proc/toggle_gq_lights(state)
	for(var/X in GLOB.teleportlocs) //Update the lights
		var/area/AR = GLOB.teleportlocs[X]
		if(AR.redalert == state)
			continue
		AR.redalert = state
		for(var/obj/machinery/light/L in AR)
			L.update()

/proc/mini_announce(message, from, html_encode = TRUE) //Even less obtrusive than minor_announce!
	if(!message)
		return
	if (html_encode)
		from = html_encode(from)
		message = html_encode(message)
	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.can_hear())
			var/complete_msg = "<meta charset='UTF-8'><h3>[from]</h3><span class='danger'>[message]</span><BR>"
			to_chat(M, complete_msg)
