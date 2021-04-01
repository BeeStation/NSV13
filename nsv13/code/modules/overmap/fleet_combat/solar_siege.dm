/*
Handles Sol being sieged, simillar to the FTL siege timer.
Only is active when there's an Earthbuster fleet in the Sol system, sends a command report every combat tick.
Note: This expects the EDF to be in Sol, and not somewhere in Brazil due to adminbus.
*/

/datum/star_system/sol/handle_combat()
	. = ..()
	if(. == COMBAT_SKIPPED)
		return

	var/datum/fleet/siege_fleet
	var/datum/fleet/defense_fleet

	for(var/datum/fleet/F in fleets)
		if(istype(F, /datum/fleet/earthbuster))
			siege_fleet = F
			break
	for(var/datum/fleet/F in fleets)
		if(istype(F, /datum/fleet/nanotrasen/earth) && !QDELETED(F))
			defense_fleet = F
			break
	if(!defense_fleet)	//Assumption: The EDF is always either in Sol or dead aka gameended.
		return

	if(siege_fleet)
		solar_siege_cycles_left--
		if(!solar_siege_cycles_left)
			for(var/datum/fleet/F in fleets)
				if(istype(F, /datum/fleet/nanotrasen/earth))
					F.defeat()
					break
		else if(solar_siege_cycles_left < solar_siege_cycles_needed - 1)
			priority_announce("Relaying Sol situation update: Hostile fleet is still present in the system and currently sieging planetary defenses. Total failure of defensive measures expected in about [solar_siege_cycles_left * COMBAT_CYCLE_INTERVAL / 600] minutes", "White Rapids Fleetwide Announcement")
		else
			priority_announce("Calling all mobile White Rapids fleet assets. An invasion fleet with considerable bombardement capability and approximately [siege_fleet.all_ships.len] ships has been detected entering the Sol system. All combat capable vessels are ordered to return and assist in system defense.", "White Rapids Fleetwide Announcement")

	else if(solar_siege_cycles_left < solar_siege_cycles_needed)
		solar_siege_cycles_left = solar_siege_cycles_needed
		priority_announce("Hostile invasion fleet in Sol has been successfully neutralized. All vessels are to return to their regular patrol patterns.", "White Rapids Fleetwide Announcement")
