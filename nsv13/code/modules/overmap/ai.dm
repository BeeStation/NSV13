//Legend:
// Aggressive will hunt you down as soon as you enter sensor range
// Passive will not attack you even if provoked
// Retaliate will return fire only
// Guard will only attack if you get too close

/obj/structure/overmap
	var/ai_controlled = FALSE //Set this to true to let the computer fly your ship.
	var/ai_behaviour = null // Determines if the AI ship shoots you first, or if you have to shoot them.
	var/list/enemies = list() //Things that have attacked us
	var/max_range = 30 //Range that AI ships can hunt you down in
	var/guard_range = 10 //Close range. Encroach on their space and die
	var/ai_can_launch_fighters = FALSE //AI variable. Allows your ai ships to spawn fighter craft
	var/list/ai_fighter_type = list()

/obj/structure/overmap/Initialize()
	. = ..()
	if(mass <= MASS_TINY)
		weapons[FIRE_MODE_PDC] = new /datum/ship_weapon/light_cannon(src)

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
	user_thrust_dir = 1
	if(last_target || QDELETED(last_target)) //Have we got a target?
		if(get_dist(last_target, src) > max_range) //Out of range - Give up the chase
			last_target = null
			desired_angle = rand(0,360)
		else //They're in our range. Calculate a path to them and fire.
			desired_angle = Get_Angle(src, last_target)
			fire(last_target) //Fire already handles things like being out of range, so we're good
	handle_ai_behaviour()

/obj/structure/overmap/proc/handle_ai_behaviour()
	for(var/obj/structure/overmap/ship in GLOB.overmap_objects)
		if(ship == src || ship.faction == faction || ship.z != z)
			continue
		ai_target(ship)

/**
*
*
* ai_target -> what happens after a targetable ship is found
* if your ship subtype is "timid" like carriers, override this to handle ai behaviours specifically, otherwise, ship will be targeted based on its "ai behaviour"
* @param ship overmap ship that was found by handle_ai_behaviour()
*
*
*/

/obj/structure/overmap/proc/ai_target(obj/structure/overmap/ship)
	switch(ai_behaviour)
		if(AI_AGGRESSIVE)
			if(get_dist(ship,src) <= max_range)
				target(ship)
		if(AI_GUARD)
			if(get_dist(ship,src) <= guard_range)
				target(ship)
		if(AI_RETALIATE)
			if(ship in enemies)
				target(ship)
	if(locate(ship) in enemies)
		if(get_dist(ship, src) <= 3)
			user_thrust_dir = 0 //Don't thrust towards ships we're already close to.
			brakes = TRUE
			try_board(ship)
		else
			user_thrust_dir = 1
			brakes = FALSE

/obj/structure/overmap/proc/try_board(obj/structure/overmap/ship)
	if(mass <= MASS_TINY)
		return FALSE
	if(SSphysics_processing.next_boarding_time <= world.time)
		SSphysics_processing.next_boarding_time = world.time + 30 MINUTES
		ship.spawn_boarders()
		return TRUE
	return FALSE

/obj/structure/overmap/proc/retreat()
	if(!last_target)
		return
	desired_angle = -Get_Angle(src, last_target) //Turn the opposite direction and run.
	user_thrust_dir = 1

/obj/structure/overmap/proc/target(atom/target)
	if(!istype(target, /obj/structure/overmap)) //Don't know why it wouldn't be..but yeah
		return
	if(obj_integrity <= max_integrity / 3)
		retreat()
		return
	add_enemy(target)
	desired_angle = Get_Angle(src, target)
	last_target = target

/obj/structure/overmap/proc/add_enemy(atom/target)
	if(!istype(target, /obj/structure/overmap)) //Don't know why it wouldn't be..but yeah
		return
	var/obj/structure/overmap/OM = target
	for(var/X in enemies) //If target's in enemies, return
		if(target == X)
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

/**
* Class specific overrides.
*/

/**
*
* Carriers are more timid, and prefer to run away from enemy ships before firing, engaging at extreme range.
*
*/

/obj/structure/overmap/syndicate/ai/carrier/ai_target(obj/structure/overmap/ship)
	if(get_dist(ship,src) <= max_range)
		if(get_dist(ship, src) <= max_range/2) //Little bit too friendly there partner.
			last_target = ship
			retreat()
		else
			target(ship)

/obj/structure/overmap/syndicate/ai/carrier/target(atom/target)
	. = ..()
	if(ai_can_launch_fighters) //Found a new enemy? Launch the CAP.
		ai_can_launch_fighters = FALSE
		if(ai_fighter_type.len)
			for(var/i = 0, i < rand(2,3), i++)
				var/ai_fighter = pick(ai_fighter_type)
				new ai_fighter(get_turf(src))
				relay_to_nearby('nsv13/sound/effects/ship/fighter_launch_short.ogg')
		addtimer(VARSET_CALLBACK(src, ai_can_launch_fighters, TRUE), 3 MINUTES)
