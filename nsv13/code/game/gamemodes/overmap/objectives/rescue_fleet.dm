/datum/overmap_objective/rescue_fleet
	name = "Rescue Fleet"
	desc = "Travel to a designated system and rescue a friendly fleet"
	brief = "Travel to a designated system and rescue a friendly fleet"
	var/datum/star_system/selected_system

/datum/overmap_objective/rescue_fleet/instance()
	//Select a system to be targeted
	var/list/candidate = list()
	for(var/datum/star_system/random/R in SSstar_system.systems)
		if(!R.trader)
			candidate += R

	selected_system = pick(candidate)

	//Update description
	desc = "(optional) Travel to [selected_system] and rescue a friendly fleet"
	brief = "(optional) Intellegence indicates that a supply convoy is going to ambushed in [selected_system], travel to the system and ensure the convoy escapes with minimal damage."

	RegisterSignal(SSstar_system.main_overmap, COMSIG_SHIP_ARRIVED, .proc/stage_encounter)

/datum/overmap_objective/rescue_fleet/proc/stage_encounter()
	if(status)
		return

	var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
	if(OM.current_system == selected_system)
		UnregisterSignal(SSstar_system.main_overmap, COMSIG_SHIP_ARRIVED)

		//Spawn the fleets
		var/datum/fleet/N = new /datum/fleet/nanotrasen/convoy()
		selected_system.fleets += N
		N.current_system = selected_system
		N.assemble(selected_system)
		RegisterSignal(N, COMSIG_FLEET_DESTROYED, .proc/encounter_failure)
		OM.hail("We are carrying valuable supplies for the Nanotrasen shipyards, we won't get out of here alive if you don't assist immediately!", N.name)

		var/datum/fleet/S = new /datum/fleet/interdiction/light()
		selected_system.fleets += S
		S.current_system = selected_system
		S.assemble(selected_system)
		RegisterSignal(S, COMSIG_FLEET_DESTROYED, .proc/encounter_success)

/datum/overmap_objective/rescue_fleet/proc/encounter_failure()
	if(status)
		return

	priority_announce("We've lost contact with the transport convoy, search for survivors if possible and continue your primary objective.")
	status = 2

/datum/overmap_objective/rescue_fleet/proc/encounter_success()
	if(status)
		return

	priority_announce("These resources should prove invaluable in our conflict with the Syndicate, good work.")
	status = 1
	var/datum/star_system/S = SSstar_system.system_by_id("Staging")
	var/datum/fleet/N = locate(/datum/fleet/nanotrasen/convoy) in selected_system
	N.move(S, TRUE)
