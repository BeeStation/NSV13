//Go to a place, board a ship, change the IFF

/datum/overmap_gamemode/boarding
	name = "Boarding"
	config_tag = "boarding"
	desc = "Boarding gamemode - board a specific ship and hack the IFF"
	brief = "You have been assigned to capture a syndicate vessel. Locate the target, eliminate any Syndicate forces with extreme prejudice, then change its transponder codes and bring it home."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 2 // Combat can postpone, but it's not the goal
	combat_delay = 10 MINUTES
	selection_weight = 5
	required_players = 14
	fixed_objectives = list(/datum/overmap_objective/board_ship)
