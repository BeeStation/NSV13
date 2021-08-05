/datum/overmap_objective/destroy_fleets
	name = "Destroy fleets"
	desc = "Destroy fleets_required enemy fleets"

	var/minimum_fleets = 1
	var/maximum_fleets = 3

	var/fleets_required = 1
	var/fleets_defeated = 0

	var/target_faction = "any"

	extension_supported = TRUE

/datum/overmap_objective/destroy_fleets/instance()
	.=..()
	fleets_required = rand(minimum_fleets, maximum_fleets) // Doing this in instance in case people want different numbers of them
	desc = "Destroy [fleets_required] enemy fleets"
	brief = "Defeat [fleets_required] [(target_faction == "any") ? "hostile" : "[target_faction]"] [(fleets_required != 1) ? "fleets" : "fleet" ]"
	RegisterSignal(SSstar_system.find_main_overmap(), COMSIG_SHIP_KILLED_FLEET, .proc/register_kill)

/datum/overmap_objective/destroy_fleets/proc/register_kill()
	fleets_defeated ++
	SSovermap_mode.update_reminder(objective=TRUE)
	check_completion()

/datum/overmap_objective/destroy_fleets/check_completion()
	.=..()
	if(status != 0)
		return
	if(fleets_defeated >= fleets_required)
		status = 1
