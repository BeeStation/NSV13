/*
This proc handles one 'cycle' of fleet combat.
A cycle happens every time the starsystem controller handles all systems with conflict.
During combat, each ship from every fleet fires at one ship of a hostile fleet.
Defending fleets have priority for shooting (A turn iterates through a system's fleets in order, so fleets that were there first get to fire first.

*/

#define DICE_DAMAGE_MULTIPLIER 20	//A pretty important define for how 'fast' combat is resolved. The final damage value of an attack gets multiplied by this before it gets applied as actual obj_damage.

#define COMBAT_ACTIVE 1
#define COMBAT_SKIPPED 2
#define COMBAT_ENDED 3

/datum/star_system/proc/handle_combat()
	if(!fleets || !fleets.len || fleets.len == 1)
		SSstar_system.contested_systems.Remove(src)
		return COMBAT_ENDED

	if(occupying_z)	//Lets not play dice games if players are watching
		return COMBAT_SKIPPED

	if(!check_conflict_status())
		SSstar_system.contested_systems.Remove(src)
		return COMBAT_ENDED

	//Now, do actual combat stuff
	for(var/datum/fleet/F in fleets)
		if(!F || QDELETED(F))	//Lets be safe
			continue
		for(var/datum/fleet/EF in shuffle(fleets - F))
			if(!EF || QDELETED(EF))
				continue
			if(EF.faction_id != F.faction_id)
				fleet_fire(F, EF)
				break

	return COMBAT_ACTIVE

/datum/star_system/proc/check_conflict_status()
	for(var/i = 1; i <= fleets.len; i++)
		var/datum/fleet/F = fleets[i]
		for(var/j = i + 1; j <= fleets.len; j++)
			var/datum/fleet/FF = fleets[j]
			if(F.faction_id != FF.faction_id)
				return TRUE

	return FALSE

/datum/star_system/proc/fleet_fire(var/datum/fleet/firing, var/datum/fleet/target)
	for(var/obj/structure/overmap/OM in firing.all_ships)
		if(!OM || QDELETED(OM))
			continue
		if(!target.all_ships || !target.all_ships.len)
			break
		var/obj/structure/overmap/OMT = pick(target.all_ships)
		if(!OMT || QDELETED(OMT))
			continue
		ship_fire(OM, OMT)

//The actual interesting part. Ships roll their dice against eachother
/datum/star_system/proc/ship_fire(var/obj/structure/overmap/firing, var/obj/structure/overmap/target)
	var/datum/combat_dice/Fdice = firing.npc_combat_dice
	var/datum/combat_dice/Tdice = target.npc_combat_dice

	var/affinity_target = FALSE
	if(target.has_ai_trait(Fdice.affinity))
		affinity_target = TRUE

	var/targetting_roll = 0
	for(var/i = 1; i <= Fdice.target_dice; i++)
		targetting_roll += rand(1, Fdice.target_roll)
	targetting_roll += Fdice.target_bonus

	if(affinity_target)
		targetting_roll = CEILING(targetting_roll * 1.5, 1)

	var/evading_roll = 0
	for(var/i = 1; i <= Tdice.evade_dice; i++)
		evading_roll += rand(1, Tdice.evade_roll)
	evading_roll += Tdice.evade_bonus

	if(evading_roll > targetting_roll)
		return //Dodged it.

	if(evading_roll)
		targetting_roll -= evading_roll	//armor pen gets reduced by evade.

	var/armoring_roll = 0
	for(var/i = 1; i <= Tdice.armor_dice; i++)
		armoring_roll += rand(1, Tdice.armor_roll)
	armoring_roll += Tdice.armor_bonus

	if(targetting_roll)
		armoring_roll -= targetting_roll

	var/damaging_roll = 0
	for(var/i = 1; i <= Fdice.damage_dice; i++)
		damaging_roll += rand(1, Fdice.damage_roll)
	damaging_roll += Fdice.damage_bonus

	if(affinity_target)
		damaging_roll = CEILING(damaging_roll * 1.5, 1)

	if(armoring_roll)
		damaging_roll -= armoring_roll

	if(damaging_roll)
		target.take_damage(damaging_roll * DICE_DAMAGE_MULTIPLIER, BRUTE, "overmap_heavy", FALSE)	//All npc combat deals overmap_heavy damage.

#undef DICE_DAMAGE_MULTIPLIER
