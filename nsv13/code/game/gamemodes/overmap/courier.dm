/datum/overmap_gamemode/courier
	name = "Courier"
	config_tag = "courier"
	desc = "Cargo assignment, bring supplies to stations"
	brief = "You have been assigned cargo duty for the Rosetta Cluster. Deliver the supplies outlined in the briefing to their destinations, then return back to Outpost 45."
	starting_system = "Argo"
	starting_faction = "nanotrasen"

	objective_reminder_setting = 0
	reminder_one = "Tu Centrala do wszystkich statków przydzielonych do patrolu Gromady Rosetta, prosimy kontynuować misję"
	reminder_two = "Tu Centrala do wszystkich statków przydzielonych do patrolu Gromady Rosetta, wasza nieaktywność została zauważona i nie będzie tolerowana."
	reminder_three = "Tu Centrala do wszystkich statków przydzielonych do patrolu Gromady Rosetta, nie płacimy wam za dryfowanie w kosmosie podczas wykonywania przydzielonej misji"
	reminder_four = "Tu Centrala do wszystkich statków obecnie przydzielonych do patrolu Gromady Rosetta, jesteście zobowiązani do wykonania przydzielonej misji"
	reminder_five = "Wasza wypłata została przeznaczona na pokrycie wydatków, dalsze ignorowanie misji doprowadzi do przymusowego terminacji."

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
