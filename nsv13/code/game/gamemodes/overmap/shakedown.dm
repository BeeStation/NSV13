/datum/overmap_gamemode/shakedown
	name = "Shakedown"
	desc = "Do some jumps and light combat"
	brief = "You have been assigned a newly refurbished vessel for a shakedown cruise. Do a burn in test of the FTL drive and destroy an enemy fleet, then return back to Outpost 45."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 1
	selection_weight = 5
	required_players = 0
	objectives = list(/datum/overmap_objective/perform_jumps, /datum/overmap_objective/destroy_fleets)
