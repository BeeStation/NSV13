/datum/overmap_gamemode/courier
	name = "Courier"
	config_tag = "courier"
	desc = "Cargo assignment, bring supplies to stations"
	brief = "You have been assigned cargo duty for the Rosetta Cluster. Deliver the supplies outlined in the briefing to their destinations, then return back to Outpost 45."
	starting_system = "Argo"
	starting_faction = "nanotrasen"

	objective_reminder_setting = 0
	reminder_one = "This is Centcomm to all vessels assigned to patrol the Rosetta Cluster, please continue on your delivery."
	reminder_two = "This is Centcomm to all vessels assigned to patrol the Rosetta Cluster, we are not paying you to idle in space during your assignment."
	reminder_three = "This is Centcomm to all vessels assigned to patrol the Rosetta Cluster, your inactivity has been noted and will not be tolerated."
	reminder_four = "This is Centcomm to the cargo vessel currently assigned to the Rosetta Cluster, you are expected to fulfill your assigned mission."
	reminder_five = "Your pay has been docked to cover expenses, continued ignorance of your mission will lead to removal by force."

	selection_weight = 5
	required_players = 0
	max_players = 10
	random_objective_amount = 3

	debug_mode = FALSE

/datum/overmap_gamemode/courier/New()
	random_objectives = subtypesof( /datum/overmap_objective/cargo/donation ) + subtypesof( /datum/overmap_objective/cargo/transfer )

	if ( debug_mode ) // I upend your code for my personal pleasure
		random_objective_amount = length( random_objectives )

		// selection_weight = INFINITY
		selection_weight = 999
		SSovermap_mode.announce_delay = 10 SECONDS

		for( var/obj/machinery/computer/ship/dradis/dradis in GLOB.machines )
			dradis.hail_range = 500
		var/obj/structure/overmap/MO = SSstar_system.find_main_overmap()
		MO.essential = TRUE
		MO.nodamage = TRUE

		for ( var/i = 0; i < length( random_objectives ); i++ )
			MO.send_supplypod( /obj/item/ship_weapon/ammunition/torpedo/freight )
		MO.send_supplypod( /obj/item/crowbar )

		message_admins( "Courier gamemode DEBUG is enabled for testing. If this is on the production server, un-testmerge the last branch that touched courier code immediately!" )
