/datum/overmap_objective/clear_system
	name = "Clear System of Enemies"
	desc = "Defeat all enemies in the TARGET system"
	brief = "Defeat all enemies in the TARGET system"
	binary = FALSE
	target = 1

	var/system_name
	var/datum/star_system/target_system

/datum/overmap_objective/clear_system/instance()
	.=..()
	desc = "Defeat all enemies in the [system_name] system"
	brief = desc
	target_system = SSstar_system.system_by_id(system_name)
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

/datum/overmap_objective/clear_system/dolos
	system_name = "Dolos Remnants"
