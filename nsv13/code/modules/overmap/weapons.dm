
/obj/item/projectile/bullet/pdc_round
	icon_state = "pdc"
	name = "teflon coated tungsten round"
	damage = 5

/obj/item/projectile/bullet/railgun_slug
	icon_state = "railgun"
	name = "hyper accelerated tungsten slug"
	damage = 80
	movement_type = FLYING | UNSTOPPABLE //Railguns punch straight through your ship

/obj/item/projectile/bullet/torpedo
	icon_state = "torpedo"
	name = "plasma torpedo"
	damage = 60
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo
	var/detonation_timer = 20 SECONDS

/obj/item/projectile/bullet/laser
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "heavylaser"
	// TODO: Balance
	damage = 110

/obj/effect/temp_visual/impact_effect/torpedo
	icon_state = "impact_torpedo"
	duration = 10

/obj/effect/temp_visual/impact_effect/torpedo/nuke
	icon_state = "explosion"
	duration = 10

/obj/effect/temp_visual/overmap_explosion
	icon = 'nsv13/goonstation/icons/hugeexplosion.dmi'
	icon_state = "explosion"
	duration = 10

/obj/effect/temp_visual/overmap_explosion/alt
	icon = 'nsv13/goonstation/icons/hugeexplosion2.dmi'
	icon_state = "explosion"
	duration = 10

/obj/item/projectile/bullet/torpedo/on_hit(atom/target, blocked = FALSE)
	..()
	if(istype(target, /obj/structure/overmap)) //Were we to explode on an actual overmap, this would oneshot the ship as it's a powerful explosion.
		return BULLET_ACT_HIT
	explosion(target, 2, 4, 4)
	return BULLET_ACT_HIT

/obj/item/projectile/bullet/torpedo/Crossed(atom/movable/AM) //Here, we check if the bullet that hit us is from a friendly ship. If it's from an enemy ship, we explode as we've been flak'd down.
	. = ..()
	if(istype(AM, /obj/item/projectile))
		var/obj/item/projectile/proj = AM
		if(!ismob(firer) || !ismob(proj.firer)) //Unlikely to ever happen but if it does, ignore.
			return
		var/mob/checking = firer
		var/mob/enemy = proj.firer
		if(checking.overmap_ship && enemy.overmap_ship) //Firer is a mob, so check the faction of their ship
			var/obj/structure/overmap/OM = checking.overmap_ship
			var/obj/structure/overmap/our_ship = enemy.overmap_ship
			if(OM.faction != our_ship.faction)
				new /obj/effect/temp_visual/impact_effect/torpedo(get_turf(src)) //Exploding effect
				var/sound/chosen = pick('nsv13/sound/effects/ship/torpedo_detonate.ogg','nsv13/sound/effects/ship/freespace2/impacts/boom_2.wav','nsv13/sound/effects/ship/freespace2/impacts/boom_3.wav','nsv13/sound/effects/ship/freespace2/impacts/subhit.wav','nsv13/sound/effects/ship/freespace2/impacts/subhit2.wav','nsv13/sound/effects/ship/freespace2/impacts/m_hit.wav','nsv13/sound/effects/ship/freespace2/impacts/hit_1.wav')
				OM.relay_to_nearby(chosen)
				qdel(src)
				return FALSE

/obj/item/projectile/bullet/torpedo/Initialize()
	. = ..()
	QDEL_IN(src, detonation_timer)

/obj/item/projectile/bullet/torpedo/on_hit(atom/target, blocked = 0)
	if(isovermap(target))
		var/obj/structure/overmap/OM = target
		OM.torpedoes_to_target -= src
	return ..()

/obj/structure/overmap/proc/handle_pdcs()
	if(fire_mode == FIRE_MODE_PDC) //If theyre aiming the PDCs manually, don't automatically flak.
		return
	if(mass <= MASS_TINY && !ai_controlled) //Small ships don't get to use PDCs. AIs still need to aim like this, though
		return
	if(!last_target || QDELETED(last_target))
		last_target = null
	var/found_target = FALSE //Have we found a torpedo to shoot down? If we can't find a torpedo to shoot, look for enemy ships in range.
	if(torpedoes_to_target.len)  //Are there any torpedoes we need to worry about? Torpedoes enter this list as theyre shot (when they target us).
		for(var/X in torpedoes_to_target) //Check through the torpedoes that our PDCs need to target
			var/atom/target = X
			if(!target || QDELETED(target)) //Clear null bullets that may have runtimed
				torpedoes_to_target -= X
				continue
			var/target_range = get_dist(target,src)
			if(target_range <= initial(weapon_range)) //The torpedo is in range, let's target it!
				found_target = TRUE
				if(prob(pdc_miss_chance)) //Gives them a chance to actually hit a torpedo, so it's not a perfect smokescreen.
					var/turf/T = get_turf(pick(orange(6,target))) //Pick a random tile within 6 turfs, this isn't a flat out miss 100% of the time though
					fire_pdcs(T, lateral=TRUE)
				else
					fire_pdcs(target, lateral=TRUE)
	if(!found_target) //Can't see a torpedo to shoot, try find an enemy ship to shoot
		for(var/X in GLOB.overmap_objects)
			if(!istype(X, /obj/structure/overmap))
				continue
			var/obj/structure/overmap/ship = X
			if(ship == src || ship.faction == faction || ship.wrecked) //No friendly fire, don't blow up wrecks that the crew may wish to loot.
				continue
			var/target_range = get_dist(ship,src)
			if(target_range > initial(weapon_range)) //If the target is out of PDC range, don't shoot. This prevents OP shit like spamming torps AND PDC flak all over a target.
				continue
			if(!QDELETED(ship) && isovermap(ship))
				fire_pdcs(ship, lateral=TRUE)

/obj/structure/overmap/proc/fire_pdcs(atom/target, lateral=TRUE) //"Lateral" means that your ship doesnt have to face the target
	var/shots_per = 3
	if(!can_fire_pdcs(shots_per))
		to_chat(gunner, "<span class='warning'>DANGER: Point defense emplacements are unable to fire due to lack of ammunition.</span>")
		return
	var/sound/chosen = pick('nsv13/sound/effects/ship/pdc.ogg','nsv13/sound/effects/ship/pdc2.ogg','nsv13/sound/effects/ship/pdc3.ogg')
	relay_to_nearby(chosen)
	for(var/i = 0, i < shots_per, i++)
		sleep(1)
		if(lateral)
			fire_lateral_projectile(/obj/item/projectile/bullet/pdc_round, target)
		else
			fire_projectiles(/obj/item/projectile/bullet/pdc_round, target)

/obj/structure/overmap/proc/can_fire_pdcs(shots) //Trigger the PDCs to fire
	if(!linked_area && !main_overmap) //We need AIs to be able to use PDCs
		return TRUE
	if(!pdcs.len)
		return FALSE
	for(var/X in pdcs)
		var/obj/structure/pdc_mount/pdc = X
		if(pdc.fire(shots))
			return TRUE
	return FALSE

/obj/structure/overmap/proc/fire(atom/target)
	if(weapon_safety)
		if(gunner)
			to_chat(gunner, "<span class='warning'>Weapon safety interlocks are active! Use the ship verbs tab to disable them!</span>")
		return
	if(ai_controlled) //Let the AI switch weapons according to range
		var/target_range = get_dist(target,src)
		if(target_range > max_range) //Our max range is the maximum possible range we can engage in. This is to stop you getting hunted from outside of your view range.
			last_target = null
		if(target_range > initial(weapon_range)) //In other words, theyre out of PDC range
			if(torpedoes > 0) //If we have torpedoes loaded, let's use them
				swap_to(FIRE_MODE_TORPEDO)
			else //No torps, we'll have to use the railgun.
				swap_to(FIRE_MODE_RAILGUN)
		else
			if(mass < MASS_LARGE) //Big ships don't use their PDCs like this, and instead let them automatically shoot at the enemy.
				swap_to(FIRE_MODE_PDC)
			else
				swap_to(FIRE_MODE_RAILGUN)
	last_target = target
	if(next_firetime > world.time)
		to_chat(pilot, "<span class='warning'>WARNING: Weapons cooldown in effect to prevent overheat.</span>")
		return
	var/target_range = get_dist(target,src)
	if(target_range > weapon_range)
		var/out_of_range = target_range-weapon_range //EG. If he's 20 tiles away and my range is 15, say WARNING, he's 5 tiles out of range!
		to_chat(pilot, "<span class='notice'>Target acquisition failed. Target is [out_of_range] km out of effective weapons range.</span>")
		return
	if(istype(target, /obj/structure/overmap))
		var/obj/structure/overmap/ship = target
		ship.add_enemy(src)
	next_firetime = world.time + fire_delay
	switch(fire_mode)
		if(FIRE_MODE_PDC)
			fire_pdcs(target)
		if(FIRE_MODE_RAILGUN)
			fire_railgun(target)
		if(FIRE_MODE_TORPEDO) //In case of bugs.
			fire_torpedo(target)
		if(FIRE_MODE_LASER)
			fire_laser(target)

/obj/structure/overmap/verb/cycle_firemode()
	set name = "Switch firemode"
	set category = "Ship"
	set src = usr.loc
	if(usr != gunner)
		return
	var/max_firemode = FIRE_MODE_LASER
	if(mass < MASS_MEDIUM) //Small craft dont get a railgun
		max_firemode = FIRE_MODE_TORPEDO
	fire_mode ++
	if(fire_mode > max_firemode)
		fire_mode = FIRE_MODE_PDC
	switch(fire_mode)
		if(FIRE_MODE_PDC)
			to_chat(usr, "<span class='notice'>Defensive flak screens: <b>OFFLINE</b>. Activating manual point defense cannon control.</span>")
			relay('nsv13/sound/effects/ship/pdc_start.ogg')
			swap_to(FIRE_MODE_PDC)
		if(FIRE_MODE_RAILGUN)
			to_chat(usr, "<span class='notice'>Charging railgun hardpoints...</span>")
			relay('nsv13/sound/effects/ship/railgun_ready.ogg')
			swap_to(FIRE_MODE_RAILGUN)
		if(FIRE_MODE_TORPEDO)
			to_chat(usr, "<span class='notice'>Long range target acquisition systems: online.</span>")
			relay('nsv13/sound/effects/ship/reload.ogg')
			swap_to(FIRE_MODE_TORPEDO)
		if(FIRE_MODE_LASER)
			// TODO: add sound and a good message
			to_chat(usr, "<span class='notice'>TODO add laser message here</span>")
			swap_to(FIRE_MODE_LASER)


/obj/structure/overmap/proc/swap_to(what=FIRE_MODE_PDC)
	switch(what)
		if(FIRE_MODE_PDC)
			fire_delay = initial(fire_delay) //all ships start on PDC mode
			weapon_range = initial(weapon_range)
			fire_mode = FIRE_MODE_PDC
		if(FIRE_MODE_RAILGUN)
			fire_delay = 10 //Very limited ammo
			weapon_range = initial(weapon_range)+30 //Gain a large range bonus. This will take care of a lot of combat.
			fire_mode = FIRE_MODE_RAILGUN
		if(FIRE_MODE_TORPEDO)
			fire_delay = 5 //These things rip into your hull, but can be easily shot down
			weapon_range = initial(weapon_range)+30 //Most combat takes place at extreme ranges, torpedoes allow for this.
			fire_mode = FIRE_MODE_TORPEDO
		if(FIRE_MODE_LASER)
			fire_delay =30 // Probably too short, figure out the real charging time or something close
			weapon_range = initial(weapon_range)+10 //TODO: figure out range
	if(ai_controlled)
		fire_delay += 10 //Make it fair on the humans who have to actually reload and stuff.

/obj/structure/overmap/proc/fire_railgun(atom/target)
	if(ai_controlled) //AI ships don't have interiors
		fire_lateral_projectile(/obj/item/projectile/bullet/railgun_slug, target, 10)
		return
	var/proj_type = null //If this is true, we've got a launcher shipside that's been able to fire.
	var/atom/proj_object = null
	var/fired = FALSE
	for(var/X in railguns)
		if(istype(X, /obj/structure/ship_weapon/railgun))
			var/obj/structure/ship_weapon/railgun/RG = X
			if(RG.can_fire())
				proj_object = RG.fire()
				if(!proj_object)
					continue
				if(istype(proj_object, /obj/item/twohanded/required/railgun_ammo))
					var/obj/item/twohanded/required/railgun_ammo/RA = proj_object
					proj_type = RA.proj_type
					qdel(proj_object)
				if(proj_type)
					fired = TRUE
					break
	if(!fired)
		to_chat(gunner, "<span class='warning'>DANGER: Launch failure! Railgun systems are not loaded.</span>")
		return


	var/sound/chosen ='nsv13/sound/effects/ship/railgun_fire.ogg'
	relay_to_nearby(chosen)
	flick("railgun_charge",railgun_overlay)
	shake_everyone(2)
	if(proj_type)
		fire_lateral_projectile(proj_type, target, 5)

/obj/structure/overmap/proc/shake_everyone(severity)
	for(var/mob/M in mobs_in_ship)
		if(M.client)
			shake_camera(M, severity, 1)

/obj/structure/overmap/proc/fire_laser(atom/target)
	if(ai_controlled) //AI ships don't have interiors
		fire_projectiles(/obj/item/projectile/bullet/laser, target)
		return
	var/fired = FALSE
	for(var/X in ship_lasers)
		if(istype(X, /obj/structure/ship_weapon/laser_cannon))
			var/obj/structure/ship_weapon/laser_cannon/LC = X
			if(LC.can_fire())
				LC.fire()
				fired = TRUE
				break
			else
				to_chat(gunner, "<span class='warning'>The cannon cannot fire</span>")
		else
			to_chat(gunner, "<span class='warning'>This is not a laser cannon</span>")
	if(!fired)
		to_chat(gunner, "<span class='warning'>ERROR: Laser systems are offline.</span>")
		return

	var/sound/chosen ='sound/weapons/lasercannonfire.ogg'
	relay_to_nearby(chosen)
	flick("laser",laser_overlay)

/obj/structure/overmap/proc/fire_torpedo(atom/target)
	if(!linked_area && !main_overmap) //AI ships don't have interiors
		if(torpedoes <= 0)
			return
		fire_projectile(/obj/item/projectile/bullet/torpedo, target, homing = TRUE, speed=1, explosive = TRUE)
		torpedoes --
		return
	var/proj_type = null //If this is true, we've got a launcher shipside that's been able to fire.
	var/obj/structure/munition/proj_object = null
	var/proj_speed = 1
	for(var/X in torpedo_tubes)
		if(istype(X, /obj/structure/ship_weapon/torpedo_launcher))
			var/obj/structure/ship_weapon/torpedo_launcher/TL = X
			proj_object = TL.fire()
			if(proj_object)
				break //Found a gun and fired it. No need to fire all the guns at once

	proj_type = proj_object?.torpedo_type
	proj_speed = proj_object?.speed
	qdel(proj_object)
	if(proj_type)
		var/sound/chosen = pick('nsv13/sound/effects/ship/torpedo.ogg','nsv13/sound/effects/ship/freespace2/m_shrike.wav','nsv13/sound/effects/ship/freespace2/m_stiletto.wav','nsv13/sound/effects/ship/freespace2/m_tsunami.wav','nsv13/sound/effects/ship/freespace2/m_wasp.wav')
		relay_to_nearby(chosen)
		if(proj_type == /obj/item/projectile/bullet/torpedo/dud) //Some brainlet MAA loaded an incomplete torp
			fire_projectile(proj_type, target, homing = FALSE, speed=proj_speed, explosive = TRUE)
		else
			fire_projectile(proj_type, target, homing = TRUE, speed=proj_speed, explosive = TRUE)
	else
		to_chat(gunner, "<span class='warning'>DANGER: Launch failure! Torpedo tubes are not loaded.</span>")


/obj/structure/overmap/bullet_act(obj/item/projectile/P)
	relay_damage(P?.type)
	. = ..()

/obj/structure/overmap/proc/relay_damage(proj_type)
	if(!main_overmap)
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
	SEND_SIGNAL(src, COMSIG_DAMAGE_TAKEN, damage_amount) //Trigger to update our list of armour plates without making the server cry.
	if(main_overmap) //Code for handling "superstructure crit" only applies to the player ship, nothing else.
		if(obj_integrity <= damage_amount || structure_crit) //Superstructure crit! They would explode otherwise, unable to withstand the hit.
			obj_integrity = 10 //Automatically set them to 10 HP, so that the hit isn't totally ignored. Say if we have a nuke dealing 1800 DMG (the ship's full health) this stops them from not taking damage from it, as it's more DMG than we can handle.
			handle_crit(damage_amount)
			return FALSE
	. = ..()

/obj/structure/overmap
	var/structure_crit = FALSE
	var/explosion_cooldown = FALSE

/obj/structure/overmap/proc/handle_crit(damage_amount) //A proc to allow ships to enter superstructure crit, this means the player ship can't die, but its insides can get torn to shreds.
	if(!structure_crit)
		relay('nsv13/sound/effects/ship/crit_alarm.ogg', message=null, loop=TRUE, channel=CHANNEL_SHIP_FX)
		priority_announce("DANGER. Ship superstructure failing. Structural integrity failure imminent. Immediate repairs are required to avoid total structural failure.","Automated announcement") //TEMP! Remove this shit when we move ruin spawns off-z
		structure_crit = TRUE
	if(explosion_cooldown)
		return
	explosion_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, explosion_cooldown, FALSE), 5 SECONDS)
	var/name = pick(GLOB.teleportlocs) //Time to kill everyone
	var/area/target = GLOB.teleportlocs[name]
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
			priority_announce("Ship structural integrity restored to acceptable levels. ","Automated announcement")
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
		if(isliving(M))
			to_chat(M, "<span class='userdanger'>You hear a loud creak coming from above you. Take cover!</span>")
			SEND_SOUND(M, pick('nsv13/sound/ambience/ship_damage/creak5.ogg','nsv13/sound/ambience/ship_damage/creak6.ogg'))

/obj/effect/temp_visual/explosion_telegraph/Destroy()
	var/turf/T = get_turf(src)
	explosion(T,3,4,4)
	. = ..()