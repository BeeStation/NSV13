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
	required_players = 0//30 // 30 players initially, with 15 crewing the hammurabi and 15 crewing the larger, more powerful hammerhead
	required_enemies = 1//10
	recommended_enemies = 10
	antag_flag = ROLE_SYNDI_CREW
	enemy_minimum_age = 0

	announce_span = "danger"
	announce_text = "Nanotrasen's incursions into Syndicate space have not gone unnoticed!\n\
	<span class='danger'>Operatives</span>: Eliminate Nanotrasen's presence in Syndicate space using the weaponry of the SSV Hammurabi, or via a thermonuclear detonation.\n\
	<span class='notice'>Crew</span>: Survive the Syndicate assault long enough for reinforcements to arrive."

	title_icon = "nukeops"

	var/list/pre_nukeops = list()

	var/nukes_left = 1

	var/datum/team/nuclear/nuke_team
	var/highpop_threshold = 45 //At what player count does the round enter "highpop" mode, and spawn the Syndicate a larger ship to compensate.
	var/datum/faction/winner = null //Has a winning faction been declared?

	var/operative_antag_datum_type = /datum/antagonist/nukeop/syndi_crew
	var/leader_antag_datum_type = /datum/antagonist/nukeop/leader/syndi_crew
	var/list/standard_ships = list("Hammurabi.dmm") //Update this list if you make more PVP ships :) ~Kmc
	var/list/highpop_ships = list("Hulk.dmm") //Update this list if you make a big PVP ship
	var/list/jobs = list()
	var/overflow_role = CONQUEST_ROLE_GRUNT
	var/time_limit = 1 HOURS + 45 MINUTES //How long do you want the mode to run for? This is capped to keep it from dragging on or OOMing

/**

Method to spawn in the Syndi ship on a brand new Z-level with the "boardable" trait active so we can fly to it.

*/

/datum/game_mode/pvp/proc/assign_jobs()
	//Now divvy up the roles! We have certain ones we _must_ fill, and others we'd _like_ to fill.
	var/list/candidates = list()
	var/list/autofill_victims = list()
	for(var/datum/syndicate_crew_role/role in GLOB.conquest_role_handler.roles)
		candidates[role] = list()

	for(var/datum/mind/nextCrewman in pre_nukeops)
		var/preferred_job = nextCrewman.current.client.prefs.preferred_syndie_role
		//Order of conquest_role_handler.roles is in descending for priority.
		var/datum/syndicate_crew_role/idealRole = GLOB.conquest_role_handler.get_job(preferred_job)
		var/list/L = candidates[idealRole]
		var/count = L.len
		//This job's filled up, OR they've picked the overflow role, which means they don't really care
		if(count >= idealRole.max_count || idealRole.max_count == INFINITY)
			autofill_victims += nextCrewman
			continue
		candidates[idealRole] += nextCrewman
	var/datum/syndicate_crew_role/overflow = GLOB.conquest_role_handler.get_job(overflow_role)
	for(var/datum/syndicate_crew_role/role in GLOB.conquest_role_handler.roles)
		for(var/datum/mind/candidate in candidates[role])
			role.assign(candidate)
	//And now dish out roles to those unlucky enough to not get their preference.
	for(var/datum/mind/autofill in autofill_victims)
		//Find the next un-filled job in order of priority.
		var/foundJob = FALSE
		for(var/datum/syndicate_crew_role/nextRole in GLOB.conquest_role_handler.roles)
			var/count = candidates[nextRole].len
			if(count >= nextRole.max_count || !nextRole.essential)
				continue
			//Cool, we've found a target!
			to_chat(autofill, "<span class='warning'>You have been autofilled into [nextRole]! If you're not comfortable playing this role due to inexperience, please ahelp!")
			nextRole.assign(autofill)
			foundJob = TRUE
			break
		if(foundJob) //They got autofilled higher up the tree.
			continue
		//Fallback: Add them to the overflow role.
		autofill.add_antag_datum(overflow)

/datum/game_mode/pvp/pre_setup()
	var/pop = num_players()
	var/map_file = pop < highpop_threshold ? pick(standard_ships) : pick(highpop_ships) //Scale the ship map to suit player pop. Larger crews need more space.
	var/ship_type = pop < highpop_threshold ? /obj/structure/overmap/syndicate/pvp : /obj/structure/overmap/syndicate/pvp/hulk
	var/obj/structure/overmap/syndiship
	if(!map_file) //Don't ask me why this would happen.
		map_file = "Hammurabi.dmm"
		ship_type = /obj/structure/overmap/syndicate/pvp

	syndiship = instance_overmap(_path=ship_type, folder= "map_files/PVP" ,interior_map_files = map_file)
	var/n_agents = antag_candidates.len
	if(n_agents > 0)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/overmap_lighting_force, syndiship), 6 SECONDS)
		var/enemies_to_spawn = max(1, required_enemies + round((num_players()-required_enemies)/10)) //Syndicates scale with pop. On a standard 30 pop, this'll be 30 - 10 -> 20 / 10 -> 2 floored = 2, where FLOOR rounds the number to a whole number.
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
	for(var/area/AR in hammurabi.linked_areas) //Fucking force a lighting update IDEK why we have to do this but it just works
		AR.set_dynamic_lighting(DYNAMIC_LIGHTING_DISABLED)
		sleep(1)
		AR.set_dynamic_lighting(DYNAMIC_LIGHTING_ENABLED)

/datum/game_mode/pvp/post_setup()
	assign_jobs()
	SSstar_system.time_limit = world.time + time_limit //Hard timecap to prevent this dragging on or crashing.
	SSstar_system.nag_interval = 2 HOURS //No external pressure in this round...
	//And now, we make it so that NT sends fleets instead of the Syndicate...
	var/datum/faction/synd = SSstar_system.faction_by_id(FACTION_ID_SYNDICATE)
	var/datum/faction/nt = SSstar_system.faction_by_id(FACTION_ID_NT)
	nt.fleet_spawn_rate = synd.fleet_spawn_rate
	synd.fleet_spawn_rate = 2 HOURS
//	SSstar_system.add_blacklist(/obj/structure/overmap/syndicate/ai/carrier) //No. Just no. Please. God no.
//	SSstar_system.add_blacklist(/obj/structure/overmap/syndicate/ai/patrol_cruiser) //Syndies only get LIGHT reinforcements.
	return ..()

/datum/game_mode/pvp/OnNukeExplosion(off_station)
	..()
	nukes_left--

/datum/game_mode/pvp/check_win()
	if(winner)
		if(winner.id != FACTION_ID_NT)
			return TRUE
		else
			return FALSE
	if (nukes_left == 0)
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
		return TRUE
	return ..()

/datum/game_mode/pvp/set_round_result()
	..()
	var result = nuke_team?.get_result()
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
