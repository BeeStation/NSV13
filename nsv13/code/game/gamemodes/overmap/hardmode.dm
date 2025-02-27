//Specific objectives and changes for hardmode

/datum/overmap_gamemode/hardmode
	name = "Dolos Assault"
	config_tag = "hardmode"
	desc = "Harder gamemode - Defeat the Syndicate in Rubicon and Dolos (intended to be used with the hardmode setting)"
	brief = "The Syndicate have prepared a strong naval force, fly to Dolos through Rubicon, and put them back in their place! Then clean up the rest of them or return home victorious."
	starting_system = "Medea"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 1
	selection_weight = 0 //Don't get chosen randomly
	required_players = 25 //Should not be relevant, but it should only have higher player counts, otherwise
	fixed_objectives = list(/datum/overmap_objective/clear_system/rubicon, /datum/overmap_objective/clear_system/dolos)
