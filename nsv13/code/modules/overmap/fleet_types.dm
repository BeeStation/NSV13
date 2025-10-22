
//Syndicate Fleets

/datum/fleet/neutral //The values here are the same as the default, copied for easier reference. This fleet is specifically one that flies in the neutral zone
	name = "\improper Syndicate scout fleet"
	fighter_types = list(/obj/structure/overmap/syndicate/ai/fighter, /obj/structure/overmap/syndicate/ai/bomber)
	destroyer_types = list(/obj/structure/overmap/syndicate/ai, /obj/structure/overmap/syndicate/ai/destroyer, /obj/structure/overmap/syndicate/ai/destroyer/flak, /obj/structure/overmap/syndicate/ai/mako_flak, /obj/structure/overmap/syndicate/ai/mako_carrier)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/cruiser, /obj/structure/overmap/syndicate/ai/assault_cruiser)
	supply_types = list(/obj/structure/overmap/syndicate/ai/carrier)
	fleet_trait = FLEET_TRAIT_NEUTRAL_ZONE

/datum/fleet/border
	name = "\improper Syndicate border defense force"
	supply_types = list(/obj/structure/overmap/syndicate/ai/carrier, /obj/structure/overmap/syndicate/ai/carrier/elite)
	fleet_trait = FLEET_TRAIT_BORDER_PATROL
	hide_movements = TRUE
	size = FLEET_DIFFICULTY_HARD //Border patrol is stronger

/datum/fleet/light_defense
	name = "\improper Syndicate defense fleet"
	fleet_trait = FLEET_TRAIT_DEFENSE //Fleet meant for general system defense, nothing major

/datum/fleet/boarding
	name = "\improper Syndicate commando taskforce"
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/assault_cruiser/boarding_frigate)
	taunts = list("Attention: This is an automated message. All non-Syndicate vessels prepare to be boarded for security clearance.")
	fleet_trait = FLEET_TRAIT_NEUTRAL_ZONE

/datum/fleet/wolfpack
	name = "\improper unidentified Syndicate fleet"
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/submarine)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/cruiser, /obj/structure/overmap/syndicate/ai/cruiser/elite, /obj/structure/overmap/syndicate/ai/mako_flak, /obj/structure/overmap/syndicate/ai/destroyer, /obj/structure/overmap/syndicate/ai/submarine/elite)
	audio_cues = list()
	hide_movements = TRUE
	taunts = list("....", "*static*")
	fleet_trait = FLEET_TRAIT_NEUTRAL_ZONE

/datum/fleet/wolfpack/elite
	name = "\improper unidentified Syndicate taskforce"
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/submarine, /obj/structure/overmap/syndicate/ai/submarine/elite)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/submarine/elite, /obj/structure/overmap/syndicate/ai/cruiser/elite)
	taunts = list(".....", "*loud microphone feedback*", "You've got nowhere to run, and nowhere to hide...")

/datum/fleet/conflagration
	name = "\improper Syndicate conflagration deterrent"
	taunts = list("Enemy ship, surrender now. This vessel is armed with hellfire weapons and eager to test them.")
	audio_cues = list()
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/conflagration, /obj/structure/overmap/syndicate/ai/conflagration/elite)
	size = FLEET_DIFFICULTY_EASY
	fleet_trait = FLEET_TRAIT_NEUTRAL_ZONE

/datum/fleet/elite
	name = "\improper elite Syndicate taskforce"
	taunts = list("Enemy ship, surrender immediately or face destruction.", "Excellent, a worthwhile target. Arm all batteries.")
	supply_types = list(/obj/structure/overmap/syndicate/ai/carrier/elite)
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/destroyer/elite, /obj/structure/overmap/syndicate/ai/submarine/elite)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/cruiser/elite)

//Space Pirate Fleets
/datum/fleet/pirate
	name = "\proper Tortuga Raiders Fleet"
	fighter_types = null
	destroyer_types = list(/obj/structure/overmap/spacepirate/ai)
	battleship_types = list(/obj/structure/overmap/spacepirate/ai/nt_missile, /obj/structure/overmap/spacepirate/ai/syndie_gunboat)
	default_ghost_ship = /obj/structure/overmap/spacepirate/ai
	supply_types = null
	alignment = "pirate"
	faction_id = FACTION_ID_PIRATES
	reward = 35

/datum/fleet/pirate/scout
	name = "\improper Tortuga Raiders scout fleet"
	audio_cues = list()
	taunts = list("Yar har! Fresh meat", "Unfurl the mainsails! We've got company", "Die landlubbers!")
	size = FLEET_DIFFICULTY_MEDIUM
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/pirate/raiding
	name = "\improper Tortuga Raiders raiding fleet"
	destroyer_types = list(/obj/structure/overmap/spacepirate/ai, /obj/structure/overmap/spacepirate/ai/boarding)
	audio_cues = list()
	taunts = list("Avast! A fine hold of loot sails our way", "Prepare the boarding crews, they've got enough loot for us all!")
	size = FLEET_DIFFICULTY_MEDIUM

/datum/fleet/pirate/tortuga
	name = "\improper Tortuga Raiders holding fleet"
	supply_types = list(/obj/structure/overmap/spacepirate/ai/dreadnought)
	audio_cues = list(/datum/soundtrack_song/bee/hierophant)
	taunts = list("These are our waters you are sailing, prepare to surrender!", "Bold of you to fly Nanotrasen colours in this system, your last mistake.")
	size = FLEET_DIFFICULTY_VERY_HARD
	fleet_trait = FLEET_TRAIT_DEFENSE
	reward = 200

/datum/fleet/pirate/tortuga/defeat()
	if(!current_system)
		return ..()
	for(var/obj/structure/overmap/survivor in current_system.system_contents)
		if(survivor.ai_controlled)
			continue
		for(var/mob/living/victorious_mob in survivor.mobs_in_ship)
			if(!victorious_mob.client)
				continue
			victorious_mob.client.give_award(/datum/award/achievement/misc/pirate_exterminator, victorious_mob)
	return ..()


//Boss battles.

/datum/fleet/rubicon //Crossing the rubicon, are we?
	name = "\proper Rubicon Crossing"
	size = FLEET_DIFFICULTY_VERY_HARD
	allow_difficulty_scaling = FALSE
	battleship_types = list(/obj/structure/overmap/syndicate/ai/kadesh)	//:)
	audio_cues = list()
	taunts = list("Better crews have tried to cross the Rubicon, you will die like they did.", "Defense force, stand ready!", "Nanotrasen filth. Munitions, ready the guns. We’ll scrub the galaxy clean of you vermin.", "This shift just gets better and better. I’ll have your Captain’s head on my wall.")
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/earthbuster
	name = "\proper Syndicate Armada" //Fleet spawned if the players are too inactive. Set course...FOR EARTH.
	destroyer_types = list(/obj/structure/overmap/syndicate/ai, /obj/structure/overmap/syndicate/ai/conflagration, /obj/structure/overmap/syndicate/ai/assault_cruiser, /obj/structure/overmap/syndicate/ai/gunboat, /obj/structure/overmap/syndicate/ai/submarine, /obj/structure/overmap/syndicate/ai/assault_cruiser/boarding_frigate)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/battleship) //The fist of sol is leading the charge
	size = FLEET_DIFFICULTY_INSANE
	allow_difficulty_scaling = FALSE
	taunts = list("We're coming for Sol, and you can't stop us. All batteries fire at will.", "Lay down your arms now, you're outnumbered.", "All hands, assume assault formation. Begin bombardment.")
	audio_cues = list(/datum/soundtrack_song/bee/countdown)

/datum/fleet/interdiction	//Pretty strong fleet with unerring hunting senses, Adminspawn for now.
	name = "\improper Syndicate interdiction fleet"	//These fun guys can and will hunt the player ship down, no matter how far away they are.
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/conflagration, /obj/structure/overmap/syndicate/ai/assault_cruiser, /obj/structure/overmap/syndicate/ai/assault_cruiser/boarding_frigate)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/kadesh)
	size = FLEET_DIFFICULTY_HARD
	taunts = list("We have come to end your meagre existance. Prepare to die.", "Hostile entering weapons range. Fire at will.", "You have been a thorn in our side for quite a while. Time to end this.", "That is a nice ship you have there. Nothing a few hellfire missiles cannot fix.")
	audio_cues = list()
	var/obj/structure/overmap/hunted_ship
	initial_move_delay = 5 MINUTES
	minimum_random_move_delay = 2 MINUTES	//These are quite a bunch faster than your usual fleets. Good luck running. It won't save you.
	maximum_random_move_delay = 4 MINUTES
	combat_move_delay = 6 MINUTES

/datum/fleet/interdiction/stealth	//More fun for badmins
	name = "\improper unidentified Syndicate heavy fleet"
	hide_movements = TRUE
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/submarine, /obj/structure/overmap/syndicate/ai/conflagration, /obj/structure/overmap/syndicate/ai/assault_cruiser)

/datum/fleet/interdiction/light	//The syndicate can spawn these randomly (though rare). Be caareful! But, at least they aren't that scary.
	name = "\improper Syndicate light interdiction fleet"
	battleship_types = list(/obj/structure/overmap/syndicate/ai/cruiser)
	size = FLEET_DIFFICULTY_MEDIUM	//Don't let this fool you though, they are still somewhat dangerous and will hunt you down.
	initial_move_delay = 12 MINUTES

/datum/fleet/dolos
	name = "\proper Dolos Welcoming Party" //Don't do it czanek, don't fucking do it!
	size = FLEET_DIFFICULTY_WHAT_ARE_YOU_DOING
	allow_difficulty_scaling = FALSE
	audio_cues = list(/datum/soundtrack_song/bee/future_perception)
	taunts = list("Don't think we didn't learn from your last attempt.", "We shall not fail again", "Your outdated MAC weapons are no match for us. Prepare to be destroyed.")
	fleet_trait = FLEET_TRAIT_DEFENSE
	destroyer_types = list(/obj/structure/overmap/syndicate/ai, /obj/structure/overmap/syndicate/ai/destroyer/elite, /obj/structure/overmap/syndicate/ai/destroyer/flak, /obj/structure/overmap/syndicate/ai/cruiser/elite, /obj/structure/overmap/syndicate/ai/mako_flak, /obj/structure/overmap/syndicate/ai/mako_carrier)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/cruiser/elite, /obj/structure/overmap/syndicate/ai/conflagration/elite)
	supply_types = list(/obj/structure/overmap/syndicate/ai/carrier/elite)

/datum/fleet/remnant
	name = "\proper The Remnant"
	size = FLEET_DIFFICULTY_WHAT_ARE_YOU_DOING
	allow_difficulty_scaling = FALSE
	audio_cues = list(/datum/soundtrack_song/bee/finale)
	taunts = list("<pre>\[DECRYPTION FAILURE]</pre>")
	fleet_trait = FLEET_TRAIT_DEFENSE
	destroyer_types = list(/obj/structure/overmap/syndicate/ai, /obj/structure/overmap/syndicate/ai/destroyer/elite, /obj/structure/overmap/syndicate/ai/destroyer/flak, /obj/structure/overmap/syndicate/ai/cruiser/elite, /obj/structure/overmap/syndicate/ai/mako_flak, /obj/structure/overmap/syndicate/ai/mako_carrier)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/cruiser/elite, /obj/structure/overmap/syndicate/ai/conflagration/elite)
	supply_types = list(/obj/structure/overmap/syndicate/ai/carrier/elite)

/datum/fleet/unknown_ship
	name = "\improper unknown Syndicate ship class"
	size = 1
	allow_difficulty_scaling = FALSE
	battleship_types = list(/obj/structure/overmap/syndicate/ai/battleship)
	audio_cues = list(/datum/soundtrack_song/bee/finale)
	taunts = list("Your assault on Rubicon only served to distract you from the real threat. It's time to end this war in one swift blow.")
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/syndicate/fistofsol_boss
	name = "SSV Fist of Sol"
	faction = FACTION_ID_SYNDICATE
	size = 1
	allow_difficulty_scaling = FALSE
	audio_cues = list(/datum/soundtrack_song/bee/countdownext)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/fistofsol)
	supply_types = list(/obj/structure/overmap/syndicate/ai/carrier/elite)
	taunts = list("What a pleasure that we should meet again. I hope you won't disappoint!")
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/hostile/alicorn_boss
	name = "\proper SGV Alicorn"
	size = 1
	hide_movements = TRUE
	allow_difficulty_scaling = FALSE
	audio_cues = list(/datum/soundtrack_song/bee/bubblegum)
	fighter_types = list(/obj/structure/overmap/hostile/ai/fighter)
	supply_types = list(/obj/structure/overmap/hostile/ai/alicorn)
	taunts = list("A powerful ship, a powerful gun, powerful ammunition. The graceful slaughter of a billion lives to save billions more, you'll be the first of many.")
	fleet_trait = FLEET_TRAIT_DEFENSE


//Nanotrasen fleets

/datum/fleet/nanotrasen
	name = "\improper Nanotrasen heavy combat fleet"
	fighter_types = list(/obj/structure/overmap/nanotrasen/ai/fighter)
	destroyer_types = list(/obj/structure/overmap/nanotrasen/ai, /obj/structure/overmap/nanotrasen/frigate/ai)
	battleship_types = list(/obj/structure/overmap/nanotrasen/patrol_cruiser/ai, /obj/structure/overmap/nanotrasen/heavy_cruiser/ai, /obj/structure/overmap/nanotrasen/battlecruiser/ai)
	supply_types = list(/obj/structure/overmap/nanotrasen/carrier/ai)
	default_ghost_ship = /obj/structure/overmap/nanotrasen/ai
	alignment = "nanotrasen"
	hide_movements = TRUE //Friendly fleets just move around as you'd expect.
	faction_id = FACTION_ID_NT
	taunts = list("Syndicate vessel, stand down or be destroyed", "You are encroaching on our airspace, prepare to be destroyed", "Unidentified vessel, your existence will be forfeit in accordance with the peacekeeper act.")
	can_reinforce = FALSE
	threat_elevation_allowed = FALSE	//Sorry EDF, nothing personal.

/datum/fleet/nanotrasen/light
	name = "\improper Nanotrasen light fleet"
	battleship_types = list(/obj/structure/overmap/nanotrasen/patrol_cruiser/ai)

/datum/fleet/nanotrasen/border
	name = "\proper Concord Border Enforcement Unit"
	taunts = list("You have violated the law. Stand down your weapons and prepare to be boarded.", "Hostile vessel. Stand down immediately or be destroyed.")
	size = FLEET_DIFFICULTY_EASY
	fleet_trait = FLEET_TRAIT_BORDER_PATROL

/datum/fleet/nanotrasen/border/defense
	name = "\proper 501st 'Crais' Fist' Expeditionary Force"
	taunts = list("You have violated the law. Stand down your weapons and prepare to be boarded.", "Hostile vessel. Stand down immediately or be destroyed.")
	size = FLEET_DIFFICULTY_EASY
	fleet_trait = FLEET_TRAIT_DEFENSE

//Solgov

/datum/fleet/solgov
	name = "\improper Solgov light exploratory fleet"
	fighter_types = list(/obj/structure/overmap/nanotrasen/solgov/ai/fighter)
	destroyer_types = list(/obj/structure/overmap/nanotrasen/solgov/ai)
	battleship_types = list(/obj/structure/overmap/nanotrasen/solgov/aetherwhisp/ai)
	supply_types = list(/obj/structure/overmap/nanotrasen/solgov/carrier/ai)
	alignment = "solgov"
	hide_movements = TRUE //They're "friendly" alright....
	faction_id = FACTION_ID_NT
	taunts = list("You are encroaching on our airspace, prepare to be destroyed", "You have entered SolGov secure airspace. Prepare to be destroyed", "You are in violation of the SolGov non-aggression agreement. Leave this airspace immediately.")
	size = FLEET_DIFFICULTY_EASY
	greetings = list("Allied vessel. You will be scanned for compliance with the peacekeeper act in 30 seconds. We thank you for your compliance.")
	var/scan_delay = 30 SECONDS
	var/scanning = FALSE

/datum/fleet/solgov/earth
	name = "\proper Earth Defense Force"
	taunts = list("You're foolish to venture this deep into Solgov space! Main batteries stand ready.", "All hands, set condition 1 throughout the fleet, enemy vessel approaching.", "Defense force, stand ready!", "We shall protect our homeland!")
	size = FLEET_DIFFICULTY_HARD
	allow_difficulty_scaling = FALSE
	audio_cues = list()
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/solgov/assemble(datum/star_system/SS, difficulty)
	. = ..()
	if(!scanning)
		addtimer(CALLBACK(src, PROC_REF(scan)), scan_delay)
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
		if((shield_scan_target.faction != shield_scan_target.name) && shield_scan_target.shields && shield_scan_target.shields.active && length(shield_scan_target.occupying_levels))
			shield_scan_target.hail("Scans have detected that you are in posession of prohibited technology. \n Your IFF signature has been marked as 'persona non grata'. \n In accordance with SGC-reg #10124, your ship and lives are now forfeit. Evacuate all civilian personnel immediately and surrender yourselves.", name)
			shield_scan_target.relay_to_nearby('nsv13/sound/effects/ship/solgov_scan_alert.ogg', ignore_self=FALSE)
			grant_oopsie_achievement(shield_scan_target)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(play_soundtrack_music), /datum/soundtrack_song/bee/mind_crawler, null, 120), 2 SECONDS)
			shield_scan_target.faction = shield_scan_target.name

/datum/fleet/solgov/proc/grant_oopsie_achievement(obj/structure/overmap/fugitive)
	for(var/mob/living/traitor in fugitive.mobs_in_ship)
		if(!traitor.client)
			continue
		traitor.client.give_award(/datum/award/achievement/misc/illegal_technology, traitor)

/datum/fleet/solgov/interdiction
	name = "\improper Solgov hunter fleet"
	destroyer_types = list(/obj/structure/overmap/nanotrasen/solgov/ai/interdictor)
	var/list/traitor_taunts = list("Rogue vessel, reset your identification codes immediately or be destroyed.", "The penalty for defection is death.", "Your crew is charged with treason and breach of contract. Lethal force is authorized.")
	size = FLEET_DIFFICULTY_INSANE
	var/players_fired_upon = FALSE
	audio_cues = list(/datum/soundtrack_song/bee/mind_crawler)
	var/obj/structure/overmap/hunted_ship

/datum/fleet/solgov/interdiction/New()
	. = ..()
	hunted_ship = SSstar_system.find_main_overmap()

/datum/fleet/solgov/interdiction/move(datum/star_system/target, force=FALSE)
	// If we're going home just delete us actually
	// Don't let the players game the ability to make solgov show up
	if(!hunted_ship && goal_system)
		qdel(src)
		return
	if(!target && hunted_ship)
		goal_system = hunted_ship.current_system
	. = ..()
	if(.)
		navigate_to(goal_system)	//Anytime we successfully move we recalculate the route, since players like moving around alot.

/datum/fleet/solgov/interdiction/assemble(datum/star_system/SS, difficulty)
	. = ..()
	for(var/obj/structure/overmap/OM as() in all_ships)
		RegisterSignal(OM, COMSIG_ATOM_BULLET_ACT, PROC_REF(check_bullet))

/datum/fleet/solgov/interdiction/encounter(obj/structure/overmap/OM)
	// Same as parent but detects if the player ship is hostile and uses different taunts
	if(OM.faction == alignment || federation_check(OM))
		OM.hail(pick(greetings), name)
	assemble(current_system)
	if(OM.faction != alignment && !federation_check(OM))
		if(OM.alpha >= 150)
			if(OM == SSstar_system.find_main_overmap())
				OM.hail(pick(traitor_taunts), name)
				RegisterSignal(OM, COMSIG_SHIP_BOARDED, PROC_REF(handle_iff_change))
			else
				OM.hail(pick(taunts), name)
			last_encounter_time = world.time
			if(audio_cues?.len)
				play_soundtrack_music(pick(audio_cues) , volume = 100)

/datum/fleet/solgov/interdiction/proc/check_bullet(obj/structure/overmap/source, obj/item/projectile/P)
	if(P.overmap_firer?.role == MAIN_OVERMAP)
		players_fired_upon = TRUE
		for(var/obj/structure/overmap/OM as() in all_ships)
			UnregisterSignal(OM, COMSIG_ATOM_BULLET_ACT)

/datum/fleet/solgov/interdiction/proc/handle_iff_change(obj/structure/overmap/source)
	switch(source.faction)
		if("nanotrasen")
			if(!players_fired_upon)
				hunted_ship = null
				goal_system = SSstar_system.system_by_id("Sol")
				if(current_system == source.current_system)
					source.hail("Don't let it happen again.", name)
			else if(current_system == source.current_system)
				source.hail("... That's not going to cut it anymore.", name)
		if("syndicate")
			// Anger
			hunted_ship = source
			goal_system = null
