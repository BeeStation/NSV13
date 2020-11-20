/client/var/last_ambience = null

/area
	var/looping_ambience = 'nsv13/sound/ambience/shipambience.ogg' //If you want an ambient sound to play on loop while theyre in a specific area, set this. Defaults to the classic "engine rumble"

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

/area/crew_quarters/dorms/nsv/state_room
	name = "Corporate Stateroom"
	icon_state = "Sleep"

/area/medical/nsv/clinic
	name = "Deck 2 Medical Clinic"
	icon_state = "medbay"

/area/medical/nsv/psychology
	name = "Psychology Office"
	icon_state = "medbay"

/area/medical/nsv/plumbing
	name = "Chemical Manufacturing"
	icon_state = "chem"
	
/area/science/nsv/astronomy
	name = "Astrometrics Lab"
	icon_state = "toxmisc"

/area/nsv/engine/corridor
	name = "Engineering Corridor"
	icon_state = "aux_base_construction"
	
/area/nsv/engine/engine_room/core
	name = "Engine Core"
	icon_state = "engine_foyer"

/area/nsv/engine/engine_room/auxiliary
	name = "Engine Auxiliary Equipment"
	icon_state = "engine_foyer"

/area/maintenance/nsv/ftlroom
	name = "FTL Control Room"
	icon_state = "maint_bridge"

/area/maintenance/nsv/turbolift/abandonedshaft
	name = "Abandoned Elevator Shaft"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck1/airlock/forward/port
	name = "Deck 1 Port Forward Airlock"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck1/airlock/forward/starboard
	name = "Deck 1 Starboard Forward Airlock"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck1/airlock/aft/port
	name = "Deck 1 Port Aft Airlock"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck1/airlock/aft/starboard
	name = "Deck 1 Starboard Aft Airlock"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck1/port
	name = "Deck 1 Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck1/central
	name = "Deck 1 Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck1/starboard
	name = "Deck 1 Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck1/starboard/aft
	name = "Deck 1 Starboard Aft Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck1/aft
	name = "Deck 1 Aft Maintenance"
	icon_state = "amaint"
	
/area/maintenance/nsv/deck1/port/aft
	name = "Deck 1 Port Aft Maintenance"
	icon_state = "pmaint"	
	
/area/maintenance/nsv/deck1/port/fore
	name = "Deck 1 Port Fore Maintenance"	
	icon_state = "pmaint"	
	
/area/maintenance/nsv/deck2/port
	name = "Deck 2 Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/starboard
	name = "Deck 2 Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/airlock/forward/port
	name = "Deck 2 Port Forward Airlock"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck2/airlock/forward/starboard
	name = "Deck 2 Starboard Forward Airlock"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck2/airlock/aft/port
	name = "Deck 2 Port Aft Airlock"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck2/airlock/aft/starboard
	name = "Deck 2 Starboard Aft Airlock"
	icon_state = "maint_bridge"

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

/area/maintenance/nsv/bridge
	name = "Fore Bridge Maintenance"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck2/starboard/fore
	name = "Deck 2 Starboard Fore Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/starboard/aft
	name = "Deck 2 Starboard Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/nsv/deck2/port/fore
	name = "Deck 2 Port Fore Maintenance"
	icon_state = "pmaint"
	
/area/maintenance/nsv/deck2/port/aft
	name = "Deck 2 Port Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/nsv/weapons
	name = "Weapons Bay Maintenance"
	icon_state = "amaint"

/area/maintenance/nsv/hangar
	name = "Hangar Bay Maintenance"
	icon_state = "amaint"

/area/hallway/nsv/deck2/forward
	name = "Deck 2 Forward Hallway"
	icon_state = "hallF"

/area/hallway/nsv/deck2/primary
	name = "Deck 2 Primary Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck1/aft
	name = "Deck 1 Aft Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck2/aft
	name = "Deck 2 Aft Hallway"
	icon_state = "hallP"

/area/maintenance/nsv/mining_ship
	has_gravity = TRUE
	looping_ambience = 'nsv13/sound/ambience/maintenance.ogg'

/area/maintenance/nsv/mining_ship/central
	name = "Rocinante maintenance"
	icon_state = "maintcentral"

/area/maintenance/nsv/mining_ship/forward
	name = "Rocinante forward maintenance"
	icon_state = "maintcentral"

/area/maintenance/nsv/mining_ship/aft
	name = "Rocinante aft maintenance"
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

/area/hallway/nsv/deck2/frame2/central
	name = "Deck 2 Frame 2 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck2/frame2/starboard
	name = "Deck 2 Frame 2 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck2/frame3/port
	name = "Deck 2 Frame 3 Port Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck2/frame3/central
	name = "Deck 2 Frame 3 Central Hallway"
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

/area/hallway/nsv/stairwell/lower
	name = "Lower Stairwell"
	icon_state = "hallS"

/area/hallway/nsv/stairwell/upper
	name = "Upper Stairwell"
	icon_state = "hallS"

/area/hallway/nsv/deck1/hallway
	name = "Deck 1 Primary Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck1/frame1/central
	name = "Deck 1 Frame 1 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck1/frame1/starboard
	name = "Deck 1 Frame 1 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck1/frame2/port
	name = "Deck 1 Frame 2 Port Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck1/frame2/central
	name = "Deck 1 Frame 2 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck1/frame2/starboard
	name = "Deck 1 Frame 2 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck1/frame3/central
	name = "Deck 1 Frame 3 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck1/frame4/central
	name = "Deck 1 Frame 4 Central Hallway"
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

/area/nsv/hanger/notkmcstupidhanger/launchtube/left
	name = "Launch Tubes 1 & 2"
	icon_state = "hallP"

/area/nsv/hanger/notkmcstupidhanger/launchtube/right
	name = "Launch Tubes 3 & 4"
	icon_state = "hallS"

/area/nsv/hanger/notkmcstupidhanger/launchtube/left/airlock
	name = "Hangar Airlock 1"

/area/nsv/hanger/notkmcstupidhanger/launchtube/right/airlock
	name = "Hangar Airlock 2"

/area/nsv/hanger/notkmcstupidhanger/hangar
	name = "Hangar Bay"
	icon_state = "hallC"

/area/nsv/hanger/notkmcstupidhanger/pilot
	name = "Pilot Lounge"
	icon_state = "shuttlered"

/area/nsv/hanger/notkmcstupidhanger/atc
	name = "Air Traffic Control"
	icon_state = "shuttlered"

/area/nsv/hanger/deck2/port
	name = "Deck 2 Port Hanger Bay"
	icon_state = "hallP"

/area/nsv/hanger/deck2/starboard
	name = "Deck 2 Starboard Hanger Bay"
	icon_state = "hallS"

/area/nsv/weapons
	name = "Weapons Bay"
	icon_state = "hallC"

/area/nsv/weapons/ordnance
	name = "Ordnance Handling Bay"
	icon_state = "hallC"
	
/area/nsv/weapons/gauss
	name = "Gauss Bay"
	icon_state = "hallC"

/area/nsv/weapons/port
	name = "Port Weapons Bay"
	icon_state = "hallP"

/area/nsv/weapons/starboard
	name = "Starboard Weapons Bay"
	icon_state = "hallS"

/area/nsv/weapons/fore
	name = "Fore Weapons Bay"
	icon_state = "hallF"

/area/nsv/magazine
	name = "Ship's Magazine"
	icon_state = "hallC"

/area/nsv/magazine/port
	name = "Port Magazine"
	icon_state = "hallP"

/area/nsv/magazine/starboard
	name = "Starboard Magazine"
	icon_state = "hallS"

/area/nsv/briefingroom
	name = "Briefing Room"
	icon_state = "hallP"

/area/nsv/crew_quarters/heads/maa
	name = "Master At Arms' Office"
	icon_state = "shuttlegrn"

/area/nsv/squad
	name = "Squad Equipment Room"
	icon_state = "shuttlegrn"

/area/nsv/shuttle

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

/area/nsv/shuttle/fob
	has_gravity = STANDARD_GRAVITY //good luck trying to fit a gen here.

/area/nsv/shuttle/fob/bridge
	name = "Mining Shuttle Bridge"
	icon_state = "bridge"

/area/nsv/shuttle/fob/central
	name = "Mining Shuttle"
	icon_state = "hallC"

/area/nsv/shuttle/fob/storage
	name = "Mining Shuttle Equipment Storage"
	icon_state = "storage"

/area/nsv/shuttle/fob/atmospherics
	name = "Mining Shuttle Maintenance"
	icon_state = "atmos"

/area/nsv/shuttle/fob/airlock/aft
	name = "Mining Shuttle Aft Airlock"
	icon_state = "hallA"

/area/nsv/shuttle/fob/airlock/port
	name = "Mining Shuttle Port Airlock"
	icon_state = "hallP"

/area/nsv/shuttle/fob/airlock/starboard
	name = "Mining Shuttle Starboard Airlock"
	icon_state = "hallS"

/area/nsv/shuttle/fob/quarters
	name = "Mining Shuttle Crew Quarters"
	icon_state = "hallC"

/area/nsv/shuttle/fob/lounge
	name = "Mining Shuttle Lounge"
	icon_state = "hallP"

/area/ruin/powered/nsv13/prisonship
	name = "Syndicate prison ship"

/area/ruin/powered/nsv13/trooptransport
	name = "Syndicate troop transport"

/area/ruin/powered/nsv13/gunship
	name = "Syndicate corvette"

/area/ruin/powered/nsv13/yacht
	name = "Luxury yacht"

/area/nostromo
	name = "DMC Rocinante"
	ambientsounds = list('nsv13/sound/ambience/leit_motif.ogg','nsv13/sound/ambience/wind.ogg','nsv13/sound/ambience/wind2.ogg','nsv13/sound/ambience/wind3.ogg','nsv13/sound/ambience/wind4.ogg','nsv13/sound/ambience/wind5.ogg','nsv13/sound/ambience/wind6.ogg')
	icon_state = "mining"
	has_gravity = TRUE

/area/nostromo/maintenance/exterior
	name = "Rocinante exterior"
	icon_state = "space_near"

/area/nostromo/maintenance/hangar
	name = "Rocinante hangar bay"
	icon_state = "hallS"

/area/nostromo/medbay
	name = "Rocinante sickbay"
	looping_ambience = 'nsv13/sound/ambience/medbay.ogg'
	icon_state = "medbay"

/area/nostromo/science
	name = "Rocinante science"
	looping_ambience = 'nsv13/sound/ambience/computer_core.ogg'
	icon_state = "toxlab"

/area/nostromo/tcomms
	name = "Rocinante TE/LE/COMM core"
	looping_ambience = 'nsv13/sound/ambience/computer_core.ogg'
	icon_state = "tcomsatcham"

/area/nostromo/bridge
	name = "Rocinante flight deck"
	looping_ambience = 'nsv13/sound/ambience/bridge.ogg'
	icon_state = "bridge"

/area/nostromo/hangar/port
	name = "Rocinante port hangar deck"
	looping_ambience = 'nsv13/sound/ambience/bridge.ogg'
	icon_state = "hallP"

/area/nostromo/hangar/starboard
	name = "Rocinante starboard hangar deck"
	looping_ambience = 'nsv13/sound/ambience/bridge.ogg'
	icon_state = "hallS"

/area/nostromo/engineering
	name = "Rocinante engineering"
	looping_ambience = 'nsv13/sound/ambience/bridge.ogg'
	icon_state = "engine"

/area/nostromo/engineering/atmospherics
	name = "Rocinante engineering"
	looping_ambience = 'nsv13/sound/ambience/bridge.ogg'
	icon_state = "atmos"

/area/nostromo/galley
	name = "Rocinante galley"
	looping_ambience = 'nsv13/sound/ambience/bridge.ogg'
	icon_state = "kitchen"

/area/nostromo/galley/coldroom
	name = "Rocinante cold room"
	icon_state = "kitchen_cold"

/area/nostromo/crew_quarters
	name = "Rocinante quarters"
	icon_state = "Sleep"
	mood_bonus = 3
	mood_message = "<span class='nicegreen'>There's no place like the dorms!\n</span>"

/area/nostromo/mining
	name = "Rocinante mining dock"
	icon_state = "mining"

/area/nostromo/security
	name = "Rocinante security"
	icon_state = "security"
	ambientsounds = HIGHSEC





//Syndie PVP ship

/area/hammurabi
	name = "SSV Hammurabi"
	ambientsounds = list('nsv13/sound/ambience/leit_motif.ogg','nsv13/sound/ambience/wind.ogg','nsv13/sound/ambience/wind2.ogg','nsv13/sound/ambience/wind3.ogg','nsv13/sound/ambience/wind4.ogg','nsv13/sound/ambience/wind5.ogg','nsv13/sound/ambience/wind6.ogg')
	noteleport = TRUE
	icon_state = "syndie-ship"
	has_gravity = TRUE

/area/hammurabi/medbay
	name = "Hammurabi sickbay"
	looping_ambience = 'nsv13/sound/ambience/medbay.ogg'
	icon_state = "medbay"

/area/hammurabi/tcomms
	name = "Hammurabi TE/LE/COMM core"
	looping_ambience = 'nsv13/sound/ambience/computer_core.ogg'
	icon_state = "tcomsatcham"

/area/hammurabi/bridge
	name = "Hammurabi flight deck"
	looping_ambience = 'nsv13/sound/ambience/bridge.ogg'
	icon_state = "syndie-control"

/area/hammurabi/armoury
	name = "Hammurabi armoury"
	icon_state = "syndie-elite"

/area/hammurabi/hangar
	name = "Hammurabi hangar bay"
	looping_ambience = 'nsv13/sound/ambience/maintenance.ogg'
	icon_state = "shuttlered"

/area/hammurabi/maintenance
	name = "Hammurabi maintenance"
	looping_ambience = 'nsv13/sound/ambience/maintenance.ogg'
	icon_state = "maintcentral"

/area/hammurabi/maintenance/exterior
	name = "Hammurabi exterior"
	icon_state = "space_near"

/area/Entered(atom/movable/M)
	// Ambience goes down here -- make sure to list each area separately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_AREA_ENTERED, M)
	SEND_SIGNAL(M, COMSIG_ENTER_AREA, src) //The atom that enters the area

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
	var/atom/foo = pick(contents) //We need something with a z-level attached to it.
	var/obj/structure/linked_overmap = foo.get_overmap()
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

/area/engine/engineering/reactor_core
	name = "Nuclear Reactor Core"

/area/engine/engineering/reactor_control
	name = "Reactor Control Room"
