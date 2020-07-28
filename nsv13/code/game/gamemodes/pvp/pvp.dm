/**

Shamelessly ripped off from nuclear.dm

*/

GLOBAL_LIST_EMPTY(syndi_crew_spawns)

GLOBAL_LIST_EMPTY(syndi_crew_leader_spawns)

/datum/game_mode/pvp
	name = "PVP"
	config_tag = "pvp"
	report_type = "pvp"
	false_report_weight = 10
	required_players = 30 // 30 players initially, with 15 crewing the hammurabi and 15 crewing the larger, more powerful hammerhead
	required_enemies = 10
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

	var/operative_antag_datum_type = /datum/antagonist/nukeop/syndi_crew
	var/leader_antag_datum_type = /datum/antagonist/nukeop/leader/syndi_crew
	var/list/standard_ships = list("Hammurabi.dmm") //Update this list if you make more PVP ships :) ~Kmc
	var/list/highpop_ships = list("Hulk.dmm") //Update this list if you make a big PVP ship
	var/list/jobs = list()

/**

Method to spawn in the Syndi ship on a brand new Z-level with the "boardable" trait active so we can fly to it.

*/

/datum/game_mode/pvp/pre_setup()
	var/pop = num_players()
	var/enemies_to_spawn = required_enemies + round((pop-required_enemies)/10) //Syndicates scale with pop. On a standard 30 pop, this'll be 30 - 10 -> 20 / 10 -> 2 floored = 2, where FLOOR rounds the number to a whole number.
	var/map_file = pop < highpop_threshold ? pick(standard_ships) : pick(highpop_ships) //Scale the ship map to suit player pop. Larger crews need more space.
	var/ship_type = pop < highpop_threshold ? /obj/structure/overmap/syndicate/pvp : /obj/structure/overmap/syndicate/pvp/hulk
	var/obj/structure/overmap/syndiship
	if(!map_file) //Don't ask me why this would happen.
		map_file = "Hammurabi.dmm"
		ship_type = /obj/structure/overmap/syndicate/pvp

	syndiship = instance_overmap(_path=ship_type, folder= "map_files/PVP" ,interior_map_files = map_file)
	var/n_agents = antag_candidates.len
	if(n_agents >= enemies_to_spawn)
		jobs["pilots"] = list() //Dictionary to store who's doing what job.
		jobs["shipside"] = list()
		jobs["marines"] = list()
		for(var/i = 0, i < enemies_to_spawn, i++)
			var/datum/mind/new_op = pick_n_take(antag_candidates)
			pre_nukeops += new_op
			new_op.assigned_role = "Syndicate crewmember"
			new_op.special_role = "Syndicate crewmember"
			log_game("[key_name(new_op)] has been selected as a syndicate crewmember")
		addtimer(CALLBACK(GLOBAL_PROC, .proc/overmap_lighting_force, syndiship), 6 SECONDS)
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
	//Assign leader
	var/datum/mind/leader_mind = pre_nukeops[1]
	var/datum/antagonist/nukeop/L = leader_mind.add_antag_datum(leader_antag_datum_type)
	nuke_team = L.nuke_team
	//Assign the remaining operatives
	for(var/I in 1 to pre_nukeops.len)
		var/datum/mind/nuke_mind = pre_nukeops[I]
		var/datum/antagonist/selected = get_job_for(nuke_mind)
		nuke_mind?.add_antag_datum(selected)
	SSstar_system.add_blacklist(/obj/structure/overmap/syndicate/ai/carrier) //No. Just no. Please. God no.
	SSstar_system.add_blacklist(/obj/structure/overmap/syndicate/ai/patrol_cruiser) //Syndies only get LIGHT reinforcements.
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
		return /datum/antagonist/nukeop/syndi_crew/shipside
	if(pilots.len < 3)
		LAZYADD(pilots, M)
		return /datum/antagonist/nukeop/syndi_crew/pilot
	LAZYADD(marines, M) //If nothing else, make them a marine.
	return operative_antag_datum_type

/datum/game_mode/pvp/OnNukeExplosion(off_station)
	..()
	nukes_left--

/datum/game_mode/pvp/check_win()
	if (nukes_left == 0)
		return TRUE
	return ..()

/datum/game_mode/pvp/check_finished()
	//Keep the round going if ops are dead but bomb is ticking.
	if(nuke_team?.operatives_dead())
		for(var/obj/machinery/nuclearbomb/N in GLOB.nuke_list)
			if(N.proper_bomb && (N.timing || N.exploding))
				return FALSE
		return TRUE
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
	return "Deep space scanners are showing a heightened level of Syndicate activity in your AO. Be on high alert for Syndicate strike teams."

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
