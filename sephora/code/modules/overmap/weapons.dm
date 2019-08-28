
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

/obj/effect/temp_visual/impact_effect/torpedo
	icon_state = "impact_torpedo"
	duration = 10

/obj/effect/temp_visual/impact_effect/torpedo/nuke
	icon_state = "explosion"
	duration = 10

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
				var/sound/chosen = pick('sephora/sound/effects/ship/torpedo_detonate.ogg','sephora/sound/effects/ship/freespace2/impacts/boom_2.wav','sephora/sound/effects/ship/freespace2/impacts/boom_3.wav','sephora/sound/effects/ship/freespace2/impacts/subhit.wav','sephora/sound/effects/ship/freespace2/impacts/subhit2.wav','sephora/sound/effects/ship/freespace2/impacts/m_hit.wav','sephora/sound/effects/ship/freespace2/impacts/hit_1.wav')
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
	if(fire_mode == FIRE_MODE_PDC) //If theyre aiming the PDCs manually, don't automatically flak
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
			if(ship == src || ship.faction == faction) //No friendly fire
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
	var/sound/chosen = pick('sephora/sound/effects/ship/pdc.ogg','sephora/sound/effects/ship/pdc2.ogg','sephora/sound/effects/ship/pdc3.ogg')
	relay_to_nearby(chosen)
	for(var/i = 0, i < shots_per, i++)
		sleep(1)
		if(lateral)
			fire_lateral_projectile(/obj/item/projectile/bullet/pdc_round, target)
		else
			fire_projectiles(/obj/item/projectile/bullet/pdc_round, target)

/obj/structure/overmap/proc/can_fire_pdcs(shots) //Trigger the PDCs to fire
	if(ai_controlled) //We need AIs to be able to use PDCs
		return TRUE
	if(!pdcs.len)
		return FALSE
	for(var/X in pdcs)
		var/obj/structure/pdc_mount/pdc = X
		if(pdc.fire(shots))
			return TRUE
	return FALSE

/obj/structure/overmap/proc/fire(atom/target)
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
			flick("railgun_charge",railgun_overlay)
			addtimer(CALLBACK(src, .proc/fire_railgun, target), 20)
			var/sound/chosen = pick('sephora/sound/effects/ship/railgun.ogg','sephora/sound/effects/ship/railgun2.ogg')
			relay_to_nearby(chosen)
		if(FIRE_MODE_TORPEDO) //In case of bugs.
			fire_torpedo(target)

/obj/structure/overmap/verb/cycle_firemode()
	set name = "Switch firemode"
	set category = "Ship"
	set src = usr.loc
	if(usr != gunner)
		return
	fire_mode ++
	if(fire_mode > FIRE_MODE_TORPEDO)
		fire_mode = FIRE_MODE_PDC
	switch(fire_mode)
		if(FIRE_MODE_PDC)
			to_chat(usr, "<span class='notice'>Defensive flak screens: <b>OFFLINE</b>. Activating manual point defense cannon control.</span>")
			relay('sephora/sound/effects/ship/pdc_start.ogg')
			swap_to(FIRE_MODE_PDC)
		if(FIRE_MODE_RAILGUN)
			to_chat(usr, "<span class='notice'>Charging railgun hardpoints...</span>")
			relay('sephora/sound/effects/ship/railgun_ready.ogg')
			swap_to(FIRE_MODE_RAILGUN)
		if(FIRE_MODE_TORPEDO)
			to_chat(usr, "<span class='notice'>Long range target acquisition systems: online.</span>")
			relay('sephora/sound/effects/ship/reload.ogg')
			swap_to(FIRE_MODE_TORPEDO)

/obj/structure/overmap/proc/swap_to(what=FIRE_MODE_PDC)
	switch(what)
		if(FIRE_MODE_PDC)
			fire_delay = initial(fire_delay) //all ships start on PDC mode
			weapon_range = initial(weapon_range)
			fire_mode = FIRE_MODE_PDC
		if(FIRE_MODE_RAILGUN)
			fire_delay = 50 //Takes time to charge up
			weapon_range = initial(weapon_range)+30 //Gain a large range bonus. This will take care of a lot of combat.
			fire_mode = FIRE_MODE_RAILGUN
		if(FIRE_MODE_TORPEDO)
			fire_delay = 5 //These things rip into your hull, but can be easily shot down
			weapon_range = initial(weapon_range)+30 //Most combat takes place at extreme ranges, torpedoes allow for this.
			fire_mode = FIRE_MODE_TORPEDO

/obj/structure/overmap/proc/fire_railgun(atom/target)
	if(ai_controlled) //AI ships don't have interiors
		fire_lateral_projectile(/obj/item/projectile/bullet/railgun_slug, target, 10)
		return
	var/proj_type = null //If this is true, we've got a railgun shipside that's been able to fire.
	for(var/X in railguns)
		if(istype(X, /obj/structure/ship_weapon/railgun))
			var/obj/structure/ship_weapon/railgun/RG = X
			proj_type = RG.fire()
			if(!proj_type)
				continue
	if(proj_type)
		fire_lateral_projectile(proj_type, target, 10)
	else
		to_chat(gunner, "<span class='warning'>DANGER: Launch failure! Railgun systems are not loaded.</span>")

/obj/structure/overmap/proc/fire_torpedo(atom/target)
	if(ai_controlled) //AI ships don't have interiors
		if(torpedoes <= 0)
			return
		fire_projectile(/obj/item/projectile/bullet/torpedo, target, homing = TRUE, speed=1, explosive = TRUE)
		torpedoes --
		return
	var/proj_type = null //If this is true, we've got a launcher shipside that's been able to fire.
	for(var/X in torpedo_tubes)
		if(istype(X, /obj/structure/ship_weapon/torpedo_launcher))
			var/obj/structure/ship_weapon/torpedo_launcher/TL = X
			proj_type = TL.fire()
			if(proj_type) //Found a gun and fired it. No need to fire all the guns at once
				break
	if(proj_type)
		var/sound/chosen = pick('sephora/sound/effects/ship/torpedo.ogg','sephora/sound/effects/ship/freespace2/m_shrike.wav','sephora/sound/effects/ship/freespace2/m_stiletto.wav','sephora/sound/effects/ship/freespace2/m_tsunami.wav','sephora/sound/effects/ship/freespace2/m_wasp.wav')
		relay_to_nearby(chosen)
		if(proj_type == /obj/item/projectile/bullet/torpedo/dud) //Some brainlet MAA loaded an incomplete torp
			fire_projectile(proj_type, target, homing = FALSE, speed=1, explosive = TRUE)
		else
			fire_projectile(proj_type, target, homing = TRUE, speed=1, explosive = TRUE)
	else
		to_chat(gunner, "<span class='warning'>DANGER: Launch failure! Torpedo tubes are not loaded.</span>")