/client/var/last_ambience = null

/area
	var/looping_ambience = 'nsv13/sound/ambience/shipambience.ogg' //If you want an ambient sound to play on loop while theyre in a specific area, set this. Defaults to the classic "engine rumble"
	var/obj/structure/overmap/linked_overmap = null //For relaying damage etc. to the interior.
	var/overmap_type = null //Set this to the type of your ship object if you want to create a secondary ship to the main one. (EG: /obj/structure/overmap/nanotrasen/patrol_cruiser/starter)

/area/space
	looping_ambience = null

/area/maintenance
	looping_ambience = 'nsv13/sound/ambience/maintenance.ogg'
	ambientsounds = list('nsv13/sound/ambience/leit_motif.ogg','nsv13/sound/ambience/wind.ogg','nsv13/sound/ambience/wind2.ogg','nsv13/sound/ambience/wind3.ogg','nsv13/sound/ambience/wind4.ogg','nsv13/sound/ambience/wind5.ogg','nsv13/sound/ambience/wind6.ogg')

/area/medical
	looping_ambience = 'nsv13/sound/ambience/medbay.ogg'
	ambientsounds = list()

/area/ai_monitored
	looping_ambience = 'nsv13/sound/ambience/computer_core.ogg'
	ambientsounds = list()

/area/bridge
	looping_ambience = 'nsv13/sound/ambience/bridge.ogg'
	ambientsounds = list()

/area/science
	looping_ambience = 'nsv13/sound/ambience/computer_core.ogg'
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

/area/maintenance/nsv/deck2/frame2/port
	name = "Deck 2 Frame 2 Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/frame2/starboard
	name = "Deck 2 Frame 2 Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/frame3/port
	name = "Deck 2 Frame 3 Port Maintenence"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/frame3/starboard
	name = "Deck 2 Frame 3 Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/frame4/port
	name = "Deck 2 Frame 4 Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/frame4/starboard
	name = "Deck 2 Frame 4 Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/frame5/port
	name = "Deck 2 Frame 5 Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/frame5/starboard
	name = "Deck 2 Frame 5 Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck3/frame1/port
	name = "Deck 3 Frame 1 Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck3/frame1/starboard
	name = "Deck 3 Frame 1 Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck3/frame2/port
	name = "Deck 3 Frame 2 Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck3/frame2/starboard
	name = "Deck 3 Frame 2 Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck3/frame3/port
	name = "Deck 3 Frame 3 Port Maintenence"
	icon_state = "pmaint"

/area/maintenance/nsv/deck3/frame3/starboard
	name = "Deck 3 Frame 3 Starboard Maintenence"
	icon_state = "smaint"

/area/maintenance/nsv/deck3/frame3/central
	name = "Deck 3 Frame 3 Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck3/frame4/central
	name = "Deck 3 Frame 4 Central Maintenance"
	icon_state = "maintcentral"

/area/hallway/nsv/deck2/frame1/port
	name = "Deck 2 Frame 1 Port Hallway"
	icon_state = "hallF"

/area/hallway/nsv/deck2/frame1/central
	name = "Deck 2 Frame 1 Central Hallway"
	icon_state = "hallC"

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

/area/hallway/nsv/deck2/frame4/port
	name = "Deck 2 Frame 4 Port Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck2/frame4/starboard
	name = "Deck 2 Frame 4 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck2/frame4/central
	name = "Deck 2 Frame 4 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck2/frame5/port
	name = "Deck 2 Frame 5 Port Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck2/frame5/starboard
	name = "Deck 2 Frame 5 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck2/frame5/central
	name = "Deck 2 Frame 5 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck3/frame1/port
	name = "Deck 3 Frame 1 Port Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck3/frame1/starboard
	name = "Deck 3 Frame 1 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck3/frame1/central
	name = "Deck 3 Frame 1 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck3/frame2/port
	name = "Deck 2 Frame 2 Port Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck3/frame2/starboard
	name = "Deck 2 Frame 2 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck3/frame3/port
	name = "Deck 3 Frame 3 Port Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck3/frame3/starboard
	name = "Deck 3 Frame 3 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck3/frame3/central
	name = "Deck 3 Frame 3 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck3/frame4/port
	name = "Deck 3 Frame 4 Port Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck3/frame4/starboard
	name = "Deck 3 Frame 4 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck1/hallway
	name = "Deck 1 Primary Hallway"
	icon_state = "hallC"

/area/crew_quarters/nsv/observation
	name = "Observation Lounge"
	icon_state = "Sleep"

/area/crew_quarters/nsv/officerquarters
	name = "Bridge Officer's Quarters"
	icon_state = "Sleep"

/area/nsv/hanger/deck3/starboard
	name = "Deck 3 Starboard Hanger Bay"
	icon_state = "hallS"

/area/nsv/hanger/deck2/port
	name = "Deck 2 Port Hanger Bay"
	icon_state = "hallP"

/area/nsv/hanger/deck2/starboard
	name = "Deck 2 Starboard Hanger Bay"
	icon_state = "hallS"

/area/nsv/weapons/port
	name = "Port Weapons Bay"
	icon_state = "hallP"

/area/nsv/weapons/starboard
	name = "Starboard Weapons Bay"
	icon_state = "hallS"

/area/nsv/weapons/fore
	name = "Fore Weapons Bay"
	icon_state = "hallF"

/area/nsv/magazine/port
	name = "Port Magazine"
	icon_state = "hallP"

/area/nsv/magazine/starboard
	name = "Starboard Magazine"
	icon_state = "hallS"

/area/nsv/briefingroom
	name = "Briefing Room"
	icon_state = "hallP"

/area/nsv/shuttle/bridge
	name = "Mining Shuttle Bridge"
	icon_state = "bridge"

/area/nsv/shuttle/central
	name = "Mining Shuttle"
	icon_state = "hallC"

/area/nsv/shuttle/storage
	name = "Mining Shuttle Equipment Storage"
	icon_state = "storage"

/area/nsv/shuttle/atmospherics
	name = "Mining Shuttle Maintenance"
	icon_state = "atmos"

/area/nsv/shuttle/airlock/aft
	name = "Mining Shuttle Aft Airlock"
	icon_state = "hallA"

/area/nsv/shuttle/airlock/port
	name = "Mining Shuttle Port Airlock"
	icon_state = "hallP"

/area/nsv/shuttle/airlock/starboard
	name = "Mining Shuttle Starboard Airlock"
	icon_state = "hallS"

/area/ruin/powered/nsv13/prisonship
	name = "Syndicate prison ship"

/area/ruin/powered/nsv13/trooptransport
	name = "Syndicate troop transport"

/area/ruin/powered/nsv13/gunship
	name = "Syndicate corvette"

/area/ruin/powered/nsv13/yacht
	name = "Luxury yacht"

/area/nostromo
	name = "NSV Nostromo"
	ambientsounds = list('nsv13/sound/ambience/leit_motif.ogg','nsv13/sound/ambience/wind.ogg','nsv13/sound/ambience/wind2.ogg','nsv13/sound/ambience/wind3.ogg','nsv13/sound/ambience/wind4.ogg','nsv13/sound/ambience/wind5.ogg','nsv13/sound/ambience/wind6.ogg')
	noteleport = TRUE
	overmap_type = /obj/structure/overmap/nanotrasen/mining_cruiser/nostromo
	icon_state = "mining"
	has_gravity = TRUE

/area/nostromo/maintenance
	name = "Nostromo maintenance"
	looping_ambience = 'nsv13/sound/ambience/maintenance.ogg'
	icon_state = "maintcentral"

/area/nostromo/maintenance/exterior
	name = "Nostromo exterior"
	icon_state = "space_near"

/area/nostromo/medbay
	name = "Nostromo sickbay"
	looping_ambience = 'nsv13/sound/ambience/medbay.ogg'
	icon_state = "medbay"

/area/nostromo/tcomms
	name = "Nostromo TE/LE/COMM core"
	looping_ambience = 'nsv13/sound/ambience/computer_core.ogg'
	icon_state = "tcomsatcham"

/area/nostromo/bridge
	name = "Nostromo flight deck"
	looping_ambience = 'nsv13/sound/ambience/bridge.ogg'
	icon_state = "bridge"

/area/Entered(atom/movable/M)
	// Ambience goes down here -- make sure to list each area separately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_AREA_ENTERED, M)
	SEND_SIGNAL(M, COMSIG_ENTER_AREA, src) //The atom that enters the area
	if(ismob(M) && linked_overmap)
		linked_overmap.mobs_in_ship += M
	if(istype(M, /obj/structure/overmap))
		var/obj/structure/overmap/OM = M
		if(OM.mobs_in_ship.len) //Relays area exits and enters. This is so that fighter pilots and crews arent registered as being still inside their carrier vessel, and thus hear its sounds.
			for(var/mob/LM in OM.mobs_in_ship)
				Entered(LM)
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
			var/list/creaks = list('nsv13/sound/ambience/ship_damage/creak1.ogg','nsv13/sound/ambience/ship_damage/creak2.ogg','nsv13/sound/ambience/ship_damage/creak3.ogg','nsv13/sound/ambience/ship_damage/creak4.ogg','nsv13/sound/ambience/ship_damage/creak5.ogg','nsv13/sound/ambience/ship_damage/creak6.ogg','nsv13/sound/ambience/ship_damage/creak7.ogg')
			var/creak = pick(creaks)
			SEND_SOUND(L, sound(creak, repeat = 0, wait = 0, volume = 100, channel = CHANNEL_AMBIENCE))
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
	if(istype(M, /obj/structure/overmap))
		var/obj/structure/overmap/OM = M
		if(OM.mobs_in_ship.len)
			for(var/mob/LM in OM.mobs_in_ship)
				Exited(LM)