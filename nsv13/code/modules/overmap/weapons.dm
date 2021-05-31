/obj/structure/overmap/proc/fire(atom/target)
	if(weapon_safety)
		if(gunner)
			to_chat(gunner, "<span class='warning'>Weapon safety interlocks are active! Use the ship verbs tab to disable them!</span>")
		return
	last_target = target
	if(next_firetime > world.time)
		return
	if(ai_controlled) //Let the AI switch weapons according to range
		ai_fire(target)
		return	//end if(ai_controlled)
	if(istype(target, /obj/structure/overmap))
		var/obj/structure/overmap/ship = target
		ship.add_enemy(src)
	next_firetime = world.time + fire_delay
	fire_weapon(target)

/obj/structure/overmap/verb/cycle_firemode()
	set name = "Switch firemode"
	set category = "Ship"
	set src = usr.loc
	if(usr != gunner)
		return

	var/stop = fire_mode
	fire_mode = WRAP_AROUND_VALUE(fire_mode + 1, 1, weapons.len + 1)

	for(fire_mode; fire_mode != stop; fire_mode = WRAP_AROUND_VALUE(fire_mode + 1, 1, weapons.len + 1))
		stoplag()
		if(swap_to(fire_mode))
			var/datum/ship_weapon/SW = weapon_types[fire_mode]
			to_chat(gunner, SW.select_alert)
			return

	// No other weapons available, go with whatever we had before
	fire_mode = stop

/obj/structure/overmap/proc/get_max_firemode()
	if(mass < MASS_MEDIUM) //Small craft dont get a railgun
		return FIRE_MODE_TORPEDO
	return FIRE_MODE_RAILGUN

/obj/structure/overmap/proc/swap_to(what=FIRE_MODE_PDC)
	if(ai_controlled || (!linked_areas.len && role != MAIN_OVERMAP)) //AI ships and fighters don't have interiors
		if((what == FIRE_MODE_TORPEDO) && !torpedoes) //Out of torpedoes
			return FALSE
		if(!(weapon_types[what]))
			return FALSE
	else if(!weapons || !weapons[what] || !weapons[what].len) //Hero ship doesn't have any weapons of this type
		return FALSE

	if(!weapon_types[what])
		return
	var/datum/ship_weapon/SW = weapon_types[what]
	fire_delay = initial(fire_delay) + SW.fire_delay
	fire_mode = what
	if(ai_controlled)
		fire_delay += 10 //Make it fair on the humans who have to actually reload and stuff.

	return TRUE

/obj/structure/overmap/proc/firemode2text(mode)
	if(!weapons[mode][1])
		return "Weapon type not found"
	var/list/selected = weapons[mode] //Clunky, but dreamchecker wanted it this way.
	var/atom/found = selected[1]
	return "[found.name]"

/obj/structure/overmap/proc/fire_weapon(atom/target, mode=fire_mode, lateral=(mass > MASS_TINY), mob/user_override=null) //"Lateral" means that your ship doesnt have to face the target
	var/failed = TRUE //Failsafe var for use in extreme lag. This should avoid situations where weapons tell the gunner that they can't fire.
	if(ai_controlled || (!linked_areas.len && role != MAIN_OVERMAP)) //AI ships and fighters don't have interiors
		if(mode == FIRE_MODE_TORPEDO || mode == FIRE_MODE_MISSILE) //because fighter torpedoes are special
			if(fire_ordnance(target, mode))
				return TRUE
		else
			var/datum/ship_weapon/weapon_type = weapon_types[mode]
			if(!weapon_type)
				return FALSE
			var/obj/proj_type = weapon_type.default_projectile_type
			for(var/i; i < weapon_type.burst_size; i++)
				fire_projectile(proj_type, target, lateral=weapon_type.lateral)
				sleep(1)
			return TRUE
	else if(weapons[mode] && weapons[mode].len) //It's the main ship, see if any part of our battery can fire
		for(var/obj/machinery/ship_weapon/SW in weapons[mode])
			if(SW.can_fire())
				failed = FALSE //Just in case the logging fucks up for whatever godforsaken reason.
				SW.fire(target, manual=(mode == fire_mode))
				add_enemy(target) //So that PVP holds up the spawning of AI enemies somewhat.
				LAZYADD(weapon_log, "[station_time_timestamp()] [(gunner) ? gunner.name : "unknown gunner"] ([(gunner && gunner.mind && gunner.mind.antag_datums) ? "<b>Antagonist</b>" : "Non-Antagonist"]) fired [firemode2text(fire_mode)] at [target]")
				return TRUE
	if(gunner && failed) //Tell them we failed
		if(world.time < next_firetime) //Silence, SPAM.
			return FALSE
		var/datum/ship_weapon/SW = weapon_types[fire_mode]
		if(SW.selectable) //So they only get notified when their firing action was not successful.
			to_chat(gunner, SW.failure_alert)
	return FALSE

/obj/structure/overmap/proc/fire_ordnance(atom/target, mode=fire_mode)
	if(mode == FIRE_MODE_TORPEDO)
		return fire_torpedo(target)
	if(mode == FIRE_MODE_MISSILE)
		return fire_missile(target)
	return FALSE

/obj/structure/overmap/proc/fire_torpedo(atom/target)
	if(ai_controlled || !linked_areas.len && role != MAIN_OVERMAP) //AI ships and fighters don't have interiors
		if(torpedoes <= 0)
			return FALSE
		torpedoes --
		fire_projectile(/obj/item/projectile/guided_munition/torpedo, target, homing = TRUE, speed=3, explosive = TRUE)
		var/obj/structure/overmap/OM = target
		if(istype(OM, /obj/structure/overmap) && OM.dradis)
			OM.dradis?.relay_sound('nsv13/sound/effects/fighters/launchwarning.ogg')
		return TRUE

/obj/structure/overmap/proc/fire_missile(atom/target)
	if(ai_controlled || !linked_areas.len && role != MAIN_OVERMAP) //AI ships and fighters don't have interiors
		if(missiles <= 0)
			return FALSE
		missiles --
		fire_projectile(/obj/item/projectile/guided_munition/missile, target, homing = TRUE, speed=1, explosive = TRUE)
		var/obj/structure/overmap/OM = target
		if(istype(OM, /obj/structure/overmap) && OM.dradis)
			OM.dradis?.relay_sound('nsv13/sound/effects/fighters/launchwarning.ogg')
		return TRUE

/obj/structure/overmap/proc/shake_everyone(severity)
	for(var/mob/M in mobs_in_ship)
		if(M.client)
			shake_camera(M, severity, 1)

/obj/structure/overmap/bullet_act(obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/beam/overmap/aiming_beam))
		return
	relay_damage(P?.type)
	. = ..()

/obj/structure/overmap/proc/relay_damage(proj_type)
	if(role != MAIN_OVERMAP)
		return
	var/turf/pickedstart
	var/turf/pickedgoal
	var/max_i = 10//number of tries to spawn bullet.
	while(!isspaceturf(pickedstart))
		var/startSide = pick(GLOB.cardinals)
		var/startZ = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
		pickedstart = spaceDebrisStartLoc(startSide, startZ)
		pickedgoal = spaceDebrisFinishLoc(startSide, startZ)
		max_i--
		if(max_i<=0)
			return
	var/obj/item/projectile/proj = new proj_type(pickedstart)
	proj.starting = pickedstart
	proj.firer = null
	proj.def_zone = "chest"
	proj.original = pickedgoal
	spawn()
		proj.fire(Get_Angle(pickedstart,pickedgoal))
		proj.set_pixel_speed(4)

/obj/structure/overmap/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	if(is_player_ship()) //Code for handling "superstructure crit" only applies to the player ship, nothing else.
		if(obj_integrity <= damage_amount || structure_crit) //Superstructure crit! They would explode otherwise, unable to withstand the hit.
			obj_integrity = 10 //Automatically set them to 10 HP, so that the hit isn't totally ignored. Say if we have a nuke dealing 1800 DMG (the ship's full health) this stops them from not taking damage from it, as it's more DMG than we can handle.
			handle_crit(damage_amount)
			return FALSE
	. = ..()

/obj/structure/overmap/proc/is_player_ship() //Should this ship be considered a player ship? This doesnt count fighters because they need to actually die.
	if(linked_areas.len || role == MAIN_OVERMAP)
		return TRUE
	return FALSE

/obj/structure/overmap
	var/structure_crit = FALSE
	var/explosion_cooldown = FALSE

/obj/structure/overmap/proc/handle_crit(damage_amount) //A proc to allow ships to enter superstructure crit, this means the player ship can't die, but its insides can get torn to shreds.
	if(!structure_crit)
		relay('nsv13/sound/effects/ship/crit_alarm.ogg', message=null, loop=TRUE, channel=CHANNEL_SHIP_FX)
		priority_announce("DANGER. Ship superstructure failing. Structural integrity failure imminent. Immediate repairs are required to avoid total structural failure.","Automated announcement ([src])") //TEMP! Remove this shit when we move ruin spawns off-z
		structure_crit = TRUE
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
		if(isliving(M) && M.client?.prefs.toggles & SOUND_AMBIENCE) && M.can_hear_ambience())
			to_chat(M, "<span class='userdanger'>You hear a loud creak coming from above you. Take cover!</span>")
			SEND_SOUND(M, pick('nsv13/sound/ambience/ship_damage/creak5.ogg','nsv13/sound/ambience/ship_damage/creak6.ogg'))

/obj/effect/temp_visual/explosion_telegraph/Destroy()
	var/turf/T = get_turf(src)
	explosion(T,3,4,4)
	. = ..()
