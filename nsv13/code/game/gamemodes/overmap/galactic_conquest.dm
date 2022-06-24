//Gamemode used during PVP

//Acquire 1000 tickets for NT
/datum/overmap_gamemode/galactic_conquest
	name = "Galactic Conquest"
	desc = "PVP Gamemode - Acquire 1000 victory tickets for Nanotrasen or destroy the Syndicate Flagship"
	brief = "Intel suggests that the Syndicate are mounting an all out assault on the Sol sector. Patrol this area and eliminate any Syndicate forces with extreme prejudice."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 1
	objective_reminder_interval = 2 HOURS //No external pressure in this round...
	selection_weight = 0 //This overmap gamemode will be used only during PVP
	fixed_objectives = list(/datum/overmap_objective/tickets/nt) //Placeholder for now


/datum/overmap_gamemode/galactic_conquest/New()
	fixed_objectives = list(/datum/overmap_objective/tickets/nt)
