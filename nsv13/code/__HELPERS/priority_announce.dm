/proc/gq_announce(message, title = "Attention:")
	if(!message)
		return

	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.can_hear())
			to_chat(M, "<span class='big bold'><font color = red>[html_encode(title)]</font color><BR>[html_encode(message)]</span><BR>")
			if(M.client.prefs.toggles & SOUND_ANNOUNCEMENTS)
				SEND_SOUND(M, sound('nsv13/sound/effects/ship/action_stations.ogg'))

/area
	var/redalert = FALSE //General quarters active?

/proc/toggle_gq_lights(state)
	for(var/X in GLOB.teleportlocs) //Update the lights
		var/area/AR = GLOB.teleportlocs[X]
		if(AR.redalert == state)
			continue
		AR.redalert = state
		spawn(0) //We're branching here so that looping through the areas doesnt depend on the lighting loop finishing. Makes me wish for multithreading :(
		for(var/obj/machinery/light/L in AR)
			L.update()