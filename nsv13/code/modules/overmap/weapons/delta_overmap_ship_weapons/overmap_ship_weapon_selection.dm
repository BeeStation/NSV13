//This file is for all the selection stuff related to osws.

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
 * Moves selected weapon up by 1 for the selected user.
 */
/obj/structure/overmap/proc/increment_selected_weapon(mob/user)
	var/list/available_weapons = mob_weapon_datum_list(usr)
	if(!length(available_weapons))
		return
	if(length(available_weapons) == 1 || !controlled_weapons[usr] || !controlled_weapon_datum[usr])
		var/datum/overmap_ship_weapon/new_weapon = available_weapons[1]
		return new_weapon.swap_to(user, 1)
	var/current_weapon_index = controlled_weapons[usr]
	var/maximum_mode = length(available_weapons)
	var/target_index = current_weapon_index + 1
	if(target_index > maximum_mode)
		target_index = target_index % maximum_mode
	var/datum/overmap_ship_weapon/new_selection = available_weapons[target_index]
	return new_selection.swap_to(user, target_index)


/**
 * Handles swapping to this weapon
 */
/datum/overmap_ship_weapon/proc/swap_to(mob/user, control_index)
	linked_overmap.controlled_weapons[user] = control_index
	linked_overmap.controlled_weapon_datum[user] = src
	if(world.time > linked_overmap.switchsound_cooldown)
		linked_overmap.relay(overmap_select_sound)
		linked_overmap.switchsound_cooldown = world.time + 5 SECONDS
	if(user)
		to_chat(user, select_alert)
	return TRUE
