/obj/structure/overmap
	var/list/interior_maps = list() //Set this for AI ships. This allows them to be boarded. A random interior is picked on a per-ship basis.
	var/wrecked = FALSE //This tells you whether an AI controlled ship has been defeated, and is in the process of exploding.
	var/obj/effect/landmark/ship_interior_spawn/interior_spawn = null //Where to spawn the ship spawner after our boarding map is deleted.

/obj/effect/landmark/ship_interior_spawn
	name = "Ship interior spawn"
	desc = "A spawner which will spawn a ship on demand. Use with caution."
	var/interior_map = null
	var/used = FALSE //Are we available to spawn with?

/obj/effect/landmark/ship_interior_spawn/proc/load(templatename, obj/structure/overmap/OM)
	if(used)
		return
	var/datum/map_template/template = SSmapping.map_templates[templatename]
	OM.interior_spawn = src //This has to go before the "load" in-case the loading deletes us.
	if(template?.load(get_turf(src), centered = FALSE))
		used = TRUE
		return TRUE
	else
		OM.interior_spawn = null
		return FALSE

/datum/map_template/corvette
	name = "Corvette"
	mappath = "_maps/templates/Corvette.dmm"

/obj/structure/overmap/proc/load_interior()
	if(!interior_maps?.len)
		return FALSE
	var/interior_map = pick(interior_maps)
	for(var/obj/effect/landmark/ship_interior_spawn/SI in GLOB.landmarks_list)
		if(!SI.used)
			if(SI.load(interior_map, src))
				priority_announce("Salvage armatures have pulled [src] to a stable nearside position of: [SI.name].","Automated announcement") //TEMP! Remove this shit when we move ruin spawns off-z
				find_area()
				return TRUE

/obj/structure/overmap/Destroy()
	STOP_PROCESSING(SSovermap, src)
	GLOB.overmap_objects -= src
	relay('nsv13/sound/effects/ship/damage/ship_explode.ogg')
	animate(src, alpha = 0,time = 20) //Ship fades to black
	if(prob(50))
		new /obj/effect/temp_visual/overmap_explosion(get_turf(src)) //Draw an explosion. Picks between two types.
	else
		new /obj/effect/temp_visual/overmap_explosion/alt(get_turf(src))
	sleep(20)
	if(main_overmap)
		priority_announce("WARNING: ([rand(10,100)]) Attempts to establish DRADIS uplink with [station_name()] have failed. Unable to ascertain operational status. Presumed status: TERMINATED","Central Intelligence Unit", 'nsv13/sound/effects/ship/reactor/explode.ogg')
		SSticker.mode.check_finished(TRUE)
		SSticker.force_ending = TRUE
		for(var/X in GLOB.teleportlocs) //Time to kill everyone
			var/area/target = GLOB.teleportlocs[X]
			var/turf/T = pick(get_area_turfs(target))
			explosion(T,20,20,20)
	. = ..()

/obj/structure/overmap/proc/decimate_area()
	if(!linked_areas.len)
		return TRUE
	if(main_overmap)
		Cinematic(CINEMATIC_ANNIHILATION,world)
		SSticker.mode.check_finished(TRUE)
		SSticker.force_ending = 1
		return TRUE
	else
		for(var/area/linked_area in linked_areas)
			for(var/obj/O in linked_area) //This is fucking disgusting but it works
				if(isobj(O))
					if(O.contents.len)
						for(var/atom/X in O.contents)
							qdel(X)
					qdel(O)
			for(var/mob/M in linked_area)
				if(isliving(M) && !M.client) //OK, this is unrealistic, but I don't want players getting deleted because of some brainlet helm operator.
					qdel(M)
			for(var/turf/T in linked_area)
				T.ChangeTurf(/turf/open/space/basic)
			qdel(linked_area)
			return TRUE
	return FALSE

/obj/structure/overmap/proc/explode()
	if(decimate_area()) //Decimate area returns true after every atom in X area has been destroyed
		interior_spawn?.used = FALSE
		qdel(src)

/obj/structure/overmap/obj_destruction(damage_flag) //When integrity reaches 0, ships will take a few minutes to despawn. This allows for the players to select them for boarding.
	if(!wrecked)
		wrecked = TRUE
		ai_controlled = FALSE
		addtimer(CALLBACK(src, .proc/explode), 2 MINUTES) //Countdown to explosion. The only thing that can save us now is another ship attempting to dock.
		relay_to_nearby('nsv13/sound/effects/ship/damage/disable.ogg') //Kaboom.
		for(var/obj/structure/overmap/OM in enemies) //If target's in enemies, return
			var/sound = pick('nsv13/sound/effects/computer/alarm.ogg','nsv13/sound/effects/computer/alarm_2.ogg')
			var/message = "<span class='warning'>ATTENTION: [src]'s reactor is going supercritical. Destruction imminent.</span>"
			OM?.tactical?.relay_sound(sound, message)
			OM.enemies -= src //Stops AI from spamming ships that are already dead
		obj_integrity = max_integrity/3 //You have to REALLY want them dead to blow up a wreck.
		STOP_PROCESSING(SSfastprocess,src)
		SpinAnimation(1000,10)
	else //OK, they've shot us again as we're despawning, that means they don't want to loot us.
		. = ..()

GLOBAL_LIST_INIT(drop_trooper_teams, list("Noble", "Helljumper","Red", "Black", "Crimson", "Osiris", "Apex", "Apollo", "Thrace", "Galactica", "Valkyrie", "Recon", "Gamma", "Alpha", "Bravo", "Charlie", "Delta", "Indigo", "Sol's fist", "Abassi", "Cartesia", "Switchback", "Majestic", "Mountain", "Shadow", "Shrike", "Sterling", "FTL", "Belter", "Moya", "Crichton"))

/obj/structure/closet/supplypod/syndicate_odst
	name = "Syndicate drop pod"
	desc = "A large pod which is used to launch syndicate drop troopers at enemy vessels. It's rare to see one of these and survive the encounter."
	style = STYLE_SYNDICATE
	explosionSize = list(0,0,0,5)
	landingDelay = 25 //Slower than usual so you have time to react
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/overmap/proc/spawn_boarders(amount)
	if(!main_overmap)
		return FALSE
	if(!amount)
		amount = rand(2,4)
	var/turf/target = safepick(get_area_turfs(/area/maintenance/ship_exterior))
	if(!target)
		return FALSE //Cut off here to avoid polling people for a spawn that will never work.
	var/list/candidates = pollCandidatesForMob("Do you want to play as a Syndicate drop trooper?", ROLE_OPERATIVE, null, ROLE_OPERATIVE, 10 SECONDS, src)
	var/pod_type = /obj/structure/closet/supplypod/syndicate_odst
	var/obj/structure/closet/supplypod/toLaunch = new pod_type()
	toLaunch.update_icon()//we update_icon() here so that the door doesnt "flicker on" right after it lands
	if(!LAZYLEN(candidates))
		return FALSE
	var/team_name = pick_n_take(GLOB.drop_trooper_teams)
	for(var/I = 0, I < amount, I++)
		if(!LAZYLEN(candidates))
			return FALSE
		var/mob/dead/observer/C = pick_n_take(candidates)
		var/mob/living/carbon/human/H = new(toLaunch)
		H.equipOutfit(/datum/outfit/syndicate/odst)
		H.key = C.key
		if(team_name) //If there is an available "team name", give them a callsign instead of a placeholder name
			var/callsign = I
			if(callsign <= 0)
				callsign = "Lead"
			else
				callsign = num2text(callsign)
			H.fully_replace_character_name(H.real_name, "[team_name]-[callsign]")
		log_game("[key_name(H)] became a syndicate drop trooper.")
		message_admins("[ADMIN_LOOKUPFLW(H)] became a syndicate drop trooper.")
		to_chat(H, "<span class='danger'>You are a syndicate drop trooper! Your mission is to sabotage [station_name()] so that our ships can dispose of it. For Abassi!")
		H.mind?.special_role = "Syndicate Drop Trooper"

	relay_to_nearby('nsv13/sound/effects/ship/boarding_pod.ogg')
	new /obj/effect/DPtarget(target, toLaunch)
	return TRUE