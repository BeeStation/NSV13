/datum/overmap_objective/go_to_system
	name = "Go To System"
	desc = "Proceed to the target system"
	brief = "Proceed to the target system"
	var/datum/star_system/target_system = null

/datum/overmap_objective/go_to_system/New()
	. = ..()
	RegisterSignal(SSstar_system.main_overmap, COMSIG_SHIP_ARRIVED, .proc/check_completion)

/datum/overmap_objective/go_to_system/instance()
	. = ..()
	brief = "Proceed to [target_system.name]"

/datum/overmap_objective/go_to_system/check_completion()
	if(SSstar_system.find_system(SSstar_system.main_overmap) == target_system)
		SSovermap_mode.update_reminder(objective=TRUE)
		status = 1
		UnregisterSignal(SSstar_system.find_main_overmap(), COMSIG_SHIP_ARRIVED)
