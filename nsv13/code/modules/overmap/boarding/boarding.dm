GLOBAL_LIST_INIT(drop_trooper_teams, list("Noble", "Helljumper","Red", "Black", "Crimson", "Osiris", "Apex", "Apollo", "Thrace", "Galactica", "Valkyrie", "Recon", "Gamma", "Alpha", "Bravo", "Charlie", "Delta", "Indigo", "Sol's fist", "Abassi", "Cartesia", "Switchback", "Majestic", "Mountain", "Shadow", "Shrike", "Sterling", "FTL", "Belter", "Moya", "Crichton"))

/datum/map_template/syndicate_boarding_pod
	name = "Syndicate Boarding Pod"
	mappath = "_maps/templates/boarding_pod.dmm"

/area/nsv/boarding_pod
	name = "Syndicate Boarding Pod"
	icon_state = "syndie-ship"
	requires_power = FALSE

/datum/map_template/spacepirate_boarding_pod
	name = "Space Pirate Boarding Pod"
	mappath = "_maps/templates/pirate_pod.dmm"

/datum/antagonist/traitor/boarder //TODO: Refactor this to not a traitor extension
	name = "Boarder" //Not the school kind :b1:
	antagpanel_category = "Boarder"
	roundend_category = "boarders"
	should_equip = FALSE
	tips = 'html/antagtips/boarder.html'
	show_to_ghosts = TRUE

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

/datum/antagonist/pirate/boarder
	name = "Space Pirate"
	var/datum/team/pirate/boarder/boarding_crew

/datum/team/pirate/boarder
	name = "Space Pirate Boarding Crew"

/datum/antagonist/pirate/boarder/greet()
	to_chat(owner, "<span class='boldannounce'>You are a Space Pirate!</span>")
	to_chat(owner, "<B>You've managed to dock within proximity of a Nanotrasen war vessel. You're outnumbered, outgunned, and under prepared in every conceivable way, but if you can manage to successfully pull off a heist on this vessel, it'd be enough to put your pirate crew on the map.</B>")
	owner.announce_objectives()

/datum/antagonist/pirate/boarder/get_team()
	return boarding_crew

/datum/antagonist/pirate/boarder/on_gain()
	if(boarding_crew)
		objectives |= boarding_crew.objectives
	. = ..()

/datum/antagonist/pirate/boarder/create_team(datum/team/pirate/boarder/new_team)
	if(!new_team)
		for(var/datum/antagonist/pirate/boarder/P in GLOB.antagonists)
			if(!P.owner)
				continue
			if(P.boarding_crew)
				boarding_crew = P.boarding_crew
				return
		if(!new_team)
			boarding_crew = new /datum/team/pirate/boarder
			boarding_crew.forge_objectives()
			return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	boarding_crew = new_team

/datum/team/pirate/boarder/forge_objectives()
	var/datum/objective/loot/plunder/P = new()
	P.team = src
	for(var/obj/machinery/computer/piratepad_control/PPC in GLOB.machines)
		var/area/A = get_area(PPC)
		if(istype(A,/area/shuttle/pirate))
			P.cargo_hold = PPC
			break
	objectives += P
	for(var/datum/mind/M in members)
		var/datum/antagonist/pirate/boarder/B = M.has_antag_datum(/datum/antagonist/pirate/boarder)
		if(B)
			B.objectives |= objectives

/datum/objective/loot/plunder
	explanation_text = "Loot and pillage the ship, transport 50000 credits worth of loot." //replace me

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

/obj/structure/overmap/proc/spawn_boarders(amount, faction_selection="syndicate")
	if(!occupying_levels?.len)
		return FALSE
	var/player_check = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	if(!amount)
		//Joker emoji
		amount = round(rand(0,(player_check/5)))
		if(amount <= 0)
			amount = 2 //This is jank, but helps me test it locally...
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
	var/list/candidates = list()
	if(player_check < 15)
		message_admins("KNPC boarder spawning aborted due to insufficient playercounts.")
		return FALSE //No... just no. I'm not that mean

	//20 or more players? You're allowed "real" boarders.
	if(player_check >= 20) // Remove the low pop boarder camping
		candidates = pollCandidatesForMob("Do you want to play as a boarding team member?", ROLE_OPERATIVE, null, ROLE_OPERATIVE, 10 SECONDS, src)
	//No candidates? Well! Guess you get to deal with some KNPCs :))))))
	if(!LAZYLEN(candidates))
		var/list/knpc_types = list()
		switch(faction_selection)
			if("syndicate")
				knpc_types = list(/mob/living/carbon/human/ai_boarder, /mob/living/carbon/human/ai_boarder/commando, /mob/living/carbon/human/ai_boarder/medic)
			if("pirate")
				knpc_types = list(/mob/living/carbon/human/ai_boarder/pirate, /mob/living/carbon/human/ai_boarder/pirate/leader, /mob/living/carbon/human/ai_boarder/pirate/sapper)
			if("greytide")
				knpc_types = list(/mob/living/carbon/human/ai_boarder/assistant)
			if("nanotrasen")
				knpc_types = list(/mob/living/carbon/human/ai_boarder/ert, /mob/living/carbon/human/ai_boarder/ert/commander, /mob/living/carbon/human/ai_boarder/medic, /mob/living/carbon/human/ai_boarder/ert/engineer)

		var/list/possible_spawns = list()
		for(var/obj/effect/landmark/patrol_node/node in GLOB.landmarks_list)
			if(node.get_overmap() == src)
				possible_spawns += node
		//Can we establish a drop zone?
		var/turf/LZ = (possible_spawns?.len) ? get_turf(pick(possible_spawns)) : null
		if(!LZ)
			message_admins("KNPC boarder spawn aborted. This ship does not support KNPCs (add some patrol nodes!))")
			return FALSE

		var/obj/structure/closet/supplypod/centcompod/toLaunch = new /obj/structure/closet/supplypod/syndicate_odst
		var/shippingLane = GLOB.areas_by_type[/area/centcom/supplypod/supplypod_temp_holding]
		toLaunch.forceMove(shippingLane)
		for(var/I = 0; I < amount; I++)
			var/soldier_type = pick(knpc_types)
			new soldier_type(toLaunch)

		new /obj/effect/pod_landingzone(LZ, toLaunch)
		return TRUE
	var/list/operatives = list()
	if(faction_selection == "syndicate")
		var/team_name = pick_n_take(GLOB.drop_trooper_teams)
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
				H.equipOutfit(/datum/outfit/pirate/space/boarding/lead) //review these
			else
				callsign = "Crew"
				var/list/pirate_kits = list(/datum/outfit/pirate/space/boarding/sapper, /datum/outfit/pirate/space/boarding/gunner) //review these
				var/kit = pick(pirate_kits)
				H.equipOutfit(kit)
			var/beggings = strings(PIRATE_NAMES_FILE, "beginnings")
			var/endings = strings(PIRATE_NAMES_FILE, "endings")
			H.fully_replace_character_name(H.real_name, "[callsign] [pick(beggings)][pick(endings)]")
			H.mind.add_antag_datum(/datum/antagonist/pirate/boarder)
			H.mind.assigned_role = "Pirate Boarder"
			log_game("[key_name(H)] became a space pirate boarder.")
			message_admins("[ADMIN_LOOKUPFLW(H)] became a space pirate boarder.")
			operatives += H
		 //No audio warning?
	return TRUE
