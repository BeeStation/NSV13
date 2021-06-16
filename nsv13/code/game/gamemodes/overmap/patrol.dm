//The default gamemode

//Acquire 1000 tickets for NT - know the drill

/datum/overmap_mission/patrol
	name = "Patrol"
	desc = "Default Gamemode - Acquire 1000 victory tickets for Nanotrasen"
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 1


/datum/overmap_objective/nt_tickets
	name = "Nanotrasen Tickets"
	desc = "Acquire [ticket_amount] Tickets for Nanotrasen"
	var/ticket_amount = 1000
