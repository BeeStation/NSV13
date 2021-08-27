/datum/overmap_objective/tickets
	name = "Tickets"
	desc = "Acquire ticket_amount Tickets for assigned_faction"
	binary = FALSE
	target = 1000
	var/assigned_faction = null

/datum/overmap_objective/tickets/New()
	var/datum/faction/F = SSstar_system.faction_by_id(assigned_faction)
	brief = "Accumulate [target] faction points for [F.name] by defeating hostile fleets and completing station missions"

/datum/overmap_objective/tickets/check_completion()
	.=..()
	if(status != 0)
		return
	var/datum/faction/F = SSstar_system.faction_by_id(assigned_faction)
	tally = F.tickets
	if(F.tickets >= target) //Check if we have the required tickets
		status = 1
		F.tickets -= target //Subtract the tickets

/datum/overmap_objective/tickets/nt
	name = "Nanotrasen Tickets"
	assigned_faction = FACTION_ID_NT
	extension_supported = TRUE
