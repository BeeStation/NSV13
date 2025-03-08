//Specific objectives and changes for hardmode

/datum/overmap_gamemode/hardmode
	name = "Dolos Assault"
	config_tag = "hardmode"
	desc = "Harder gamemode - Defeat the Syndicate in Rubicon and Dolos (intended to be used with the hardmode setting)"
	brief = "The Syndicate have prepared a strong naval force, fly to Dolos through Rubicon, and put them back in their place! Then clean up the rest of them or return home victorious."
	starting_system = "Medea" //Start closer to the frontline for immediate action
	starting_faction = "nanotrasen"
	objective_reminder_setting = 1
	whitelist_only = TRUE //Needs to be specifically enabled in the map config to roll (outside of the specific hardmode toggle)
	selection_weight = 5
	required_players = 25 //You'll need a decent sized crew
	fixed_objectives = list(/datum/overmap_objective/clear_system/rubicon, /datum/overmap_objective/clear_system/dolos)
	reminder_origin = "Whiterapids QRF Command"
