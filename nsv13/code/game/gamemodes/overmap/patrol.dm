//The default gamemode

//Acquire 1000 tickets for NT - you know the drill

/datum/overmap_gamemode/patrol
	name = "Patrol"
	desc = "Default Gamemode - Acquire 1000 victory tickets for Nanotrasen"
	brief = "You have been assigned to standard patrol duty beyond the Foothold sector. Patrol this area and eliminate any Syndicate forces with extreme prejudice, then return back to Outpost 45."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 1
	selection_weight = 0
	required_players = 0
	objectives = list(/datum/overmap_objective/tickets/nt)

/datum/overmap_objective/tickets
	name = "Tickets"
	desc = "Acquire ticket_amount Tickets for assigned_faction"
	var/assigned_faction = null
	var/ticket_amount = 0

/datum/overmap_objective/tickets/New()
	var/datum/faction/F = SSstar_system.faction_by_id(assigned_faction)
	brief = "Accumulate [ticket_amount] faction points for [F.name] by defeating hostile fleets and completing station missions"

/datum/overmap_objective/tickets/check_completion()
	.=..()
	if(status != 0)
		return
	var/datum/faction/F = SSstar_system.faction_by_id(assigned_faction)
	if(F.tickets >= ticket_amount) //Check if we have the required tickets
		status = 1
		F.tickets -= ticket_amount //Subtract the tickets

/datum/overmap_objective/tickets/nt
	name = "Nanotrasen Tickets"
	assigned_faction = FACTION_ID_NT
	ticket_amount = 1000
	extension_supported = TRUE



////////////////////////////////////////

/datum/overmap_gamemode/one
	name = "one"
	desc = "one"
	brief = "You have been assigned to standard patrol duty beyond the Foothold sector. Patrol this area and eliminate any Syndicate forces with extreme prejudice, then return back to Outpost 45."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 1
	selection_weight = 5
	required_players = 5
	objectives = list(/datum/overmap_objective/tickets/nt)

/datum/overmap_gamemode/two
	name = "two"
	desc = "two"
	brief = "You have been assigned to standard patrol duty beyond the Foothold sector. Patrol this area and eliminate any Syndicate forces with extreme prejudice, then return back to Outpost 45."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 1
	selection_weight = 5
	required_players = 5
	objectives = list(/datum/overmap_objective/tickets/nt)
