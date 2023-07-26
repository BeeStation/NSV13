/**

Shamelessly ripped off from nuclear.dm

*/

GLOBAL_LIST_EMPTY(syndi_crew_spawns)

GLOBAL_LIST_EMPTY(syndi_crew_leader_spawns)

/datum/game_mode/pvp
	name = "Galactic Conquest"
	config_tag = "pvp"
	report_type = "pvp"
	false_report_weight = 10
	required_players = 24 //40 // 40 to make 20 v 20
	required_enemies = 12 //20
	recommended_enemies = 15
	role_preference = /datum/role_preference/antagonist/pvp
	antag_datum = /datum/antagonist/nukeop/syndi_crew

	announce_span = "danger"
	announce_text = "The Syndicate are planning an all out assault!\n\
	<span class='danger'>Syndicate crew</span>: Destroy NT fleets and capture systems with your beacon.</span>\n\
	<span class='notice'>Crew</span>: Destroy the Syndicate crew, and defeat any Syndicate reinforcements that appear.</span>"

	title_icon = "conquest"

	var/list/pre_nukeops = list()

	var/nukes_left = 1

	var/datum/team/nuclear/nuke_team
	var/highpop_threshold = 45 //At what player count does the round enter "highpop" mode, and spawn the Syndicate a larger ship to compensate.
	var/datum/faction/winner = null //Has a winning faction been declared?

	var/operative_antag_datum_type = /datum/antagonist/nukeop/syndi_crew
	var/leader_antag_datum_type = /datum/antagonist/nukeop/leader/syndi_crew
	var/list/jobs = list()
	var/overflow_role = CONQUEST_ROLE_GRUNT
	var/time_limit = 2 HOURS + 30 MINUTES //How long do you want the mode to run for? This is capped to keep it from dragging on or OOMing
	var/list/maps = list(
		list(path = "hammurabiPVP.json", pop = list(0, 30)),
		list(path = "astraeusPVP.json", pop = list(31, 39)),
		list(path = "babylonPVP.json", pop = list(40, INFINITY))
		) //Basic list of maps. Tell me (Kmc) to improve this if you decide you want to add more than 1 PVP map and i'll make it use JSON instead. ~Kmc 23/02/2021 I got called a lazy hack so I went and did this properly :(
	var/obj/structure/overmap/syndiship = null
	var/end_on_team_death = FALSE //Should the round end when the syndies die?

/**

Method to spawn in the Syndi ship on a brand new Z-level with the "boardable" trait active so we can fly to it.

*/

/datum/game_mode/pvp/proc/assign_jobs()
	//Now divvy up the roles! We have certain ones we _must_ fill, and others we'd _like_ to fill.
	var/list/autofill_victims = list()
	//Round 1: Try assign people to their ideal roles.
	for(var/datum/mind/nextCrewman in pre_nukeops)
		var/preferred_job = nextCrewman.current.client.prefs.preferred_syndie_role
		//Order of conquest_role_handler.roles is in descending for priority.
		var/datum/syndicate_crew_role/idealRole = GLOB.conquest_role_handler.get_job(preferred_job)
		//This job's filled up, OR they've picked the overflow role, which means they don't really care, so we autofill them!
		if(!idealRole || idealRole.max_count == INFINITY || !idealRole.assign(nextCrewman))
			autofill_victims += nextCrewman
			continue

	var/datum/syndicate_crew_role/overflow = GLOB.conquest_role_handler.get_job(overflow_role)
	//Round 2: now dish out roles to those unlucky enough to not get their preference.
	for(var/datum/mind/autofill in autofill_victims)
		//Find the next un-filled job in order of priority.
		var/foundJob = FALSE
		for(var/datum/syndicate_crew_role/nextRole in GLOB.conquest_role_handler.roles)
			if(!nextRole.essential) //We don't forcibly fill opt in, non-essential roles.
				continue
			if(nextRole.assign(autofill))
				//Cool, we've found a target!
				to_chat(autofill, "<span class='warning'>You have been autofilled into [nextRole]! If you're not comfortable playing this role due to inexperience, please ahelp!")
				foundJob = TRUE
				break

		if(!foundJob) //No job? Fallback time.
			overflow.assign(autofill)


/datum/game_mode/pvp/pre_setup()
	var/n_agents = antag_candidates.len
	if(!syndiship)
		//syndiship = instance_overmap(_path=ship_type, folder= "map_files/Instanced/map_files" ,interior_map_files = map_file, midround=TRUE)
		//Pick a map! any map... (based on pop)
		var/list/possible = list()
		for(var/list/data in maps)
			var/list/pop = data["pop"] //Linters :vomit:
			//Check the bounds of the map.
			if(num_players() < pop[1] || num_players() > pop[2])
				continue
			possible += data["path"]

		var/ship_file = file("_maps/map_files/Instanced/[pick(possible)]")
		if(!isfile(ship_file)) //Why would this ever happen? Who knows, I sure don't.
			message_admins("ERROR SETTING UP PVP: Invalid json file [ship_file]. Tell a coder to fix this.")
			CRASH("Invalid json file \"[ship_file]\" tried to load in PVP setup.")
		syndiship = instance_ship_from_json(ship_file)

	if(n_agents > 0)
		//Registers two signals to check either ship as being destroyed.
		RegisterSignal(syndiship, COMSIG_PARENT_QDELETING, PROC_REF(force_loss))
		RegisterSignal(SSstar_system.find_main_overmap(), COMSIG_PARENT_QDELETING, PROC_REF(force_win))
		SSovermap_mode.mode = new/datum/overmap_gamemode/galactic_conquest //Change the overmap gamemode
		message_admins("Galactic Conquest in progress. Overmap gamemode is now [SSovermap_mode.mode.name]")
		var/enemies_to_spawn = max(1, round(num_players()/2.5)) //Syndicates scale with pop. On a standard 30 pop, this'll be 30 - 10 -> 20 / 10 -> 2 floored = 2, where FLOOR rounds the number to a whole number.
		for(var/i = 0, i < enemies_to_spawn, i++)
			var/datum/mind/new_op = pick_n_take(antag_candidates)
			pre_nukeops += new_op
			new_op.assigned_role = "Syndicate crewmember"
			new_op.special_role = "Syndicate crewmember"
			log_game("[key_name(new_op)] has been selected as a syndicate crewmember!")
		return TRUE
	else
		qdel(syndiship)
		setup_error = "Not enough syndicate crew candidates"
		return FALSE
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
/proc/overmap_lighting_force(obj/structure/overmap/hammurabi)
	set waitfor = FALSE
	for(var/area/AR in hammurabi.linked_areas) //Force lighting to update. Not pretty, but it works
		AR.set_dynamic_lighting(DYNAMIC_LIGHTING_FORCED)

/datum/game_mode/pvp/post_setup()
	assign_jobs()
	SSstar_system.time_limit = world.time + time_limit //Hard timecap to prevent this dragging on or crashing.
	//And now, we make it so that NT sends fleets instead of the Syndicate...
	var/datum/faction/synd = SSstar_system.faction_by_id(FACTION_ID_SYNDICATE)
	var/datum/faction/nt = SSstar_system.faction_by_id(FACTION_ID_NT)
	nt.fleet_spawn_rate = synd.fleet_spawn_rate
	synd.fleet_spawn_rate = 2 HOURS
	SSshuttle.registerHostileEnvironment(src)//Evac is disallowed
	return ..()

/datum/game_mode/pvp/OnNukeExplosion(off_station)
	..()
	nukes_left--

//This happens when the Nebuchadnezzar is destroyed
/datum/game_mode/pvp/proc/force_loss()
	winner = SSstar_system.faction_by_id(FACTION_ID_NT)
	check_finished()
	SSticker.force_ending = TRUE

//And this subsequently happens if the nsv is taken out
/datum/game_mode/pvp/proc/force_win()
	winner = SSstar_system.faction_by_id(FACTION_ID_SYNDICATE)
	check_finished()
	SSticker.force_ending = TRUE

/datum/game_mode/pvp/check_win()
	if(winner)
		if(winner.id != FACTION_ID_NT)
			return TRUE
		else
			return FALSE
	if(nukes_left == 0)
		return TRUE
	return ..()

/datum/game_mode/pvp/check_finished()
	if(winner) //SSstar_system has declared a winner! Time to clean up.
		return TRUE

	//Keep the round going if ops are dead but bomb is ticking.
	if(nuke_team?.operatives_dead())
		for(var/obj/machinery/nuclearbomb/N in GLOB.nuke_list)
			if(N.proper_bomb && (N.timing || N.exploding))
				return FALSE
		return end_on_team_death
	return ..()

/datum/game_mode/pvp/set_round_result()
	..()
	var/result = nuke_team?.get_result()
	//First off, did they manage to nuke the ship?
	if(result == NUKE_RESULT_NUKE_WIN)
		SSticker.mode_result = "win - syndicate nuke"
		SSticker.news_report = STATION_NUKED
		return
	switch(winner.id)
		if(FACTION_ID_NT)
			SSticker.mode_result = "loss - Nanotrasen repelled the invasion"
			SSticker.news_report = PVP_SYNDIE_LOSS
			return
		if(FACTION_ID_PIRATES)
			SSticker.mode_result = "partial win - The Syndicate's allies secured a large amount of territory."
			SSticker.news_report = PVP_SYNDIE_PIRATE_WIN
			return
		if(FACTION_ID_SYNDICATE)
			SSticker.mode_result = "syndicate major victory! - The Syndicate has secured a large amount of territory."
			SSticker.news_report = PVP_SYNDIE_WIN
			return
	SSticker.mode_result = "syndicate minor loss! - Nanotrasen's allies were able to repel the invasion."
	SSticker.news_report = PVP_SYNDIE_LOSS

/datum/game_mode/pvp/generate_report()
	return "Intel suggests that the Syndicate are mounting an all out assault on the Sol sector. Be prepared for anything."

/datum/game_mode/pvp/generate_credit_text()
	var/list/round_credits = list()

	round_credits += "<center><h1>The syndicate crew:</h1>"
	for(var/datum/mind/operative in nuke_team.members)
		round_credits += "<center><h2>[operative.name] as a Syndicate crewmember</h2>"

	round_credits += ..()
	return round_credits
