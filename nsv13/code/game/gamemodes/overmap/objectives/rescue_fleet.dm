/datum/overmap_objective/rescue_fleet
	name = "Rescue Fleet"
	desc = "Travel to a designated system and rescue a friendly fleet"
	var/datum/star_system/selected_system

/datum/overmap_objective/rescue_fleet/instance()
	//Select a system to be targeted
	var/list/candidate = list()
	for(var/datum/star_system/random/R in SSstar_system.systems)
		if(!R.trader)
			candidate += R

	selected_system = pick(candidate)

	//Update description
	desc = "Travel to [selected_system] and rescue a friendly fleet"
	brief = "A supply convoy has been ambushed in [selected_system], travel to the system and ensure the convoy escapes with minimal damage."

	RegisterSignal(SSstar_system.main_overmap, COMSIG_SHIP_ARRIVED, .proc/stage_event)

/datum/overmap_objective/rescue_fleet/proc/stage_event()
	var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
	if(OM.current_system == selected_system)
	//Send a help message
	
		//Spawn the fleets
		var/datum/fleet/N = new /datum/fleet/nanotrasen/convoy()
		selected_system.fleets += N
		N.current_system = selected_system
		N.assemble(selected_system)
		RegisterSignal(N, COMSIG_SHIP_KILLED_FLEET, .proc/event_failure)

		var/datum/fleet/S = new /datum/fleet/interdiction/light()
		selected_system.fleets += S
		S.current_system = selected_system
		S.assemble(selected_system)
		RegisterSignal(S, COMSIG_SHIP_KILLED_FLEET, .proc/event_success)

/datum/overmap_objective/rescue_fleet/proc/event_failure()
	if(status == 0)
		//send message here
		status = 2
	
/datum/overmap_objective/rescue_fleet/proc/event_success()
	if(status == 0)
		//send messge here
		status = 1
		var/datum/star_system/S = SSstar_system.system_by_id("Staging")
		var/datum/fleet/N = locate(/datum/fleet/nanotrasen/convoy) in selected_system
		N.move(S, TRUE)