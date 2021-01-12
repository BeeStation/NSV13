GLOBAL_LIST_INIT(drop_trooper_teams, list("Noble", "Helljumper","Red", "Black", "Crimson", "Osiris", "Apex", "Apollo", "Thrace", "Galactica", "Valkyrie", "Recon", "Gamma", "Alpha", "Bravo", "Charlie", "Delta", "Indigo", "Sol's fist", "Abassi", "Cartesia", "Switchback", "Majestic", "Mountain", "Shadow", "Shrike", "Sterling", "FTL", "Belter", "Moya", "Crichton"))

/datum/map_template/pvp_pod
	name = "Syndicate Boarding Pod"
	mappath = "_maps/templates/boarding_pod.dmm"

/area/nsv/boarding_pod
	name = "Syndicate Boarding Pod"
	icon_state = "syndie-ship"
	requires_power = FALSE

/datum/antagonist/traitor/boarder
	name = "Boarder" //Not the school kind :b1:
	antagpanel_category = "Boarder"
	roundend_category = "boarders"
	should_equip = FALSE
	tips = 'html/antagtips/boarder.html'

/datum/antagonist/traitor/boarder/forge_human_objectives()
	var/martyr_chance = prob(20)
	if (!(locate(/datum/objective/hijack) in objectives))
		var/datum/objective/hijack/hijack_objective = new
		hijack_objective.owner = owner
		add_objective(hijack_objective)
		return

	var/martyr_compatibility = TRUE //You can't succeed in stealing if you're dead.
	for(var/datum/objective/O in objectives)
		if(!O.martyr_compatible)
			martyr_compatibility = 0
			break

	if(martyr_compatibility && martyr_chance)
		var/datum/objective/martyr/martyr_objective = new
		martyr_objective.owner = owner
		add_objective(martyr_objective)
		return

//God I love abusing OOP. This is disgusting.

/obj/structure/overmap/fighter/utility/prebuilt/carrier/syndicate/boarding

//MASSIVE TODO: Rewrite all of this shit.

/obj/structure/overmap/fighter/utility/prebuilt/carrier/syndicate/boarding/Initialize(mapload, operatives, teamName)
	. = ..()
	name = (teamName) ? "[teamName] squad boarding craft" : name
	//flight_state = 6
	toggle_canopy()
	var/found_pilot = FALSE
	for(var/mob/living/carbon/user in operatives)
		user.forceMove(src)
		if(user.client && !user.client.is_afk() && !pilot) //No AFK pilots for the love of GOD
			start_piloting(user, "all_positions")
			found_pilot = TRUE //This should't ever be false. If it is, all the operatives are AFK and we'll fix the situation ourselves.
		else
			start_piloting(user, "observer")
		mobs_in_ship += user
		if(user?.client?.prefs.toggles & SOUND_AMBIENCE) //Disable ambient sounds to shut up the noises.
			SEND_SOUND(user, sound('nsv13/sound/effects/fighters/cockpit.ogg', repeat = TRUE, wait = 0, volume = 100, channel=CHANNEL_SHIP_ALERT))
		return TRUE
	if(!found_pilot)
		message_admins("WARNING: Boarders spawned in a boarding ship, but were all AFK. One will be randomly assigned as pilot despite this.")
		var/mob/living/victim = pick(operatives)
		start_piloting(victim, "all_positions")

///Finds a "safe" place to dump a boarding pod, with a bit of distance from the transition edge to avoid visual hiccups.
/proc/boardingPodStartLoc(startSide, Z)
	var/starty
	var/startx
	switch(startSide)
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
	. = locate(startx, starty, Z)

/obj/structure/overmap/proc/spawn_boarders(amount)
	if(!linked_areas.len)
		return FALSE
	if(!amount)
		amount = rand(2,4)
	var/list/zs = list()
	if(!occupying_levels.len)
		message_admins("Failed to spawn boarders for [name], it doesn't seem to have any occupying z-levels. (Interior)")
		return FALSE
	for(var/datum/space_level/SL in occupying_levels)
		zs += SL.z_value
	var/startside = pick(GLOB.cardinals)
	var/turf/target = boardingPodStartLoc(startside, pick(zs))
	if(!target)
		message_admins("Failed to spawn boarders for [name], does it have an interior?")
		return FALSE //Cut off here to avoid polling people for a spawn that will never work.
	if(SSstar_system.admin_boarding_override)
		message_admins("Failed to spawn boarders for [name] due to admin boarding override.")
		return FALSE //Allows the admins to disable boarders for event rounds
	var/player_check = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	if(player_check < 0) // Remove the low pop boarder camping
		message_admins("Failed to spawn boarders for [name] due to insufficient player count.")
		return FALSE
	var/list/candidates = pollCandidatesForMob("Do you want to play as a Syndicate drop trooper?", ROLE_OPERATIVE, null, ROLE_OPERATIVE, 10 SECONDS, src)
	if(!LAZYLEN(candidates))
		return FALSE
	var/list/operatives = list()
	var/team_name = pick_n_take(GLOB.drop_trooper_teams)
	var/datum/map_template/pvp_pod/currentPod = new /datum/map_template/pvp_pod()
	currentPod.load(target, TRUE)
	for(var/I = 0, I < amount, I++)
		if(!LAZYLEN(candidates))
			break
		var/mob/dead/observer/C = pick_n_take(candidates)
		var/mob/living/carbon/human/H = new(target)
		H.equipOutfit(/datum/outfit/syndicate/odst)
		H.key = C.key
		if(team_name) //If there is an available "team name", give them a callsign instead of a placeholder name
			var/callsign = I
			if(callsign <= 0)
				callsign = "Lead"
			else
				callsign = num2text(callsign)
			H.fully_replace_character_name(H.real_name, "[team_name]-[callsign]")
			H.mind.add_antag_datum(/datum/antagonist/traitor/boarder)
		log_game("[key_name(H)] became a syndicate drop trooper.")
		message_admins("[ADMIN_LOOKUPFLW(H)] became a syndicate drop trooper.")
		to_chat(H, "<span class='danger'>You are a syndicate drop trooper! Cripple [station_name()] to the best of your ability, by any means you see fit. You have been given some objectives to guide you in the pursuit of this goal.")
		operatives += H
	relay('nsv13/sound/effects/ship/boarding_pod.ogg', "<span class='userdanger'>You can hear several tethers attaching to the ship.</span>")
	return TRUE
