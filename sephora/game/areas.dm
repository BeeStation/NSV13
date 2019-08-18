/client/var/last_ambience = null

/area
	var/looping_ambience = 'sephora/sound/ambience/shipambience.ogg' //If you want an ambient sound to play on loop while theyre in a specific area, set this. Defaults to the classic "engine rumble"
	var/obj/structure/overmap/linked_overmap = null //For relaying damage etc. to the interior.

/area/space
	looping_ambience = null

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

/area/science
	looping_ambience = 'sephora/sound/ambience/computer_core.ogg'
	ambientsounds = list()

/area/crew_quarters/dorms/nsv/dorms_1
	name = "Deck 2 Fore Quarters"
	icon_state = "Sleep"
	safe = TRUE

/area/crew_quarters/dorms/nsv/dorms_2
	name = "Deck 2 Aft Quarters"
	icon_state = "Sleep"
	safe = TRUE

/area/medical/nsv/clinic
	name = "Deck 2 Medical Clinic"
	icon_state = "medbay"

/area/maintenance/nsv/deck2/frame1/port
	name = "Deck 2 Frame 1 Port Maintenence"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/frame1/starboard
	name = "Deck 2 Frame 1 Starboard Maintenence"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/frame1/central
	name = "Deck 2 Frame 1 Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck2/frame3/port
	name = "Deck 2 Frame 3 Port Maintenence"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/frame3/starboard
	name = "Deck 2 Frame 3 Starboard Maintenance"
	icon_state = "smaint"

/area/hallway/nsv/deck2/frame1/port
	name = "Deck 2 Frame 1 Port Hallway"
	icon_state = "hallF"

/area/hallway/nsv/deck2/frame1/starboard
	name = "Deck 2 Frame 1 Starboard Hallway"
	icon_state = "hallF"

/area/hallway/nsv/deck2/frame2/port
	name = "Deck 2 Frame 2 Port Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck2/frame2/starboard
	name = "Deck 2 Frame 2 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck2/frame3/port
	name = "Deck 2 Frame 3 Port Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck2/frame3/starboard
	name = "Deck 2 Frame 3 Starboard Hallway"
	icon_state = "hallC"

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
		SEND_SOUND(L, sound(null, repeat = 0, wait = 0, volume = 100, channel = CHANNEL_BUZZ))
		L.client.last_ambience = null
		return
	if(L.client && L.client.prefs.toggles & SOUND_SHIP_AMBIENCE && L.client?.last_ambience != looping_ambience)
		L.client.ambience_playing = 1
		SEND_SOUND(L, sound(looping_ambience, repeat = 1, wait = 0, volume = 100, channel = CHANNEL_BUZZ))
		L.client.last_ambience = looping_ambience
	if(linked_overmap && !L.client.played)
		var/progress = linked_overmap.obj_integrity
		var/goal = linked_overmap.max_integrity
		progress = CLAMP(progress, 0, goal)
		progress = round(((progress / goal) * 100), 50)//If the ship goes below 50% health, we start creaking like mad.
		if(progress <= 50)
			var/list/creaks = list('sephora/sound/ambience/ship_damage/creak1.ogg','sephora/sound/ambience/ship_damage/creak2.ogg','sephora/sound/ambience/ship_damage/creak3.ogg','sephora/sound/ambience/ship_damage/creak4.ogg','sephora/sound/ambience/ship_damage/creak5.ogg','sephora/sound/ambience/ship_damage/creak6.ogg','sephora/sound/ambience/ship_damage/creak7.ogg')
			var/creak = pick(creaks)
			SEND_SOUND(L, sound(creak, repeat = 0, wait = 0, volume = 70, channel = CHANNEL_AMBIENCE))
			L.client.played = TRUE
			addtimer(CALLBACK(L.client, /client/proc/ResetAmbiencePlayed), 300)
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