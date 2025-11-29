//This file is for all the selection stuff related to osws.

/**
 * Returns the correct weapon list to use for a passed user.
 */
/obj/structure/overmap/proc/mob_weapon_datum_list(mob/living/user)
	if(!user)
		return list()
	if(gunner == user)
		if(pilot == user)
			return pilotgunner_weapon_datums
		else
			return gunner_weapon_datums
	else if(pilot == user)
		return pilot_weapon_datums
	return list()

/**
 * Adjusts the sort priority of the weapon (affecting cycling & AI selection)
 * * Drops all current weapon selection on use
 */
/datum/overmap_ship_weapon/proc/adjust_priority(new_priority)
	if(new_priority == sort_priority)
		return
	sort_priority = new_priority
	var/list/current_users = list() //List of users to carryover through reorganization
	for(var/mob/user in linked_overmap.controlled_weapon_datum)
		current_users += user
	linked_overmap.drop_all_weapon_selection()
	reinsert_into_overmap_weapons()
	for(var/mob/user in current_users)
		linked_overmap.increment_selected_weapon(user, no_sound = TRUE)

/**
 * Selects the weapon of this number.
 * * Called by e.g. the select weapon keybind.
 */
/obj/structure/overmap/proc/select_weapon(number, mob/user)
	if(number <= 0)
		return
	var/list/available_weapons = mob_weapon_datum_list(user)
	var/num_available = length(available_weapons)
	if(!num_available || num_available < number)
		return
	var/datum/overmap_ship_weapon/new_weapon = available_weapons[number]
	new_weapon.swap_to(user, number)

/**
 * Clears the selected weapons for the passed user.
 * * Usually called when someone stops piloting / gunning.
 */
/obj/structure/overmap/proc/drop_weapon_selection(mob/user)
	if(controlled_weapon_datum[user])
		var/datum/overmap_ship_weapon/dropping_weapon = controlled_weapon_datum[user]
		dropping_weapon.on_swap_from()
	controlled_weapons -= user
	controlled_weapon_datum -= user

/**
 * This unselects all weapons for all users.
 */
/obj/structure/overmap/proc/drop_all_weapon_selection()
	for(var/key in controlled_weapon_datum)
		var/datum/overmap_ship_weapon/dropping_weapon = controlled_weapon_datum[key]
		if(dropping_weapon)
			dropping_weapon.on_swap_from()
	controlled_weapon_datum.Cut()
	controlled_weapons.Cut()

/**
 * Moves selected weapon up by 1 for the selected user.
 */
/obj/structure/overmap/proc/increment_selected_weapon(mob/user, no_message = FALSE, no_sound = FALSE)
	var/list/available_weapons = mob_weapon_datum_list(user)
	if(!length(available_weapons))
		return
	if(length(available_weapons) == 1 || !controlled_weapons[user] || !controlled_weapon_datum[user])
		var/datum/overmap_ship_weapon/new_weapon = available_weapons[1]
		return new_weapon.swap_to(user, 1, no_message, no_sound)
	var/current_weapon_index = controlled_weapons[user]
	var/maximum_mode = length(available_weapons)
	var/target_index = current_weapon_index + 1
	if(target_index > maximum_mode)
		target_index = target_index % maximum_mode
	var/datum/overmap_ship_weapon/new_selection = available_weapons[target_index]
	return new_selection.swap_to(user, target_index, no_message, no_sound)


/**
 * Handles swapping to this weapon
 */
/datum/overmap_ship_weapon/proc/swap_to(mob/user, control_index, no_message = FALSE, no_sound = FALSE)
	var/datum/overmap_ship_weapon/old_weapon = linked_overmap.controlled_weapon_datum[user]
	linked_overmap.controlled_weapons[user] = control_index
	linked_overmap.controlled_weapon_datum[user] = src
	if(old_weapon == src)
		return TRUE //No changes being applied.
	if(old_weapon)
		old_weapon.on_swap_from()
	on_swap_to()
	if(overmap_select_sound && !no_sound && world.time > linked_overmap.switchsound_cooldown)
		linked_overmap.relay(overmap_select_sound)
		linked_overmap.switchsound_cooldown = world.time + 5 SECONDS
	if(select_alert && !no_message && user)
		to_chat(user, select_alert)
	return TRUE

/datum/overmap_ship_weapon/proc/on_swap_to()
	controller_count++

/datum/overmap_ship_weapon/proc/on_swap_from()
	controller_count--
