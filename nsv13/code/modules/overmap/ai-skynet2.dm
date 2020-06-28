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
#define AI_SCORE_PRIORITY 50
#define AI_SCORE_DEFAULT 25
#define AI_SCORE_LOW_PRIORITY 15
#define AI_SCORE_VERY_LOW_PRIORITY 5 //Very low priority, acts as a failsafe to ensure that the AI always picks _something_ to do.

#define AI_PDC_RANGE 12

#define FLEET_DIFFICULTY_EASY 4 //if things end up being too hard, this is a safe number for a fight you _should_ always win.
#define FLEET_DIFFICULTY_MEDIUM 6
#define FLEET_DIFFICULTY_HARD 10
#define FLEET_DIFFICULTY_INSANE 20 //If you try to take on the rubicon ;)
#define FLEET_DIFFICULTY_DEATH 30 //Suicide run

#define AI_TRAIT_SUPPLY 1
#define AI_TRAIT_BATTLESHIP 2
#define AI_TRAIT_DESTROYER 3
#define AI_TRAIT_ANTI_FIGHTER 4

GLOBAL_LIST_EMPTY(ai_goals)

/datum/fleet
	var/name = "501st fleet"//Todo: randomize this name
	//Ai fleet type enum. Add your new one here. Use a define, or text if youre lazy.
	var/list/taskforces = list("fighters" = list(), "destroyers" = list(), "battleships" = list(), "supply" = list())
	var/list/fighter_types = list(/obj/structure/overmap/syndicate/ai/fighter)
	var/list/destroyer_types = list(/obj/structure/overmap/syndicate/ai, /obj/structure/overmap/syndicate/ai/assault_cruiser, /obj/structure/overmap/syndicate/ai/gunboat, /obj/structure/overmap/syndicate/ai/submarine)
	var/list/battleship_types = list(/obj/structure/overmap/syndicate/ai/patrol_cruiser) //TODO: Implement above list for more ship variety.
	var/list/supply_types = list(/obj/structure/overmap/syndicate/ai/carrier)

/datum/fleet/nanotrasen
	name = "NT fleet"
	fighter_types = list(/obj/structure/overmap/nanotrasen/ai/fighter)
	destroyer_types = list(/obj/structure/overmap/nanotrasen/ai)
	battleship_types = list(/obj/structure/overmap/nanotrasen/patrol_cruiser/ai, /obj/structure/overmap/nanotrasen/heavy_cruiser/ai, /obj/structure/overmap/nanotrasen/battleship/ai)
	supply_types = list(/obj/structure/overmap/nanotrasen/carrier/ai)

//Temporary magic testing proc. Remove this shit when youre done with it not 6am Kmc!
/obj/structure/overmap/proc/f()
	if(!current_system)
		return
	var/datum/fleet/foo = new /datum/fleet()
	fleet = foo //grab that, REF
	foo.assemble(current_system)

/obj/structure/overmap/proc/g()
	if(!current_system)
		return
	var/datum/fleet/foo = new /datum/fleet/nanotrasen()
	fleet = foo //grab that, REF
	foo.assemble(current_system)

/datum/fleet/New()
	. = ..()
	//Populate the list of valid goals, if we don't already have them
	if(!GLOB.ai_goals.len)
		for(var/x in subtypesof(/datum/ai_goal))
			GLOB.ai_goals += new x

/datum/fleet/proc/assemble(datum/star_system/SS, difficulty=FLEET_DIFFICULTY_MEDIUM)
	if(!SS || !SS.occupying_z) //Only loaded in levels are supported at this time. TODO: Fix this.
		return FALSE
	/*Fleet comp! Let's use medium as an example:
	6 total
	3 destroyers (1/2 of the fleet size)
	2 battleships (1/4th of the fleet)
	2 supply ships (1/4th of the fleet)
	*/
	//This may look lazy, but it's easier than storing all this info in one massive dict. Deal with it!
	for(var/I=0; I<round(difficulty/2);I++){
		var/shipType = pick(destroyer_types)
		var/obj/structure/overmap/member = new shipType()
		taskforces["destroyers"] += member
		member.fleet = src
		SS.add_ship(member)
	}
	for(var/I=0; I<round(difficulty/4);I++){
		var/shipType = pick(battleship_types)
		var/obj/structure/overmap/member = new shipType()
		taskforces["battleships"] += member
		member.fleet = src
		SS.add_ship(member)
	}
	for(var/I=0; I<round(difficulty/4);I++){
		var/shipType = pick(supply_types)
		var/obj/structure/overmap/member = new shipType()
		taskforces["supply"] += member
		member.fleet = src
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
	if(!istype(OM) || !OM.ai_controlled || (required_trait && OM.ai_trait != required_trait))
		return 0 //0 Score, in other terms, the AI will ignore this task completely.
	return (score > 0 ? score : TRUE) //Children sometimes NEED this true value to run their own checks.

//Delete the AI's last orders, tell the AI ship what to do.
/datum/ai_goal/proc/assume(obj/structure/overmap/OM)
	if(OM.current_goal)
		OM.current_goal = null
	OM.speed_limit = initial(OM.speed_limit) //Just in case we mucked around with this with formation objectives.
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
	if(!OM.fleet.taskforces["supply"].len)
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
		OM.move_mode = NORTH
		if(get_dist(OM, supplyPost) <= AI_PDC_RANGE)
			OM.speed_limit = supplyPost.velocity.x + supplyPost.velocity.y
		else
			OM.desired_angle = Get_Angle(OM, supplyPost)
			OM.speed_limit = initial(OM.speed_limit)
			OM.brakes = FALSE

/datum/ai_goal/seek
	name = "Search and destroy"
	score = AI_SCORE_DEFAULT

/datum/ai_goal/seek/check_score(obj/structure/overmap/OM)
	if(!..()) //If it's not an overmap, or it's not linked to a fleet.
		return 0
	if(!OM.last_target || QDELETED(OM.last_target))
		for(var/obj/structure/overmap/ship in GLOB.overmap_objects)
			if(OM.warcrime_blacklist[ship.type])
				continue
			if(!ship || QDELETED(ship) || ship == OM || get_dist(OM, ship) > OM.max_tracking_range || ship.faction == OM.faction || ship.z != OM.z || ship.is_sensor_visible(OM) < SENSOR_VISIBILITY_TARGETABLE)
				continue
			OM.add_enemy(ship)
			OM.last_target = ship
			break
	if(OM.last_target) //If we can't find a target, then don't bother hunter-killering.
		return score
	else
		return AI_SCORE_VERY_LOW_PRIORITY //Just so that there's a "default" behaviour to avoid issues.

/datum/ai_goal/seek/action(obj/structure/overmap/OM)
	..()
	OM.speed_limit = initial(OM.speed_limit) //Just in case we mucked around with this with formation objectives.
	OM.brakes = FALSE
	OM.move_mode = NORTH
	if(OM.last_target)
		OM.desired_angle = Get_Angle(OM, OM.last_target)
		if(get_dist(OM, OM.last_target) <= 10)
			OM.desired_angle = -Get_Angle(OM, OM.last_target)
	else
		OM.desired_angle = 0 //Just fly around in a straight line, I guess.

/datum/ai_goal/defend
	name = "Protect supply lines"
	score = AI_SCORE_LOW_PRIORITY

/datum/ai_goal/defend/action(obj/structure/overmap/OM)
	..()
	if(!OM.defense_target || QDELETED(OM.defense_target))
		OM.defense_target = pick(OM.fleet.taskforces["supply"])
	OM.move_mode = NORTH
	if(get_dist(OM, OM.defense_target) <= AI_PDC_RANGE)
		OM.speed_limit = OM.defense_target.velocity.x + OM.defense_target.velocity.y
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
		return (OM.fleet.taskforces["supply"].len ? AI_SCORE_CRITICAL : AI_SCORE_LOW_PRIORITY)
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
	OM.speed_limit = initial(OM.speed_limit)
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
		for(var/obj/structure/overmap/ship in GLOB.overmap_objects)
			if(OM.warcrime_blacklist[ship.type])
				continue
			if(!ship || QDELETED(ship) || ship == OM || get_dist(OM, ship) > OM.max_tracking_range || ship.faction == OM.faction || ship.z != OM.z || ship.is_sensor_visible(OM) < SENSOR_VISIBILITY_TARGETABLE)
				continue
			if(ship.mass > MASS_TINY)
				continue
			OM.add_enemy(ship)
			OM.last_target = ship
			break
	if(OM.last_target) //If we can't find a target, then don't bother hunter-killering.
		return score
	else
		return 0 //Default back to the "hunt down ships" behaviour.

/obj/structure/overmap/proc/choose_goal()
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
	var/max_tracking_range = 115 //Range that AI ships can hunt you down in. The amounts to almost half the Z-level.
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
		if(target_range <= AI_PDC_RANGE)
			new_firemode = (mass > MASS_MEDIUM) ? FIRE_MODE_GAUSS : FIRE_MODE_PDC //This makes large ships a legitimate threat.
		else
			var/obj/structure/overmap/OM = last_target
			if(istype(OM) && OM.mass >= MASS_SMALL)
				if(!torpedoes)
					new_firemode = (mass > MASS_TINY) ? FIRE_MODE_RAILGUN : FIRE_MODE_PDC
				else
					new_firemode = FIRE_MODE_TORPEDO
			else //Small target or not actually an overmap. Prefer missiles, as theyre more optimal vs subcapitals
				if(!missiles)
					new_firemode = (mass > MASS_TINY) ? FIRE_MODE_RAILGUN : FIRE_MODE_PDC
				else
					new_firemode = FIRE_MODE_MISSILE
		if(!weapon_types[new_firemode]) //Sometimes we just don't support certain weapons.
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
		if(shots_left <= 0 && new_firemode != FIRE_MODE_PDC && new_firemode != FIRE_MODE_GAUSS)
			return //No shots left! We'll have to resupply somewhere down the line. PDC shots will still go off though!
		if(new_firemode != FIRE_MODE_PDC && new_firemode != FIRE_MODE_GAUSS) //Don't penalise them for weapons that are designed to be spammed.
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
				try_board(last_target)
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

/obj/structure/overmap/proc/try_board(obj/structure/overmap/ship)
	if(mass < MASS_MEDIUM || get_dist(ship, src) > 6)
		return FALSE
	next_boarding_attempt = world.time + 5 MINUTES //We very rarely try to board.
	if(SSovermap.next_boarding_time <= world.time)
		SSovermap.next_boarding_time = world.time + 30 MINUTES
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
				current_system?.add_enemy(newFighter)
				if(fleet)
					newFighter.fleet = fleet
					fleet.taskforces["fighters"] += newFighter //Lets our fighters come back to the mothership to fuel up every so often.
				relay_to_nearby('nsv13/sound/effects/ship/fighter_launch_short.ogg')
		addtimer(VARSET_CALLBACK(src, ai_can_launch_fighters, TRUE), 3 MINUTES)
	if(OM in enemies) //If target's in enemies, return
		return
	enemies += target
	if(OM.role == MAIN_OVERMAP)
		set_security_level(SEC_LEVEL_RED) //Action stations when the ship is under attack, if it's the main overmap.
		SSstar_system.last_combat_enter = world.time //Tag the combat on the SS
		SSstar_system.modifier = 0 //Reset overmap spawn modifier
		var/datum/round_event_control/_overmap_event_handler/OEH = locate(/datum/round_event_control/_overmap_event_handler) in SSevents.control
		OEH.weight = 0 //Reset controller weighting
	if(OM.tactical)
		var/sound = pick('nsv13/sound/effects/computer/alarm.ogg','nsv13/sound/effects/computer/alarm_3.ogg','nsv13/sound/effects/computer/alarm_4.ogg')
		var/message = "<span class='warning'>DANGER: [src] is now targeting [OM].</span>"
		OM.tactical.relay_sound(sound, message)
	else
		if(OM.dradis)
			playsound(OM.dradis, 'nsv13/sound/effects/fighters/being_locked.ogg', 100, FALSE)
