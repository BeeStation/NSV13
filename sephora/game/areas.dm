/area
	var/looping_ambience = null //If you want an ambient sound to play on loop while theyre in a specific area, set this
	var/obj/structure/overmap/linked_overmap = null //For relaying damage etc. to the interior.

/area/maintenance
	looping_ambience = 'sephora/sound/ambience/maintenance.ogg'
	ambientsounds = list('sephora/sound/ambience/leit_motif.ogg')

/area/medical
	looping_ambience = 'sephora/sound/ambience/medbay.ogg'
	ambientsounds = list()

/area/ai_monitored
	looping_ambience = 'sephora/sound/ambience/computer_core.ogg'
	ambientsounds = list()

/area/bridge
	looping_ambience = 'sephora/sound/ambience/bridge.ogg'
	ambientsounds = list()

/area/Entered(atom/movable/M)
	// Ambience goes down here -- make sure to list each area separately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_AREA_ENTERED, M)
	SEND_SIGNAL(M, COMSIG_ENTER_AREA, src) //The atom that enters the area
	if(ismob(M) && linked_overmap)
		linked_overmap.mobs_in_ship += M
	if(!isliving(M))
		return

	var/mob/living/L = M
	if(!L.ckey)
		return
	if(!looping_ambience)
		return
	if(L.client && L.client.prefs.toggles & SOUND_SHIP_AMBIENCE)
		L.client.ambience_playing = 1
		SEND_SOUND(L, sound(looping_ambience, repeat = 1, wait = 0, volume = 100, channel = CHANNEL_BUZZ))
	if(linked_overmap)
		var/progress = linked_overmap.obj_integrity
		var/goal = linked_overmap.max_integrity
		progress = CLAMP(progress, 0, goal)
		progress = round(((progress / goal) * 100), 50)//If the ship goes below 50% health, we start creaking like mad.
		if(progress <= 50)
			var/list/creaks = list('sephora/sound/ambience/ship_damage/creak1.ogg','sephora/sound/ambience/ship_damage/creak2.ogg','sephora/sound/ambience/ship_damage/creak3.ogg','sephora/sound/ambience/ship_damage/creak4.ogg','sephora/sound/ambience/ship_damage/creak5.ogg')
			var/creak = pick(creaks)
			SEND_SOUND(L, sound(creak, repeat = 0, wait = 0, volume = 100, channel = CHANNEL_AMBIENCE))
			return
	if(prob(35))
		if(!ambientsounds.len)
			return
		var/sound = pick(ambientsounds)

		if(!L.client.played)
			SEND_SOUND(L, sound(sound, repeat = 0, wait = 0, volume = 25, channel = CHANNEL_AMBIENCE))
			L.client.played = TRUE
			addtimer(CALLBACK(L.client, /client/proc/ResetAmbiencePlayed), 600)

/area/Exited(atom/movable/M)
	SEND_SIGNAL(src, COMSIG_AREA_EXITED, M)
	SEND_SIGNAL(M, COMSIG_EXIT_AREA, src) //The atom that exits the area
	if(ismob(M) && linked_overmap)
		linked_overmap.mobs_in_ship -= M
	if(!isliving(M))
		return

	var/mob/living/L = M
	if(!L.ckey)
		return
	L.client.ResetAmbiencePlayed()
	L.client.ambience_playing = 0
	if(L.client && !L.client.ambience_playing && L.client.prefs.toggles & SOUND_SHIP_AMBIENCE)
		L.client.ambience_playing = 1
		SEND_SOUND(L, sound('sephora/sound/ambience/shipambience.ogg', repeat = 1, wait = 0, volume = 80, channel = CHANNEL_BUZZ))