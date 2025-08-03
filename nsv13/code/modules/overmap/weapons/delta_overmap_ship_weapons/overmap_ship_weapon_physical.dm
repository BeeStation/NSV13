//This file is for things related to linkage the the "real" in-world weapons.

//Overmap proc that leads us here

/**
 * Links a physical ship weapon on this (src) ship to an appropriate ship weapon datum or creates one if needed.
 */
/obj/structure/overmap/proc/add_weapon(obj/machinery/ship_weapon/weapon)
	if(!weapon_addition_allowed)
		return
	var/desired_type = weapon.weapon_datum_type
	for(var/datum/overmap_ship_weapon/ship_weapon_datum in overmap_weapon_datums)
		if(ship_weapon_datum.type != desired_type)
			continue
		ship_weapon_datum.link_physical_weapon(weapon)
		return

	/*
	We have reached the end,
	there was no proper weapon for us -
	Thus, create one from nothing.
	*/

	var/datum/overmap_ship_weapon/new_weapon = new desired_type(src)
	new_weapon.link_physical_weapon(weapon)
	new_weapon.delete_if_last_weapon_removed = TRUE //Lets not keep unneeded at-runtime created guns around to prevent clutter.


/*
Warning: Most of the following procs expect a /obj/machinery/ship_weapon, but have their arguments left ambiguous to let you do weird stuff in child procs.
If you intend to make use of that quirk (by handling non-machinery), override the procs and don't use them as is.
*/


/**
 * Links a passed physical weapon to this ship weapon datum.
 */
/datum/overmap_ship_weapon/proc/link_physical_weapon(weapon)
	var/obj/machinery/ship_weapon/physical_weapon = weapon
	weapons["all"] |= physical_weapon
	physical_weapon.linked_overmap_ship_weapon = src

/**
 * Unlinks a passed physical weapon from this weapon datum (may lead to deletion of datum if at-need created)
 */
/datum/overmap_ship_weapon/proc/unlink_physical_weapon(weapon, bypass_delete_on_last_weapon = FALSE)
	var/obj/machinery/ship_weapon/physical_weapon = weapon
	weapons["all"] -= physical_weapon
	weapons["loaded"] -= physical_weapon
	physical_weapon.linked_overmap_ship_weapon = null
	if(delete_if_last_weapon_removed && !bypass_delete_on_last_weapon && !length(weapons["all"]))
		unlink_and_delete_weapon() //I could just call qdel but this is cleaner to read.

/**
 * Unlinks all linked physical weapons from this weapon datum. Called mostly by destroy.
 */
/datum/overmap_ship_weapon/proc/unlink_all_physical_weapons(bypass_delete_on_last_weapon = FALSE)
	for(var/obj/machinery/ship_weapon/weapon in weapons)
		unlink_physical_weapon(weapon, bypass_delete_on_last_weapon)

/**
 * By default, adds the passed physical weapon to the weapons counting as loaded.
 */
/datum/overmap_ship_weapon/proc/mark_physical_weapon_loaded(weapon)
	weapons["loaded"] |= weapon

/**
 * By default, removes the passed physical weapon from the weapons counting as loaded.
 */
/datum/overmap_ship_weapon/proc/mark_physical_weapon_unloaded(weapon)
	weapons["loaded"] -= weapon

