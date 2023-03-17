/datum/overmap_gamemode/shakedown
	name = "Shakedown"
	config_tag = "shakedown"
	desc = "Do some jumps and light combat"
	brief = "You have been assigned a newly refurbished vessel for a shakedown cruise. Do a burn-in of the Thirring Drive and test the weapons, then return back to Outpost 45."
	starting_system = "Argo"
	starting_faction = "nanotrasen"

	objective_reminder_setting = 0
	reminder_one = "This is Centcomm to all vessels assigned to patrol the Rosetta Cluster, please continue on your shakedown."
	reminder_two = "This is Centcomm to all vessels assigned to patrol the Rosetta Cluster, we are not paying you to idle in space during your assignment."
	reminder_three = "This is Centcomm to all vessels assigned to patrol the Rosetta Cluster, your inactivity has been noted and will not be tolerated."
	reminder_four = "This is Centcomm to the explore vessel currently assigned to the Rosetta Cluster, you are expected to fulfill your assigned mission."
	reminder_five = "Your pay has been docked to cover expenses, continued ignorance of your mission will lead to removal by force."

	selection_weight = 5
	required_players = 0
	max_players = 10
	random_objective_amount = 3

/datum/overmap_gamemode/shakedown/New()
	random_objectives = list(
		/datum/overmap_objective/perform_jumps,
		/datum/overmap_objective/destroy_fleets,
		/datum/overmap_objective/apnw_efficiency
	)
