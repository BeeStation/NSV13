/obj/structure/overmap/proc/add_weapon_overlay(type)
	var/path = text2path(type)
	var/obj/weapon_overlay/OL = new path
	OL.icon = icon
	OL.appearance_flags |= KEEP_APART
	OL.appearance_flags |= RESET_TRANSFORM
	vis_contents += OL
	weapon_overlays += OL
	return OL

/obj/structure/overmap/proc/fire(atom/target, mob/user, datum/overmap_ship_weapon/firing_weapon)
	if(weapon_safety)
		if(user)
			to_chat(user, "<span class='warning'>Weapon safety interlocks are active! Use the ship verbs tab to disable them!</span>")
		return
	if(!firing_weapon && !ai_controlled)
		if(!user)
			return
		else
			if(!controlled_weapon_datum[user])
				return
			var/datum/overmap_ship_weapon/selected_weapon = controlled_weapon_datum
			if(!istype(selected_weapon))
				return
			firing_weapon = selected_weapon

	handle_cloak(CLOAK_TEMPORARY_LOSS)
	last_target = target
	if(ai_controlled) //Let the AI switch weapons according to range
		ai_fire(target)
		return
	if(istype(target, /obj/structure/overmap))
		var/obj/structure/overmap/ship = target
		ship.add_enemy(src)
	if(user)
		fire_weapon(target, user, firing_weapon)
	else
		fire_weapon(target, firing_weapon = firing_weapon)

/obj/structure/overmap/proc/fire_weapon(atom/target, mob/user_override=gunner, datum/overmap_ship_weapon/firing_weapon, ai_aim=FALSE) //"Lateral" means that your ship doesnt have to face the target
	if(ghost_controlled) //Hook in our ghost ship functions
		if(!firing_weapon.get_ammo())
			if(!ai_resupply_scheduled)
				ai_resupply_scheduled = TRUE
				addtimer(CALLBACK(src, PROC_REF(ai_self_resupply)), ai_resupply_time)

	if(weapon_safety)
		return FALSE
	if((firing_weapon.fire_proc_chain(target, user_override, ai_aim=ai_aim)))
		return TRUE
	else
		. = FALSE
		if(user_override && firing_weapon) //Tell them we failed
			if(world.time < firing_weapon.next_firetime) //Silence, SPAM.
				return
			to_chat(user_override, firing_weapon.failure_alert)

//OSW WIP - DELETE ALL AFTER THIS

/obj/structure/overmap/proc/fire_torpedo(atom/target, ai_aim = FALSE, burst = 1)
	if(ai_controlled || !linked_areas.len && role != MAIN_OVERMAP) //AI ships and fighters don't have interiors
		if(torpedoes <= 0)
			return FALSE
		if(isovermap(target))
			ai_aim = FALSE // This is a homing projectile
		var/launches = min(torpedoes, burst)

		fire_projectile(torpedo_type, target, speed=3, lateral = TRUE, ai_aim = ai_aim)
		var/datum/ship_weapon/SW = weapon_types[FIRE_MODE_TORPEDO]
		relay_to_nearby(pick(SW.overmap_firing_sounds))

		if(launches > 1)
			fire_torpedo_burst(target, ai_aim, launches - 1)
		torpedoes -= launches
		return TRUE

/obj/structure/overmap/proc/fire_torpedo_burst(atom/target, ai_aim = FALSE, burst = 1)
	set waitfor = FALSE
	for(var/cycle = 1; cycle <= burst; cycle++)
		sleep(3)
		if(QDELETED(src))	//We might get shot.
			return
		if(QDELETED(target))
			target = null
		fire_projectile(torpedo_type, target, speed=3, lateral = TRUE, ai_aim = ai_aim)
		var/datum/ship_weapon/SW = weapon_types[FIRE_MODE_TORPEDO]
		relay_to_nearby(pick(SW.overmap_firing_sounds))


//Burst arg currently unused for this proc.
/obj/structure/overmap/proc/fire_missile(atom/target, ai_aim = FALSE, burst = 1)
	if(ai_controlled || !linked_areas.len && role != MAIN_OVERMAP) //AI ships and fighters don't have interiors
		if(missiles <= 0)
			return FALSE
		missiles --
		var/obj/structure/overmap/OM = target
		if(istype(OM))
			ai_aim = FALSE // This is a homing projectile
		fire_projectile(missile_type, target, lateral = FALSE, ai_aim = ai_aim)
		var/datum/ship_weapon/SW = weapon_types[FIRE_MODE_MISSILE]
		relay_to_nearby(pick(SW.overmap_firing_sounds))
		return TRUE
