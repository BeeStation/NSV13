//The NSV13 Version of Game Mode, except it for the overmap and runs parallel to Game Mode

#define STATUS_INPROGRESS 0
#define STATUS_COMPLETED 1
#define STATUS_FAILED 2
#define STATUS_OVERRIDE 3

#define REMINDER_OBJECTIVES 0
#define REMINDER_COMBAT_RESET 1
#define REMINDER_COMBAT_DELAY 2
#define REMINDER_OVERRIDE 3

SUBSYSTEM_DEF(overmap_mode)
	name = "overmap_mode"
	wait = 10
	init_order = INIT_ORDER_OVERMAP_MODE

	var/escalation = 0								//Admin ability to tweak current mission difficulty level
	var/threat_elevation = 0						//Threat generated or reduced via various activities, directly buffing enemy fleet sizes and possibly other things if implemented.
	var/highest_objective_completion = 0				//What was the highest amount of objectives completed? If it increases, reduce threat.
	var/player_check = 0 							//Number of players connected when the check is made for gamemode
	var/datum/overmap_gamemode/mode 				//The assigned mode
	var/datum/overmap_gamemode/forced_mode = null							//Admin forced gamemode prior to initialization

	var/objective_reminder_override = FALSE 		//Are we currently using the reminder system?
	var/last_objective_interaction = 0 				//Last time the crew interacted with one of our objectives
	var/next_objective_reminder = 0 				//Next time we automatically remind the crew to proceed with objectives
	var/objective_reminder_stacks = 0 				//How many times has the crew been automatically reminded of objectives without any progress
	var/objective_resets_reminder = FALSE			//Do we only reset the reminder when we complete an objective?
	var/combat_resets_reminder = FALSE 				//Does combat in the overmap reset the reminder?
	var/combat_delays_reminder = FALSE 				//Does combat in the overmap delay the reminder?
	var/combat_delay_amount = 0 					//How much the reminder is delayed by combat

	var/announce_delay = 3 MINUTES					//How long do we wait?
	var/announced_objectives = FALSE 				//Have we announced the objectives yet?
	var/round_extended = FALSE 						//Has the round already been extended already?
	var/admin_override = FALSE						//Stops the mission ending
	var/objectives_completed = FALSE				//Did they finish all the objectives that are available to them?
	var/already_ended = FALSE						//Is the round already in an ending state, i.e. we return jumped
	var/mode_initialised = FALSE

	var/override_ghost_boarders = FALSE 			//Used by admins to force disable player boarders
	var/override_ghost_ships = FALSE				//Used by admins to force disable player ghost ships

	var/check_completion_timer = 0

	var/list/mode_cache

	var/list/modes
	var/list/mode_names

/datum/controller/subsystem/overmap_mode/Initialize(start_timeofday)
	//Retrieve the list of modes
	//Check our map for any white/black lists
	//Exclude or lock any modes due to maps
	//Check the player numbers
	//Exclude or lock any modes due to players
	//Use probs to pick a mode from the trimmed pool
	//Set starting systems for the player ships
	//Load and set objectives

	mode_cache = subtypesof(/datum/overmap_gamemode)

	var/list/probabilities = config.Get(/datum/config_entry/keyed_list/omode_probability)
	var/list/min_pop = config.Get(/datum/config_entry/keyed_list/omode_min_pop)
	var/list/max_pop = config.Get(/datum/config_entry/keyed_list/omode_max_pop)

	for(var/M in mode_cache)
		var/datum/overmap_gamemode/GM = M
		if(initial(GM.whitelist_only)) //Remove all of our only whitelisted modes
			mode_cache -= M

	if(length(SSmapping.config.omode_blacklist) > 0)
		if(locate("all") in SSmapping.config.omode_blacklist)
			mode_cache.Cut()
		else
			for(var/S in SSmapping.config.omode_blacklist) //Grab the string to be the path - is there a proc for this?
				var/B = text2path("/datum/overmap_gamemode/[S]")
				mode_cache -= B

	if(length(SSmapping.config.omode_whitelist) > 0)
		for(var/S in SSmapping.config.omode_whitelist) //Grab the string to be the path - is there a proc for this?
			var/W = text2path("/datum/overmap_gamemode/[S]")
			mode_cache += W

	for(var/mob/dead/new_player/P in GLOB.player_list) //Count the number of connected players
		if(P.client)
			player_check ++

	for(var/M in mode_cache) //Check and remove any modes that we have insufficient players for the mode
		var/datum/overmap_gamemode/GM = M
		var/config_tag = initial(GM.config_tag)

		var/required_players = 0
		if(config_tag in min_pop)
			required_players = min_pop[config_tag]
		else
			required_players = initial(GM.required_players)
		var/max_players = 0
		if(config_tag in max_pop)
			max_players = max_pop[config_tag]
		else
			max_players = initial(GM.max_players)

		if(player_check < required_players)
			mode_cache -= M
		else if((max_players > 0) && (player_check > max_players))
			mode_cache -= M

	if(length(mode_cache))
		var/list/mode_select = list()
		if(forced_mode)
			mode = new forced_mode
		else
			for(var/M in mode_cache)
				var/datum/overmap_gamemode/GM = M
				var/config_tag = initial(GM.config_tag)

				var/selection_weight = 0
				if(config_tag in probabilities)
					selection_weight = probabilities[config_tag]
				else
					selection_weight = initial(GM.selection_weight)
				for(var/I = 0, I < selection_weight, I++) //Populate with weight number of instances
					mode_select += M

			if(length(mode_select))
				var/mode_type = pick(mode_select)
				mode = new mode_type

	if(mode)
		message_admins("[mode.name] has been selected as the overmap gamemode")
		log_game("[mode.name] has been selected as the overmap gamemode")
	else
		mode = new/datum/overmap_gamemode/patrol() //Holding that as the default for now - REPLACE ME LATER
		message_admins("Error: mode section pool empty - defaulting to PATROL")
		log_game("Error: mode section pool empty - defaulting to PATROL")

	return ..()

/datum/controller/subsystem/overmap_mode/proc/setup_overmap_mode()
	mode_initialised = TRUE
	switch(mode.objective_reminder_setting) //Load the reminder settings
		if(REMINDER_OBJECTIVES)
			objective_resets_reminder = TRUE
		if(REMINDER_COMBAT_RESET)
			combat_resets_reminder = TRUE
		if(REMINDER_COMBAT_DELAY)
			combat_delays_reminder = TRUE
			combat_delay_amount = mode.combat_delay
		if(REMINDER_OVERRIDE)
			objective_reminder_override = TRUE

	var/list/objective_pool = list() //Create instances of our objectives

	mode.objectives += mode.fixed_objectives //Add our fixed objectives

	if(mode.random_objective_amount) //Do we have random objectives?
		var/list/select_objectives = mode.random_objectives
		for(var/datum/overmap_objective/objective in mode.random_objectives)
			if(player_check < initial(objective.required_players))
				select_objectives -= objective
			if((initial(objective.maximum_players) > 0) && (player_check > initial(objective.maximum_players)))
				select_objectives -= objective
		for(var/I = 0, I < mode.random_objective_amount, I++) //We pick from our pool of random objectives
			if(!length(select_objectives))
				message_admins("Overmap mode ran out of random objectives to pick!")
				break
			mode.objectives += pick_n_take(select_objectives)

	for(var/O in mode.objectives)
		var/datum/overmap_objective/I = new O()
		objective_pool += I

	mode.objectives = objective_pool
	instance_objectives()

	var/obj/structure/overmap/MO = SSstar_system.find_main_overmap()
	if(MO)
		var/datum/star_system/target = SSstar_system.system_by_id(mode.starting_system)
		var/datum/star_system/curr = MO.current_system
		curr?.remove_ship(MO)
		MO.jump_end(target) //Move the ship to the designated start
		if(mode.starting_faction)
			MO.faction = mode.starting_faction //If we have a faction override, set it

	var/obj/structure/overmap/MM = SSstar_system.find_main_miner() //ditto for the mining ship until delete
	if(MM)
		var/datum/star_system/target = SSstar_system.system_by_id(mode.starting_system)
		var/datum/star_system/curr = MM.current_system
		curr?.remove_ship(MM)
		MM.jump_end(target)
		if(mode.starting_faction)
			MM.faction = mode.starting_faction

/datum/controller/subsystem/overmap_mode/proc/instance_objectives()
	for( var/I = 1, I <= length( mode.objectives ), I++ )
		var/datum/overmap_objective/O = mode.objectives[ I ]
		if(O.instanced == FALSE)
			O.objective_number = I
			O.instance() //Setup any overmap assets

/datum/controller/subsystem/overmap_mode/proc/modify_threat_elevation(value)
	if(!value)
		return
	threat_elevation = max(threat_elevation + value, 0)	//threat never goes below 0

/datum/controller/subsystem/overmap_mode/fire()
	if(SSticker.current_state == GAME_STATE_PLAYING) //Wait for the game to begin
		if(world.time >= check_completion_timer) //Fire this automatically every ten minutes to prevent round stalling
			if(world.time > TE_INITIAL_DELAY)
				modify_threat_elevation(TE_THREAT_PER_HOUR / 6)	//Accurate enough... although update this if the completion timer interval gets changed :)
			difficulty_calc() //Also do our difficulty check here
			mode.check_completion()
			check_completion_timer += 10 MINUTES

		if(!objective_reminder_override)
			if(world.time >= next_objective_reminder)
				mode.check_completion()
				if(objectives_completed || already_ended)
					return
				objective_reminder_stacks ++
				next_objective_reminder = world.time + mode.objective_reminder_interval
				if(!round_extended) //Normal Loop
					switch(objective_reminder_stacks)
						if(1) //something
							priority_announce("[mode.reminder_one]", "[mode.reminder_origin]")
							mode.consequence_one()
						if(2) //something else
							priority_announce("[mode.reminder_two]", "[mode.reminder_origin]")
							mode.consequence_two()
						if(3) //something else +
							priority_announce("[mode.reminder_three]", "[mode.reminder_origin]")
							mode.consequence_three()
						if(4) //last chance
							priority_announce("[mode.reminder_four]", "[mode.reminder_origin]")
							mode.consequence_four()
						if(5) //mission critical failure
							priority_announce("[mode.reminder_five]", "[mode.reminder_origin]")
							mode.consequence_five()
						else // I don't know what happened but let's go around again
							objective_reminder_stacks = 0
				else
					var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
					var/datum/star_system/S = SSstar_system.return_system
					if(length(OM.current_system?.enemies_in_system))
						if(objective_reminder_stacks == 3)
							priority_announce("Auto-recall to [S.name] will occur once you are out of combat.", "[mode.reminder_origin]")
						return // Don't send them home while there are enemies to kill
					switch(objective_reminder_stacks) //Less Stacks Here, Prevent The Post-Round Stalling
						if(1)
							priority_announce("Auto-recall to [S.name] will occur in [(mode.objective_reminder_interval * 2) / 600] Minutes.", "[mode.reminder_origin]")

						if(2)
							priority_announce("Auto-recall to [S.name] will occur in [(mode.objective_reminder_interval * 1) / 600] Minutes.", "[mode.reminder_origin]")

						else
							priority_announce("Auto-recall to [S.name] activated, additional objective aborted.", "[mode.reminder_origin]")
							mode.victory()

/datum/controller/subsystem/overmap_mode/proc/start_reminder()
	next_objective_reminder = world.time + mode.objective_reminder_interval
	addtimer(CALLBACK(src, PROC_REF(announce_objectives)), announce_delay)

/datum/controller/subsystem/overmap_mode/proc/announce_objectives()
 	/*
	Replace with a SMEAC brief?
	- Situation
	- Mission
	- Execution
	- Administration
	- Communication
	*/

	var/text = "<b>[GLOB.station_name]</b>, <br>You have been assigned the following mission by <b>[capitalize(mode.starting_faction)]</b> and are expected to complete it with all due haste. Please ensure your crew is properly informed of your objectives and delegate tasks accordingly."
	var/static/title = ""
	if(!announced_objectives)
		title += "Mission Briefing: [random_capital_letter()][random_capital_letter()][random_capital_letter()]-[GLOB.round_id]"
	else //Add an extension if this isn't roundstart
		title += "-Ext."

	text = "[text] <br><br> [mode.brief] <br><br> Objectives:"

	for(var/datum/overmap_objective/O in mode.objectives)
		text = "[text] <br> - [O.brief]"

		if(!SSovermap_mode.announced_objectives)  // Prevents duplicate report spam when assigning additional objectives
			O.print_objective_report()

	print_command_report(text, title, TRUE)
	announced_objectives = TRUE

/datum/controller/subsystem/overmap_mode/proc/update_reminder(var/objective = FALSE)
	if(objective && objective_resets_reminder) //Is objective? Full Reset
		last_objective_interaction = world.time
		objective_reminder_stacks = 0
		next_objective_reminder = world.time + mode.objective_reminder_interval
		return

	if(combat_resets_reminder) //Set for full reset on combat
		objective_reminder_stacks = 0
		next_objective_reminder = world.time + mode.objective_reminder_interval
		return

	if(combat_delays_reminder) //Set for time extension on combat
		next_objective_reminder += combat_delay_amount
		return

/datum/controller/subsystem/overmap_mode/proc/request_additional_objectives()
	for(var/datum/overmap_objective/O in mode.objectives)
		O.ignore_check = TRUE //We no longer care about checking these objective against completion

	/* This doesn't work and I don't have the time to refactor all of it right now so on the TODO pile it goes!
	var/list/extension_pool = subtypesof(/datum/overmap_objective)
	var/players = get_active_player_count(TRUE, TRUE, FALSE) //Number of living, non-AFK players including non-humanoids
	for(var/datum/overmap_objective/O in extension_pool)
		if(initial(O.extension_supported) == FALSE) //Clear the pool of anything we can't add
			extension_pool -= O
		if(players < initial(O.required_players)) //Not enough people
			extension_pool -= O
		if((initial(O.maximum_players) > 0) && (players > initial(O.maximum_players))) //Too many people
			extension_pool -= O

	if(length(extension_pool))
		var/datum/overmap_objective/selected = pick(extension_pool) //Insert new objective
		mode.objectives += new selected
	else
		message_admins("No additional objective candidates! Defaulting to tickets")
		mode.objectives += new /datum/overmap_objective/tickets
	*/

	var/datum/star_system/rubicon = SSstar_system.system_by_id("Rubicon")
	if(get_active_player_count(TRUE,TRUE,FALSE) > 10 && length(rubicon.enemies_in_system)) //Make sure there are enemies to fight
		mode.objectives += new /datum/overmap_objective/clear_system/rubicon
	else
		mode.objectives += new /datum/overmap_objective/tickets
		for(var/datum/faction/F in SSstar_system.factions)
			F.send_fleet(custom_difficulty = (mode.difficulty + 1)) //Extension is more challenging
			escalation += 1
			message_admins("Overmap difficulty has been increased by 1!")

	instance_objectives()

	announce_objectives() //Let them all know

	//Reset the reminder system & impose a hard timelimit
	combat_resets_reminder = FALSE
	combat_delays_reminder = FALSE
	mode.objective_reminder_interval = 10 MINUTES
	objective_reminder_stacks = 0
	next_objective_reminder = world.time + mode.objective_reminder_interval

/datum/controller/subsystem/overmap_mode/proc/difficulty_calc()
	var/players = get_active_player_count(TRUE, FALSE, FALSE) //Check how many players are still alive
	mode.difficulty = CLAMP((CEILING(players / 10, 1)), 1, 5)
	mode.difficulty += escalation //Our admin adjustment
	if(mode.difficulty <= 0)
		mode.difficulty = 1

/datum/overmap_gamemode
	var/name = null											//Name of the gamemode type
	var/config_tag = null									//Tag for config file weight
	var/desc = null											//Description of the gamemode for ADMINS
	var/brief = null										//Description of the gamemode for PLAYERS
	var/selection_weight = 0								//Used to determine the chance of this gamemode being selected
	var/required_players = 0								//Required number of players for this gamemode to be randomly selected
	var/max_players = 0										//Maximum amount of players allowed for this mode, 0 = unlimited
	var/difficulty = null									//Difficulty of the gamemode as determined by player count / abus abuse: 1 is minimum, 10 is maximum
	var/starting_system = null								//Here we define where our player ships will start
	var/starting_faction = null 							//Here we define which faction our player ships belong
	var/objective_reminder_setting = REMINDER_OBJECTIVES	//0 - Objectives reset remind. 1 - Combat resets reminder. 2 - Combat delays reminder. 3 - Disables reminder
	var/objective_reminder_interval = 15 MINUTES			//Interval between objective reminders
	var/combat_delay = 0									//How much time is added to the reminder timer
	var/list/objectives = list()							//The actual gamemode objectives go here after being selected
	var/list/fixed_objectives = list()						//The fixed objectives for the mode - always selected
	var/list/random_objectives = list()						//The random objectives for the mode - the pool to be chosen from
	var/random_objective_amount = 0							//How many random objectives we are going to get
	var/whitelist_only = FALSE								//Can only be selected through map bound whitelists
	var/debug_mode = FALSE 									//Debug var, for gamemode-specific testing

	//Reminder messages
	var/reminder_origin = "Naval Command"
	var/reminder_one = "This is Centcomm to all vessels assigned to patrol the Rosetta Cluster, please continue on your mission"
	var/reminder_two = "This is Centcomm to all vessels assigned to patrol the Rosetta Cluster, your inactivity has been noted and will not be tolerated."
	var/reminder_three = "This is Centcomm to all vessels assigned to patrol the Rosetta Cluster, we are not paying you to idle in space during your assigned mission"
	var/reminder_four = "This is Centcomm to the vessel currently assigned to the Rosetta Cluster, you are expected to fulfill your assigned mission"
	var/reminder_five = "This is Centcomm, due to your slow pace, a Syndicate Interdiction fleet has tracked you down, prepare for combat!"

/datum/overmap_gamemode/New()
	objectives = list(
		/datum/overmap_objective/perform_jumps
	)

/datum/overmap_gamemode/Destroy()
	for(var/datum/overmap_objective/objective in objectives)
		QDEL_NULL(objective)
	objectives.Cut()
	. = ..()

/datum/overmap_gamemode/proc/consequence_one()

/datum/overmap_gamemode/proc/consequence_two()
	var/datum/faction/F = SSstar_system.faction_by_name(SSstar_system.find_main_overmap().faction)
	F.lose_influence(25)

/datum/overmap_gamemode/proc/consequence_three()
	var/datum/faction/F = SSstar_system.faction_by_name(SSstar_system.find_main_overmap().faction)
	F.lose_influence(25)

/datum/overmap_gamemode/proc/consequence_four()
	var/datum/faction/F = SSstar_system.faction_by_name(SSstar_system.find_main_overmap().faction)
	F.lose_influence(25)

/datum/overmap_gamemode/proc/consequence_five()
	//Hotdrop O'Clock
	var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
	var/datum/star_system/target
	if(SSstar_system.ships[OM]["current_system"] != null)
		target = OM.current_system
	else
		target = SSstar_system.ships[OM]["target_system"]
	priority_announce("Attention all ships throughout the fleet, assume DEFCON 1. A Syndicate invasion force has been spotted in [target]. All fleets must return to allied space and assist in the defense.") //need a faction message
	var/datum/fleet/F = new /datum/fleet/interdiction() //need a fleet
	target.fleets += F
	F.current_system = target
	F.assemble(target)
	SSovermap_mode.objective_reminder_stacks = 0 //Reset

/datum/overmap_gamemode/proc/check_completion() //This gets called by checking the communication console/modcomp program + automatically once every 10 minutes
	if(SSovermap_mode.already_ended)
		return
	if(SSovermap_mode.objectives_completed)
		victory()
		return

	var/objective_length = objectives.len
	var/objective_check = 0
	var/successes = 0
	var/failed = FALSE
	for(var/datum/overmap_objective/O in objectives)
		O.check_completion() 	//First we try to check completion on each objective
		if(O.status == STATUS_OVERRIDE) //Victory override check
			victory()
			return
		else if(O.status == STATUS_COMPLETED)
			objective_check ++
			successes++
		else if(O.status == STATUS_FAILED)
			objective_check ++
			if(O.ignore_check == TRUE) //This was a gamemode objective
				failed = TRUE
	if(successes > SSovermap_mode.highest_objective_completion)
		SSovermap_mode.modify_threat_elevation(-TE_OBJECTIVE_THREAT_NEGATION * (successes - SSovermap_mode.highest_objective_completion))
		SSovermap_mode.highest_objective_completion = successes
	if(istype(SSticker.mode, /datum/game_mode/pvp)) //If the gamemode is PVP and a faction has over a 700 points, they win.
		for(var/datum/faction/F in SSstar_system.factions)
			var/datum/game_mode/pvp/mode = SSticker.mode
			if(F.tickets >= 700)
				mode.winner = F //This should allow the mode to finish up by itself
				mode.check_finished()
	if((objective_check >= objective_length) && !failed)
		victory()

/datum/overmap_gamemode/proc/victory()
	SSovermap_mode.objectives_completed = TRUE
	if(SSovermap_mode.admin_override)
		message_admins("[GLOB.station_name] has completed its objectives but round end has been overriden by admin intervention")
		return
	if(SSvote.mode == "Press On Or Return Home?") // We're still voting
		return

	var/datum/star_system/S = SSstar_system.return_system
	S.hidden = FALSE
	if(!SSovermap_mode.round_extended)	//If we haven't yet extended the round, let us vote!
		priority_announce("Mission Complete - Vote Pending") //TEMP get better words
		SSvote.initiate_vote("Press On Or Return Home?", "Centcomm", forced=TRUE, popup=FALSE)
	else	//Begin FTL return jump
		var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
		if(!length(OM.current_system?.enemies_in_system))
			priority_announce("Mission Complete - Returning to [S.name]") //TEMP get better words
			OM.force_return_jump()

/datum/overmap_gamemode/proc/defeat() //Override this if defeat is to be called based on an objective
	priority_announce("Mission Critical Failure - Standby for carbon asset liquidation")
	SSticker.mode.check_finished(TRUE)
	SSticker.force_ending = TRUE

/datum/overmap_objective
	var/name										//Name for admin view
	var/desc										//Short description for admin view
	var/brief										//Description for PLAYERS
	var/stage										//For multi step objectives
	var/binary = TRUE								//Is this just a simple T/F objective?
	var/tally = 0									//How many of the objective goal has been completed
	var/target = 0									//How many of the objective goal is required
	var/status = STATUS_INPROGRESS					//0 = In-progress, 1 = Completed, 2 = Failed, 3 = Victory Override (this will end the round)
	var/extension_supported = FALSE 				//Is this objective available to be a random extended round objective?
	var/ignore_check = FALSE						//Used for checking extended rounds
	var/instanced = FALSE							//Have we yet run the instance proc for this objective?
	var/objective_number = 0						//The objective's index in the list. Useful for creating arbitrary report titles
	var/required_players = 0						//Minimum number of players to get this if it's a random/extended objective
	var/maximum_players = 0							//Maximum number of players to get this if it's a random/extended objective. 0 is unlimited.

/datum/overmap_objective/New()

/datum/overmap_objective/proc/instance() //Used to generate any in world assets
	if ( SSovermap_mode.announced_objectives )
		// If this objective was manually added by admins after announce, prints a new report. Otherwise waits for the gamemode to be announced before instancing reports
		print_objective_report()

	instanced = TRUE

/datum/overmap_objective/proc/check_completion()

/datum/overmap_objective/proc/print_objective_report()

/datum/overmap_objective/custom
	name = "Custom"

/datum/overmap_objective/custom/New(passed_input) //Receive the string and make it brief/desc
	.=..()
	desc = passed_input
	brief = passed_input

//////ADMIN TOOLS//////

/client/proc/overmap_mode_controller() //Admin Verb for the Overmap Gamemode controller
	set name = "Overmap Gamemode Controller"
	set desc = "Manage the Overmap Gamemode"
	set category = "Adminbus"
	var/datum/overmap_mode_controller/omc = new(usr)
	omc.ui_interact(usr)

/datum/overmap_mode_controller
	var/name = "Overmap Gamemode Controller"
	var/client/holder = null

/datum/overmap_mode_controller/New(H)
	if(istype(H, /client))
		var/client/C = H
		holder = C
	else
		var/mob/M = H
		holder = M.client
	.=..()

/datum/overmap_mode_controller/ui_state(mob/user)
	return GLOB.admin_state

/datum/overmap_mode_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OvermapGamemodeController")
		ui.open()
		ui.set_autoupdate(TRUE) // Countdowns

/datum/overmap_mode_controller/ui_act(action, params)
	if(..())
		return
	var/adjust = text2num(params["adjust"])
	if(action == "current_escalation")
		if(isnum(adjust))
			SSovermap_mode.escalation = adjust
			if(SSovermap_mode.escalation > 5)
				SSovermap_mode.escalation = 5
			if(SSovermap_mode.escalation < -5)
				SSovermap_mode.escalation = -5
			SSovermap_mode.difficulty_calc()

	switch(action)
		if("adjust_threat")
			var/amount = input("Enter amount of threat to add (or substract if negative)", "Adjust Threat") as num|null
			SSovermap_mode.modify_threat_elevation(amount)
		if("change_gamemode")
			if(SSovermap_mode.mode_initialised)
				message_admins("Post Initilisation Overmap Gamemode Changes Not Currently Supported") //SoonTM
				return
			var/list/gamemode_pool = subtypesof(/datum/overmap_gamemode)
			var/datum/overmap_gamemode/S = input(usr, "Select Overmap Gamemode", "Change Overmap Gamemode") as null|anything in gamemode_pool
			if(isnull(S))
				return
			if(SSovermap_mode.mode_initialised)
				qdel(SSovermap_mode.mode)
				SSovermap_mode.mode = new S()
				message_admins("[key_name_admin(usr)] has changed the overmap gamemode to [SSovermap_mode.mode.name]")
			else
				SSovermap_mode.forced_mode = S
				message_admins("[key_name_admin(usr)] has changed the overmap gamemode to [initial(S.name)]")
			return
		if("add_objective")
			var/list/objectives_pool = (subtypesof(/datum/overmap_objective) - /datum/overmap_objective/custom)
			var/datum/overmap_objective/S = input(usr, "Select objective to add", "Add Objective") as null|anything in objectives_pool
			if(isnull(S))
				return
			var/extra
			if(ispath(S,/datum/overmap_objective/clear_system))
				extra = input(usr, "Select a target system", "Select System") as null|anything in SSstar_system.systems
			SSovermap_mode.mode.objectives += new S(extra)
			SSovermap_mode.instance_objectives()
			return
		if("add_custom_objective")
			var/custom_desc = input("Input Objective Briefing", "Custom Objective") as text|null
			SSovermap_mode.mode.objectives += new /datum/overmap_objective/custom(custom_desc)
			return
		if("view_vars")
			usr.client.debug_variables(locate(params["target"]))
			return
		if("remove_objective")
			var/datum/overmap_objective/O = locate(params["target"])
			SSovermap_mode.mode.objectives -= O
			qdel(O)
			return
		if("change_objective_state")
			var/list/o_state = list("In-Progress",
									"Completed",
									"Failed",
									"Victory Override")
			var/new_state = input("Select state to set", "Change Objective State") as null|anything in o_state
			if(new_state == "In-Progress")
				new_state = STATUS_INPROGRESS
			else if(new_state == "Completed")
				new_state = STATUS_COMPLETED
			else if(new_state == "Failed")
				new_state = STATUS_FAILED
			else if(new_state == "Victory Override")
				new_state = STATUS_OVERRIDE
			var/datum/overmap_objective/O = locate(params["target"])
			O.status = new_state
			return
		if("toggle_reminder")
			SSovermap_mode.objective_reminder_override = !SSovermap_mode.objective_reminder_override
			return
		if("extend_reminder")
			var/amount = input("Enter amount to extend by in minutes:", "Extend Reminder") as num|null
			SSovermap_mode.next_objective_reminder += amount MINUTES
			return
		if("reset_stage")
			SSovermap_mode.objective_reminder_stacks = 0
			return
		if("override_completion")
			SSovermap_mode.admin_override = !SSovermap_mode.admin_override
			return
		if("spawn_ghost_ship")
			set waitfor = FALSE

			//Choose spawn location logic
			var/target_location
			switch(alert(usr, "Spawn at a random spot in the current mainship Z level or your location?", "Select Spawn Location", "Ship Z", "Current Loc", "Cancel"))
				if("Cancel")
					return
				if("Ship Z")
					var/obj/structure/overmap/MS = SSstar_system.find_main_overmap()
					target_location = locate(rand(round(world.maxx/2) + 10, world.maxx - 39), rand(40, world.maxy - 39), MS.z)
				if("Current Loc")
					target_location = usr.loc

			//Choose ship spawn
			var/list/ship_list = list()
			ship_list += typesof(/obj/structure/overmap/nanotrasen/ai)
			ship_list += typesof(/obj/structure/overmap/spacepirate/ai)
			ship_list += typesof(/obj/structure/overmap/syndicate/ai)
			ship_list += typesof(/obj/structure/overmap/nanotrasen/solgov/ai)
			var/obj/structure/overmap/target_ship = input(usr, "Select which ship to spawn (note: factions will apply):", "Select Ship") as null|anything in ship_list

			//Choose ghost logic
			var/target_ghost
			switch(alert(usr, "Who is going to pilot this ghost ship?", "Pilot Select Format", "Open", "Choose", "Cancel"))
				if("Cancel")
					return
				if("Open")
					var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you wish to pilot a [initial(target_ship.faction)] [initial(target_ship.name)]?", ROLE_GHOSTSHIP, /datum/role_preference/midround_ghost/ghost_ship, 20 SECONDS, POLL_IGNORE_GHOSTSHIP)
					if(LAZYLEN(candidates))
						var/mob/dead/observer/C = pick(candidates)
						target_ghost = C
					else
						return
				if("Choose")
					target_ghost = input(usr, "Select player to pilot ghost ship:", "Select Player") as null|anything in GLOB.clients

			//Now the actual spawning
			var/obj/structure/overmap/GS = new target_ship(target_location)
			GS.ghost_ship(target_ghost)
			message_admins("[key_name_admin(usr)] has spawned a ghost [GS.name]!")
			log_admin("[key_name_admin(usr)] has spawned a ghost [GS.name]!")

		if("toggle_ghost_ships")
			if(SSovermap_mode.override_ghost_ships)
				SSovermap_mode.override_ghost_ships = FALSE
				message_admins("[key_name_admin(usr)] has ENABLED player ghost ships.")
			else if(!SSovermap_mode.override_ghost_ships)
				SSovermap_mode.override_ghost_ships = TRUE
				message_admins("[key_name_admin(usr)] has DISABLED player ghost ships.")

		if("toggle_ghost_boarders")
			if(SSovermap_mode.override_ghost_boarders)
				SSovermap_mode.override_ghost_boarders = FALSE
				message_admins("[key_name_admin(usr)] has ENABLED player antag boarders.")
			else if(!SSovermap_mode.override_ghost_boarders)
				SSovermap_mode.override_ghost_boarders = TRUE
				message_admins("[key_name_admin(usr)] has DISABLED player antag boarders.")

/datum/overmap_mode_controller/ui_data(mob/user)
	var/list/data = list()
	var/list/objectives = list()
	if(SSovermap_mode.mode)
		data["current_gamemode"] = SSovermap_mode.mode.name
	else if(SSovermap_mode.forced_mode)
		data["current_gamemode"] = initial(SSovermap_mode.forced_mode.name)
	data["current_description"] = SSovermap_mode.mode?.desc
	data["mode_initalised"] = SSovermap_mode?.mode_initialised
	data["current_difficulty"] = SSovermap_mode.mode?.difficulty
	data["current_escalation"] = SSovermap_mode.escalation
	data["reminder_time_remaining"] = (SSovermap_mode.next_objective_reminder - world.time) / 10 //Seconds
	data["reminder_interval"] = SSovermap_mode.mode?.objective_reminder_interval / 600 //Minutes
	data["reminder_stacks"] = SSovermap_mode.objective_reminder_stacks
	data["toggle_reminder"] = SSovermap_mode.objective_reminder_override
	data["toggle_override"] = SSovermap_mode.admin_override
	data["threat_elevation"] = SSovermap_mode.threat_elevation
	data["threat_per_size_point"] = TE_POINTS_PER_FLEET_SIZE
	data["toggle_ghost_ships"] = SSovermap_mode.override_ghost_ships
	data["toggle_ghost_boarders"] = SSovermap_mode.override_ghost_boarders
	for(var/datum/overmap_objective/O in SSovermap_mode.mode?.objectives)
		var/list/objective_data = list()
		objective_data["name"] = O.name
		objective_data["desc"] = O.desc
		switch(O.status)
			if(STATUS_INPROGRESS)
				objective_data["status"] = "In-Progress"
			if(STATUS_COMPLETED)
				objective_data["status"] = "Completed"
			if(STATUS_FAILED)
				objective_data["status"] = "Failed"
			if(STATUS_OVERRIDE)
				objective_data["status"] = "Completed - VICTORY OVERRIDE"
		objective_data["datum"] = "\ref[O]"
		objectives[++objectives.len] = objective_data
	data["objectives_list"] = objectives
	return data

#undef STATUS_INPROGRESS
#undef STATUS_COMPLETED
#undef STATUS_FAILED
#undef STATUS_OVERRIDE
#undef REMINDER_OBJECTIVES
#undef REMINDER_COMBAT_RESET
#undef REMINDER_COMBAT_DELAY
#undef REMINDER_OVERRIDE
