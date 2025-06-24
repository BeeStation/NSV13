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

	last_target = target
	if(istype(target, /obj/structure/overmap))
		var/obj/structure/overmap/ship = target
		ship.add_enemy(src)
	if(ai_controlled) //This part of the proc doesn't really get reached with current calls, but why not have it be working anyways.
		if(firing_weapon)
			fire_weapon(target, firing_weapon = firing_weapon, ai_aim = TRUE)
			return
		//Let the AI switch weapons according to range
		if(ai_flags & AI_FLAG_ELITE)
			ai_elite_fire(target)
		else
			ai_fire(target)
		return
	if(user)
		fire_weapon(target, user, firing_weapon)
	else
		fire_weapon(target, firing_weapon = firing_weapon)

/obj/structure/overmap/proc/fire_weapon(atom/target, mob/user_override=gunner, datum/overmap_ship_weapon/firing_weapon, ai_aim=FALSE)
	if(ghost_controlled) //Hook in our ghost ship functions
		if(!firing_weapon.get_ammo())
			if(!ai_resupply_scheduled)
				ai_resupply_scheduled = TRUE
				addtimer(CALLBACK(src, PROC_REF(ai_self_resupply)), ai_resupply_time)

	if(weapon_safety)
		return FALSE
	. = firing_weapon.fire_proc_chain(target, user_override, ai_aim=ai_aim)
	if(!.)
		. = FALSE
		if(user_override && firing_weapon) //Tell them we failed
			if(world.time < firing_weapon.next_error_report) //Silence, SPAM.
				return
			to_chat(user_override, firing_weapon.failure_alert)
			firing_weapon.next_error_report = world.time + 0.5 SECONDS
