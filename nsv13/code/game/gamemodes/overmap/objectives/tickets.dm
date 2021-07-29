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
