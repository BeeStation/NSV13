/**

Damage behaviour for overmap ships

Seen here:
Superstructure crit
Repairs
Bullet reactions

*/


/obj/structure/overmap/proc/shake_everyone(severity)
	for(var/mob/M in mobs_in_ship)
		if(M.client)
			shake_camera(M, severity, 1)

/obj/structure/overmap/proc/e(){
	while(1){
		stoplag(1)
		add_overlay(new /obj/effect/temp_visual/overmap_shield_hit(get_turf(src), src))
	}
}
/obj/structure/overmap/proc/f(){
	add_overlay(new /obj/effect/temp_visual/overmap_shield_hit(get_turf(src), src))
}

/obj/structure/overmap/bullet_act(obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/beam/overmap/aiming_beam))
		return
	if(shields && shields.absorb_hit(P.damage))
		var/damage_sound = pick('nsv13/sound/effects/ship/damage/shield_hit.ogg', 'nsv13/sound/effects/ship/damage/shield_hit2.ogg')
		if(!impact_sound_cooldown)
			add_overlay(new /obj/effect/temp_visual/overmap_shield_hit(get_turf(src), src))
			relay(damage_sound)
			if(P.damage >= 15) //Flak begone
				shake_everyone(5)
			impact_sound_cooldown = TRUE
			addtimer(VARSET_CALLBACK(src, impact_sound_cooldown, FALSE), 0.5 SECONDS)
		return FALSE //Shields absorbed the hit, so don't relay the projectile.
	relay_damage(P?.type)
	if(!use_armour_quadrants || !P.collider2d || !collider2d)
		. = ..()
		return
	else
		playsound(src, P.hitsound, 50, 1)
		visible_message("<span class='danger'>[src] is hit by \a [P]!</span>", null, null, COMBAT_MESSAGE_RANGE)
		if(!QDELETED(src)) //Bullet on_hit effect might have already destroyed this object
			var/datum/vector2d/point_of_collision = src.collider2d.get_collision_point(P.collider2d)//Get the collision point, see if the armour quadrants need to absorb this hit.
			take_quadrant_hit(run_obj_armor(P.damage, P.damage_type, P.flag, null, P.armour_penetration), check_quadrant(point_of_collision)) //This looks horrible, but trust me, it isn't! Probably!. Armour_quadrant.dm for more info

/obj/structure/overmap/proc/relay_damage(proj_type)
	if(!occupying_levels.len)
		return
	var/datum/space_level/SL = pick(occupying_levels)
	var/theZ = SL.z_value
	var/startside = pick(GLOB.cardinals)
	var/turf/pickedstart = spaceDebrisStartLoc(startside, theZ)
	var/turf/pickedgoal = locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), theZ)
	var/obj/item/projectile/proj = new proj_type(pickedstart)
	proj.starting = pickedstart
	proj.firer = null
	proj.def_zone = "chest"
	proj.original = pickedgoal
	spawn()
		proj.fire(Get_Angle(pickedstart,pickedgoal))
		proj.set_pixel_speed(4)

/obj/structure/overmap/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	var/blocked = FALSE
	var/damage_sound = pick(GLOB.overmap_impact_sounds)
	if(shields && shields.absorb_hit(damage_amount))
		blocked = TRUE
		damage_sound = pick('nsv13/sound/effects/ship/damage/shield_hit.ogg', 'nsv13/sound/effects/ship/damage/shield_hit2.ogg')
		if(!impact_sound_cooldown)
			add_overlay(new /obj/effect/temp_visual/overmap_shield_hit(get_turf(src), src))
	if(!impact_sound_cooldown && damage_sound)
		relay(damage_sound)
		if(damage_amount >= 15) //Flak begone
			shake_everyone(5)
		impact_sound_cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, impact_sound_cooldown, FALSE), 1 SECONDS)
	if(blocked)
		return FALSE
	SEND_SIGNAL(src, COMSIG_DAMAGE_TAKEN, damage_amount) //Trigger to update our list of armour plates without making the server cry.
	if(is_player_ship()) //Code for handling "superstructure crit" only applies to the player ship, nothing else.
		if(obj_integrity <= damage_amount || structure_crit) //Superstructure crit! They would explode otherwise, unable to withstand the hit.
			obj_integrity = 10 //Automatically set them to 10 HP, so that the hit isn't totally ignored. Say if we have a nuke dealing 1800 DMG (the ship's full health) this stops them from not taking damage from it, as it's more DMG than we can handle.
			handle_crit(damage_amount)
			return FALSE
	update_icon()
	. = ..()

/obj/structure/overmap/proc/is_player_ship() //Should this ship be considered a player ship? This doesnt count fighters because they need to actually die.
	if(linked_areas.len || role == MAIN_OVERMAP)
		return TRUE
	return FALSE

/obj/structure/overmap/proc/handle_crit(damage_amount) //A proc to allow ships to enter superstructure crit, this means the player ship can't die, but its insides can get torn to shreds.
	if(!structure_crit)
		relay('nsv13/sound/effects/ship/crit_alarm.ogg', message=null, loop=TRUE, channel=CHANNEL_SHIP_FX)
		priority_announce("DANGER. Ship superstructure failing. Structural integrity failure imminent. Immediate repairs are required to avoid total structural failure.","Automated announcement ([src])") //TEMP! Remove this shit when we move ruin spawns off-z
		structure_crit = TRUE
		structure_crit_timer = addtimer(CALLBACK(src, .proc/handle_critical_failure_part_1, FALSE), 5 MINUTES)
	if(explosion_cooldown)
		return
	explosion_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, explosion_cooldown, FALSE), 5 SECONDS)
	var/area/target = null
	if(role == MAIN_OVERMAP)
		var/name = pick(GLOB.teleportlocs) //Time to kill everyone
		target = GLOB.teleportlocs[name]
	else
		target = pick(linked_areas)
	var/turf/T = pick(get_area_turfs(target))
	new /obj/effect/temp_visual/explosion_telegraph(T)

/obj/structure/overmap/proc/handle_critical_failure_part_1()
	structure_crit_no_return = TRUE //Better launch those escape pods pronto
	priority_announce("DANGER. Ship superstructure critical failure imminent. No return threshold reached.","Automated announcement ([src])")
	addtimer(CALLBACK(src, .proc/handle_critical_failure_part_2, FALSE), 5 MINUTES)

/obj/structure/overmap/proc/handle_critical_failure_part_2()
	if(role == MAIN_OVERMAP)
		for(var/M in mobs_in_ship)
			if(!locate(M) in operators)
				start_piloting(M, "observer") //Make sure everyone sees the ship is exploding
		sleep(10)
		STOP_PROCESSING(SSovermap, src) //Reject player input
		src.SpinAnimation(1000, 1) //Drift
		var/michael_bay = rand(5,8) //How many explosions we're going to see (lens flares cost extra)
		for(var/I = 0, I < michael_bay, I++)
			var/obj/effect/temp_visual/nuke_impact/MB = new /obj/effect/temp_visual/nuke_impact(get_turf(src))
			MB.pixel_x = rand(-120, 20)
			MB.pixel_y = rand(-160, 20)
			sleep(rand(10, 30))
		sleep(20)
		qdel(src) //kaboom goes the ship
		sleep(100)
		//flick an awesome cinematic screen here - WYSI
		SSticker.mode.check_finished(TRUE)
		SSticker.force_ending = TRUE
	else
		qdel(src) //copy some of the above stuff later (when its shiny)

/obj/structure/overmap/proc/try_repair(amount)
	var/withrepair = obj_integrity+amount
	if(withrepair > max_integrity) //No overheal
		obj_integrity = max_integrity
	else
		obj_integrity += amount
	if(structure_crit)
		if(obj_integrity >= max_integrity/3) //You need to repair a good chunk of her HP before you're getting outta this fucko.
			stop_relay(channel=CHANNEL_SHIP_FX)
			priority_announce("Ship structural integrity restored to acceptable levels. ","Automated announcement ([src])")
			structure_crit = FALSE
			if(structure_crit_timer)
				deltimer(structure_crit_timer)

/obj/effect/temp_visual/explosion_telegraph
	name = "Explosion imminent!"
	icon = 'nsv13/icons/overmap/effects.dmi'
	icon_state = "target"
	duration = 6 SECONDS
	randomdir = 0
	light_color = LIGHT_COLOR_ORANGE
	layer = ABOVE_MOB_LAYER

/obj/effect/temp_visual/explosion_telegraph/Initialize()
	. = ..()
	set_light(4)
	for(var/mob/M in orange(src, 3))
		if(isliving(M))
			to_chat(M, "<span class='userdanger'>You hear a loud creak coming from above you. Take cover!</span>")
			SEND_SOUND(M, pick('nsv13/sound/ambience/ship_damage/creak5.ogg','nsv13/sound/ambience/ship_damage/creak6.ogg'))

/obj/effect/temp_visual/explosion_telegraph/Destroy()
	var/turf/T = get_turf(src)
	explosion(T,3,4,4)
	. = ..()
