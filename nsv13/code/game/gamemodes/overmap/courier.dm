/datum/overmap_gamemode/courier
	name = "Courier"
	desc = "Cargo assignment, bring supplies to stations"
	brief = "You have been assigned cargo duty for the Delphic Expanse. Deliver the supplies outlined in the briefing to their destinations, then return back to Outpost 45."
	starting_system = "Argo"
	starting_faction = "nanotrasen"

	objective_reminder_setting = 0
	reminder_one = "This is Centcomm to all vessels assigned to explore the Delphic Expanse, please continue on your delivery."
	reminder_two = "This is Centcomm to all vessels assigned to explore the Delphic Expanse, we are not paying you to idle in space during your assignment."
	reminder_three = "This is Centcomm to all vessels assigned to explore the Delphic Expanse, your inactivity has been noted and will not be tolerated."
	reminder_four = "This is Centcomm to the cargo vessel currently assigned to the Delphic Expanse, you are expected to fulfill your assigned mission."
	reminder_five = "Your pay has been docked to cover expenses, continued ignorance of your mission will lead to removal by force."

	selection_weight = 5
	required_players = 0
	max_players = 10
	random_objective_amount = 3

/datum/overmap_gamemode/New()
	random_objectives = list(
		/datum/overmap_objective/cargo/donation/chems, 
		/datum/overmap_objective/cargo/donation/blood, 
		/datum/overmap_objective/cargo/donation/food,
		/datum/overmap_objective/cargo/donation/minerals,
		/datum/overmap_objective/cargo/donation/munitions,
		/datum/overmap_objective/cargo/donation/social_supplies,
		/datum/overmap_objective/cargo/transfer/credits,
		/datum/overmap_objective/cargo/transfer/data,
		/datum/overmap_objective/cargo/transfer/documents,
		/datum/overmap_objective/cargo/transfer/emergency_supplies,
		/datum/overmap_objective/cargo/transfer/fighter_parts,
		/datum/overmap_objective/cargo/transfer/specimen,
	)
