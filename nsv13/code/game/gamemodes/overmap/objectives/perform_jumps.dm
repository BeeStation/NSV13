/datum/overmap_objective/perform_jumps
	name = "Perform jumps"
	desc = "Perform jumps_required FTL jumps"

	var/minimum_jumps = 8
	var/maximum_jumps = 13

	var/jumps_required = 1
	var/jumps_completed = -1 // Don't count staging

/datum/overmap_objective/perform_jumps/instance()
	.=..()
	jumps_required = rand(minimum_jumps, maximum_jumps) // Doing this in instance in case people want different numbers of them
	brief = "Perform [jumps_required] FTL jumps"
	RegisterSignal(SSstar_system.find_main_overmap(), COMSIG_SHIP_ARRIVED, .proc/register_jump)

/datum/overmap_objective/perform_jumps/proc/register_jump()
	jumps_completed ++
	SSovermap_mode.update_reminder(objective=TRUE)
	check_completion()

/datum/overmap_objective/perform_jumps/check_completion()
	.=..()
	if(status != 0)
		return
	if(jumps_completed >= jumps_required)
		status = 1
		UnregisterSignal(SSstar_system.find_main_overmap(), COMSIG_SHIP_ARRIVED)
