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
	//flags = SS_NO_INIT

	var/escalation = 0								//Admin ability to tweak current mission difficulty level
	var/player_check = 0 							//Number of players connected when the check is made for gamemode
	var/datum/overmap_gamemode/mode 				//The assigned mode

	var/objective_reminder_override = FALSE 		//Are we currently using the reminder system?
	var/last_objective_interaction = 0 				//Last time the crew interacted with one of our objectives
	var/next_objective_reminder = 0 				//Next time we automatically remind the crew to proceed with objectives
	var/objective_reminder_stacks = 0 				//How many times has the crew been automatically reminded of objectives without any progress
	var/combat_resets_reminder = FALSE 				//Does combat in the overmap reset the reminder?
	var/combat_delays_reminder = FALSE 				//Does combat in the overmap delay the reminder?
	var/combat_delay_amount = 0 					//How much the reminder is delayed by combat

	var/announced_objectives = FALSE 				//Have we announced the objectives yet?
	var/round_extended = FALSE 						//Has the round already been extended already?
	var/admin_override = FALSE						//Stops the mission ending
	var/already_ended = FALSE						//Is the round already in an ending state

	var/check_completion_timer = 0

	var/list/mode_cache

	var/list/modes
	var/list/mode_names

//some legacy vars that need to be resolved in other files
	var/next_nag_time = 0
	var/nag_interval = 30 MINUTES //Get off your asses and do some work idiots
	var/nag_stacks = 0 //How many times have we told you to get a move on?

/datum/controller/subsystem/overmap_mode/Initialize(start_timeofday)
	//Retrieve the list of modes
	//Check our map for any white/black lists
	//Exclude or lock any modes due to maps
	//Check the player numbers
	//Exclude or lock any modes due to players
	//Use probs to pick a mode from the trimmed pool
	//Set starting systems for the player ships
	//Load and set objectives

	mode_cache = typecacheof(/datum/overmap_gamemode, TRUE)

	for(var/D in subtypesof(/datum/overmap_gamemode))
		var/datum/overmap_gamemode/N = new D()
		mode_cache[D] = N

	var/list/mode_pool = mode_cache

	for(var/M in mode_pool)
		var/datum/overmap_gamemode/GM = mode_pool[M]
		if(GM.whitelist_only) //Remove all of our only whitelisted modes
			QDEL_NULL(mode_pool[M])
			mode_pool -= M

	if(SSmapping.config.omode_blacklist.len > 0)
		if(locate("all") in SSmapping.config.omode_blacklist)
			mode_pool = list() //Clear the list
		else
			for(var/S in SSmapping.config.omode_blacklist) //Grab the string to be the path - is there a proc for this?
				var/B = text2path("/datum/overmap_gamemode/[S]")
				QDEL_NULL(mode_pool[B])
				mode_pool -= B

	if(SSmapping.config.omode_whitelist.len > 0)
		for(var/S in SSmapping.config.omode_whitelist) //Grab the string to be the path - is there a proc for this?
			var/W = text2path("/datum/overmap_gamemode/[S]")
			mode_pool[W] = new W()

	for(var/mob/dead/new_player/P in GLOB.player_list) //Count the number of connected players
		if(P.client)
			player_check ++

	for(var/M in mode_pool) //Check and remove any modes that we have insufficient players for the mode
		var/datum/overmap_gamemode/GM = mode_pool[M]
		if(player_check < GM.required_players)
			QDEL_NULL(mode_pool[M])
			mode_pool -= M

	if(mode_pool.len)
		var/list/mode_select = list()
		for(var/M in mode_pool)
			var/datum/overmap_gamemode/GM = mode_pool[M]
			for(var/I = 0, I < GM.selection_weight, I++) //Populate with weight number of instances
				mode_select += M

		if(mode_select.len)
			var/mode_type = pick(mode_select)
			mode = mode_pool[mode_type]
			message_admins("[mode.name] has been selected as the overmap gamemode")
			log_game("[mode.name] has been selected as the overmap gamemode")
	if(!mode)
		//mode_type = /datum/overmap_gamemode/patrol //Holding that as the default for now - REPLACE ME LATER
		mode = new/datum/overmap_gamemode/patrol()
		message_admins("Error: mode section pool empty - defaulting to PATROL")
		log_game("Error: mode section pool empty - defaulting to PATROL")


	switch(mode.objective_reminder_setting) //Load the reminder settings
		if(REMINDER_COMBAT_RESET)
			combat_resets_reminder = TRUE
		if(REMINDER_COMBAT_DELAY)
			combat_delays_reminder = TRUE
			combat_delay_amount = mode.combat_delay
		if(REMINDER_OVERRIDE)
			objective_reminder_override = TRUE

	var/list/objective_pool = list() //Create instances of our objectives
	for(var/O in mode.objectives)
		var/datum/overmap_objective/I = new O()
		objective_pool += I

	mode.objectives = objective_pool
	for(var/datum/overmap_objective/O in mode.objectives)
		O.instance() //Setup any overmap assets

	var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
	if(OM)
		var/datum/star_system/target = SSstar_system.system_by_id(mode.starting_system)
		OM.jump(target) //Move the ship to the designated start
		if(mode.starting_faction)
			OM.faction = mode.starting_faction //If we have a faction override, set it

/datum/controller/subsystem/overmap_mode/fire()

	if(world.time >= 3 MINUTES && !announced_objectives) //Send out our objectives
		announce_objectives()

	if(world.time >= check_completion_timer) //Fire this automatically every ten minutes to prevent round stalling
		difficulty_calc() //Also do our difficulty check here
		mode.check_completion()
		check_completion_timer += 10 MINUTES

	if(!objective_reminder_override)
		if(world.time >= next_objective_reminder)
			objective_reminder_stacks ++
			next_objective_reminder = world.time + mode.objective_reminder_interval
			switch(objective_reminder_stacks)
				if(1)
					//something
					priority_announce("[mode.reminder_one]", "[mode.reminder_origin]")
					mode.consequence_one()
				if(2)
					//something else
					priority_announce("[mode.reminder_two]", "[mode.reminder_origin]")
					mode.consequence_two()
				if(3)
					//something else +
					priority_announce("[mode.reminder_three]", "[mode.reminder_origin]")
					mode.consequence_three()
				if(4)
					//last chance
					priority_announce("[mode.reminder_four]", "[mode.reminder_origin]")
					mode.consequence_four()
				if(5)
					//mission critical failure
					priority_announce("[mode.reminder_five]", "[mode.reminder_origin]")
					mode.consequence_five()

/datum/controller/subsystem/overmap_mode/New()
	.=..()
	next_objective_reminder = world.time + mode.objective_reminder_interval

/datum/controller/subsystem/overmap_mode/proc/announce_objectives()
	announced_objectives = TRUE

 	/*
	Replace with a SMEAC brief?
	- Situation
	- Mission
	- Execution
	- Administration
	- Communication
	*/

	var/text = "<b>[GLOB.station_name]</b>, <br>You have been assigned the following mission by <b>[capitalize(mode.starting_faction)]</b> and are expected to complete it with all due haste. Please ensure your crew is properly informed of your objectives and delegate tasks accordingly."
	var/title = "Mission Briefing: [random_capital_letter()][random_capital_letter()][random_capital_letter()]-[GLOB.round_id]"

	text = "[text] <br><br> [mode.brief] <br><br> Objectives:"

	for(var/datum/overmap_objective/O in mode.objectives)
		text = "[text] <br> - [O.brief]"

	print_command_report(text, title, TRUE)

/datum/controller/subsystem/overmap_mode/proc/update_reminder(var/objective = FALSE)
	if(objective) //Is objective? Full Reset
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
		O.ignore_check = TRUE //We no longer care about checking these objective against completeion

	var/list/extension_pool = typecacheof(/datum/overmap_objective, TRUE)
	for(var/O in extension_pool)
		var/datum/overmap_objective/OO = new O()
		if(OO.extension_supported == FALSE) //Clear the pool of anything we can't add
			extension_pool -= O
		else
			extension_pool[O] = OO

	var/datum/overmap_objective/selected = extension_pool[pick(extension_pool)] //Insert new objective
	mode.objectives += new selected()
	for(var/datum/overmap_objective/O in mode.objectives)
		if(O.ignore_check == FALSE)
			O.instance()

	announce_objectives() //Let them all know

/datum/controller/subsystem/overmap_mode/proc/difficulty_calc()
	var/players = get_active_player_count(TRUE, FALSE, FALSE) //Check how many players are still alive
	switch(players)
		if(0 to 10)
			mode.difficulty = 1
		if(10 to 20)
			mode.difficulty = 2
		if(20 to 30)
			mode.difficulty = 3
		if(30 to 40)
			mode.difficulty = 4
		if(40 to INFINITY)
			mode.difficulty = 5

	mode.difficulty += escalation //Our admin adjustment
	if(mode.difficulty <= 0)
		mode.difficulty = 1

/datum/overmap_gamemode
	var/name = null											//Name of the gamemode type
	var/desc = null											//Description of the gamemode for ADMINS
	var/brief = null										//Description of the gamemode for PLAYERS
	var/config_tag = null									//Do we have a tag?
	var/selection_weight = 0								//Used to determine the chance of this gamemode being selected
	var/required_players = 0								//Required number of players for this gamemode to be randomly selected
	var/difficulty = null									//Difficulty of the gamemode as determined by player count / abus abuse: 1 is minimum, 10 is maximum
	var/starting_system = null								//Here we define where our player ships will start
	var/starting_faction = null 							//Here we define which faction our player ships belong
	var/objective_reminder_setting = REMINDER_OBJECTIVES	//0 - Objectives reset remind. 1 - Combat resets reminder. 2 - Combat delays reminder. 3 - Disables reminder
	var/objective_reminder_interval = 15 MINUTES			//Interval between objective reminders
	var/combat_delay = 0									//How much time is added to the reminder timer
	var/list/objectives = list()							//The actual gamemode objectives go here
	var/whitelist_only = FALSE								//Can only be selected through map bound whitelists

	//Reminder messages
	var/reminder_origin = "Naval Command"
	var/reminder_one = "Case 1"
	var/reminder_two = "Case 2"
	var/reminder_three = "Case 3"
	var/reminder_four = "Case 4"
	var/reminder_five = "Case 5"

/datum/overmap_gamemode/proc/consequence_one()


/datum/overmap_gamemode/proc/consequence_two()


/datum/overmap_gamemode/proc/consequence_three()


/datum/overmap_gamemode/proc/consequence_four()
	var/datum/faction/F = SSstar_system.faction_by_id(starting_faction)
	F.lose_influence(100)

/datum/overmap_gamemode/proc/consequence_five()
	//Hotdrop O'Clock
	var/datum/star_system/target = SSstar_system.find_main_overmap().current_system
	priority_announce("Faction Hunter something something Hotdrop") //need a faction message
	var/datum/fleet/F = new /datum/fleet/interdiction() //need a fleet
	target.fleets += F
	F.current_system = target
	F.assemble(target)



/datum/overmap_gamemode/proc/check_completion() //This gets called by checking the communication console/modcomp program + automatically once every 10 minutes
	if(SSovermap_mode.already_ended)
		return

	var/objective_length = objectives.len
	var/objective_check = 0
	var/failed = FALSE
	for(var/datum/overmap_objective/O in objectives)
		O.check_completion() 	//First we try to check completion on each objective
		if(O.status == STATUS_OVERRIDE) //Victory override check
			victory()
			return
		else if(O.status == STATUS_COMPLETED)
			objective_check ++
		else if(O.status == STATUS_FAILED)
			objective_check ++
			if(O.ignore_check == TRUE) //This was a gamemode objective
				failed = TRUE

	if((objective_check >= objective_length) && !failed)
		victory()

/datum/overmap_gamemode/proc/victory()
	if(SSovermap_mode.admin_override)
		message_admins("[GLOB.station_name] has completed its objectives but round end has been overriden by admin intervention")
		return

	priority_announce("Mission Complete - Vote Pending") //TEMP
	if(!SSovermap_mode.round_extended)	//If we haven't yet extended the round, let us vote!
		SSvote.initiate_vote("Press On Or Return Home?", "Centcomm", forced=TRUE, popup=FALSE)
	else	//Begin FTL jump to Outpost 45
		priority_announce("Mission Complete - Returning to Outpost 45") //TEMP
		var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
		OM.force_return_jump(SSstar_system.system_by_id("Outpost 45")) //replace with a new proc to not instantly jump
	return

/datum/overmap_gamemode/proc/defeat() //Override this if defeat is to be called based on an objective
	SSticker.mode.check_finished(TRUE)
	SSticker.force_ending = TRUE
	return

/datum/overmap_objective
	var/name							//Name for admin view
	var/desc							//Short description for admin view
	var/brief							//Description for PLAYERS
	var/stage							//For multi step objectives
	var/status = STATUS_INPROGRESS		//0 = In-progress, 1 = Completed, 2 = Failed, 3 = Victory Override (this will end the round)
	var/extension_supported = FALSE 	//Is this objective available to be a random extended round objective?
	var/ignore_check = FALSE			//Used for checking extended rounds

/datum/overmap_objective/New()

/datum/overmap_objective/proc/instance() //Used to generate any in world assets
	return

/datum/overmap_objective/proc/check_completion()
	return

#undef STATUS_INPROGRESS
#undef STATUS_COMPLETED
#undef STATUS_FAILED
#undef STATUS_OVERRIDE
#undef REMINDER_OBJECTIVES
#undef REMINDER_COMBAT_RESET
#undef REMINDER_COMBAT_DELAY
#undef REMINDER_OVERRIDE
