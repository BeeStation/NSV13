//Legend:
// Aggressive will hunt you down as soon as you enter sensor range
// Passive will not attack you even if provoked
// Retaliate will return fire only
// Guard will only attack if you get too close

#define DECISION_TERMINATOR 2
#define AI_PDC_RANGE 12

/obj/structure/overmap
	var/ai_controlled = FALSE //Set this to true to let the computer fly your ship.
	var/ai_behaviour = null // Determines if the AI ship shoots you first, or if you have to shoot them.
	var/list/enemies = list() //Things that have attacked us
	var/max_weapon_range = 30
	var/max_tracking_range = 115 //Range that AI ships can hunt you down in. The amounts to almost half the Z-level.
	var/guard_range = 10 //Close range. Encroach on their space and die
	var/ai_can_launch_fighters = FALSE //AI variable. Allows your ai ships to spawn fighter craft
	var/list/ai_fighter_type = list()

	var/last_decision = 0
	var/decision_delay = 2 SECONDS
	var/boredom = 0 //How long has this AI ship been waiting outside of combat? They'll eventually get bored and come chase you.
	var/boredom_attack_threshold = 10 //10 lots of 20 second cooldowns until it gets fed up and just throws itself at you
	var/move_mode = 0
	var/next_boarding_attempt = 0

	var/reloading_torpedoes = FALSE
	var/reloading_missiles = FALSE
	var/static/list/warcrime_blacklist = typecacheof(list(/obj/structure/overmap/fighter/escapepod, /obj/structure/overmap/asteroid))//Ok. I'm not THAT mean...yet. (Hello karmic, it's me karmic 2)

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
					if(!reloading_torpedoes && initial(torpedoes) > 0) //Not every fighter needs torps...
						reloading_torpedoes = TRUE
						addtimer(CALLBACK(src, .proc/reload_torpedoes), 2 MINUTES)
				else
					new_firemode = FIRE_MODE_TORPEDO
			else //Small target or not actually an overmap. Prefer missiles, as theyre more optimal vs subcapitals
				if(!missiles)
					new_firemode = (mass > MASS_TINY) ? FIRE_MODE_RAILGUN : FIRE_MODE_PDC
					if(!reloading_missiles && initial(missiles) > 0)
						reloading_missiles = TRUE
						addtimer(CALLBACK(src, .proc/reload_missiles), 2 MINUTES)
				else
					new_firemode = FIRE_MODE_MISSILE
		if(new_firemode != FIRE_MODE_PDC) //If we're not on PDCs, let's fire off some PDC salvos while we're busy shooting people. This is still affected by weapon cooldowns so that they lay off on their target a bit.
			for(var/obj/structure/overmap/ship in GLOB.overmap_objects)
				if(warcrime_blacklist[ship.type])
					continue
				if(!ship || QDELETED(ship) || ship == src || get_dist(src, ship) > max_weapon_range || ship.faction == src.faction || ship.z != z)
					continue
				fire_weapon(ship, FIRE_MODE_PDC)
				break
		fire_mode = new_firemode
		fire_weapon(target, new_firemode)
		next_firetime = world.time + (0.5 SECONDS) + (fire_delay*2)

//Torpedoes are more heavy hitting, thus you don't get very many.

/obj/structure/overmap/proc/reload_torpedoes()
	reloading_torpedoes = FALSE
	torpedoes = ++mass

//Missiles are a lot more spammable, and are for dealing with small craft

/obj/structure/overmap/proc/reload_missiles()
	reloading_missiles = FALSE
	missiles = mass*2

//Branch 1 decides if we're a capital ship or not, and whether we're going to be ramming the enemy.

/obj/structure/overmap/proc/is_low()
	return (obj_integrity < (max_integrity / 2)) ? .proc/is_cap_ship : .proc/can_board //Todo

/obj/structure/overmap/proc/is_cap_ship()
	return (mass >= MASS_SMALL) ? .proc/is_very_low : .proc/should_retreat

/obj/structure/overmap/proc/is_very_low()
	return (obj_integrity < (max_integrity / 3)) ? .proc/ram : .proc/fall_back

//Branch 2 decides if we should try to board, or just run away

/obj/structure/overmap/proc/can_board()
	return (world.time >= next_boarding_attempt && mass >= MASS_MEDIUM) ? .proc/resume_targeting : .proc/is_cap_ship

/obj/structure/overmap/proc/should_retreat()
	return (mass <= MASS_SMALL && obj_integrity < (max_integrity/2)) ? .proc/retreat : .proc/resume_targeting


//We're not low, so do a big ol' strafing run at the ship.
/obj/structure/overmap/proc/resume_targeting()
	if(!last_target)
		return
	if(get_dist(src, last_target) <= 3) //Yeah we're a bit too close for comfort! Do a strafing run instead.
		retreat()
		return DECISION_TERMINATOR
	inertial_dampeners = TRUE
	desired_angle = Get_Angle(src, last_target)
	move_mode = NORTH
	brakes = FALSE
	return DECISION_TERMINATOR

/obj/structure/overmap/proc/retreat()
	if(!last_target)
		return
	boredom ++
	if(boredom >= boredom_attack_threshold)
		boredom = 0
		ram()
		return
	brakes = FALSE
	desired_angle = -Get_Angle(src, last_target) //Turn the opposite direction and run.
	move_mode = NORTH
	return DECISION_TERMINATOR

/obj/structure/overmap/proc/ram()
	if(!last_target)
		return
	inertial_dampeners = TRUE
	speed_limit = 10
	brakes = FALSE
	desired_angle = Get_Angle(src, last_target) //Get up close and personal.
	move_mode = NORTH
	addtimer(VARSET_CALLBACK(src, speed_limit, initial(speed_limit)), decision_delay)
	return DECISION_TERMINATOR

/obj/structure/overmap/proc/fall_back()
	if(!last_target)
		return
	if(get_dist(src, last_target) > max_weapon_range)
		resume_targeting()
		return
	if(get_dist(src, last_target) >= 15)
		brakes = TRUE
		return DECISION_TERMINATOR
	brakes = FALSE
	inertial_dampeners = TRUE
	move_mode = SOUTH
	desired_angle = Get_Angle(src, last_target) //Keep facing them to deliver punishment.
	return DECISION_TERMINATOR

/obj/structure/overmap/proc/handle_ai_behaviour()
	if(!last_target || QDELETED(last_target))
		for(var/obj/structure/overmap/ship in GLOB.overmap_objects)
			if(warcrime_blacklist[ship.type])
				continue
			if(!ship || QDELETED(ship) || ship == src || get_dist(src, ship) > max_tracking_range || ship.faction == src.faction || ship.z != z || ship.is_sensor_visible(src) < SENSOR_VISIBILITY_TARGETABLE)
				continue
			add_enemy(ship)
			break
	if(world.time >= last_decision + decision_delay)
		last_decision = world.time
		decision(.proc/is_low) //Start the decision making process!

/obj/structure/overmap/proc/decision(proctype)
	if(!ai_controlled || !proctype)
		return FALSE //Only AI ships need to decide stuff.
	if(!last_target)
		move_mode = NORTH
		brakes = FALSE
		return
	var/result = CallAsync(src, proctype)
	if(result != DECISION_TERMINATOR){
		if(result)
			decision(result)
			return
		else
			resume_targeting() //Default to just running into the enemy
			return
	}
	else{
		return
	}
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
			desired_angle = rand(0,360)
		else //They're in our tracking range. Let's hunt them down.
			if(get_dist(last_target, src) <= max_weapon_range) //Theyre within weapon range.  Calculate a path to them and fire.
				desired_angle = Get_Angle(src, last_target)
				try_board(last_target)
				ai_fire(last_target) //Fire already handles things like being out of range, so we're good
	handle_ai_behaviour()
	if(move_mode)
		user_thrust_dir = move_mode

/obj/structure/overmap/proc/try_board(obj/structure/overmap/ship)
	if(mass < MASS_MEDIUM || get_dist(ship, src) > 6)
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
				current_system?.add_enemy(newFighter)
				relay_to_nearby('nsv13/sound/effects/ship/fighter_launch_short.ogg')
		addtimer(VARSET_CALLBACK(src, ai_can_launch_fighters, TRUE), 3 MINUTES)
	if(OM in enemies) //If target's in enemies, return
		return
	enemies += target
	if(OM.role == MAIN_OVERMAP)
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
