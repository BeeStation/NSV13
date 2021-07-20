//The default gamemode

//Acquire 1000 tickets for NT - you know the drill

/datum/overmap_gamemode/patrol
	name = "Patrol"
	desc = "Default Gamemode - Acquire 1000 victory tickets for Nanotrasen"
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 1
	selection_weight = 5
	required_players = 0
	objectives = list(/datum/overmap_objective/tickets/nt)

/datum/overmap_objective/tickets
	name = "Tickets"
	desc = "Acquire ticket_amount Tickets for assigned_faction"
	var/assigned_faction = null
	var/ticket_amount = 0

/datum/overmap_objective/tickets/New()
	desc = "Acquire [ticket_amount] Tickets for [assigned_faction]"

datum/overmap_objective/tickets/check_completion()
	var/datum/faction/F = locate(assigned_faction in SSstar_system.factions)
	if(F.tickets >= ticket_amount)
		return TRUE
	return FALSE

/datum/overmap_objective/tickets/nt
	name = "Nanotrasen Tickets"
	assigned_faction = "nanotrasen"
	ticket_amount = 1000
