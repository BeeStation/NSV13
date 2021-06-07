/*SKYNET 2 AI by Kmc2000
"Because SKYNET 1 wasn't good enough."
This implements fleet movement for AIs through the use of very basic "utility score" AI programming.
How this works:
Instead of a traditional decision tree like we used back in SKYNET 1, Skynet 2 uses utility scoring, a technique similar to GOAP.
Instead of giving the AI a preset, flat list of decisions to make, the AI will now make decisions "on the fly" based on what task is most important to it at the time.
-This can vary! And can be anything you want. Maybe you're making a asteroid slinger ship, and you want to ensure that it has an asteroid to fling at someone BEFORE attacking an enemy ship. In this case, you'd just say that the "get asteroid" goal is more important to the AI than the "search and destroy" goal. (Though be sure to lock it to that specific ship via traits!)
This code uses singleton datums to give AI orders.
Workflow:
AIs like score, every few seconds, they'll run through all the subtypes of datum/ai_goal, which are stored in a global list. If it has a goal, and finds a higher priority task, it'll switch focus to whatever task we want it to.
Example:
Frame 1: Ai shoots ship, runs out of ammo
Frame 2: Ai ship's "search and destroy" goal is now a lower priority than its resupply goal, as it recognises that it's fresh out of ammo. It'll now go find a supply ship and get re-armed there.
Current task hierarchy (as of 10/02/2021)!
1: Repair and re-arm. If a ship becomes critically damaged, or runs out of bullets, it will rush to a supply ship to resupply (if available), and heal up.
2: (if you're a battleship): Defend the supply lines. Battleships stick close to the supply ships and keep them safe.
3: (Non-supply ships) Search and destroy: Attempt to find a target that's visible and within tracking range. - This is replaced with Swarm for fighters and bombers, which will somewhat cooperate while hunting down targets.
4: Patrol: Destroyers and Supply ships will slowly patrol the sector for hostile ships, with their escorts in tow. Supply ships run when they spot anything close, Destroyers engage.
5: (All ships) Defend the supply lines: If AIs cannot find a suitable target, they'll flock back to the main fleet and protect the tankers. More nimble attack squadrons will blade off in wings and attack the enemy if they get too close, with the battleships staying behind to protect their charges.
Adding tasks is easy! Just define a datum for it.
*/

#define AI_SCORE_MAXIMUM 1000 //No goal combination should ever exceed this.
#define AI_SCORE_SUPERCRITICAL 500
#define AI_SCORE_CRITICAL 100
#define AI_SCORE_SUPERPRIORITY 75
#define AI_SCORE_HIGH_PRIORITY 60
#define AI_SCORE_PRIORITY 50
#define AI_SCORE_DEFAULT 25
#define AI_SCORE_LOW_PRIORITY 15
#define AI_SCORE_VERY_LOW_PRIORITY 5 //Very low priority, acts as a failsafe to ensure that the AI always picks _something_ to do.

#define AI_PDC_RANGE 12

#define FLEET_DIFFICULTY_EASY 2 //if things end up being too hard, this is a safe number for a fight you _should_ always win.
#define FLEET_DIFFICULTY_MEDIUM 5
#define FLEET_DIFFICULTY_HARD 8
#define FLEET_DIFFICULTY_VERY_HARD 10
#define FLEET_DIFFICULTY_INSANE 15 //If you try to take on the rubicon ;)
#define FLEET_DIFFICULTY_WHAT_ARE_YOU_DOING 25
#define FLEET_DIFFICULTY_DEATH 30 //Suicide run

#define SCALE_FLEETS_WITH_POP TRUE //Change this to false if you want fleet size to be static. Fleets will be scaled down if the game detects underpopulation, however it can also scale them up to be more of a challenge.

#define AI_TRAIT_SUPPLY 1
#define AI_TRAIT_BATTLESHIP 2
#define AI_TRAIT_DESTROYER 3
#define AI_TRAIT_ANTI_FIGHTER 4
#define AI_TRAIT_BOARDER 5 //Ships that like to board you.
#define AI_TRAIT_SWARMER 6 //Ships that love to act in swarms. Aka, Fighters.

//Fleet behaviour. Border patrol fleets will stick to patrolling their home space only. Invasion fleets ignore home space and fly around. If the fleet has a goal system or is a interdictor, this gets mostly ignored, but stays as fallback.
#define FLEET_TRAIT_BORDER_PATROL 1
#define FLEET_TRAIT_INVASION 2
#define FLEET_TRAIT_NEUTRAL_ZONE 3
#define FLEET_TRAIT_DEFENSE 4

GLOBAL_LIST_EMPTY(ai_goals)

/datum/fleet
	var/name = "Syndicate Invasion Fleet"//Todo: randomize this name
	//Ai fleet type enum. Add your new one here. Use a define, or text if youre lazy.
	var/list/taskforces = list("fighters" = list(), "destroyers" = list(), "battleships" = list(), "supply" = list())
	var/list/fighter_types = list(/obj/structure/overmap/syndicate/ai/fighter, /obj/structure/overmap/syndicate/ai/bomber)
	var/list/destroyer_types = list(/obj/structure/overmap/syndicate/ai, /obj/structure/overmap/syndicate/ai/destroyer, /obj/structure/overmap/syndicate/ai/destroyer/flak, /obj/structure/overmap/syndicate/ai/cruiser, /obj/structure/overmap/syndicate/ai/mako_flak, /obj/structure/overmap/syndicate/ai/mako_carrier)
	var/list/battleship_types = list(/obj/structure/overmap/syndicate/ai/cruiser) //TODO: Implement above list for more ship variety.
	var/list/supply_types = list(/obj/structure/overmap/syndicate/ai/carrier)
	var/list/all_ships = list()
	var/list/lances = list()
	var/size = FLEET_DIFFICULTY_MEDIUM //How big is this fleet anyway?
	var/allow_difficulty_scaling = TRUE	//Set this to false if the fleet is supposed to have a constant difficulty as opposed to scaling with pop.
	var/list/audio_cues = list() //Does this fight come with a theme tune? Takes youtube / media links so that we don't have to store a bunch of copyrighted music on the box.
	var/instantiated = FALSE //If we're not instantiated, moving all the ships is a piece of cake, if we are however, we do some extra steps to FTL them all.
	var/datum/star_system/current_system = null //Where are we?
	var/datum/star_system/goal_system = null //Where are we looking to go?
	var/list/plotted_course = FALSE
	var/list/navigation_spec_alignments = list()	//If for some reason you have a fleet that is supposed to navigate smart, but also isn't allowed (or even only allowed) some alignment types, use this.
	var/navigation_spec_alignment_type = ALIGNMENT_BLACKLIST	//ALIGNMENT_BLACKLIST: Do not use systems with these alignments | ALIGNMENT_WHITELIST: Only use systems with these alignments.
	var/navigation_uses_wormholes = TRUE	//If for some reason you want a fleet type that can't use wormholes (in navigation!!, it'll still use them for random wandering), be my guest, and just set this to FALSE
	var/allow_hidden_systems = FALSE	//Set this to true if you want to allow the fleet to plot courses using hidden systems.
	var/hide_movements = FALSE
	var/alignment = "syndicate"
	var/list/taunts = list("Unidentified vessel, you have entered our airspace. Leave immediately or be destroyed", "Identify yourselves immediately or be destroyed", "Unidentified vessel, leave immediately. You are entering Syndicate territory.", "Hold it right there. Prepare to be boarded, Captain.", "Nanotrasen vessel, surrender immediately or face unnecessary casualties.", "All Nanotrasen crewmen, please prepare for immediate evisceration.", "Unidentified vessel, transmit your credentials now or- Wait a second, that’s the ship we’re looking for! Deploy fighters!", "Nanotrasen? You’ve just made my day, all crafts prepare to engage.", "Unknown vessel, failure to contact Syndicate control on frequency 0.4 is a suspected act of aggression. Prepare for engagement.")
	var/list/greetings = list("IFF confirmed, good to see you", "Allied vessel, IFF confirmed.")
	var/list/recently_visited = list()
	var/fleet_trait = FLEET_TRAIT_INVASION
	var/last_encounter_time = 0
	var/datum/faction/faction = null
	var/faction_id = FACTION_ID_SYNDICATE
	var/reward = 100 //Reward for defeating this fleet, is credited to this faction's enemies.

	var/initial_move_delay = 10 MINUTES
	var/minimum_random_move_delay = 5 MINUTES
	var/maximum_random_move_delay = 10 MINUTES
	var/combat_move_delay = 10 MINUTES

//BFS search algo. Entirely unused for now.
/datum/fleet/proc/bfs(datum/star_system/target)
	if(!current_system)
		return //No pathfinding from /NULL/
	if(!target)
		target = SSstar_system.system_by_id("Sol")
	var/list/path = list()
	//Firstly, let's BFS from the target system to get what we actually need to go through.
	var/list/queue = list()
	var/list/visited = list()

	var/list/ourQueue = list()
	var/list/ourVisited = list()

	visited[target] = TRUE
	queue += target

	ourVisited[current_system] = TRUE
	ourQueue += current_system

	while(queue.len)
		var/datum/star_system/SS = queue[1]
		queue.Cut(1,2)
		for(var/_name in SS.adjacency_list)
			var/datum/star_system/sys = SSstar_system.system_by_id(_name)
			if(!visited[sys])
				visited[sys] = TRUE
				queue += sys
				path += sys

	for(var/X in path)
		message_admins(X)

	return target

/datum/fleet/proc/move(datum/star_system/target, force=FALSE)
	var/course_picked_target = FALSE
	if(!target)
		if(goal_system)
			if(current_system == goal_system)
				if(!force)
					addtimer(CALLBACK(src, .proc/move), rand(minimum_random_move_delay, maximum_random_move_delay))
				return //We already arrived at our goal, time to chill here unless it changes.
			if(!plotted_course || !plotted_course.len)	//Route len should ONLY be empty if we already arrived.
				navigate_to(goal_system)
		if(!plotted_course || !plotted_course.len)	//When route is still FALSE after this. there is no way to our goal, so we just pick a random system instead. If it was just a empty list, we are AT our goal instead, though that should early return earlier.
			var/list/potential = list()
			var/list/fallback = list()
			//Pick a movement target based on our fleet trait.
			for(var/_name in current_system.adjacency_list)
				var/datum/star_system/sys = SSstar_system.system_by_id(_name)
				if(sys.hidden)
					continue
				switch(fleet_trait)
					if(FLEET_TRAIT_DEFENSE)
						return FALSE //These boss fleets do not move.
					if(FLEET_TRAIT_NEUTRAL_ZONE) //These fleets live in the neutral zone
						if(sys.alignment != "unaligned" && sys.alignment != "uncharted")
							continue
					if(FLEET_TRAIT_BORDER_PATROL)
						if(sys.alignment != alignment)
							continue
					if(FLEET_TRAIT_INVASION)
						if(sys.alignment == alignment)
							continue
						if(sys.alignment == "unaligned")
							fallback += sys
							continue
				potential += sys
			if(!potential.len)
				potential = fallback //Nowhere else to go.
			if(!potential.len)	//Welp, we are stuck here for now.
				if(!force)
					addtimer(CALLBACK(src, .proc/move), rand(minimum_random_move_delay, maximum_random_move_delay))
				return FALSE
			target = pick(potential)
		else
			target = plotted_course[1]	//This shouldn't be able to reach this point with an empty route, so it *should* be safe.
			course_picked_target = TRUE
	if(!force)
		addtimer(CALLBACK(src, .proc/move), rand(minimum_random_move_delay, maximum_random_move_delay))
		//Precondition: We're allowed to go to this system.
		if(!course_picked_target)
			switch(fleet_trait)
				if(FLEET_TRAIT_DEFENSE)
					return FALSE //These boss fleets do not move.
				if(FLEET_TRAIT_BORDER_PATROL)
					if(target.alignment != alignment)
						return FALSE
				if(FLEET_TRAIT_INVASION)
					if(target.alignment == alignment)
						return FALSE
				if(FLEET_TRAIT_NEUTRAL_ZONE)
					if(target.alignment == alignment)
						return FALSE

		if(world.time < last_encounter_time + combat_move_delay) //So that fleets don't leave mid combat.
			return FALSE

	current_system.fleets -= src
	if(current_system.fleets && current_system.fleets.len)
		var/datum/fleet/F = pick(current_system.fleets)
		current_system.alignment = F.alignment
		current_system.mission_sector = FALSE
		for(var/datum/fleet/FF in current_system.fleets)
			if(FF.alignment != initial(current_system.alignment))
				current_system.mission_sector = TRUE
	else
		current_system.alignment = initial(current_system.alignment)
		current_system.mission_sector = FALSE
	if(instantiated)//If the fleet was "instantiated", that means it's already been encountered, and we need to track the states of all the ships in it.
		for(var/obj/structure/overmap/OM in all_ships)
			if(QDELETED(OM))
				continue
			target.system_contents += OM
			if(!target.occupying_z)
				STOP_PROCESSING(SSphysics_processing, OM)
				if(OM.physics2d)
					STOP_PROCESSING(SSphysics_processing, OM.physics2d)
				var/backupx = OM.x
				var/backupy = OM.y
				OM.moveToNullspace()
				if(backupx && backupy)
					target.contents_positions[OM] = list("x" = backupx, "y" = backupy) //Cache the ship's position so we can regenerate it later.
				else
					target.contents_positions[OM] = list("x" = rand(15, 240), "y" = rand(15, 240))
			else
				if(!OM.z)
					START_PROCESSING(SSphysics_processing, OM)
					if(OM.physics2d)
						START_PROCESSING(SSphysics_processing, OM.physics2d)
				target.add_ship(OM)
			current_system.system_contents -= OM
			if(alignment != "nanotrasen" && alignment != "solgov") //NT, SGC or whatever don't count as enemies that NT hire you to kill.
				current_system.enemies_in_system -= OM
				target.enemies_in_system += OM
			if(current_system.contents_positions[OM]) //If we were loaded, but the system was not.
				current_system.contents_positions -= OM
			OM.current_system = target
	target.fleets += src
	current_system = target
	if(target.alignment != alignment)
		current_system.mission_sector = TRUE
	target.alignment = alignment //We've taken it over.
	if(!hide_movements)
		minor_announce("Typhoon drive signatures detected in [current_system]", "White Rapids EAS")
	for(var/obj/structure/overmap/OM in current_system.system_contents){
		if(OM.mobs_in_ship?.len)
			encounter(OM)
	}
	if(current_system.check_conflict_status())
		if(!SSstar_system.contested_systems.Find(current_system))
			SSstar_system.contested_systems.Add(current_system)
	if(course_picked_target)
		plotted_course -= target
	else if(plotted_course && plotted_course.len)	//We jumped. but didn't follow our course! Recalculate!
		navigate_to(goal_system)
	return TRUE

/datum/fleet/interdiction/move(datum/star_system/target, force=FALSE)
	if(!target && hunted_ship)
		goal_system = hunted_ship.current_system
	. = ..()
	if(.)
		navigate_to(goal_system)	//Anytime we successfully move we recalculate the route, since players like moving around alot.

/datum/fleet/interdiction/New()
	. = ..()
	hunted_ship = SSstar_system.find_main_overmap()

/datum/fleet/earthbuster/New()
	. = ..()
	goal_system = SSstar_system.system_by_id("Sol")


//Clear a ship from this fleet.
/datum/fleet/proc/remove_ship(obj/structure/overmap/OM)
	all_ships -= OM
	last_encounter_time = world.time
	for(var/V in taskforces)	//Very cursed but it works!
		var/list/L = taskforces["[V]"]
		if(!L)
			continue
		for(var/obj/structure/overmap/OOM in L)	//I'm gonna OOM
			if(OOM == OM)
				L.Remove(OM)
				break	//Ships should exist once in a each taskforce, unless something is very wrong in there.
	if(!all_ships.len) //We've been defeated!
		defeat()

/datum/fleet/proc/defeat()
	minor_announce("[name] has been defeated [(current_system && !current_system.hidden) ? "during combat in the [current_system.name] system" : "in battle"].", "White Rapids Fleet Command")
	current_system.fleets -= src
	if(current_system.fleets && current_system.fleets.len)
		var/datum/fleet/F = pick(current_system.fleets)
		current_system.alignment = F.alignment
		current_system.mission_sector = FALSE
		for(var/datum/fleet/FF in current_system.fleets)
			if(FF.alignment != initial(current_system.alignment))
				current_system.mission_sector = TRUE
	else
		current_system.alignment = initial(current_system.alignment)
		current_system.mission_sector = FALSE
	var/player_caused = FALSE
	for(var/obj/structure/overmap/OOM in current_system.system_contents)
		if(!OOM.mobs_in_ship.len)
			continue
		player_caused = TRUE
		for(var/mob/M in OOM.mobs_in_ship)
			if(M.client)
				var/client/C = M.client
				C.tgui_panel?.stop_music()
	if(player_caused)	//Only modify influence if players caused this, otherwise someone else claimed the kill and it doesn't modify influence for the purpose of Patrol completion.
		faction = SSstar_system.faction_by_id(faction_id)
		faction?.lose_influence(reward)
	QDEL_NULL(src)

/datum/fleet/nanotrasen/earth/defeat()
	. = ..() //If you lose sol...game over man, game over.
	priority_announce("SolGov command do you read?! Requesting immediate assistance, we have a foothold situation, repeat, a foothold sit##----///", "White Rapids Fleet Command")
	SSticker.mode.check_finished(TRUE)
	SSticker.force_ending = TRUE

/obj/structure/overmap/proc/force_jump(where)
	if(!where)
		return
	var/datum/star_system/SS = SSstar_system.system_by_id(where)
	if(!SS)
		return
	var/datum/star_system/curr = SSstar_system.ships[src]["current_system"]
	curr?.remove_ship(src)
	jump(SS, FALSE)

/obj/structure/overmap/proc/try_hail(mob/living/user, var/obj/structure/overmap/source_ship)
	if(!isliving(user))
		return FALSE
	if(!source_ship)
		return FALSE
	var/text = stripped_input(user, "What do you want to say?", "Hailing")
	if(text)
		source_ship.hail(text, name, user.name, TRUE) // Let the crew on the source ship know an Outbound message was sent
		hail(text, source_ship.name, user.name)

/obj/structure/overmap/proc/hail(var/text, var/ship_name, var/player_name, var/outbound = FALSE)
	if(!text)
		return
	if(!ship_name)
		return
	var/player_string = ""
	if(player_name) // No sender means AI ship
		player_string = " (Sent by [player_name])"

	if(outbound)
		relay('nsv13/sound/effects/ship/freespace2/computer/textdraw.wav', "<h3>Outbound hail to: [ship_name][player_string]</h3><hr><span class='danger'>[text]</span><br>")
	else
		relay('nsv13/sound/effects/ship/freespace2/computer/textdraw.wav', "<h1>Incoming hail from: [ship_name][player_string]</h1><hr><span class='userdanger'>[text]</span><br>")

/proc/get_internet_sound(web_sound_input)
	if(!web_sound_input)
		return
	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		message_admins("<span class='boldwarning'>YT-DL not set up! Check your configs and that you've installed it.</span>")
		return
	if(istext(web_sound_input))
		var/web_sound_url = ""
		if(istext(web_sound_input))
			var/list/music_extra_data = list()
			if(length(web_sound_input))
				web_sound_input = trim(web_sound_input)
			if(findtext(web_sound_input, ":") && !findtext(web_sound_input, GLOB.is_http_protocol))
				message_admins("<span class='boldwarning'>Non-http(s) URIs are not allowed.</span>")
				message_admins("<span class='warning'>For youtube-dl shortcuts like ytsearch: please use the appropriate full url from the website.</span>")
				return
			var/shell_scrubbed_input = shell_url_scrub(web_sound_input)
			var/list/output = world.shelleo("[ytdl] --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height<=360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_scrubbed_input]\"")
			var/errorlevel = output[SHELLEO_ERRORLEVEL]
			var/stdout = output[SHELLEO_STDOUT]
			var/stderr = output[SHELLEO_STDERR]
			if(!errorlevel)
				var/list/data
				try
					data = json_decode(stdout)
				catch(var/exception/e)
					message_admins("<span class='boldwarning'>Youtube-dl JSON parsing FAILED:</span>")
					message_admins("<span class='warning'>[e]: [stdout]</span>")
					return

				if (data["url"])
					web_sound_url = data["url"]
					music_extra_data["start"] = data["start_time"]
					music_extra_data["end"] = data["end_time"]
				else
					message_admins("<span class='boldwarning'>Youtube-dl URL retrieval FAILED:</span>")
					message_admins("<span class='warning'>[stderr]</span>")
			if(web_sound_url && !findtext(web_sound_url, GLOB.is_http_protocol))
				message_admins("<span class='boldwarning'>BLOCKED: Content URL not using http(s) protocol</span>")
				message_admins("<span class='warning'>The media provider returned a content URL that isn't using the HTTP or HTTPS protocol</span>")
				return
			return list(web_sound_url, music_extra_data)

/datum/fleet/proc/encounter(obj/structure/overmap/OM)
	if(OM.faction == alignment)
		OM.hail(pick(greetings), name)
	assemble(current_system)
	if(OM.faction != alignment)
		if(OM.alpha >= 150) //Sensor cloaks my boy, sensor cloaks
			OM.hail(pick(taunts), name)
			last_encounter_time = world.time
			if(audio_cues?.len)
				OM.play_music(pick(audio_cues))


///Pass in a youtube link, have it played ONLY on that overmap. This should be called by code or admins only.
/obj/structure/overmap/proc/play_music(url)
	set waitfor = FALSE //Don't hold up the jump
	if(!istext(url))
		return FALSE
	var/list/result = get_internet_sound(url)
	if(!result || !islist(result))
		return
	var/web_sound_url = result[1] //this is cringe but it works
	var/music_extra_data = result[2]
	if(web_sound_url)
		for(var/mob/M in mobs_in_ship)
			if(M.client)
				var/client/C = M.client
				C.tgui_panel?.stop_music()
				C.tgui_panel?.play_music(web_sound_url, music_extra_data)

//Syndicate Fleets

/datum/fleet/neutral
	name = "Syndicate Scout Fleet"
	fleet_trait = FLEET_TRAIT_NEUTRAL_ZONE

/datum/fleet/border
	name = "Syndicate border defense force"
	fleet_trait = FLEET_TRAIT_BORDER_PATROL
	hide_movements = TRUE

/datum/fleet/boarding
	name = "Syndicate Commando Taskforce"
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/assault_cruiser/boarding_frigate)
	taunts = list("Attention: This is an automated message. All non-Syndicate vessels prepare to be boarded for security clearance.")
	fleet_trait = FLEET_TRAIT_NEUTRAL_ZONE

/datum/fleet/wolfpack
	name = "Unidentified Fleet"
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/submarine)
	audio_cues = list("https://www.youtube.com/watch?v=sMejhjMfKj4", "https://www.youtube.com/watch?v=bfskFravnWM", "https://www.youtube.com/watch?v=C3WcBLLMnQ4")
	hide_movements = TRUE
	taunts = list("....", "*static*")
	fleet_trait = FLEET_TRAIT_NEUTRAL_ZONE

/datum/fleet/nuclear
	name = "Syndicate nuclear deterrent"
	taunts = list("Enemy ship, surrender now. This vessel is armed with thermonuclear weapons and eager to test them.")
	audio_cues = list("https://www.youtube.com/watch?v=0iXfWWrwrlQ", "https://www.youtube.com/watch?v=YW2bPkw0VyU")
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/nuclear, /obj/structure/overmap/syndicate/ai/nuclear/elite)
	size = 2
	fleet_trait = FLEET_TRAIT_NEUTRAL_ZONE

/datum/fleet/elite
	name = "Syndicate Elite Taskforce"
	taunts = list("Enemy ship, surrender immediately or face destruction.", "Excellent, a worthwhile target. Arm all batteries.")
	supply_types = list(/obj/structure/overmap/syndicate/ai/carrier/elite)
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/destroyer/elite)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/cruiser/elite)

//Space Pirate Fleets
/datum/fleet/pirate
	name = "Space Pirate Fleet"
	fighter_types = null
	destroyer_types = list(/obj/structure/overmap/spacepirate/ai)
	battleship_types = list(/obj/structure/overmap/spacepirate/ai/nt_missile, /obj/structure/overmap/spacepirate/ai/syndie_gunboat)
	supply_types = null
	alignment = "pirate"
	faction_id = FACTION_ID_PIRATES
	reward = 35

/datum/fleet/pirate/scout
	name = "Space pirate scout fleet"
	audio_cues = list("https://www.youtube.com/watch?v=LjhF3yIeDSc", "https://www.youtube.com/watch?v=dsLHf9X8P8w")
	taunts = list("Yar har! Fresh meat", "Unfurl the mainsails! We've got company", "Die landlubbers!")
	size = FLEET_DIFFICULTY_MEDIUM
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/pirate/raiding
	name = "Space pirate raiding fleet"
	destroyer_types = list(/obj/structure/overmap/spacepirate/ai, /obj/structure/overmap/spacepirate/ai/boarding)
	audio_cues = list("https://www.youtube.com/watch?v=LjhF3yIeDSc", "https://www.youtube.com/watch?v=dsLHf9X8P8w")
	taunts = list("Avast! A fine hold of loot sails our way", "Prepare the boarding crews, they've got enough loot for us all!")
	size = FLEET_DIFFICULTY_MEDIUM

/datum/fleet/pirate/tortuga
	name = "Space pirate holding fleet"
	supply_types = list(/obj/structure/overmap/spacepirate/ai/dreadnought)
	audio_cues = list("https://www.youtube.com/watch?v=48b_TY8Jl2w", "https://www.youtube.com/watch?v=ntDt-502ftw")
	taunts = list("These are our waters you are sailing, prepare to surrender!", "Bold of you to fly Nanotrasen colours in this system, your last mistake.")
	size = FLEET_DIFFICULTY_VERY_HARD
	fleet_trait = FLEET_TRAIT_DEFENSE
	reward = 100	//Difficult pirate fleet, so default reward.

//Boss battles.

/datum/fleet/rubicon //Crossing the rubicon, are we?
	name = "Rubicon Crossing"
	size = FLEET_DIFFICULTY_VERY_HARD
	allow_difficulty_scaling = FALSE
	audio_cues = list("https://www.youtube.com/watch?v=mhXuYp0n88g", "https://www.youtube.com/watch?v=l1J-2nIovYw", "https://www.youtube.com/watch?v=M_MdmLWmDHs")
	taunts = list("Better crews have tried to cross the Rubicon, you will die like they did.", "Defense force, stand ready!", "Nanotrasen filth. Munitions, ready the guns. We’ll scrub the galaxy clean of you vermin.", "This shift just gets better and better. I’ll have your Captain’s head on my wall.")
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/earthbuster
	name = "Syndicate Armada" //Fleet spawned if the players are too inactive. Set course...FOR EARTH.
	destroyer_types = list(/obj/structure/overmap/syndicate/ai, /obj/structure/overmap/syndicate/ai/nuclear, /obj/structure/overmap/syndicate/ai/assault_cruiser, /obj/structure/overmap/syndicate/ai/gunboat, /obj/structure/overmap/syndicate/ai/submarine, /obj/structure/overmap/syndicate/ai/assault_cruiser/boarding_frigate)
	size = FLEET_DIFFICULTY_VERY_HARD
	allow_difficulty_scaling = FALSE
	taunts = list("We're coming for Sol, and you can't stop us. All batteries fire at will.", "Lay down your arms now, you're outnumbered.", "All hands, assume assault formation. Begin bombardment.")
	audio_cues = list("https://www.youtube.com/watch?v=k8-HHivlj8k")

/datum/fleet/interdiction	//Pretty strong fleet with unerring hunting senses, Adminspawn for now.
	name = "Syndicate Interdiction Fleet"	//These fun guys can and will hunt the player ship down, no matter how far away they are.
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/nuclear, /obj/structure/overmap/syndicate/ai/assault_cruiser, /obj/structure/overmap/syndicate/ai/assault_cruiser/boarding_frigate)
	size = FLEET_DIFFICULTY_HARD
	taunts = list("We have come to end your meagre existance. Prepare to die.", "Hostile entering weapons range. Fire at will.", "You have been a thorn in our side for quite a while. Time to end this.", "That is a nice ship you have there. Nothing a few nuclear missiles cannot fix.")
	audio_cues = list("https://www.youtube.com/watch?v=dTKakINXjl8")
	var/obj/structure/overmap/hunted_ship
	initial_move_delay = 5 MINUTES
	minimum_random_move_delay = 2 MINUTES	//These are quite a bunch faster than your usual fleets. Good luck running. It won't save you.
	maximum_random_move_delay = 4 MINUTES
	combat_move_delay = 6 MINUTES

/datum/fleet/interdiction/stealth	//More fun for badmins
	name = "Unidentified Heavy Fleet"
	hide_movements = TRUE
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/submarine, /obj/structure/overmap/syndicate/ai/nuclear, /obj/structure/overmap/syndicate/ai/assault_cruiser)

/datum/fleet/interdiction/light	//The syndicate can spawn these randomly (though rare). Be caareful! But, at least they aren't that scary.
	name = "Syndicate Light Interdiction Fleet"
	size = FLEET_DIFFICULTY_MEDIUM	//Don't let this fool you though, they are still somewhat dangerous and will hunt you down.
	initial_move_delay = 12 MINUTES

/datum/fleet/dolos
	name = "Dolos Welcoming Party" //Don't do it czanek, don't fucking do it!
	size = FLEET_DIFFICULTY_WHAT_ARE_YOU_DOING
	allow_difficulty_scaling = FALSE
	audio_cues = list("https://www.youtube.com/watch?v=UPHmazxB38g") //FTL13 ;(
	taunts = list("Don't think we didn't learn from your last attempt.", "We shall not fail again", "Your outdated MAC weapons are no match for us. Prepare to be destroyed.")
	fleet_trait = FLEET_TRAIT_DEFENSE
	destroyer_types = list(/obj/structure/overmap/syndicate/ai, /obj/structure/overmap/syndicate/ai/destroyer/elite, /obj/structure/overmap/syndicate/ai/destroyer/flak, /obj/structure/overmap/syndicate/ai/cruiser/elite, /obj/structure/overmap/syndicate/ai/mako_flak, /obj/structure/overmap/syndicate/ai/mako_carrier)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/cruiser/elite, /obj/structure/overmap/syndicate/ai/nuclear/elite)
	supply_types = list(/obj/structure/overmap/syndicate/ai/carrier/elite)

/datum/fleet/remnant
	name = "The Remnant"
	size = FLEET_DIFFICULTY_WHAT_ARE_YOU_DOING
	allow_difficulty_scaling = FALSE
	audio_cues = list("https://www.youtube.com/watch?v=ALn-7v9BxNg")
	taunts = list("<pre>\[DECRYPTION FAILURE]</pre>")
	fleet_trait = FLEET_TRAIT_DEFENSE
	destroyer_types = list(/obj/structure/overmap/syndicate/ai, /obj/structure/overmap/syndicate/ai/destroyer/elite, /obj/structure/overmap/syndicate/ai/destroyer/flak, /obj/structure/overmap/syndicate/ai/cruiser/elite, /obj/structure/overmap/syndicate/ai/mako_flak, /obj/structure/overmap/syndicate/ai/mako_carrier)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/cruiser/elite, /obj/structure/overmap/syndicate/ai/nuclear/elite)
	supply_types = list(/obj/structure/overmap/syndicate/ai/carrier/elite)

/datum/fleet/unknown_ship
	name = "Unknown Ship Class"
	size = 1
	allow_difficulty_scaling = FALSE
	battleship_types = list(/obj/structure/overmap/syndicate/ai/battleship)
	audio_cues = list("https://www.youtube.com/watch?v=zyPSAkz84vM")
	taunts = list("Your assault on Rubicon only served to distract you from the real threat. It's time to end this war in one swift blow.")
	fleet_trait = FLEET_TRAIT_DEFENSE

//Nanotrasen fleets

/datum/fleet/nanotrasen
	name = "Nanotrasen heavy combat fleet"
	fighter_types = list(/obj/structure/overmap/nanotrasen/ai/fighter)
	destroyer_types = list(/obj/structure/overmap/nanotrasen/ai, /obj/structure/overmap/nanotrasen/missile_cruiser/ai)
	battleship_types = list(/obj/structure/overmap/nanotrasen/patrol_cruiser/ai, /obj/structure/overmap/nanotrasen/heavy_cruiser/ai, /obj/structure/overmap/nanotrasen/battlecruiser/ai)
	supply_types = list(/obj/structure/overmap/nanotrasen/carrier/ai)
	alignment = "nanotrasen"
	hide_movements = TRUE //Friendly fleets just move around as you'd expect.
	faction_id = FACTION_ID_NT
	taunts = list("Syndicate vessel, stand down or be destroyed", "You are encroaching on our airspace, prepare to be destroyed", "Unidentified vessel, your existence will be forfeit in accordance with the peacekeeper act.")

/datum/fleet/nanotrasen/light
	name = "Nanotrasen light fleet"
	battleship_types = list(/obj/structure/overmap/nanotrasen/patrol_cruiser/ai)

/datum/fleet/nanotrasen/border
	name = "Concord Border Enforcement Unit"
	taunts = list("You have violated the law. Stand down your weapons and prepare to be boarded.", "Hostile vessel. Stand down immediately or be destroyed.")
	size = FLEET_DIFFICULTY_EASY
	fleet_trait = FLEET_TRAIT_BORDER_PATROL

/datum/fleet/nanotrasen/border/defense
	name = "501st 'Crais' Fist' Expeditionary Force"
	taunts = list("You have violated the law. Stand down your weapons and prepare to be boarded.", "Hostile vessel. Stand down immediately or be destroyed.")
	size = FLEET_DIFFICULTY_EASY
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/nanotrasen/earth
	name = "Earth Defense Force"
	taunts = list("You're foolish to venture this deep into Solgov space! Main batteries stand ready.", "All hands, set condition 1 throughout the fleet, enemy vessel approaching.", "Defense force, stand ready!", "We shall protect our homeland!")
	size = FLEET_DIFFICULTY_HARD
	allow_difficulty_scaling = FALSE
	audio_cues = list("https://www.youtube.com/watch?v=k8-HHivlj8k")
	fleet_trait = FLEET_TRAIT_DEFENSE

//Solgov

/datum/fleet/solgov
	name = "Solgov light exploratory fleet"
	fighter_types = list(/obj/structure/overmap/nanotrasen/solgov/ai/fighter)
	destroyer_types = list(/obj/structure/overmap/nanotrasen/solgov/ai)
	battleship_types = list(/obj/structure/overmap/nanotrasen/solgov/aetherwhisp/ai)
	supply_types = list(/obj/structure/overmap/nanotrasen/solgov/carrier/ai)
	alignment = "nanotrasen"
	hide_movements = TRUE //They're "friendly" alright....
	faction_id = FACTION_ID_NT
	taunts = list("You are encroaching on our airspace, prepare to be destroyed", "You have entered SolGov secure airspace. Prepare to be destroyed", "You are in violation of the SolGov non-aggression agreement. Leave this airspace immediately.")
	size = FLEET_DIFFICULTY_EASY
	greetings = list("Allied vessel. You will be scanned for compliance with the peacekeeper act in 30 seconds. We thank you for your compliance.")
	var/scan_delay = 30 SECONDS
	var/scanning = FALSE

/datum/fleet/solgov/assemble(datum/star_system/SS, difficulty)
	. = ..()
	if(!scanning)
		addtimer(CALLBACK(src, .proc/scan), scan_delay)
		scanning = TRUE

/datum/fleet/solgov/proc/scan()
	scanning = FALSE
	if(!current_system)
		return FALSE
	for(var/obj/structure/overmap/OM in current_system.system_contents)
		OM.relay('nsv13/sound/effects/ship/solgov_scan.ogg')
	sleep(5 SECONDS)
	for(var/obj/structure/overmap/shield_scan_target in current_system.system_contents)
		if(istype(shield_scan_target, /obj/structure/overmap/nanotrasen/solgov))
			continue //We don't scan our own boys.
		//Ruh roh.... (Persona non gratas do not need to be scanned again.)
		if((shield_scan_target.faction != shield_scan_target.name) && shield_scan_target.shields && shield_scan_target.shields.active && shield_scan_target.occupying_levels?.len)
			shield_scan_target.hail("Scans have detected that you are in posession of prohibited technology. \n Your IFF signature has been marked as 'persona non grata'. \n In accordance with SGC-reg #10124, your ship and lives are now forfeit. Evacuate all civilian personnel immediately and surrender yourselves.", name)
			shield_scan_target.relay_to_nearby('nsv13/sound/effects/ship/solgov_scan_alert.ogg', ignore_self=FALSE)
			shield_scan_target.faction = shield_scan_target.name

/datum/fleet/New()
	. = ..()
	if(allow_difficulty_scaling)
		//Account for pre-round spawned fleets.
		var/num_players = (SSticker?.mode) ? SSticker.mode.num_players() : 0
		if(num_players <= 15) //You get an easier time of it on lowpop
			size = round(size * 0.8)
		else
			size = round(size + (num_players / 10) ) //Lightly scales things up.
	size = CLAMP(size, FLEET_DIFFICULTY_EASY, INFINITY)
	faction = SSstar_system.faction_by_id(faction_id)
	reward *= size //Bigger fleet = larger reward
	if(current_system)
		current_system.alignment = alignment
		if(current_system.alignment != initial(current_system.alignment))
			current_system.mission_sector = TRUE
		assemble(current_system)
	addtimer(CALLBACK(src, .proc/move), initial_move_delay)

//A fleet has entered a system. Assemble the fleet so that it lives in this system now.

/datum/fleet/proc/assemble(datum/star_system/SS, difficulty=size)
	if(!SS)
		return
	if(SS.occupying_z && instantiated)
		for(var/obj/structure/overmap/unbox in all_ships)
			if(SS.occupying_z != unbox.z)	//If we have ships 'stored' in nullspace or somewhere else, get them all into our system.
				SS.add_ship(unbox)
				START_PROCESSING(SSphysics_processing, unbox) //And let's restart its processing since it's likely stopped if they were in nullspace.
				if(unbox.physics2d)
					START_PROCESSING(SSphysics_processing, unbox.physics2d) //Respawn this ship's collider so it can start colliding once more
		return
	if(instantiated)
		return
	SS.alignment = alignment
	if(SS.alignment != initial(SS.alignment))
		SS.mission_sector = TRUE
	current_system = SS	//It should already have a system but lets be safe and move it.
	instantiated = TRUE
	/*Fleet comp! Let's use medium as an example:
	6 total
	3 destroyers (1/2 of the fleet size)
	2 battleships (1/4th of the fleet)
	2 supply ships (1/4th of the fleet)
	*/
	//This may look lazy, but it's easier than storing all this info in one massive dict. Deal with it!
	if(destroyer_types?.len)
		for(var/I=0; I<max(round(difficulty/2), 1);I++){
			var/shipType = pick(destroyer_types)
			var/obj/structure/overmap/member = new shipType()
			taskforces["destroyers"] += member
			member.fleet = src
			member.current_system = current_system
			if(alignment != "nanotrasen" && alignment != "solgov") //NT, SGC or whatever don't count as enemies that NT hire you to kill.
				current_system.enemies_in_system += member
			all_ships += member
			RegisterSignal(member, COMSIG_PARENT_QDELETING , /datum/fleet/proc/remove_ship, member)
			if(SS.occupying_z)
				SS.add_ship(member)
			else
				LAZYADD(SS.system_contents, member)
				SS.contents_positions[member] = list("x" = rand(15, 240), "y" = rand(15, 240)) //If the system isn't loaded, just give them randomized positions.
				STOP_PROCESSING(SSphysics_processing, member)
				if(member.physics2d)
					STOP_PROCESSING(SSphysics_processing, member.physics2d)
		}
	if(battleship_types?.len)
		for(var/I=0; I<max(round(difficulty/4), 1);I++){
			var/shipType = pick(battleship_types)
			var/obj/structure/overmap/member = new shipType()
			taskforces["battleships"] += member
			member.fleet = src
			member.current_system = current_system
			if(alignment != "nanotrasen" && alignment != "solgov") //NT, SGC or whatever don't count as enemies that NT hire you to kill.
				current_system.enemies_in_system += member
			all_ships += member
			RegisterSignal(member, COMSIG_PARENT_QDELETING , /datum/fleet/proc/remove_ship, member)
			if(SS.occupying_z)
				SS.add_ship(member)
			else
				LAZYADD(SS.system_contents, member)
				SS.contents_positions[member] = list("x" = rand(15, 240), "y" = rand(15, 240)) //If the system isn't loaded, just give them randomized positions..
				STOP_PROCESSING(SSphysics_processing, member)
				if(member.physics2d)
					STOP_PROCESSING(SSphysics_processing, member.physics2d)
		}
	if(supply_types?.len)
		for(var/I=0; I<max(round(difficulty/4), 1);I++){
			var/shipType = pick(supply_types)
			var/obj/structure/overmap/member = new shipType()
			taskforces["supply"] += member
			member.fleet = src
			member.current_system = current_system
			if(alignment != "nanotrasen" && alignment != "solgov") //NT, SGC or whatever don't count as enemies that NT hire you to kill.
				current_system.enemies_in_system += member
			all_ships += member
			RegisterSignal(member, COMSIG_PARENT_QDELETING , /datum/fleet/proc/remove_ship, member)
			if(SS.occupying_z)
				SS.add_ship(member)
			else
				LAZYADD(SS.system_contents, member)
				SS.contents_positions[member] = list("x" = rand(15, 240), "y" = rand(15, 240)) //If the system isn't loaded, just give them randomized positions..
				STOP_PROCESSING(SSphysics_processing, member)
				if(member.physics2d)
					STOP_PROCESSING(SSphysics_processing, member.physics2d)
		}
	if(SS.check_conflict_status())
		if(!SSstar_system.contested_systems.Find(SS))
			SSstar_system.contested_systems.Add(SS)
	return TRUE

/*
A bloated proc for checking AI trait(s) of a overmap vs. required trait(s) given as arg.
Accepts singular variables aswell as lists, on both sides.
Has potential to return incorrect results if you give a list with at least one duplicated element as arg. So, don't.
*/
/obj/structure/overmap/proc/has_ai_trait(var/V)
	if(islist(V))
		var/list/CTS = V	//CheckTraitS
		if(islist(ai_trait))
			var/list/OTS = ai_trait	//OvermapTraitS
			for(var/CT in CTS)
				var/found = FALSE
				for(var/OT in OTS)
					if(OT == CT)
						found = TRUE
						break
				if(!found)
					return FALSE
			return TRUE
		else
			return FALSE	//If there are multiple required traits, but only one existing trait, we can be sure they don't have all of them, provided there isn't doubleoccurances in the list.
	else
		if(islist(ai_trait))
			var/list/OTS = ai_trait
			for(var/OT in OTS)
				if(OT == V)
					return TRUE	//One required trait, multiple present ones = We can early return TRUE.
			return FALSE
		else
			return V == ai_trait


/datum/ai_goal
	var/name = "Placeholder goal" //Please keep these human readable for debugging!
	var/score = 0
	var/required_trait = null //Set this if you want this task to only be achievable by certain types of ship.

//Method to get the score of a certain action. This can change the "base" score if the score of a specific action goes up, to encourage skynet to go for that one instead.
//@param OM - If you want this score to be affected by the stats of an overmap.

/datum/ai_goal/proc/check_score(obj/structure/overmap/OM)
	if(!istype(OM) || !OM.ai_controlled)
		return 0 //0 Score, in other terms, the AI will ignore this task completely.
	if(required_trait)
		if(islist(OM.ai_trait))
			var/found = FALSE
			for(var/X in OM.ai_trait)
				if(X == required_trait)
					found = TRUE
					break
			if(!found)
				return 0
		else
			if(OM.ai_trait != required_trait)
				return 0
	return (score > 0 ? score : TRUE) //Children sometimes NEED this true value to run their own checks.

//Delete the AI's last orders, tell the AI ship what to do.
/datum/ai_goal/proc/assume(obj/structure/overmap/OM)
	if(OM.current_goal)
		OM.current_goal = null
	action(OM)

//What happens when the AI ship physically assumes this goal? This is the method you'll want to override to make the AI ship do things!
/datum/ai_goal/proc/action(obj/structure/overmap/OM)
	OM.current_goal = src

/datum/ai_goal/rearm
	name = "Re-arm at supply ship"
	score = 0

//If the ship in question is low health, or low on ammo, it will attempt to re-arm and repair at a supply ship. If there are no supply ships, then we'll ignore this one.

/datum/ai_goal/rearm/check_score(obj/structure/overmap/OM)
	if(!..() || !OM.fleet) //If it's not an overmap, or it's not linked to a fleet.
		return 0
	var/list/L = OM.fleet.taskforces["supply"] //I don't know why we have to do it this way, but dreamchecker is forcing us to.
	if(!L.len)
		return 0 //Can't resupply if there's no supply station/ship. Carry on fighting!
	if(OM.obj_integrity < OM.max_integrity/3)
		return AI_SCORE_SUPERPRIORITY
	if(OM.shots_left < initial(OM.shots_left)/3)
		return AI_SCORE_PRIORITY
	return 0

/datum/ai_goal/rearm/action(obj/structure/overmap/OM)
	..()
	if(OM.current_lance)
		var/datum/lance/L = OM.current_lance
		if(L.lance_target && L.last_finder == OM)
			L.lance_target = null	//Clear our relayed target if we fly to resupply to make it a bit easier on the players.
			L.last_finder = null
	var/obj/structure/overmap/supplyPost = null
	for(var/obj/structure/overmap/supply in OM.fleet.taskforces["supply"])
		supplyPost = supply
		break
	if(supplyPost) //Neat, we've found a supply post. Autobots roll out.
		if(get_dist(OM, supplyPost) <= AI_PDC_RANGE)
			OM.brakes = TRUE
		else
			OM.move_toward(supplyPost)

/datum/ai_goal/seek
	name = "Search and destroy"
	score = AI_SCORE_DEFAULT

/datum/ai_goal/seek/check_score(obj/structure/overmap/OM)
	if(!OM.fleet && !OM.current_lance) //If this is a rogue / lone AI. This should be their only objective.
		return AI_SCORE_MAXIMUM
	if(!..()) //If it's not an overmap, or it's not linked to a fleet.
		return 0
	if(OM.has_ai_trait(AI_TRAIT_SUPPLY))
		return 0	//Carriers don't hunt you down, they just patrol. The dirty work is reserved for their escorts.
	if(!OM.last_target || QDELETED(OM.last_target))
		OM.seek_new_target()
	if(OM.last_target) //If we can't find a target, then don't bother hunter-killering.
		return score
	else
		return AI_SCORE_VERY_LOW_PRIORITY //Just so that there's a "default" behaviour to avoid issues.

/datum/ai_goal/seek/action(obj/structure/overmap/OM)
	..()
	if(OM.last_target)
		if(get_dist(OM, OM.last_target) <= 10)
			OM.move_away_from(OM.last_target)
		else
			OM.move_toward(OM.last_target)
	else
		OM.send_radar_pulse() //Send a pong when we're actively hunting.
		OM.seek_new_target()
		OM.move_toward(null) //Just fly around in a straight line, I guess.

/*
Ships with this goal create a a lance, but are not exactly bound to it. They'll fly off on their own if they find a closeby target, but if they have none they'll try assisting with their lance target.
*/
/datum/ai_goal/swarm
	name = "Join a lance and subsequently search & swarm targets."
	score = AI_SCORE_DEFAULT
	required_trait = AI_TRAIT_SWARMER

/datum/ai_goal/swarm/check_score(obj/structure/overmap/OM)
	if(!..())
		return 0
	if(!OM.fleet && !OM.current_lance)
		return 0
	if(OM.current_lance)
		return AI_SCORE_PRIORITY
	return score

/datum/ai_goal/swarm/action(obj/structure/overmap/OM)
	..()
	if(!OM.current_lance)	//If we aren't in a lance already: Handle that.
		if(!OM.fleet)
			return
		for(var/datum/lance/L in OM.fleet.lances)
			if(L.member_count < L.maximum_members)
				L.add_member(OM)
				break
		if(!OM.current_lance)	//we didn't find a lance to join, make our own
			new /datum/lance(OM, OM.fleet)
	if(!OM.current_lance)
		return	//Something that shouldn't have happened happened.

	var/datum/lance/L = OM.current_lance
	if(!OM.last_target)
		OM.send_radar_pulse()
		OM.seek_new_target()

	if(!OM.last_target)	//We didn't find a target
		if(L.lance_target)
			if(L.last_finder == OM)
				L.lance_target = null
				L.last_finder = null
				regroup_swarm(OM, L)
				return
			else
				OM.add_enemy(L.lance_target)
				OM.last_target = L.lance_target
		else	//No targets anywhere we could grab, regroup or float, depending on if you are the leader.
			regroup_swarm(OM, L)
			return
	//If we get to hdere, we should have a target
	if(!L.lance_target)	//Relay target
		L.lance_target = OM.last_target
		L.last_finder = OM

	else if(L.last_finder == OM && OM.last_target != L.lance_target)	//We switched targets, relay this too.
		L.lance_target = OM.last_target

	if(get_dist(OM, OM.last_target) <= 4)	//Hunt them down.
		OM.move_away_from(OM.last_target)
	else
		OM.move_toward(OM.last_target)

/*
If leader: Return to a bigger ship and wait around it.
If not leader: Return to leader.
Staging point priorities are supply ships > battleships > destroyers > just float
*/
/datum/ai_goal/swarm/proc/regroup_swarm(var/obj/structure/overmap/OM, var/datum/lance/L)
	var/obj/structure/overmap/movement_target
	if(OM == L.lance_leader)
		movement_target = find_staging_point(OM)
	else
		movement_target = L.lance_leader

	if(!movement_target)
		OM.move_toward(null)	//Just drift I guess?
	else
		if(get_dist(OM, movement_target) <= 8)
			OM.brakes = TRUE
			OM.move_mode = null
			OM.desired_angle = movement_target.angle //Style points
		else
			OM.move_toward(movement_target)
/*
Seek a ship thich we'll station ourselves around
*/
/datum/ai_goal/swarm/proc/find_staging_point(var/obj/structure/overmap/OM)
	var/list/L	//We need this
	if(!OM.fleet)
		return
	L = OM.fleet.taskforces["supply"]
	if(L.len)
		return L[1]	//gives us a consistant target.
	L = OM.fleet.taskforces["battleships"]
	if(L.len)
		return L[1]
	L = OM.fleet.taskforces["destroyers"]
	if(L.len)
		return L[1]


//Boarding! Boarders love to board your ships.
/datum/ai_goal/board
	name = "Board target"
	score = AI_SCORE_HIGH_PRIORITY
	required_trait = AI_TRAIT_BOARDER

/datum/ai_goal/board/check_score(obj/structure/overmap/OM)
	if(!..())
		return 0
	if(!OM.last_target || QDELETED(OM.last_target))
		OM.seek_new_target(max_weight_class=null, min_weight_class=null, interior_check=TRUE)
	if(OM.last_target) //If we can't find a target, then don't bother hunter-killering.
		return score
	else
		return AI_SCORE_VERY_LOW_PRIORITY //Just so that there's a "default" behaviour to avoid issues.

/datum/ai_goal/board/action(obj/structure/overmap/OM)
	..()
	if(OM.last_target)
		OM.move_toward(OM.last_target)
		if(get_dist(OM.last_target, OM) <= 8)
			var/obj/structure/overmap/foo = OM.last_target
			if(istype(foo))
				OM.desired_angle = foo.angle //Pull up parallel beside it for style points.
		if(OM.can_board(OM.last_target))
			OM.try_board(OM.last_target)
			return FALSE
	else
		OM.move_toward(null) //Just fly around in a straight line, I guess.

/datum/ai_goal/defend
	name = "Protect supply lines"
	score = AI_SCORE_LOW_PRIORITY

/datum/ai_goal/defend/action(obj/structure/overmap/OM)
	..()
	if(prob(5))	//Sometimes ping, but not that often.
		OM.send_radar_pulse()
	if(!OM.defense_target || QDELETED(OM.defense_target))
		var/list/supplyline = OM.fleet.taskforces["supply"]
		OM.defense_target = supplyline?.len ? pick(OM.fleet.taskforces["supply"]) : OM

	if(get_dist(OM, OM.defense_target) <= AI_PDC_RANGE)
		OM.brakes = TRUE
		OM.move_mode = null
		OM.desired_angle = OM.defense_target.angle //Turn and face boys!
	else
		OM.move_toward(OM.defense_target)

//Battleships love to stick to supply ships like glue. This becomes the default behaviour if the AIs cannot find any targets.
/datum/ai_goal/defend/check_score(obj/structure/overmap/OM)
	if(!..() || !OM.fleet) //If it's not an overmap, or it's not linked to a fleet.
		return score
	var/list/supplyline = OM.fleet.taskforces["supply"]
	if(!supplyline || !supplyline.len)
		return 0	//If there is nothing to defend, lets hunt the guys that destroyed our supply line instead.
	if(OM.has_ai_trait(AI_TRAIT_SUPPLY))
		return 0	//Can't defend ourselves

	if(OM.has_ai_trait(AI_TRAIT_BATTLESHIP))
		return AI_SCORE_CRITICAL
	return score //If you've got nothing better to do, come group with the main fleet.

//Goal used entirely for supply ships, signalling them to run away! Most ships use the "repair and re-arm" goal instead of this one.
/datum/ai_goal/retreat
	name = "Maintain safe distance from enemies"

//Supply ships are timid, and will always try to run.
/datum/ai_goal/retreat/check_score(obj/structure/overmap/OM)
	if(!..() || !OM.fleet) //If it's not an overmap, or it's not linked to a fleet.
		return 0
	if(!OM.has_ai_trait(AI_TRAIT_SUPPLY))
		return 0
	OM.last_target = null
	OM.seek_new_target(max_distance = OM.max_tracking_range)	//Supply ships will only start running if an enemy actually comes close.
	if(OM.last_target)
		return AI_SCORE_CRITICAL
	return AI_SCORE_VERY_LOW_PRIORITY

//Supply ships are sheepish, and like to run away. Otherwise, they patrol the sector until they find enemies, in which case they run and let their escorts handle the rest.

/datum/ai_goal/retreat/action(obj/structure/overmap/OM)
	..()
	OM.brakes = TRUE
	var/obj/structure/overmap/foo = OM.last_target
	if(!foo || !istype(foo) || get_dist(OM, foo) > foo.max_weapon_range) //You can run on for a long time, run on for a long time, run on for a long time, sooner or later gonna cut you down
		return //Just drift aimlessly, let the fleet form up with it.
	OM.move_mode = NORTH
	OM.brakes = FALSE
	OM.desired_angle = -Get_Angle(OM, OM.last_target) //Turn the opposite direction and run.

//Patrol goal in case there is no target.
/datum/ai_goal/patrol
	name = "Patrol system"
	score = AI_SCORE_DEFAULT

/datum/ai_goal/patrol/check_score(obj/structure/overmap/OM)
	if(!..())
		return 0
	if(!OM.last_target)
		OM.seek_new_target()
	if(OM.last_target)
		if(get_dist(OM, OM.last_target) < OM.max_tracking_range)
			OM.patrol_target = null	//Clear our destination if we are getting close to the enemy. Otherwise we resume patrol to our old destination.
			return 0
		if(!OM.has_ai_trait(AI_TRAIT_SUPPLY))	//Supply ships only stop patrolling to run away (which when needed still has higher score
			return 0
	if(OM.has_ai_trait(AI_TRAIT_SUPPLY))
		if(OM.resupplying)
			return 0
		return AI_SCORE_HIGH_PRIORITY	//Supply ships like slowly patrolling the sector.
	return score

/datum/ai_goal/patrol/action(obj/structure/overmap/OM)
	..()
	if(prob(8))	//Ping every now and then, so things can't sneak up on you.
		OM.send_radar_pulse()
	if(OM.patrol_target && get_dist(OM, OM.patrol_target) <= 8)
		OM.patrol_target = null	//You have arrived at your destination.
	if(!OM.patrol_target || OM.patrol_target.z != OM.z)
		var/min_x = max(OM.x - 50, 15)
		var/max_x = min(OM.x + 50, 240)
		var/min_y = max(OM.y - 50, 15)
		var/max_y = min(OM.y + 50, 240)
		var/x_target = rand(min_x, max_x)
		var/y_target = rand(min_y, max_y)
		OM.patrol_target = locate(x_target, y_target, OM.z)
	if(!OM.patrol_target)
		return	//Somehow, there still is no target. Well, return it is.

	OM.move_toward(OM.patrol_target)





//Goal used for anti-fighter craft, encouraging them to attempt to lock on to smaller ships.
/datum/ai_goal/seek/flyswatter
	name = "Hunt down fighters"
	required_trait = AI_TRAIT_ANTI_FIGHTER
	score = AI_SCORE_PRIORITY

//Supply ships are timid, and will always try to run.
/datum/ai_goal/seek/flyswatter/check_score(obj/structure/overmap/OM)
	if(!..())
		return 0
	var/obj/structure/overmap/target = OM.last_target
	if(!OM.last_target || !istype(target) || QDELETED(OM.last_target) || target.mass > MASS_TINY)
		OM.seek_new_target(max_weight_class=MASS_TINY)
	if(OM.last_target) //If we can't find a target, then don't bother hunter-killering.
		return score
	else
		return 0 //Default back to the "hunt down ships" behaviour.

/obj/structure/overmap/proc/choose_goal()
	//Populate the list of valid goals, if we don't already have them
	if(!GLOB.ai_goals.len)
		for(var/x in subtypesof(/datum/ai_goal))
			GLOB.ai_goals += new x
	var/best_score = 0
	var/datum/ai_goal/chosen = null
	for(var/datum/ai_goal/goal in GLOB.ai_goals)
		var/newScore = goal.check_score(src)
		if(newScore > best_score)
			best_score = newScore
			chosen = goal
	if(!chosen)
		return //Uh..yeah..whoops?
	if(chosen == current_goal)
		chosen.action(src)
		return
	chosen.assume(src)

//Basic inherited stuff that we need goes here:

/obj/structure/overmap
	var/ai_controlled = FALSE //Set this to true to let the computer fly your ship.
	var/ai_behaviour = null // Determines if the AI ship shoots you first, or if you have to shoot them.
	var/list/enemies = list() //Things that have attacked us
	var/max_weapon_range = 50
	var/max_tracking_range = 50//50, 100 when pinging - Range that AI ships can hunt you down in. The amounts to almost half the Z-level.
	var/obj/structure/overmap/defense_target = null
	var/ai_can_launch_fighters = FALSE //AI variable. Allows your ai ships to spawn fighter craft
	var/list/ai_fighter_type = list()
	var/ai_trait = AI_TRAIT_DESTROYER

	var/last_decision = 0
	var/decision_delay = 2 SECONDS
	var/move_mode = 0
	var/next_boarding_attempt = 0

	var/reloading_torpedoes = FALSE
	var/reloading_missiles = FALSE
	var/static/list/warcrime_blacklist = typecacheof(list(/obj/structure/overmap/fighter/escapepod, /obj/structure/overmap/asteroid))//Ok. I'm not THAT mean...yet. (Hello karmic, it's me karmic 2)

	//Fleet organisation
	var/shots_left = 15 //Number of arbitrary shots an AI can fire with its heavy weapons before it has to resupply with a supply ship.
	var/resupply_range = 15
	var/resupplying = 0	//Are we resupplying things right now? If yes, how many?
	var/can_resupply = FALSE //Can this ship resupply other ships?
	var/obj/structure/overmap/resupply_target = null
	var/datum/fleet/fleet = null
	var/datum/current_lance = null	//Some ships can assign themselves to a lance, which will act together.
	var/turf/patrol_target = null
	var/datum/ai_goal/current_goal = null
	var/obj/structure/overmap/squad_lead = null
	var/obj/structure/overmap/last_overmap = null
	var/switchsound_cooldown = 0

/obj/structure/overmap/proc/ai_fire(atom/target)
	if(next_firetime > world.time)
		return
	if(istype(target, /obj/structure/overmap))
		add_enemy(target)
		var/target_range = get_dist(src,target)
		var/new_firemode = FIRE_MODE_GAUSS
		if(target_range > max_weapon_range) //Our max range is the maximum possible range we can engage in. This is to stop you getting hunted from outside of your view range.
			last_target = null
			return
		var/best_distance = INFINITY //Start off infinitely high, as we have not selected a distance yet.
		var/will_use_shot = FALSE //Will this shot count as depleting "shots left"? Heavy weapons eat ammo, PDCs do not.
		//So! now we pick a weapon.. We start off with PDCs, which have an effective range of "5". On ships with gauss, gauss will be chosen 90% of the time over PDCs, because you can fire off a PDC salvo anyway.
		//Heavy weapons take ammo, stuff like PDC and gauss do NOT for AI ships. We make decisions on the fly as to which gun we get to shoot. If we've run out of ammo, we have to resort to PDCs only.
		for(var/I = FIRE_MODE_PDC; I <= MAX_POSSIBLE_FIREMODE; I++) //We should ALWAYS default to PDCs.
			var/datum/ship_weapon/SW = weapon_types[I]
			if(!SW)
				continue
			var/distance = target_range - SW.range_modifier //How close to the effective range of the given weapon are we?
			if(distance < best_distance)
				if(!SW.valid_target(src, target))
					continue
				if(SW.weapon_class > WEAPON_CLASS_LIGHT)
					if(shots_left <= 0)
						continue //If we are out of shots. Continue.
				var/arc = Get_Angle(src, target)
				if(SW.firing_arc && arc > SW.firing_arc) //So AIs don't fire their railguns into nothing.
					continue
				if(SW.weapon_class > WEAPON_CLASS_LIGHT)
					will_use_shot = TRUE
				else
					will_use_shot = FALSE
				new_firemode = I
				best_distance = distance
		if(!weapon_types[new_firemode]) //I have no physical idea how this even happened, but ok. Sure. If you must. If you REALLY must. We can do this, Sarah. We still gonna do this? It's been 5 years since the divorce, can't you just let go?
			new_firemode = FIRE_MODE_GAUSS
		if(new_firemode != FIRE_MODE_GAUSS && current_system) //If we're not on PDCs, let's fire off some PDC salvos while we're busy shooting people. This is still affected by weapon cooldowns so that they lay off on their target a bit.
			var/datum/ship_weapon/SW = weapon_types[FIRE_MODE_GAUSS]
			if(SW)
				for(var/obj/structure/overmap/ship in current_system.system_contents)
					if(warcrime_blacklist[ship.type])
						continue
					if(!ship || QDELETED(ship) || ship == src || get_dist(src, ship) > max_weapon_range || ship.faction == src.faction || ship.z != z)
						continue
					fire_weapon(ship, FIRE_MODE_GAUSS)
					break
		fire_mode = new_firemode
		if(will_use_shot) //Don't penalise them for weapons that are designed to be spammed.
			shots_left --
		fire_weapon(target, new_firemode)
		next_firetime = world.time + (1 SECONDS) + (fire_delay*2)
		handle_cloak(CLOAK_TEMPORARY_LOSS)
/**
*
*
* Proc override to handle AI ship specific requirements such as spawning a pilot, making it move away, and calling its ai behaviour action.
*
*/

/obj/structure/overmap/proc/ai_process() //For ai ships, this allows for target acquisition, tactics etc.
	set waitfor = FALSE
	handle_autonomous_targeting()
	SSstar_system.update_pos(src)
	if(!ai_controlled)
		return
	if(!z)	//Lets only fully stop processing on AI ships that get to nullspace with their processing still running, to not accidentally fuck up stuff.
		STOP_PROCESSING(SSphysics_processing, src)
		if(physics2d)
			STOP_PROCESSING(SSphysics_processing, physics2d)
		return
	choose_goal()
	if(!pilot) //AI ships need a pilot so that they aren't hit by their own bullets. Projectiles.dm's can_hit needs a mob to be the firer, so here we are.
		pilot = new /mob/living(get_turf(src))
		pilot.overmap_ship = src
		pilot.name = "Dummy AI pilot"
		pilot.mouse_opacity = FALSE
		pilot.alpha = FALSE
		pilot.forceMove(src)
		gunner = pilot
	if(last_target) //Have we got a target?
		var/obj/structure/overmap/OM = last_target
		if(get_dist(last_target, src) > max(max_tracking_range, OM.sensor_profile) || istype(OM) && OM.is_sensor_visible(src) < SENSOR_VISIBILITY_TARGETABLE) //Out of range - Give up the chase
			if(istype(OM) && has_ai_trait(AI_TRAIT_DESTROYER) && OM.z == z)
				patrol_target = get_turf(last_target)	//Destroyers are wary and will actively investigate when their target exits their sensor range. You might be able to use this to your advantage though!
			last_target = null
		else //They're in our tracking range. Let's hunt them down.
			if(get_dist(last_target, src) <= max_weapon_range) //Theyre within weapon range.  Calculate a path to them and fire.
				ai_fire(last_target) //Fire already handles things like being out of range, so we're good
	if(move_mode)
		user_thrust_dir = move_mode
	if(can_resupply)
		if(resupply_target && !QDELETED(resupply_target) && get_dist(src, resupply_target) <= resupply_range)
			new /obj/effect/temp_visual/heal(get_turf(resupply_target))
			return
		var/list/maybe_resupply = current_system.system_contents.Copy()
		shuffle(maybe_resupply)	//Lets not have a fixed resupply list that can cause things to be wonky.
		for(var/obj/structure/overmap/OM in maybe_resupply)
			if(OM.z != z || OM == src || OM.faction != faction || get_dist(src, OM) > resupply_range) //No self healing
				continue
			if(OM.obj_integrity >= OM.max_integrity && OM.shots_left >= initial(OM.shots_left)) //No need to resupply this ship at all.
				continue
			resupply_target = OM
			addtimer(CALLBACK(src, .proc/resupply), 5 SECONDS)	//Resupply comperatively fast, but not instant. Repairs take longer.
			resupplying++
			break
//Method to allow a supply ship to resupply other AIs.

/obj/structure/overmap/proc/resupply()
	resupplying--
	if(!resupply_target || QDELETED(resupply_target) || get_dist(src, resupply_target) > resupply_range)
		resupply_target = null
		return
	var/missileStock = initial(resupply_target.missiles)
	if(missileStock > 0)
		resupply_target.missiles = missileStock
	var/torpStock = initial(resupply_target.torpedoes)
	if(torpStock > 0)
		resupply_target.torpedoes = torpStock
	resupply_target.shots_left = initial(resupply_target.shots_left)
	resupply_target.try_repair(resupply_target.max_integrity  * 0.1)
	resupply_target = null

/obj/structure/overmap/proc/can_board(obj/structure/overmap/ship)
	if(!ship.linked_areas.len)
		return FALSE
	if(get_dist(ship, src) > 8)
		return FALSE
	if(SSphysics_processing.next_boarding_time <= world.time || next_boarding_attempt <= world.time)
		return TRUE
	return FALSE

/obj/structure/overmap/proc/try_board(obj/structure/overmap/ship)
	if(get_dist(ship, src) > 8)
		return FALSE
	next_boarding_attempt = world.time + 5 MINUTES //We very rarely try to board.
	if(SSphysics_processing.next_boarding_time <= world.time)
		SSphysics_processing.next_boarding_time = world.time + 30 MINUTES
		ship.spawn_boarders(null, src.faction)
		return TRUE
	return FALSE

/obj/structure/overmap/proc/add_enemy(atom/target)
	if(!istype(target, /obj/structure/overmap)) //Don't know why it wouldn't be..but yeah
		return
	var/obj/structure/overmap/OM = target
	if(OM.faction == faction)
		return
	last_target = target
	if(ai_can_launch_fighters) //Found a new enemy? Release the hounds
		ai_can_launch_fighters = FALSE
		var/cancelled = FALSE
		if(ai_fighter_type.len)
			for(var/i = 0, i < rand(2,3), i++)
				var/ai_fighter = pick(ai_fighter_type)
				var/turf/launch_turf = get_turf(pick(orange(3, src)))
				if(!launch_turf)
					cancelled = TRUE
					if(!i)
						ai_can_launch_fighters = TRUE
					else
						addtimer(VARSET_CALLBACK(src, ai_can_launch_fighters, TRUE), (1 + i) MINUTES)
					break
				var/obj/structure/overmap/newFighter = new ai_fighter(launch_turf)
				newFighter.last_target = last_target
				if(current_system)
					current_system.system_contents += newFighter
					newFighter.current_system = current_system
				if(fleet)
					newFighter.fleet = fleet
					fleet.taskforces["fighters"] += newFighter //Lets our fighters come back to the mothership to fuel up every so often.
					fleet.all_ships += newFighter
					fleet.RegisterSignal(newFighter, COMSIG_PARENT_QDELETING , /datum/fleet/proc/remove_ship, newFighter)

				relay_to_nearby('nsv13/sound/effects/ship/fighter_launch_short.ogg')
		if(!cancelled)
			addtimer(VARSET_CALLBACK(src, ai_can_launch_fighters, TRUE), 3 MINUTES)
	if(OM in enemies) //If target's in enemies, return
		return
	enemies += target
	if(OM.role == MAIN_OVERMAP)
		if(GLOB.security_level < SEC_LEVEL_RED)	//Lets not pull them out of Zebra / Delta
			set_security_level(SEC_LEVEL_RED) //Action stations when the ship is under attack, if it's the main overmap.
		SSstar_system.last_combat_enter = world.time //Tag the combat on the SS
		SSstar_system.nag_stacks = 0 //Reset overmap spawn modifier
		SSstar_system.nag_interval = initial(SSstar_system.nag_interval)
		SSstar_system.next_nag_time = world.time + SSstar_system.nag_interval
		var/datum/round_event_control/_overmap_event_handler/OEH = locate(/datum/round_event_control/_overmap_event_handler) in SSevents.control
		OEH.weight = 0 //Reset controller weighting
	if(OM.tactical)
		var/sound = pick('nsv13/sound/effects/computer/alarm.ogg','nsv13/sound/effects/computer/alarm_3.ogg','nsv13/sound/effects/computer/alarm_4.ogg')
		var/message = "<span class='warning'>DANGER: [src] is now targeting [OM].</span>"
		OM.tactical.relay_sound(sound, message)
	else
		if(OM.dradis)
			playsound(OM.dradis, 'nsv13/sound/effects/fighters/being_locked.ogg', 100, FALSE)

//Pathfinding...sorta
/obj/structure/overmap/proc/move_toward(atom/target)
	brakes = FALSE
	move_mode = NORTH
	inertial_dampeners = TRUE
	if(!target || QDELETED(target))
		if(defense_target) //Maybe it's defending a ship, it'll still need to find its way home.
			target = defense_target
		else
			return
	desired_angle = Get_Angle(src, target)
	//Raycasting! Should finally give the AI ships their driver's license....
	for(var/turf/T in getline(src, target))
		var/dist = get_dist(get_turf(src), T)
		if(dist >= 8) //ignore collisions this far away, no need to dodge that.
			break
		var/obj/structure/overmap/blocked = null
		//This is...inefficient, but unavoidable without some equally expensive vector math.
		for(var/obj/structure/overmap/OM in current_system.system_contents)
			if(OM == src) //:sigh: this one tripped me up
				continue
			if(get_dist(get_turf(OM), T) <= 5 && OM.mass > MASS_TINY) //Who cares about fighters anyway!
				blocked = OM
				break
		if(blocked) //Time to do some evasive. Determine the object's direction to evade in the opposite direction.
			if(blocked.velocity.x > 0)
				move_mode = EAST //The ship should still drift forward / backwards, but in this case let's not accelerate into an asteroid shall we...
				inertial_dampeners = FALSE
			if(blocked.velocity.x <= 0)
				move_mode = WEST
				inertial_dampeners = FALSE
			return


	//If the AI is going to be blocked in its path, it'll need to dodge very slightly

/obj/structure/overmap/proc/move_away_from(atom/target)
	brakes = FALSE
	move_mode = NORTH
	if(!target || QDELETED(target))
		return
	desired_angle = -Get_Angle(src, target)

//Method that will get you a new target, based on basic params.
/obj/structure/overmap/proc/seek_new_target(max_weight_class=null, min_weight_class=null, interior_check=FALSE, max_distance)
	var/list/shiplist = current_system?.system_contents.Copy()	//We need to Copy() so shuffle doesn't make the global list messier
	if(!shiplist || !shiplist.len)
		return FALSE
	shuffle(shiplist)	//Because we go through this list from first to last, shuffling will make the way we select targets appear more random.
	for(var/obj/structure/overmap/ship in shiplist)
		if(warcrime_blacklist[ship.type])
			continue
		if(!ship || QDELETED(ship) || ship == src || get_dist(src, ship) > max(max_tracking_range, ship.sensor_profile) || ship.faction == faction || ship.z != z || ship.is_sensor_visible(src) < SENSOR_VISIBILITY_TARGETABLE)
			continue
		if(max_distance && get_dist(src, ship) > max_distance)
			continue
		if(max_weight_class && ship.mass > max_weight_class)
			continue
		if(min_weight_class && ship.mass < min_weight_class)
			continue
		if(interior_check && !ship.linked_areas.len) //So that boarders don't waste their time and try commit to boarding other AIs...yet.
			continue
		add_enemy(ship)
		last_target = ship
		return TRUE
	return FALSE

/client/proc/system_manager() //Creates a verb for admins to open up the ui
	set name = "Starsystem Management"
	set desc = "Manage fleets / systems that exist in game"
	set category = "Adminbus"
	var/datum/starsystem_manager/man = new(usr)//create the datum
	man.ui_interact(usr)//datum has a tgui component, here we open the window

/datum/starsystem_manager
	var/name = "Starsystem manager"
	var/client/holder = null

/datum/starsystem_manager/New(H)//H can either be a client or a mob due to byondcode(tm)
	if (istype(H,/client))
		var/client/C = H
		holder = C //if its a client, assign it to holder
	else
		var/mob/M = H
		holder = M.client //if its a mob, assign the mob's client to holder
	. = ..()

/datum/starsystem_manager/ui_state(mob/user)
        return GLOB.admin_state

/datum/starsystem_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SystemManager")
		ui.open()

/datum/starsystem_manager/ui_data(mob/user)
	var/list/data = list()
	var/list/systems_info = list()
	for(var/datum/star_system/SS in SSstar_system.systems)
		var/list/sys_inf = list()
		sys_inf["name"] = SS.name
		sys_inf["system_type"] = SS.system_type
		sys_inf["alignment"] = capitalize(SS.alignment)
		sys_inf["sys_id"] = "\ref[SS]"
		sys_inf["fleets"] = list() //2d array mess in 3...2...1..
		for(var/datum/fleet/F in SS.fleets)
			var/list/fleet_info = list()
			fleet_info["name"] = F.name
			fleet_info["id"] = "\ref[F]"
			fleet_info["colour"] = (F.alignment == "nanotrasen") ? null : "bad"
			var/list/fuckYouDreamChecker = sys_inf["fleets"]
			fuckYouDreamChecker[++fuckYouDreamChecker.len] = fleet_info
		systems_info[++systems_info.len] = sys_inf
	data["systems_info"] = systems_info
	return data

/datum/starsystem_manager/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("jumpFleet")
			var/datum/fleet/target = locate(params["id"])
			if(!istype(target))
				return
			var/datum/star_system/sys = input(usr, "Select a jump target for [target]...","Fleet Management", null) as null|anything in SSstar_system.systems
			if(!sys || !istype(sys))
				return FALSE
			message_admins("[key_name(usr)] forced [target] to jump to [sys].")
			target.move(sys, TRUE)
		if("createFleet")
			var/datum/star_system/target = locate(params["sys_id"])
			if(!istype(target))
				return
			var/fleet_type = input(usr, "What fleet template would you like to use?","Fleet Creation", null) as null|anything in typecacheof(/datum/fleet)
			if(!fleet_type)
				return
			var/datum/fleet/F = new fleet_type()
			target.fleets += F
			F.current_system = target
			F.assemble(target)
			message_admins("[key_name(usr)] created a fleet ([F.name]) at [target].")


/client/proc/instance_overmap_menu() //Creates a verb for admins to open up the ui
	set name = "Instance Overmap"
	set desc = "Load a ship midround."
	set category = "Adminbus"

	if(IsAdminAdvancedProcCall())
		return FALSE

	var/list/choices = flist("_maps/map_files/Instanced/")
	var/ship_file = input(usr, "What ship would you like to load?","Ship Instancing", null) as null|anything in choices
	if(!ship_file)
		return
	if(instance_ship_from_json(ship_file))
		message_admins("[key_name(src)] has instanced a copy of [ship_file]!")
	else
		message_admins("Failed to instance a copy of [ship_file]!")

/proc/instance_ship_from_json(ship_file)
	if(!ship_file)
		message_admins("Error loading ship, null file passed in.")
		return
	if(!isfile(ship_file))
		message_admins("Error loading ship from JSON. Check that the file exists.")
		return
	var/list/json = json_decode(file2text(ship_file))
	if(!json)
		return
	var/shipName = json["map_name"]
	var/shipType = text2path(json["ship_type"])
	var/mapPath = json["map_path"]
	var/mapFile = json["map_file"]
	var/list/traits = json["traits"]
	if (istext(mapFile))
		if (!fexists("_maps/[mapPath]/[mapFile]"))
			log_world("Map file ([mapPath]/[mapFile]) does not exist!")
			return
	else if (islist(mapFile))
		for (var/file in mapFile)
			if (!fexists("_maps/[mapPath]/[file]"))
				log_world("Map file ([mapPath]/[file]) does not exist!")
				return
	var/obj/structure/overmap/OM = instance_overmap(shipType, mapPath, mapFile, traits, ZTRAITS_BOARDABLE_SHIP, TRUE)
	if(OM)
		OM.name = shipName
	return OM
