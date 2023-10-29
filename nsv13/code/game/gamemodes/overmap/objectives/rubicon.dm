/datum/overmap_objective/clear_system
	name = "Clear System of Enemies"
	desc = "Defeat all enemies in the TARGET system"
	brief = "Defeat all enemies in the TARGET system"
	binary = FALSE
	target = 1

	var/system_name
	var/datum/star_system/target_system

/datum/overmap_objective/clear_system/New(datum/star_system/passed_input)
	.=..()
	if(passed_input)
		system_name = passed_input.name
	if(!system_name)
		for(var/datum/star_system/S in SSstar_system.neutral_zone_systems)
			if(S.hidden)
				continue
			if(length(S.enemies_in_system))
				system_name = S.name
				break
			continue

/datum/overmap_objective/clear_system/instance()
	.=..()
	desc = "Defeat all enemies in the [system_name] system"
	brief = desc
	target_system = SSstar_system.system_by_id(system_name)
	target_system.hidden = FALSE
	RegisterSignal(SSstar_system.find_main_overmap(), COMSIG_SHIP_KILLED_FLEET, PROC_REF(check_completion))

/datum/overmap_objective/clear_system/check_completion()
	.=..()
	if(status != 0)
		return
	if(!length(target_system.enemies_in_system))
		status = 1

/datum/overmap_objective/clear_system/rubicon
	system_name = "Rubicon"
	extension_supported = TRUE
	required_players = 10

/datum/overmap_objective/clear_system/dolos
	system_name = "Dolos Remnants"
	extension_supported = TRUE //Only if Rubicon is not available
	required_players = 10
