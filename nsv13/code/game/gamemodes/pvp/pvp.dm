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
	antag_flag = ROLE_SYNDI_CREW
	enemy_minimum_age = 0

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
	var/shipside_antag_datum_type = /datum/antagonist/nukeop/syndi_crew/shipside
	var/pilot_antag_datum_type = /datum/antagonist/nukeop/syndi_crew/pilot
	var/list/standard_ships = list("Hammurabi.dmm") //Update this list if you make more PVP ships :) ~Kmc
	var/list/highpop_ships = list("Hulk.dmm") //Update this list if you make a big PVP ship
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
		RegisterSignal(syndiship, COMSIG_PARENT_QDELETING, .proc/force_loss)
		RegisterSignal(SSstar_system.find_main_overmap(), COMSIG_PARENT_QDELETING, .proc/force_win)
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

//Overridable method which spawns in the ship we want to use.
/datum/game_mode/pvp/proc/generate_ship(ship_type, map_file)
	return instance_overmap(_path=ship_type, folder= "map_files/PVP" ,interior_map_files = map_file)

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
/proc/overmap_lighting_force(obj/structure/overmap/hammurabi)
	set waitfor = FALSE
	for(var/area/AR in hammurabi.linked_areas) //Force lighting to update. Not pretty, but it works
		AR.set_dynamic_lighting(DYNAMIC_LIGHTING_FORCED)
/datum/game_mode/pvp/proc/force_lighting(obj/structure/overmap/hammurabi)
	for(var/area/AR in hammurabi.linked_areas) //Fucking force a lighting update IDEK why we have to do this but it just works
		if(AR.dynamic_lighting)
			AR.set_dynamic_lighting(DYNAMIC_LIGHTING_DISABLED)
			sleep(1)
			AR.set_dynamic_lighting(DYNAMIC_LIGHTING_ENABLED)

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

/**

Method to assign a job, in order of descending priority. We REALLY need people to at least fly the ship and maintain it, then pilots, then standard marines.

*/

/datum/game_mode/pvp/proc/get_job_for(datum/mind/M)
	var/list/pilots = jobs["pilots"]
	var/list/shipsides = jobs["shipside"]
	var/list/marines = jobs["marines"]
	if(shipsides.len < 2)
		LAZYADD(shipsides, M)
		return shipside_antag_datum_type
	if(pilots.len < 3)
		LAZYADD(pilots, M)
		return pilot_antag_datum_type
	LAZYADD(marines, M) //If nothing else, make them a marine.
	return operative_antag_datum_type

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
	if(result == NUKE_RESULT_FLUKE)
		SSticker.mode_result = "loss - syndicate base nuked"
		SSticker.news_report = OPERATIVE_SKIRMISH
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

/datum/antagonist/nukeop/syndi_crew
	name = "Syndicate crew"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/syndi_crew
	job_rank = ROLE_SYNDI_CREW

/datum/outfit/syndicate/no_crystals/syndi_crew
	name = "Syndicate marine"
	head = /obj/item/clothing/head/HoS/beret/syndicate
	suit = /obj/item/clothing/suit/ship/syndicate_crew
	uniform = /obj/item/clothing/under/ship/pilot/syndicate

/datum/antagonist/nukeop/syndi_crew/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ops.ogg',100,0)
	to_chat(owner, "<span class='notice'>You are a crewman aboard a Syndicate vessel!</span>")
	to_chat(owner, "<span class='warning'>Ensure the destruction of [station_name()], no matter what. Eliminate Nanotrasen's presence in the Abassi ridge before they can establish a foothold. The fleet is counting on you!</span>")
	owner.announce_objectives()

/datum/antagonist/nukeop/leader/syndi_crew
	name = "Syndicate captain"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/leader

/datum/antagonist/nukeop/leader/syndi_crew/give_alias()
	title = pick("Captain", "Commander", "Admiral")
	if(nuke_team && nuke_team.syndicate_name)
		owner.current.real_name = "[nuke_team.syndicate_name] [title]"
	else
		owner.current.real_name = "Syndicate [title]"

/datum/outfit/syndicate/no_crystals
	implants = list()

/datum/outfit/syndicate/no_crystals/shipside
	name = "Syndicate engineer"
	head = /obj/item/clothing/head/HoS/beret/syndicate
	glasses = /obj/item/clothing/glasses/meson/engine
	gloves = /obj/item/clothing/gloves/combat
	belt = /obj/item/storage/belt/utility/full/engi
	uniform = /obj/item/clothing/under/ship/syndicate_tech

/datum/antagonist/nukeop/syndi_crew/shipside
	name = "Syndicate crew (shipside)"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/shipside
	job_rank = ROLE_SYNDI_CREW

/datum/antagonist/nukeop/syndi_crew/shipside/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ops.ogg',100,0)
	to_chat(owner, "<span class='notice'>You are an engineer aboard a Syndicate vessel!</span>")
	to_chat(owner, "<span class='warning'>You are responsible for shipside duties such as flying the ship, handling the ship's fighters, and maintaining the stormdrive / superstructure. You should not deviate from this job unless you find someone who's willing to trade with you!</span>")
	owner.announce_objectives()

/datum/outfit/syndicate/no_crystals/pilot
	name = "Syndicate fighter pilot"
	head = /obj/item/clothing/head/beret/ship/pilot
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	suit = /obj/item/clothing/suit/jacket //Bomber jacket

/datum/antagonist/nukeop/syndi_crew/pilot
	name = "Syndicate crew (fighter pilot)"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/pilot
	job_rank = ROLE_SYNDI_CREW

/datum/antagonist/nukeop/syndi_crew/pilot/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ops.ogg',100,0)
	to_chat(owner, "<span class='notice'>You are a Syndicate fighter pilot!</span>")
	to_chat(owner, "<span class='warning'>You are responsible for flying the ship's boarding craft and fighters, coordinate with the marines to find out which of these two are needed. You should not deviate from this job unless you find someone who's willing to trade with you!</span>")
	owner.announce_objectives()

/datum/outfit/syndicate/no_crystals/leader
	name = "Syndicate captain"
	id = /obj/item/card/id/syndicate/nuke_leader
	gloves = /obj/item/clothing/gloves/krav_maga/combatglovesplus
	r_hand = /obj/item/nuclear_challenge
	head = /obj/item/clothing/head/beret/durathread
	suit = /obj/item/clothing/suit/space/officer
	backpack_contents = list(/obj/item/storage/box/syndie=1,\
	/obj/item/kitchen/knife/combat/survival=1,\
	/obj/item/pvp_nuke_spawner)
	command_radio = TRUE
	implants = list()

/datum/antagonist/nukeop/leader/syndi_crew/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ops.ogg',100,0)
	to_chat(owner, "<span class='notice'>You are a [title] in the Syndicate navy commanding a Syndicate warship! You have total authority over your team members, and may tackle your objectives as you see fit.</span>")
	to_chat(owner, "<span class='notice'>The Syndicate will periodically send light reinforcements to nearby systems. Use them to your advantage.</span>")
	to_chat(owner, "<span class='notice'>You have numerous options at your disposal. You can attempt to weaken [station_name()] in open combat ahead of boarding it, or remain silent and await a chance to stealthily board it.</span>")
	to_chat(owner, "<span class='notice'>You have a number of raptors at your disposal, these are how your team can board the enemy, as each Raptor can hold up to 8 people..</span>")
	to_chat(owner, "<span class='notice'><b>Your destination will be announced when performing FTL jumps due to DRADIS tracking. Be very aware of this when considering an engagement, as NT will be warned.</b></span>")
	to_chat(owner, "<span class='notice'><b>You have been given a device to summon a nuke to your location. Use this to destroy the enemy.</b></span>")
	to_chat(owner, "<span class='warning'>Ensure the destruction of [station_name()], no matter what. Eliminate Nanotrasen's presence in the Abassi ridge before they can establish a foothold. The fleet is counting on you!</span>")
	addtimer(CALLBACK(src, .proc/nuketeam_name_assign), 1)
	owner.announce_objectives()

/obj/item/pvp_nuke_spawner
	name = "Nuclear summon device"
	desc = "A small device that will summon the Hammurabi's nuclear warhead to your location. Click it in your hand to use it."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-green"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	req_one_access_txt = "150"

/obj/item/pvp_nuke_spawner/attack_self(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(!is_station_level(user.z))
		to_chat(user, "<span class='notice'>A message crackles in your ear: Operative. You have not yet reached [station_name()], ensure you are on the enemy ship before you attempt to summon a nuke.</span>")
		return
	if(alert("Are you sure you want to summon a nuke to your location?",name,"Yes","No") == "Yes")
		to_chat(user, "<span class='notice'>You press a button on [src] and a nuke appears.</span>")
		var/obj/machinery/nuclearbomb/syndicate/nuke = locate() in GLOB.nuke_list
		nuke.visible_message("<span class='warning'>[src] fizzles out of existence!</span>")
		nuke?.forceMove(get_turf(user))
		do_sparks(1, TRUE, src)
		qdel(src)

/datum/antagonist/nukeop/syndi_crew/move_to_spawnpoint()
	owner.current.forceMove(pick(GLOB.syndi_crew_spawns))

/datum/antagonist/nukeop/leader/syndi_crew/move_to_spawnpoint()
	owner.current.forceMove(pick(GLOB.syndi_crew_leader_spawns))

/obj/effect/landmark/start/nukeop/syndi_crew
	name = "Syndicate crew"

/obj/effect/landmark/start/nukeop/syndi_crew/Initialize()
	..()
	GLOB.syndi_crew_spawns += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/nukeop/syndi_crew_leader
	name = "Syndicate captain"

/obj/effect/landmark/start/nukeop/syndi_crew_leader/Initialize()
	..()
	GLOB.syndi_crew_leader_spawns += loc
	return INITIALIZE_HINT_QDEL