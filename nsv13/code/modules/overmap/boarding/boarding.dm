#define DROP_TROOPER_TEAMS list("Noble", "Helljumper","Red", "Black", "Crimson", "Osiris", "Apex", "Apollo", "Thrace", "Galactica", "Valkyrie", "Recon", "Gamma", "Alpha", "Bravo", "Charlie", "Delta", "Indigo", "Sol's fist", "Abassi", "Cartesia", "Switchback", "Majestic", "Mountain", "Shadow", "Shrike", "Sterling", "FTL", "Belter", "Moya", "Crichton")

/** Attempts to spawn knpc or player boarders for this ship.
 * Arguments:
 * * amount: Number of boarders to spawn. Will be automatically choosen, based on SSovermap mode difficulty if argument not passed in.
 * * faction_selection: Faction the boarders belong to. Valid values are currently "syndicate", "pirate", "greytide", "nanotrasen"
 * * min_players: Number of active players below which boarders won't spawn.
 * * min_players_for_ghosts: Number of active players below which gosts won't be offered to become boarders.
 * Returns:
 * * TRUE when boarders were spawned, FALSE if aborted regularly, otherwise throws an exception
*/
/obj/structure/overmap/proc/spawn_boarders(amount, faction_selection="syndicate", min_players = 5, min_players_for_ghosts = 20)
	if(SSovermap_mode.override_ghost_boarders)
		message_admins("Failed to spawn boarders for [name] due to admin boarding override.")
		return FALSE //Allows the admins to disable boarders for event rounds
	var/player_check = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	if(player_check < min_players)
		message_admins("KNPC boarder spawning aborted due to insufficient playercounts.")
		return FALSE //No... just no. I'm not that mean
	if(!length(occupying_levels))
		message_admins("Failed to spawn boarders for [name], it doesn't seem to have any occupying z-levels. (Interior)")
		throw EXCEPTION("Failed to spawn boarders for [name], it doesn't seem to have any occupying z-levels. (Interior)")

	if(!amount)
		amount = CEILING(1 + (SSovermap_mode.mode.difficulty / 2), 1)
	var/list/zs = list()
	for(var/datum/space_level/SL in occupying_levels)
		zs += SL.z_value
	var/turf/target = choose_boarding_location(zs)
	if(!target)
		message_admins("Failed to spawn boarders for [name], does it have an interior?")
		return FALSE //Cut off here to avoid polling people for a spawn that will never work.
	var/list/candidates = list()

	//20 or more players? You're allowed "real" boarders.
	if(player_check >= min_players_for_ghosts) // Remove the low pop boarder camping
		candidates = pollCandidatesForMob("Do you want to play as a boarding team member?", ROLE_OPERATIVE, /datum/role_preference/midround_ghost/boarder, 10 SECONDS, src)
	//No candidates? Well! Guess you get to deal with some KNPCs :))))))
	if(!length(candidates))
		return spawn_knpcs(amount, faction_selection)
	return spawn_player_boarders(candidates, target, amount, faction_selection)


/**
 * Finds a "safe" turf to dump a player boarding pod,
   with a bit of distance from the transition edge to avoid visual hiccups.
 * Arguments:
 * * z_levels: decks of the ship
 * Returns:
 * * "safe" turf
 */
/obj/structure/overmap/proc/choose_boarding_location(z_levels)
	var/startside = pick(GLOB.cardinals)
	var/starty
	var/startx
	switch(startside)
		if(NORTH)
			starty = world.maxy-(TRANSITIONEDGE+10)
			startx = rand((TRANSITIONEDGE+10), world.maxx-(TRANSITIONEDGE+10))
		if(EAST)
			starty = rand((TRANSITIONEDGE+10),world.maxy-(TRANSITIONEDGE+10))
			startx = world.maxx-(TRANSITIONEDGE+10)
		if(SOUTH)
			starty = (TRANSITIONEDGE+10)
			startx = rand((TRANSITIONEDGE+10), world.maxx-(TRANSITIONEDGE+10))
		if(WEST)
			starty = rand((TRANSITIONEDGE+10), world.maxy-(TRANSITIONEDGE+10))
			startx = (TRANSITIONEDGE+10)
	return locate(startx, starty, pick(z_levels))


/** Attempts to spawn knpc boarders for this ship.
 * Arguments:
 * * amount: Number of boarders to spawn. Will be automatically choosen, based on SSovermap mode difficulty if !amount.
 * * faction_selection: String for the faction the boarders belong to. See [/obj/structure/overmap/proc/spawn_boarders] for valid values.
 */
/obj/structure/overmap/proc/spawn_knpcs(amount, faction_selection="syndicate")
	if(!amount)
		amount = CEILING(1 + (SSovermap_mode.mode.difficulty / 2), 1)
	var/list/knpc_types = list()
	switch(faction_selection)
		if("syndicate")
			knpc_types = list(/mob/living/carbon/human/ai_boarder/syndicate/pistol, /mob/living/carbon/human/ai_boarder/syndicate/smg, /mob/living/carbon/human/ai_boarder/syndicate/shotgun)
		if("pirate")
			knpc_types = list(/mob/living/carbon/human/ai_boarder/space_pirate/pistol, /mob/living/carbon/human/ai_boarder/space_pirate/auto_pistol)
		if("greytide")
			knpc_types = list(/mob/living/carbon/human/ai_boarder/assistant)
		if("nanotrasen")
			knpc_types = list(/mob/living/carbon/human/ai_boarder/ert, /mob/living/carbon/human/ai_boarder/ert/commander, /mob/living/carbon/human/ai_boarder/ert/medic, /mob/living/carbon/human/ai_boarder/ert/engineer)
		if("zombies")
			knpc_types = list(/mob/living/carbon/human/ai_boarder/zombie,)
		if("droid")
			knpc_types = list(/mob/living/carbon/human/ai_boarder/boarding_droid,)
		if("catgirl")
			knpc_types = list(/mob/living/carbon/human/species/felinid/npc, /mob/living/carbon/human/ai_boarder/assistant/felinid)
		else
			message_admins("KNPC spawn failed. No knpcs configured for faction name \"[faction_selection]\".")
			throw EXCEPTION("No knpcs configured for faction name \"[faction_selection]\"")

	var/list/possible_spawns = list()
	for(var/obj/effect/landmark/patrol_node/node in GLOB.landmarks_list)
		if(node.get_overmap() == src)
			possible_spawns += node
	//Can we establish a drop zone?
	var/turf/LZ = (length(possible_spawns)) ? get_turf(pick(possible_spawns)) : null
	if(!LZ)
		message_admins("KNPC boarder spawn aborted. This ship does not support KNPCs (add some patrol nodes!)")
		throw EXCEPTION("KNPC boarder spawn aborted. This ship does not support KNPCs (add some patrol nodes!)")

	switch(faction_selection)
		if("syndicate")
			relay('nsv13/sound/effects/ship/boarding_pod.ogg', "<span class='userdanger'>You can hear several tethers attaching to the ship.</span>")
		else //No other special cases exist but this is a switch anyways to support them in the future (pirates have no tell)

	var/obj/structure/closet/supplypod/syndicate_odst/toLaunch = new()
	var/shippingLane = GLOB.areas_by_type[/area/centcom/supplypod/supplypod_temp_holding]
	toLaunch.forceMove(shippingLane)
	for(var/I = 0; I < amount; I++)
		var/soldier_type = pick(knpc_types)
		new soldier_type(toLaunch)

	new /obj/effect/pod_landingzone(LZ, toLaunch)


/** Attempts to spawn player boarders for this ship.
 * Arguments:
 * * candidates: willing ghosts' mobs
 * * target: turf where the boarding pod will be spawned.
 * * amount: Number of boarders to spawn. Will be automatically choosen, based on SSovermap mode difficulty if !amount.
 * * faction_selection: String for the faction the boarders belong to. See [/obj/structure/overmap/proc/spawn_boarders] for valid values.
 */
/obj/structure/overmap/proc/spawn_player_boarders(candidates, target, amount, faction_selection="syndicate")
	if(!amount)
		amount = CEILING(1 + (SSovermap_mode.mode.difficulty / 2), 1)
	var/list/operatives = list()
	if(faction_selection == "syndicate")
		var/team_name = pick_n_take(DROP_TROOPER_TEAMS)
		var/datum/map_template/syndicate_boarding_pod/currentPod = new /datum/map_template/syndicate_boarding_pod()
		currentPod.load(target, TRUE)
		for(var/I = 0, I < amount, I++)
			if(!LAZYLEN(candidates))
				break
			var/mob/dead/observer/C = pick_n_take(candidates)
			var/mob/living/carbon/human/H = new(target)
			H.key = C.key
			if(team_name) //If there is an available "team name", give them a callsign instead of a placeholder name
				var/callsign = I
				if(callsign <= 0)
					callsign = "Lead"
					H.equipOutfit(/datum/outfit/syndicate/odst/smg)
				else
					callsign = num2text(callsign)
					var/list/syndi_kits = list(/datum/outfit/syndicate/odst/smg, /datum/outfit/syndicate/odst/shotgun, /datum/outfit/syndicate/odst/medic)
					var/kit = pick(syndi_kits)
					H.equipOutfit(kit)
				H.fully_replace_character_name(H.real_name, "[team_name]-[callsign]")
				H.mind.add_antag_datum(/datum/antagonist/traitor/boarder)
				H.mind.assigned_role = "Syndicate Boarder"
			log_game("[key_name(H)] became a syndicate drop trooper.")
			message_admins("[ADMIN_LOOKUPFLW(H)] became a syndicate drop trooper.")
			to_chat(H, "<span class='danger'>You are a syndicate drop trooper! Cripple [station_name()] to the best of your ability, by any means you see fit. You have been given some objectives to guide you in the pursuit of this goal.")
			operatives += H
		relay('nsv13/sound/effects/ship/boarding_pod.ogg', "<span class='userdanger'>You can hear several tethers attaching to the ship.</span>")

	else if(faction_selection == "pirate")
		var/datum/map_template/spacepirate_boarding_pod/currentPod = new /datum/map_template/spacepirate_boarding_pod()
		currentPod.load(target, TRUE)
		for(var/I = 0, I < amount, I++)
			if(!LAZYLEN(candidates))
				break
			var/mob/dead/observer/C = pick_n_take(candidates)
			var/mob/living/carbon/human/H = new(target)
			H.key = C.key
			var/callsign = I
			if(callsign <= 0)
				callsign = "First Mate"
				H.equipOutfit(/datum/outfit/pirate/space/boarding/lead)
			else
				callsign = "Crew"
				var/list/pirate_kits = list(/datum/outfit/pirate/space/boarding/sapper, /datum/outfit/pirate/space/boarding/gunner) //review these
				var/kit = pick(pirate_kits)
				H.equipOutfit(kit)
			var/beginnings = strings(PIRATE_NAMES_FILE, "beginnings")
			var/endings = strings(PIRATE_NAMES_FILE, "endings")
			H.fully_replace_character_name(H.real_name, "[callsign] [pick(beginnings)][pick(endings)]")
			H.mind.add_antag_datum(/datum/antagonist/pirate/boarder)
			H.mind.assigned_role = "Pirate Boarder"
			log_game("[key_name(H)] became a space pirate boarder.")
			message_admins("[ADMIN_LOOKUPFLW(H)] became a space pirate boarder.")
			operatives += H
		//Crew intentionally isn't informed of boarding pirates.



#undef DROP_TROOPER_TEAMS
