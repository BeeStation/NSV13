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
Current task hierarchy (as of 28/06/2020)!
1: Repair and re-arm. If a ship becomes critically damaged, or runs out of bullets, it will rush to a supply ship to resupply (if available), and heal up.
2: (if you're a battleship): Defend the supply lines. Battleships stick close to the supply ships and keep them safe.
3: Search and destroy: Attempt to find a target that's visible and within tracking range.
4: (All ships) Defend the supply lines: If AIs cannot find a suitable target, they'll flock back to the main fleet and protect the tankers. More nimble attack squadrons will blade off in wings and attack the enemy if they get too close, with the battleships staying behind to protect their charges.
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
#define FLEET_DIFFICULTY_MEDIUM 4
#define FLEET_DIFFICULTY_HARD 8
#define FLEET_DIFFICULTY_VERY_HARD 15
#define FLEET_DIFFICULTY_INSANE 20 //If you try to take on the rubicon ;)
#define FLEET_DIFFICULTY_DEATH 30 //Suicide run

#define AI_TRAIT_SUPPLY 1
#define AI_TRAIT_BATTLESHIP 2
#define AI_TRAIT_DESTROYER 3
#define AI_TRAIT_ANTI_FIGHTER 4
#define AI_TRAIT_BOARDER 5 //Ships that like to board you.

//Fleet behaviour. Border patrol fleets will stick to patrolling their home space only. Invasion fleets ignore home space and fly around.
#define FLEET_TRAIT_BORDER_PATROL 1
#define FLEET_TRAIT_INVASION 2
#define FLEET_TRAIT_NEUTRAL_ZONE 3
#define FLEET_TRAIT_DEFENSE 4

GLOBAL_LIST_EMPTY(ai_goals)

/datum/fleet
	var/name = "Syndicate Invasion Fleet"//Todo: randomize this name
	//Ai fleet type enum. Add your new one here. Use a define, or text if youre lazy.
	var/list/taskforces = list("fighters" = list(), "destroyers" = list(), "battleships" = list(), "supply" = list())
	var/list/fighter_types = list(/obj/structure/overmap/syndicate/ai/fighter)
	var/list/destroyer_types = list(/obj/structure/overmap/syndicate/ai, /obj/structure/overmap/syndicate/ai/assault_cruiser, /obj/structure/overmap/syndicate/ai/gunboat, /obj/structure/overmap/syndicate/ai/submarine, /obj/structure/overmap/syndicate/ai/assault_cruiser/boarding_frigate)
	var/list/battleship_types = list(/obj/structure/overmap/syndicate/ai/patrol_cruiser) //TODO: Implement above list for more ship variety.
	var/list/supply_types = list(/obj/structure/overmap/syndicate/ai/carrier)
	var/list/all_ships = list()
	var/size = FLEET_DIFFICULTY_MEDIUM //How big is this fleet anyway?
	var/list/audio_cues = list() //Does this fight come with a theme tune? Takes youtube / media links so that we don't have to store a bunch of copyrighted music on the box.
	var/instantiated = FALSE //If we're not instantiated, moving all the ships is a piece of cake, if we are however, we do some extra steps to FTL them all.
	var/datum/star_system/current_system = null //Where are we?
	var/datum/star_system/goal_system = null //Where are we looking to go?
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
	if(!target)
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
		target = pick(potential)
	if(!force)
		addtimer(CALLBACK(src, .proc/move), rand(5 MINUTES, 10 MINUTES))
		//Precondition: We're allowed to go to this system.
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

		if(world.time < last_encounter_time + 10 MINUTES) //So that fleets don't leave mid combat.
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
				OM.moveToNullspace()
				target.contents_positions[OM] = list("x" = OM.x, "y" = OM.y) //Cache the ship's position so we can regenerate it later.
			else
				OM.forceMove(get_turf(locate(OM.x, OM.y, target.occupying_z)))
			current_system.system_contents -= OM
			target.system_contents += OM
			if(alignment != "nanotrasen" && alignment != "solgov") //NT, SGC or whatever don't count as enemies that NT hire you to kill.
				current_system.enemies_in_system -= OM
				target.enemies_in_system += OM
			if(current_system.contents_positions[OM]) //If we were loaded, but the system was not.
				current_system.contents_positions -= OM
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

//Clear a ship from this fleet.
/datum/fleet/proc/remove_ship(obj/structure/overmap/OM)
	all_ships -= OM
	last_encounter_time = world.time
	for(var/list/L in taskforces)
		for(var/obj/structure/overmap/OOM in L)
			if(OM == OOM) //I'm gonna OOM
				L -= OOM
				break
	if(!all_ships.len) //We've been defeated!
		defeat()

/datum/fleet/proc/defeat()
	minor_announce("[name] has been defeated in battle", "White Rapids Fleet Command")
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
	faction = SSstar_system.faction_by_id(faction_id)
	faction?.lose_influence(reward)
	for(var/obj/structure/overmap/OOM in current_system.system_contents)
		if(!OOM.mobs_in_ship.len)
			continue
		for(var/mob/M in OOM.mobs_in_ship)
			if(M.client)
				var/client/C = M.client
				if(C.chatOutput && !C.chatOutput.broken && C.chatOutput.loaded)
					C.chatOutput.stopMusic()
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
			var/list/result = get_internet_sound(pick(audio_cues))
			if(!result || !islist(result))
				return
			var/web_sound_url = result[1] //this is cringe but it works
			var/music_extra_data = result[2]
			if(web_sound_url)
				for(var/mob/M in OM.mobs_in_ship)
					if(M.client)
						var/client/C = M.client
						if(C.chatOutput && !C.chatOutput.broken && C.chatOutput.loaded)
							C.chatOutput.stopMusic()
							C.chatOutput.sendMusic(web_sound_url, music_extra_data)

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
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/nuclear)
	size = 2
	fleet_trait = FLEET_TRAIT_NEUTRAL_ZONE

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

//Boss battles.

/datum/fleet/rubicon //Crossing the rubicon, are we?
	name = "Rubicon Crossing"
	size = FLEET_DIFFICULTY_HARD
	audio_cues = list("https://www.youtube.com/watch?v=mhXuYp0n88g", "https://www.youtube.com/watch?v=l1J-2nIovYw", "https://www.youtube.com/watch?v=M_MdmLWmDHs")
	taunts = list("Better crews have tried to cross the Rubicon, you will die like they did.", "Defense force, stand ready!", "Nanotrasen filth. Munitions, ready the guns. We’ll scrub the galaxy clean of you vermin.", "This shift just gets better and better. I’ll have your Captain’s head on my wall.")
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/pirate
	name = "Pirate scout fleet"
	audio_cues = list("https://www.youtube.com/watch?v=WMSoo4B2hFU", "https://www.youtube.com/watch?v=dsLHf9X8P8w")
	taunts = list("Yar har! Fresh meat", "Unfurl the mainsails! We've got company", "Die landlubbers!")
	size = FLEET_DIFFICULTY_MEDIUM
	fleet_trait = FLEET_TRAIT_DEFENSE
	faction_id = FACTION_ID_PIRATES

/datum/fleet/nanotrasen/earth
	name = "Earth Defense Force"
	taunts = list("You're foolish to venture this deep into Solgov space! Main batteries stand ready.", "All hands, set condition 1 throughout the fleet, enemy vessel approaching.", "Defense force, stand ready!", "We shall protect our homeland!")
	size = FLEET_DIFFICULTY_HARD
	audio_cues = list("https://www.youtube.com/watch?v=k8-HHivlj8k")
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/earthbuster
	name = "Syndicate Armada" //Fleet spawned if the players are too inactive. Set course...FOR EARTH.
	destroyer_types = list(/obj/structure/overmap/syndicate/ai, /obj/structure/overmap/syndicate/ai/nuclear, /obj/structure/overmap/syndicate/ai/assault_cruiser, /obj/structure/overmap/syndicate/ai/gunboat, /obj/structure/overmap/syndicate/ai/submarine, /obj/structure/overmap/syndicate/ai/assault_cruiser/boarding_frigate)
	size = FLEET_DIFFICULTY_VERY_HARD
	taunts = list("We're coming for Sol, and you can't stop us. All batteries fire at will.", "Lay down your arms now, you're outnumbered.", "All hands, assume assault formation. Begin bombardment.")
	audio_cues = list("https://www.youtube.com/watch?v=k8-HHivlj8k")

/datum/fleet/dolos
	name = "Dolos Welcoming Party" //Don't do it czanek, don't fucking do it!
	size = FLEET_DIFFICULTY_INSANE
	audio_cues = list("https://www.youtube.com/watch?v=UPHmazxB38g") //FTL13 ;(
	taunts = list("You shouldn't have come here...", "Prepare to die.", "Nanotrasen? Here? Bold.")
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/abassi
	name = "1st Syndicate Defense Force" //Don't do it czanek, don't fucking do it!
	size = FLEET_DIFFICULTY_DEATH
	audio_cues = list("https://www.youtube.com/watch?v=3tAShpPu6K0")
	taunts = list("Your existence has come to an end.", "You should be glad you made it this far, but you'll come no further.")
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/unknown_ship
	name = "Unknown Ship Class"
	size = 1
	battleship_types = list(/obj/structure/overmap/syndicate/ai/battleship)
	audio_cues = list("https://www.youtube.com/watch?v=zyPSAkz84vM")
	taunts = list("Your assault on Rubicon only served to distract you from the real threat. It's time to end this war in one swift blow.")
	fleet_trait = FLEET_TRAIT_DEFENSE

//Nanotrasen fleets

/datum/fleet/nanotrasen
	name = "Nanotrasen heavy combat fleet"
	fighter_types = list(/obj/structure/overmap/nanotrasen/ai/fighter)
	destroyer_types = list(/obj/structure/overmap/nanotrasen/ai)
	battleship_types = list(/obj/structure/overmap/nanotrasen/patrol_cruiser/ai, /obj/structure/overmap/nanotrasen/heavy_cruiser/ai, /obj/structure/overmap/nanotrasen/battleship/ai, /obj/structure/overmap/nanotrasen/battlecruiser/ai)
	supply_types = list(/obj/structure/overmap/nanotrasen/carrier/ai)
	alignment = "nanotrasen"
	hide_movements = TRUE //Friendly fleets just move around as you'd expect.
	faction_id = FACTION_ID_NT
	taunts = list("Syndicate vessel, stand down or be destroyed", "You are encroaching on our airspace, prepare to be destroyed", "Unidentified vessel, your existence will be forfeit in accordance with the peacekeeper act.")

/datum/fleet/nanotrasen/light
	name = "Nanotrasen light fleet"
	battleship_types = list(/obj/structure/overmap/nanotrasen/patrol_cruiser/ai)

/datum/fleet/New()
	. = ..()
	if(current_system)
		assemble(current_system)
	addtimer(CALLBACK(src, .proc/move), 10 MINUTES)

//A ship has entered a system with a fleet present. Assemble the fleet so that it lives in this system now.

/datum/fleet/proc/assemble(datum/star_system/SS, difficulty=size)
	if(!SS)
		return
	SS.alignment = alignment
	if(!SS.occupying_z) //Only loaded in levels are supported at this time. TODO: Fix this.
		return FALSE
	faction = SSstar_system.faction_by_id(faction_id)
	instantiated = TRUE
	current_system = SS
	reward *= size //Bigger fleet = larger reward
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
			SS.add_ship(member)
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
			SS.add_ship(member)
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
			SS.add_ship(member)
		}
	return TRUE

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
			for(var/X in OM.ai_trait)
				if(X == required_trait)
					break
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
	if(!OM.fleet) //If this is a rogue / lone AI. This should be their only objective.
		return AI_SCORE_MAXIMUM
	if(!..()) //If it's not an overmap, or it's not linked to a fleet.
		return 0
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
		OM.seek_new_target()
		OM.move_toward(null) //Just fly around in a straight line, I guess.

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
	if(!OM.defense_target || QDELETED(OM.defense_target))
		OM.defense_target = OM.fleet.taskforces["supply"] ? pick(OM.fleet.taskforces["supply"]) : OM
	OM.move_mode = NORTH
	if(get_dist(OM, OM.defense_target) <= AI_PDC_RANGE)
		OM.brakes = TRUE
		OM.move_mode = null
		OM.desired_angle = OM.defense_target.angle //Turn and face boys!
	else
		OM.brakes = FALSE
		OM.desired_angle = Get_Angle(OM, OM.defense_target)

//Battleships love to stick to supply ships like glue. This becomes the default behaviour if the AIs cannot find any targets.
/datum/ai_goal/defend/check_score(obj/structure/overmap/OM)
	if(!..() || !OM.fleet) //If it's not an overmap, or it's not linked to a fleet.
		return score
	if(OM.ai_trait == AI_TRAIT_BATTLESHIP)
		var/list/L = OM.fleet.taskforces["supply"]
		return (L.len ? AI_SCORE_CRITICAL : AI_SCORE_LOW_PRIORITY)
	return score //If you've got nothing better to do, come group with the main fleet.

//Goal used entirely for supply ships, signalling them to run away! Most ships use the "repair and re-arm" goal instead of this one.
/datum/ai_goal/retreat
	name = "Maintain safe distance from enemies"

//Supply ships are timid, and will always try to run.
/datum/ai_goal/retreat/check_score(obj/structure/overmap/OM)
	if(!..() || !OM.fleet) //If it's not an overmap, or it's not linked to a fleet.
		return 0
	if(OM.ai_trait == AI_TRAIT_SUPPLY)
		return AI_SCORE_CRITICAL
	return 0

//Supply ships are sheepish, and like to run away. Otherwise, they just act as a stationary FOB.

/datum/ai_goal/retreat/action(obj/structure/overmap/OM)
	..()
	OM.brakes = TRUE
	var/obj/structure/overmap/foo = OM.last_target
	if(!foo || !istype(foo) || get_dist(OM, foo) > foo.max_weapon_range) //You can run on for a long time, run on for a long time, run on for a long time, sooner or later gonna cut you down
		return //Just drift aimlessly, let the fleet form up with it.
	OM.move_mode = NORTH
	OM.brakes = FALSE
	OM.desired_angle = -Get_Angle(OM, OM.last_target) //Turn the opposite direction and run.

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
	var/max_weapon_range = 30
	var/max_tracking_range = 300//115 //Range that AI ships can hunt you down in. The amounts to almost half the Z-level.
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
	var/can_resupply = FALSE //Can this ship resupply other ships?
	var/obj/structure/overmap/resupply_target = null
	var/datum/fleet/fleet = null
	var/datum/ai_goal/current_goal = null
	var/obj/structure/overmap/squad_lead = null
	var/obj/structure/last_overmap = null
	var/switchsound_cooldown = 0

/obj/structure/overmap/proc/ai_fire(atom/target)
	if(next_firetime > world.time)
		return
	if(istype(target, /obj/structure/overmap))
		add_enemy(target)
		var/target_range = get_dist(src,target)
		var/new_firemode = FIRE_MODE_PDC
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
					will_use_shot = TRUE
				var/arc = Get_Angle(src, target)
				if(SW.firing_arc && arc > SW.firing_arc) //So AIs don't fire their railguns into nothing.
					continue
				new_firemode = I
				best_distance = distance
		if(!weapon_types[new_firemode]) //I have no physical idea how this even happened, but ok. Sure. If you must. If you REALLY must. We can do this, Sarah. We still gonna do this? It's been 5 years since the divorce, can't you just let go?
			new_firemode = FIRE_MODE_PDC
		if(new_firemode != FIRE_MODE_PDC) //If we're not on PDCs, let's fire off some PDC salvos while we're busy shooting people. This is still affected by weapon cooldowns so that they lay off on their target a bit.
			for(var/obj/structure/overmap/ship in GLOB.overmap_objects)
				if(warcrime_blacklist[ship.type])
					continue
				if(!ship || QDELETED(ship) || ship == src || get_dist(src, ship) > max_weapon_range || ship.faction == src.faction || ship.z != z)
					continue
				fire_weapon(ship, FIRE_MODE_PDC)
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

/obj/structure/overmap/proc/slowprocess() //For ai ships, this allows for target acquisition, tactics etc.
	handle_pdcs()
	SSstar_system.update_pos(src)
	if(!ai_controlled)
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
		if(get_dist(last_target, src) > max_tracking_range || istype(OM) && OM.is_sensor_visible(src) < SENSOR_VISIBILITY_TARGETABLE) //Out of range - Give up the chase
			last_target = null
		else //They're in our tracking range. Let's hunt them down.
			if(get_dist(last_target, src) <= max_weapon_range) //Theyre within weapon range.  Calculate a path to them and fire.
				ai_fire(last_target) //Fire already handles things like being out of range, so we're good
	if(move_mode)
		user_thrust_dir = move_mode
	if(can_resupply)
		if(resupply_target && get_dist(src, resupply_target) <= resupply_range)
			new /obj/effect/temp_visual/heal(get_turf(resupply_target))
			return
		for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
			if(OM.z != z || OM == src || OM.faction != faction || get_dist(src, OM) > resupply_range) //No self healing
				continue
			if(OM.obj_integrity >= OM.max_integrity && OM.shots_left >= initial(OM.shots_left)) //No need to resupply this ship at all.
				continue
			resupply_target = OM
			addtimer(CALLBACK(src, .proc/resupply), 30 SECONDS)
			break
//Method to allow a supply ship to resupply other AIs.

/obj/structure/overmap/Destroy()
	if(fleet)
		for(var/list/L in fleet.taskforces) //Clean out the null refs.
			for(var/obj/structure/overmap/OM in L)
				if(OM == src)
					L -= src
	. = ..()

/obj/structure/overmap/proc/resupply()
	if(!resupply_target || get_dist(src, resupply_target) > resupply_range)
		return
	var/missileStock = initial(resupply_target.missiles)
	if(missileStock > 0)
		resupply_target.missiles = missileStock
	var/torpStock = initial(resupply_target.torpedoes)
	if(torpStock > 0)
		resupply_target.torpedoes = torpStock
	resupply_target.shots_left = initial(resupply_target.shots_left)
	resupply_target.obj_integrity = resupply_target.max_integrity
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
		ship.spawn_boarders()
		return TRUE
	return FALSE

/obj/structure/overmap/proc/add_enemy(atom/target)
	if(!istype(target, /obj/structure/overmap)) //Don't know why it wouldn't be..but yeah
		return
	var/obj/structure/overmap/OM = target
	if(OM.faction == src.faction)
		return
	last_target = target
	if(ai_can_launch_fighters) //Found a new enemy? Release the hounds
		ai_can_launch_fighters = FALSE
		if(ai_fighter_type.len)
			for(var/i = 0, i < rand(2,3), i++)
				var/ai_fighter = pick(ai_fighter_type)
				var/obj/structure/overmap/newFighter = new ai_fighter(get_turf(pick(orange(3, src))))
				newFighter.last_target = last_target
				current_system?.system_contents += newFighter
				if(fleet)
					newFighter.fleet = fleet
					fleet.taskforces["fighters"] += newFighter //Lets our fighters come back to the mothership to fuel up every so often.
					fleet.all_ships += newFighter
					fleet.RegisterSignal(newFighter, COMSIG_PARENT_QDELETING , /datum/fleet/proc/remove_ship, newFighter)

				relay_to_nearby('nsv13/sound/effects/ship/fighter_launch_short.ogg')
		addtimer(VARSET_CALLBACK(src, ai_can_launch_fighters, TRUE), 3 MINUTES)
	if(OM in enemies) //If target's in enemies, return
		return
	enemies += target
	if(OM.role == MAIN_OVERMAP)
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
		for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
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
/obj/structure/overmap/proc/seek_new_target(max_weight_class=null, min_weight_class=null, interior_check=FALSE)
	for(var/obj/structure/overmap/ship in GLOB.overmap_objects)
		if(warcrime_blacklist[ship.type])
			continue
		if(!ship || QDELETED(ship) || ship == src || get_dist(src, ship) > max_tracking_range || ship.faction == faction || ship.z != z || ship.is_sensor_visible(src) < SENSOR_VISIBILITY_TARGETABLE)
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

/datum/starsystem_manager/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)//ui_interact is called when the client verb is called.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SystemManager", "Starsystem Manager", 400, 400, master_ui, state)
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
	ship_file = file("_maps/map_files/Instanced/[ship_file]")
	if(!isfile(ship_file))
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
		message_admins("[key_name(src)] has instanced a copy of [ship_file].")
		OM.name = shipName
