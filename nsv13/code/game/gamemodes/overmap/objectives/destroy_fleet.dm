/datum/overmap_objective/destroy_fleets
	name = "Destroy fleets"
	desc = "Destroy fleets_required enemy fleets"
	binary = FALSE
	target = 1

	var/minimum_fleets = 1
	var/maximum_fleets = 3

	var/target_faction = "any"

	extension_supported = FALSE

/datum/overmap_objective/destroy_fleets/instance()
	.=..()
	target = rand(minimum_fleets, maximum_fleets) // Doing this in instance in case people want different numbers of them
	desc = "Destroy [target] enemy fleets"
	brief = "Defeat [target] [(target_faction == "any") ? "hostile" : "[target_faction]"] [(target != 1) ? "fleets" : "fleet" ]"
	RegisterSignal(SSstar_system.find_main_overmap(), COMSIG_SHIP_KILLED_FLEET, .proc/register_kill)

/datum/overmap_objective/destroy_fleets/proc/register_kill()
	tally ++
	SSovermap_mode.update_reminder(objective=TRUE)
	check_completion()

/datum/overmap_objective/destroy_fleets/check_completion()
	.=..()
	if(status != 0)
		return
	if(tally >= target)
		status = 1
