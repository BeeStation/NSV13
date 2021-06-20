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

/obj/effect/temp_visual/fading_overmap
	name = "Foo"
	duration = 3 SECONDS
	mouse_opacity = FALSE

/obj/effect/temp_visual/fading_overmap/Initialize(mapload, name, icon, icon_state)
	. = ..()
	src.name = name
	src.icon = icon
	src.icon_state = icon_state
	play()

/obj/effect/temp_visual/fading_overmap/proc/play()
	set waitfor = FALSE
	SpinAnimation(500, 1)
	animate(src, alpha = 0,time = 30) //Ship fades to black
	if(prob(50))
		new /obj/effect/temp_visual/overmap_explosion(get_turf(src)) //Draw an explosion. Picks between two types.
	else
		new /obj/effect/temp_visual/overmap_explosion/alt(get_turf(src))


/datum/cinematic/nsv_kaboom
	id = CINEMATIC_NSV_SHIP_KABOOM

/datum/cinematic/nsv_kaboom/content()
	screen.icon = 'nsv13/icons/effects/station_explosion.dmi'
	flick("ship_go_byebye",screen)
	sleep(3.5 SECONDS)
	screen.icon_state = "summary"
	cinematic_sound(sound('sound/effects/explosion_distant.ogg'))
	special()

/proc/overmap_explode(list/areas)
	if(!areas)
		return
	for(var/area/AR in areas)
		var/turf/T = pick(get_area_turfs(AR))
		explosion(T,30,30,30)

/obj/structure/overmap/proc/decimate_area()
	if(!linked_areas.len)
		return TRUE
	if(role == MAIN_OVERMAP)
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
/obj/structure/closet/supplypod/syndicate_odst
	name = "Syndicate drop pod"
	desc = "A large pod which is used to launch syndicate drop troopers at enemy vessels. It's rare to see one of these and survive the encounter."
	style = STYLE_SYNDICATE
	explosionSize = list(0,0,0,5)
	delays = list(POD_TRANSIT = 30, POD_FALLING = 25, POD_OPENING = 30, POD_LEAVING = 30) //Slower than usual so you have time to react
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
