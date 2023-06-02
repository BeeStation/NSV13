//The default gamemode

//Acquire 1000 tickets for NT - you know the drill

/datum/overmap_gamemode/patrol
	name = "Patrol"
	config_tag = "patrol"
	desc = "Default Gamemode - Acquire 1000 victory tickets for Nanotrasen"
	brief = "You have been assigned to standard patrol duty beyond the Foothold sector. Patrol this area and eliminate any Syndicate forces with extreme prejudice, then return back to Outpost 45."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 1
	selection_weight = 5
	required_players = 10
	fixed_objectives = list(/datum/overmap_objective/tickets/nt)
