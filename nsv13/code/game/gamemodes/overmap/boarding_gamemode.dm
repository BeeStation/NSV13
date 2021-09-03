//Go to a place, board a ship, change the IFF

/datum/overmap_gamemode/boarding
	name = "Boarding"
	desc = "Boarding gamemode - board a specific ship and hack the IFF"
	brief = "You have been assigned to capture a syndicate . Patrol this area and eliminate any Syndicate forces with extreme prejudice, then return back to Outpost 45."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 1
	selection_weight = 20
	required_players = 17
	objectives = list(/datum/overmap_objective/board_ship)
