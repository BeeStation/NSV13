/datum/overmap_objective/perform_jumps
	name = "Perform jumps"
	desc = "Perform jumps_required FTL jumps"
	binary = FALSE
	tally = -1 // Don't count staging
	target = 1

	var/minimum_jumps = 8
	var/maximum_jumps = 13

/datum/overmap_objective/perform_jumps/instance()
	.=..()
	target = rand(minimum_jumps, maximum_jumps) // Doing this in instance in case people want different numbers of them
	desc = "Perform [target] FTL jumps"
	brief = "Perform [target] FTL jumps"
	RegisterSignal(SSstar_system.find_main_overmap(), COMSIG_SHIP_ARRIVED, .proc/register_jump)

/datum/overmap_objective/perform_jumps/proc/register_jump()
	tally ++
	SSovermap_mode.update_reminder(objective=TRUE)
	check_completion()

/datum/overmap_objective/perform_jumps/check_completion()
	.=..()
	if(status != 0)
		return
	if(tally >= target)
		status = 1
		UnregisterSignal(SSstar_system.find_main_overmap(), COMSIG_SHIP_ARRIVED)
