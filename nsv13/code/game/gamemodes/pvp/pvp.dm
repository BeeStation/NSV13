/**

Shamelessly ripped off from nuclear.dm

*/

GLOBAL_LIST_EMPTY(syndi_crew_spawns)

GLOBAL_LIST_EMPTY(syndi_crew_leader_spawns)

/datum/game_mode/pvp
	name = "PVP"
	config_tag = "pvp"
	report_type = "nuclear"
	false_report_weight = 10
	required_players = 0 // 30 players initially, with 15 crewing the hammurabi and 15 crewing the larger, more powerful hammerhead
	required_enemies = 1
	recommended_enemies = 20
	antag_flag = ROLE_SYNDI_CREW
	enemy_minimum_age = 14

	announce_span = "danger"
	announce_text = "Nanotrasen's incursions into Syndicate space have not gone unnoticed!\n\
	<span class='danger'>Operatives</span>: Eliminate Nanotrasen's presence in Syndicate space using the weaponry of the SSV Hammurabi, or via a thermonuclear detonation.\n\
	<span class='notice'>Crew</span>: Survive the Syndicate assault long enough for reinforcements to arrive."

	title_icon = "nukeops"

	var/const/agents_possible = 15 //If we ever need more syndicate agents.
	var/list/pre_nukeops = list()

	var/nukes_left = 1

	var/datum/team/nuclear/nuke_team

	var/operative_antag_datum_type = /datum/antagonist/nukeop/syndi_crew
	var/leader_antag_datum_type = /datum/antagonist/nukeop/leader/syndi_crew
	var/time_limit
	var/list/syndi_ships = list('_maps/map_files/PVP/Hammurabi.dmm') //Update this list if you make more PVP ships :) ~Kmc


/**

Method to spawn in the Syndi ship on a brand new Z-level with the "boardable" trait active so we can fly to it.

*/
/datum/game_mode/pvp/proc/make_syndi_ship()
//	set waitfor = FALSE
	message_admins("Spawning in syndi ship map, this may take a while. No the game hasn't crashed, I'm just loading a map before we start.") //Warn the admins. This shit takes a while.
	var/map_file = pick(syndi_ships)
	var/datum/map_template/template = new(map_file, "Syndicate space vessel")
	template.load_new_z()

	var/x = round((world.maxx - 255)/2)
	var/y = round((world.maxy - 255)/2)

	var/datum/space_level/level = SSmapping.add_new_zlevel(name, list(ZTRAIT_AWAY = TRUE, ZTRAIT_BOARDABLE = TRUE, ZTRAIT_STATION = FALSE))
	var/datum/parsed_map/parsed = load_map(file(map_file), x, y, level?.z_value, no_changeturf=(SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop=TRUE)
	var/list/bounds = parsed.bounds
	if(!bounds)
		return FALSE

	repopulate_sorted_areas()

	//initialize things that are normally initialized after map load
	parsed.initTemplateBounds()
	smooth_zlevel(world.maxz)
	log_game("Syndicate space ship loaded at [x],[y],[world.maxz]")
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_CORVI))
		new /obj/structure/overmap/syndicate/hammurabi(get_turf(locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), z))) //Make a new syndie ship object in Corvi.
	return level

/datum/game_mode/pvp/pre_setup()
	make_syndi_ship() //Spawn our syndie vessel. GOT THIS FAR LASTNIGHT
	var/n_agents = num_players() > 1 ? min(round(num_players() / 10), antag_candidates.len, agents_possible) : 1
	to_chat(world, n_agents)
	if(n_agents >= required_enemies)
		for(var/i = 0, i < n_agents, i++)
			var/datum/mind/new_op = pick_n_take(antag_candidates)
			pre_nukeops += new_op
			new_op.assigned_role = "Syndicate crewmember"
			new_op.special_role = "Syndicate crewmember"
			log_game("[key_name(new_op)] has been selected as a syndicate crewmember")
		return TRUE
	else
		setup_error = "Not enough nuke op candidates"
		return FALSE
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/pvp/post_setup()
	//Assign leader
	var/datum/mind/leader_mind = pre_nukeops[1]
	var/datum/antagonist/nukeop/L = leader_mind.add_antag_datum(leader_antag_datum_type)
	nuke_team = L.nuke_team
	//Assign the remaining operatives
	for(var/datum/mind/nuke_mind in pre_nukeops.len)
		nuke_mind?.add_antag_datum(operative_antag_datum_type)
	time_limit = world.time + 45 MINUTES //Puts a hard cap on the time limit to avoid boredom.
	addtimer(CALLBACK(src, .proc/check_win), 45.5 MINUTES)
	SSstarsystem.add_blacklist(/obj/structure/overmap/syndicate/ai/carrier) //No. Just no. Please. God no.
	SSstarsystem.add_blacklist(/obj/structure/overmap/syndicate/ai/patrol_cruiser) //Syndies only get LIGHT reinforcements.
	return ..()

/datum/game_mode/pvp/OnNukeExplosion(off_station)
	..()
	nukes_left--

/datum/game_mode/pvp/check_win()
	if (nukes_left == 0)
		return TRUE
	if(world.time >= time_limit)
		return FALSE
	return ..()

/datum/game_mode/pvp/check_finished()
	//Keep the round going if ops are dead but bomb is ticking.
	if(nuke_team.operatives_dead())
		for(var/obj/machinery/nuclearbomb/N in GLOB.nuke_list)
			if(N.proper_bomb && (N.timing || N.exploding))
				return FALSE
	return ..()

/datum/game_mode/pvp/set_round_result()
	..()
	var result = nuke_team.get_result()
	if(result == NUKE_RESULT_NUKE_WIN)
		SSticker.mode_result = "win - syndicate nuke"
		SSticker.news_report = STATION_NUKED
	else
		SSticker.mode_result = "loss - Nanotrasen reinforcements arrived "
		SSticker.news_report = OPERATIVE_SKIRMISH

/datum/game_mode/pvp/generate_report()
	priority_announce("[station_name()]. Our incursion into Syndicate space has not gone unnoticed. Your orders are to establish a foothold and survive until the NSV Agatha King, Solaris and Typhoon can reach you. All other orders are secondary to this. We estimate they'll take around 45 minutes to get to you. Good luck, and be on your toes.")
	return "Long range DRADIS uplinks show a massive Syndicate force is en-route to your location. Hold out until we can send reinforcements to you."

/datum/game_mode/pvp/generate_credit_text()
	var/list/round_credits = list()

	round_credits += "<center><h1>The syndicate crew:</h1>"
	for(var/datum/mind/operative in nuke_team.members)
		round_credits += "<center><h2>[operative.name] as a Syndicate crewmember</h2>"

	round_credits += ..()
	return round_credits

/datum/antagonist/nukeop/syndi_crew
	name = "Syndicate crew"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals
	job_rank = ROLE_SYNDI_CREW

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