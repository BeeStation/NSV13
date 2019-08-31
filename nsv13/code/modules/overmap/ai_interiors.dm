/obj/structure/overmap
	var/interior_maps = null //Set this for AI ships. This allows them to be boarded. A random interior is picked on a per-ship basis.
	var/wrecked = FALSE //This tells you whether an AI controlled ship has been defeated, and is in the process of exploding.

/obj/effect/landmark/ship_interior_spawn
	name = "Ship interior spawn"
	desc = "A spawner which will spawn a ship on demand. Use with caution."
	var/interior_map = null

/obj/effect/landmark/ship_interior_spawn/proc/load(templatename)
	var/datum/map_template/template = SSmapping.map_templates[templatename]
	if(template?.load(get_turf(src), centered = FALSE))
		return TRUE
	else
		return FALSE

/datum/map_template/corvette
	name = "Corvette"
	mappath = "_maps/templates/sephora/Corvette.dmm"

/obj/structure/overmap/Destroy()
	relay('nsv13/sound/effects/ship/damage/ship_explode.ogg')
	animate(src, alpha = 0,time = 20)
	if(prob(50))
		new /obj/effect/temp_visual/overmap_explosion(get_turf(src)) //Draw an explosion. Picks between two types.
	else
		new /obj/effect/temp_visual/overmap_explosion/alt(get_turf(src))
	sleep(20)
	. = ..()

/obj/structure/overmap/obj_destruction(damage_flag) //When integrity reaches 0, ships will take a few minutes to despawn. This allows for the players to select them for boarding.
	if(!wrecked)
		wrecked = TRUE
		ai_controlled = FALSE
		QDEL_IN(src, 120 SECONDS)
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