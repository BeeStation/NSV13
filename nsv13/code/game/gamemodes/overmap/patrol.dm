//The default gamemode

//Acquire 1000 tickets for NT - you know the drill

/datum/overmap_gamemode/patrol
	name = "Patrol"
	desc = "Default Gamemode - Acquire 1000 victory tickets for Nanotrasen"
	brief = "You have been assigned to standard patrol duty beyond the Foothold sector. Patrol this area and eliminate any Syndicate forces with extreme prejudice, then return back to Outpost 45."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 1
	selection_weight = 5
	required_players = 0
	objectives = list(/datum/overmap_objective/tickets/nt)

	reminder_one = "This is Centcomm to all vessels assigned to explore the Delphic Expanse, please continue on your patrol."
	reminder_two = "This is Centcomm to all vessels assigned to explore the Delphic Expanse, we are not paying you to idle in space during your assignment."
	reminder_three = "This is Centcomm to all vessels assigned to explore the Delphic Expanse, your inactivity has been noted and will not be tolerated."
	reminder_four = "This is Centcomm to the explore vessel currently assigned to the Delphic Expanse, you are expected to fulfill your assigned patrol."
	reminder_five = "The vessel is no longer responding to commands. Enacting emergency defense conditions. All shipside squads must assist in getting the ship ready for combat by any means necessary."
