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
	set waitfor = FALSE	//Lets not freeze the game ending and ship del
	if(!areas)
		return
	for(var/area/AR in areas)
		var/turf/T = pick(get_area_turfs(AR))
		explosion(T,7,0,0, ignorecap = TRUE)
		sleep(3 SECONDS)

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
