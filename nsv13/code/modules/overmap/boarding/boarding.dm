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
	to_chat(owner, "<B>Debug message, replace with text later</B>")
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
	var/datum/objective/plunder/P = new()
	P.team = src
	for(var/obj/structure/overmap/fighter/utility/boarding/BU in GLOB.overmap_objects)
		for(var/obj/item/fighter_component/primary/utility/hold/tier3/CH in BU)
			P.cargo_hold = CH
	objectives += P
	for(var/datum/mind/M in members)
		var/datum/antagonist/pirate/boarder/B = M.has_antag_datum(/datum/antagonist/pirate/boarder)
		if(B)
			B.objectives |= objectives

/datum/objective/plunder
	var/obj/item/fighter_component/primary/utility/hold/tier3/cargo_hold
	explanation_text = "Loot the [station_name()] and store it in your Sabre's cargohold."
	var/target_value = 50000



/*
	var/datum/objective/loot/getbooty = new()
	getbooty.team = src
	for(var/obj/machinery/computer/piratepad_control/P in GLOB.machines)
		var/area/A = get_area(P)
		if(istype(A,/area/shuttle/pirate))
			getbooty.cargo_hold = P
			break
	getbooty.update_explanation_text()
	objectives += getbooty
	for(var/datum/mind/M in members)
		var/datum/antagonist/pirate/P = M.has_antag_datum(/datum/antagonist/pirate)
		if(P)
			P.objectives |= objectives
*/
/*
/datum/objective/loot
	var/obj/machinery/computer/piratepad_control/cargo_hold
	explanation_text = "Acquire valuable loot and store it in designated area."
	var/target_value = 50000


/datum/objective/loot/update_explanation_text()
	if(cargo_hold)
		var/area/storage_area = get_area(cargo_hold)
		explanation_text = "Acquire loot and store [target_value] of credits worth in [storage_area.name] cargo hold."

/datum/objective/loot/proc/loot_listing()
	//Lists notable loot.
	if(!cargo_hold || !cargo_hold.total_report)
		return "Nothing"
	cargo_hold.total_report.total_value = sortTim(cargo_hold.total_report.total_value, cmp = /proc/cmp_numeric_dsc, associative = TRUE)
	var/count = 0
	var/list/loot_texts = list()
	for(var/datum/export/E in cargo_hold.total_report.total_value)
		if(++count > 5)
			break
		loot_texts += E.total_printout(cargo_hold.total_report,notes = FALSE)
	return loot_texts.Join(", ")

/datum/objective/loot/proc/get_loot_value()
	return cargo_hold ? cargo_hold.points : 0

/datum/objective/loot/check_completion()
	return ..() || get_loot_value() >= target_value
*/

/obj/structure/overmap/fighter/utility/boarding
	components = list(/obj/item/fighter_component/fuel_tank/tier2,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/primary/utility/hold/tier3,
						/obj/item/fighter_component/countermeasure_dispenser)
	req_one_access = ACCESS_SYNDICATE

//MASSIVE TODO: Rewrite all of this shit.

/obj/structure/overmap/fighter/utility/boarding/Initialize(mapload, operatives, teamName, factionSelection)
	. = ..()
	name = (teamName) ? "[teamName] squad boarding craft" : name
	faction = factionSelection
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
	foo()

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

/obj/structure/overmap/proc/spawn_boarders(amount, faction_selection)
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
	if(SSstar_system.admin_boarding_override)
		message_admins("Failed to spawn boarders for [name] due to admin boarding override.")
		return FALSE //Allows the admins to disable boarders for event rounds
	var/player_check = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	if(player_check < 0) // Remove the low pop boarder camping
		message_admins("Failed to spawn boarders for [name] due to insufficient player count.")
		return FALSE
	if(faction_selection == "syndicate")
		var/turf/target = boardingPodStartLoc(startside, pick(zs))
		if(!target)
			message_admins("Failed to spawn boarders for [name], does it have an interior?")
			return FALSE //Cut off here to avoid polling people for a spawn that will never work.
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
			log_game("[key_name(H)] became a syndicate drop trooper.")
			message_admins("[ADMIN_LOOKUPFLW(H)] became a syndicate drop trooper.")
			to_chat(H, "<span class='danger'>You are a syndicate drop trooper! Cripple [station_name()] to the best of your ability, by any means you see fit. You have been given some objectives to guide you in the pursuit of this goal.")
			operatives += H
		relay('nsv13/sound/effects/ship/boarding_pod.ogg', "<span class='userdanger'>You can hear several tethers attaching to the ship.</span>")

	else if(faction_selection == "pirate")
		var/turf/target = get_turf(pick(docking_points))
		if(!target)
			message_admins("Failed to spawn boarders for [name], does it have an interior?")
			return FALSE //Cut off here to avoid polling people for a spawn that will never work
		var/list/candidates = pollCandidatesForMob("Do you want to play as a Space Pirate boarding crewmember?", ROLE_OPERATIVE, null, ROLE_OPERATIVE, 10 SECONDS, src)
		if(!LAZYLEN(candidates))
			return FALSE
		var/list/operatives = list()
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
			log_game("[key_name(H)] became a space pirate boarder.")
			message_admins("[ADMIN_LOOKUPFLW(H)] became a space pirate boarder.")
			operatives += H
		var/ship_name = strings(PIRATE_NAMES_FILE, "ship_names")
		var/obj/structure/overmap/fighter/utility/boarding/B = new /obj/structure/overmap/fighter/utility/boarding(target, operatives, "[pick(ship_name)]", faction_selection) //No audio warning, watch that dradis
	return TRUE
