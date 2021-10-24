/obj/structure/overmap/proc/add_weapon_overlay(type)
	var/path = text2path(type)
	var/obj/weapon_overlay/OL = new path
	OL.icon = icon
	OL.appearance_flags |= KEEP_APART
	OL.appearance_flags |= RESET_TRANSFORM
	vis_contents += OL
	weapon_overlays += OL
	return OL

/obj/structure/overmap/proc/fire(atom/target)
	if(weapon_safety)
		if(gunner)
			to_chat(gunner, "<span class='warning'>Weapon safety interlocks are active! Use the ship verbs tab to disable them!</span>")
		return
	handle_cloak(CLOAK_TEMPORARY_LOSS)
	last_target = target
	if(ai_controlled) //Let the AI switch weapons according to range
		ai_fire(target)
		return	//end if(ai_controlled)
	if(istype(target, /obj/structure/overmap))
		var/obj/structure/overmap/ship = target
		ship.add_enemy(src)
	fire_weapon(target)

/obj/structure/overmap/proc/fire_weapon(atom/target, mode=fire_mode, lateral=(mass > MASS_TINY), mob/user_override=gunner, ai_aim=FALSE) //"Lateral" means that your ship doesnt have to face the target
	var/datum/ship_weapon/SW = weapon_types[mode]
	if(weapon_safety)
		return FALSE
	if(SW?.fire(target, ai_aim=ai_aim))
		return TRUE
	else
		if(user_override && SW) //Tell them we failed
			if(world.time < SW.next_firetime) //Silence, SPAM.
				return FALSE
			to_chat(user_override, SW.failure_alert)
	return FALSE

/obj/structure/overmap/verb/cycle_firemode()
	set name = "Switch firemode"
	set category = "Ship"
	set src = usr.loc
	if(usr != gunner)
		return

	var/stop = fire_mode
	fire_mode = WRAP_AROUND_VALUE(fire_mode + 1, 1, weapon_types.len + 1)

	for(fire_mode; fire_mode != stop; fire_mode = WRAP_AROUND_VALUE(fire_mode + 1, 1, weapon_types.len + 1))
		if(swap_to(fire_mode))
			return TRUE

	// No other weapons available, go with whatever we had before
	fire_mode = stop

/obj/structure/overmap/proc/get_max_firemode()
	if(mass < MASS_MEDIUM) //Small craft dont get a railgun
		return FIRE_MODE_TORPEDO
	return FIRE_MODE_MAC

/obj/structure/overmap/proc/swap_to(what=FIRE_MODE_ANTI_AIR)
	if(!weapon_types[what])
		return FALSE
	var/datum/ship_weapon/SW = weapon_types[what]
	if(!SW.selectable)
		return FALSE
	fire_mode = what
	if(world.time > switchsound_cooldown)
		relay(SW.overmap_select_sound)
		switchsound_cooldown = world.time + 5 SECONDS
	if(gunner)
		to_chat(gunner, SW.select_alert)
	return TRUE

/obj/structure/overmap/proc/fire_torpedo(atom/target, ai_aim = FALSE)
	if(ai_controlled || !linked_areas.len && role != MAIN_OVERMAP) //AI ships and fighters don't have interiors
		if(torpedoes <= 0)
			return FALSE
		torpedoes --
		var/obj/structure/overmap/OM = target
		if(istype(OM))
			ai_aim = FALSE // This is a homing projectile
		fire_projectile(torpedo_type, target, homing = TRUE, speed=3, lateral = TRUE, ai_aim = ai_aim)
		if(istype(OM, /obj/structure/overmap) && OM.dradis)
			OM.dradis?.relay_sound('nsv13/sound/effects/fighters/launchwarning.ogg')
		var/datum/ship_weapon/SW = weapon_types[FIRE_MODE_TORPEDO]
		relay_to_nearby(pick(SW.overmap_firing_sounds))
		return TRUE

/obj/structure/overmap/proc/fire_missile(atom/target, ai_aim = FALSE)
	if(ai_controlled || !linked_areas.len && role != MAIN_OVERMAP) //AI ships and fighters don't have interiors
		if(missiles <= 0)
			return FALSE
		missiles --
		var/obj/structure/overmap/OM = target
		if(istype(OM))
			ai_aim = FALSE // This is a homing projectile
		fire_projectile(/obj/item/projectile/guided_munition/missile, target, homing = TRUE, lateral = FALSE, ai_aim = ai_aim)
		if(istype(OM, /obj/structure/overmap) && OM.dradis)
			OM.dradis?.relay_sound('nsv13/sound/effects/fighters/launchwarning.ogg')
		var/datum/ship_weapon/SW = weapon_types[FIRE_MODE_MISSILE]
		relay_to_nearby(pick(SW.overmap_firing_sounds))
		return TRUE
