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

/obj/structure/overmap/proc/slowprocess() //For ai ships, this allows for target acquisition, tactics etc.
	handle_pdcs()
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
	if(last_target) //Have we got a target?
		if(get_dist(last_target, src) > max_range) //Out of range - Give up the chase
			last_target = null
			desired_angle = rand(0,360)
		else //They're in our range. Calculate a path to them and fire.
			desired_angle = Get_Angle(src, last_target)
			fire(last_target) //Fire already handles things like being out of range, so we're good
	else
		for(var/X in GLOB.overmap_objects)
			if(!istype(X, /obj/structure/overmap))
				continue
			var/obj/structure/overmap/ship = X
			if(ship == src || ship.faction == faction)
				continue
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

/obj/structure/overmap/proc/target(atom/target)
	if(!istype(target, /obj/structure/overmap)) //Don't know why it wouldn't be..but yeah
		return
	add_enemy(target)
	desired_angle = Get_Angle(src, target)
	last_target = target

/obj/structure/overmap/proc/add_enemy(atom/target)
	if(!target in enemies)
		enemies += target