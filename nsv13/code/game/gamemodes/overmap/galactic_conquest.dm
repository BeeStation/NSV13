//Special gamemode used only in PVP. This gamemode should not be used outside of PVP.
//This is used to prevent other overmap gamemodes (delivery, boarding, shakedown) from getting in the way.
/datum/overmap_gamemode/galactic_conquest
	name = "Galactic Conquest"
	config_tag = "conquest"
	desc = "PVP Gamemode - Acquire 700 victory tickets for Nanotrasen or destroy the Syndicate Flagship"
	brief = "Intel suggests that the Syndicate are mounting an all out assault on the Sol sector. Patrol this area and eliminate any Syndicate forces with extreme prejudice."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = MODE_REMINDER_OVERRIDE //No external pressure in this round...
	fixed_objectives = list(/datum/overmap_objective/tickets/nt) //Placeholder for now

//Alternate mode of the galactic conquest gamemode - control a specific deepspace system.
/datum/overmap_gamemode/galactic_conquest/system_control
	name = "System Control"
	config_tag = "conquest"
	desc = "PVP Gamemode - Control the target system for a certain amount of time, or destroy the enemy flagship."
	brief = "Intel suggests that the Syndicate are attempting to stabilize a wormhole corridor leading directly to the core of the Sol sector. Make haste and prevent their success."
	fixed_objectives = list(/datum/overmap_objective/control_system)
