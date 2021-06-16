//The NSV13 Version of Game Mode, except it for the overmap and runs parallel to Game Mode
//This needs to fire before SSstar_system

SUBSYSTEM_DEF(overmap_mode)
	name = "overmap_mode"
	wait = 10
	//flags = SS_NO_INIT

	var/escalation = null
	var/player_check = 0 //Number of players connected when the check is made for gamemode
	var/datum/overmap_mission/mode //The assigned mode

	var/last_objective_interaction = 0 //Last time the crew interacted with one of our objectives
	var/next_objective_reminder = 0 //Next time we automatically remind the crew to proceed with objectives
	var/objective_reminder_interval = 30 MINUTES //Interval between objective reminders
	var/objective_reminder_stacks = 0 //How many times has the crew been automatically reminded of objectives without any progress
	var/combat_resets_reminder = FALSE //Does combat in the overmap reset the reminder?
	var/combat_delays_reminder = FALSE //Does combat in the overmap delay the reminder?
	var/combat_delay_amount = 0 //How much the reminder is delayed by combat


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

	mode_cache = typecacheof(/datum/overmap_mission, TRUE)


	//All the possible modes we can select fro,
	var/list/possible = list()

	//Run throughthe subtypes, try instance them
	for(var/dtype in subtypesof(/datum/overmap_mission))
		var/datum/overmap_mission/candidate = new dtype()
		if(candidate.is_selectable())
			possible += (candidate=candidate.weight)
	//Pick using pickweight to account for weight.
	mode = pickweight(possible) || new /datum/overmap_mission/patrol



	var/list/mode_pool = mode_cache

	for(var/datum/overmap_mission/M in mode_pool)
		if(M.whitelist_only) //Remove all of our only whitelisted modes
			mode_pool -= M

	if(SSmapping.config.omode_blacklist.len > 0)
		if(locate("all") in SSmapping.config.omode_blacklist)
			mode_pool = list() //Clear the list
		else
			for(var/S in SSmapping.config.omode_blacklist) //Grab the string to be the path - is there a proc for this?
				var/datum/overmap_mission/B = text2path("/datum/overmap_mission/[S]")
				mode_pool -= B

	if(SSmapping.config.omode_whitelist.len > 0)
		for(var/S in SSmapping.config.omode_whitelist) //Grab the string to be the path - is there a proc for this?
			var/datum/overmap_mission/W = text2path("/datum/overmap_mission/[S]")
			mode_pool += W

	for(var/mob/dead/new_player/P in GLOB.player_list) //Count the number of connected players
		if(P.client)
			player_check ++

	for(var/datum/overmap_mission/M in mode_pool) //Check and remove any modes that we have insufficient players for the mode
		if(player_check < M.required_players)
			mode_pool -= M

	if(mode_pool.len <= 0) //If the pool is empty, we set the default
		mode = /datum/overmap_mission/patrol //Holding that as the default for now - REPLACE ME LATER
		message_admins("Error: mode section pool empty - defaulting to PATROL")

	else //Here we need to generate a ticket system that pulls from the config - aka: AAAAAAAAAAAAAAAAAAAA

		var/list/mode_select = list()
		for(var/datum/overmap_mission/M in mode_pool)
			for(var/I = 0, I < M.selection_weight, I++) //What could go wrong
				mode_select += M

		mode = pick(mode_select)
		message_admins("[mode.name] has been selected as the overmap gamemode")

	switch(mode.objective_reminder_setting) //Load the reminder settings
		if(1)
			combat_resets_reminder = TRUE
		if(2)
			combat_delays_reminder = TRUE
			combat_delay_amount = mode.combat_delay


	//configuration.dm line 341 /datum/controller/configuration/proc/get_runnable_modes()

	//We need to poll and assign each of the weights from the config and assign them to their datums
	//We should probably do this for players too
	//Which means we should do this way up above ^^ AAAAAAAAAAAAAAAAAAAA

	//CONFIG_GET(number/)




/datum/controller/subsystem/overmap_mode/fire()

	if(world.time >= next_objective_reminder)
		objective_reminder_stacks ++
		next_objective_reminder = world.time + objective_reminder_interval
		switch(objective_reminder_stacks)
			if(1)
				//something
				priority_announce("Case 1", "Naval Command")
			if(2)
				//something else
				priority_announce("Case 2", "Naval Command")
			if(3)
				//something else +
				priority_announce("Case 3", "Naval Command")
			if(4)
				//last chance
				priority_announce("Case 4", "Naval Command")
			if(5)
				//mission critical failure
				priority_announce("Case 5", "Naval Command")

/datum/controller/subsystem/overmap_mode/New()
	.=..()
	next_objective_reminder = world.time + objective_reminder_interval

/datum/controller/subsystem/overmap_mode/proc/check_completion()


/datum/controller/subsystem/overmap_mode/proc/update_reminder(var/objective = FALSE)
	if(objective) //Is objective? Full Reset
		last_objective_interaction = world.time
		objective_reminder_stacks = 0
		objective_reminder_interval = initial(objective_reminder_interval)
		next_objective_reminder = world.time + objective_reminder_interval
		return

	if(combat_resets_reminder) //Set for full reset on combat
		objective_reminder_stacks = 0
		objective_reminder_interval = initial(objective_reminder_interval)
		next_objective_reminder = world.time + objective_reminder_interval
		return

	if(combat_delays_reminder) //Set for time extension on combat
		next_objective_reminder += combat_delay_amount
		return




/datum/overmap_mission
	var/name = null						//Name of the mission type
	var/desc = null						//Description of the mission
	var/config_tag = null				//Do we have a tag?
	var/selection_weight = null			//Used to detrmine the chance of this mission being selected
	var/required_players = null			//Required number of players for this mission to be randomly selected
	var/difficulty = null				//Difficulty of the mission as determined by player count / abus abuse
	var/starting_system = null			//Here we define where our player ships will start
	var/starting_faction = null 		//Here we define which faction our player ships belong
	var/objective_reminder_setting = 0	//0 - Objectives reset remind. 1 - Combat resets reminder. 2 - Combat delays reminder.
	var/combat_delay = 0				//How much time is added to the reminder timer
	var/list/objectives = list()		//The actual mission objectives go here
	var/whitelist_only = FALSE			//Can only be selected through map bound whitelists


/datum/overmap_objective
	var/name
	var/desc
	var/stage

