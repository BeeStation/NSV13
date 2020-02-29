/////////////////////////////////////////////////////////////////////////
// ACKNOWLEDGEMENTS:  Credit to yogstation (Monster860) for this code. //
// I had no part in writing this movement engine, that's his work      //
/////////////////////////////////////////////////////////////////////////

/obj/vector_overlay
	name = "Vector overlay for overmap ships"
	desc = "Report this to a coder"
	icon = 'nsv13/icons/overmap/thrust_vector.dmi'
	icon_state = "thrust_low"
	mouse_opacity = FALSE
	alpha = 0
	layer = HIGH_OBJ_LAYER

/obj/structure/overmap
	var/last_process = 0
	var/obj/vector_overlay/vector_overlay

/obj/structure/overmap/proc/can_move()
	return TRUE //Placeholder for everything but fighters. We can later extend this if / when we want to code in ship engines.

/obj/structure/overmap/process(time)
	time /= 10 // fuck off with your deciseconds
	last_process = world.time

	if(world.time > last_slowprocess + 10)
		last_slowprocess = world.time
		slowprocess()

	var/last_offset_x = offset_x
	var/last_offset_y = offset_y
	var/last_angle = angle
	var/desired_angular_velocity = 0
	if(isnum(desired_angle))
		// do some finagling to make sure that our angles end up rotating the short way
		while(angle > desired_angle + 180)
			angle -= 360
			last_angle -= 360
		while(angle < desired_angle - 180)
			angle += 360
			last_angle += 360
		if(abs(desired_angle - angle) < (max_angular_acceleration * time))
			desired_angular_velocity = (desired_angle - angle) / time
		else if(desired_angle > angle)
			desired_angular_velocity = 2 * sqrt((desired_angle - angle) * max_angular_acceleration * 0.25)
		else
			desired_angular_velocity = -2 * sqrt((angle - desired_angle) * max_angular_acceleration * 0.25)
	var/angular_velocity_adjustment = CLAMP(desired_angular_velocity - angular_velocity, -max_angular_acceleration*time, max_angular_acceleration*time)
	if(angular_velocity_adjustment)
		last_rotate = angular_velocity_adjustment / time
		angular_velocity += angular_velocity_adjustment
	else
		last_rotate = 0
	angle += angular_velocity * time

	// calculate drag and shit

	var/velocity_mag = sqrt(velocity_x*velocity_x+velocity_y*velocity_y) // magnitude
	if(velocity_mag || angular_velocity)
		var/drag = 0
		for(var/turf/T in locs)
			if(isspaceturf(T))
				continue
			drag += 0.001
			var/floating = FALSE
			if(T.has_gravity() && velocity_mag > 0.1)
				floating = TRUE // Increase drag when not in space.
			if((!floating && T.has_gravity())) // brakes are a kind of magboots okay?
				drag += is_mining_level(z) ? 0.1 : 0.5 // some serious drag. Damn. Except lavaland, it has less gravity or something
				if(velocity_mag > 5 && prob(velocity_mag * 4) && istype(T, /turf/open/floor))
					var/turf/open/floor/TF = T
					TF.make_plating() // pull up some floor tiles. Stop going so fast, ree.
					take_damage(3, BRUTE, "melee", FALSE)
			var/datum/gas_mixture/env = T.return_air()
			if(env)
				var/pressure = env.return_pressure()
				drag += velocity_mag * pressure * 0.0001 // 1 atmosphere should shave off 1% of velocity per tile
		if(velocity_mag > 20)
			drag = max(drag, (velocity_mag - 20) / time)
		if(drag)
			if(velocity_mag)
				var/drag_factor = 1 - CLAMP(drag * time / velocity_mag, 0, 1)
				velocity_x *= drag_factor
				velocity_y *= drag_factor
			if(angular_velocity != 0)
				var/drag_factor_spin = 1 - CLAMP(drag * 30 * time / abs(angular_velocity), 0, 1)
				angular_velocity *= drag_factor_spin

	// Alright now calculate the THRUST
	var/thrust_x
	var/thrust_y
	var/fx = cos(90 - angle)
	var/fy = sin(90 - angle) //This appears to be a vector.
	var/sx = fy
	var/sy = -fx
	last_thrust_forward = 0
	last_thrust_right = 0
	if(brakes) //If our brakes are engaged, attempt to slow them down
		// basically calculates how much we can brake using the thrust
		var/forward_thrust = -((fx * velocity_x) + (fy * velocity_y)) / time
		var/right_thrust = -((sx * velocity_x) + (sy * velocity_y)) / time
		forward_thrust = CLAMP(forward_thrust, -backward_maxthrust, forward_maxthrust)
		right_thrust = CLAMP(right_thrust, -side_maxthrust, side_maxthrust)
		thrust_x += forward_thrust * fx + right_thrust * sx;
		thrust_y += forward_thrust * fy + right_thrust * sy;
		last_thrust_forward = forward_thrust
		last_thrust_right = right_thrust
	else // Add our thrust to the movement vector
		if(can_move())
			if(user_thrust_dir & NORTH)
				thrust_x += fx * forward_maxthrust
				thrust_y += fy * forward_maxthrust
				last_thrust_forward = forward_maxthrust
			if(user_thrust_dir & SOUTH)
				thrust_x -= fx * backward_maxthrust
				thrust_y -= fy * backward_maxthrust
				last_thrust_forward = -backward_maxthrust
			if(user_thrust_dir & EAST)
				thrust_x += sx * side_maxthrust
				thrust_y += sy * side_maxthrust
				last_thrust_right = side_maxthrust
			if(user_thrust_dir & WEST)
				thrust_x -= sx * side_maxthrust
				thrust_y -= sy * side_maxthrust
				last_thrust_right = -side_maxthrust
	 //Stops you yeeting off at lightspeed. This made AI ships really frustrating to play against.
	if(velocity_x > speed_limit)
		velocity_x = speed_limit
	if(velocity_y > speed_limit)
		velocity_y = speed_limit
	if(velocity_x < -speed_limit)
		velocity_x = -speed_limit
	if(velocity_y < -speed_limit)
		velocity_y = -speed_limit
	velocity_x += thrust_x * time //And speed us up based on how long we've been thrusting (up to a point)
	velocity_y += thrust_y * time
	if(pilot?.client?.keys_held["Q"] && can_move()) //While theyre pressing E || Q, turn.
		desired_angle -= 15 //Otherwise it feels sluggish as all hell
	if(pilot?.client?.keys_held["E"] && can_move())
		desired_angle += 15
	offset_x += velocity_x * time
	offset_y += velocity_y * time
	// alright so now we reconcile the offsets with the in-world position.
	while((offset_x > 0 && velocity_x > 0) || (offset_y > 0 && velocity_y > 0) || (offset_x < 0 && velocity_x < 0) || (offset_y < 0 && velocity_y < 0))
		var/failed_x = FALSE
		var/failed_y = FALSE
		if(offset_x > 0 && velocity_x > 0)
			dir = EAST
			if(!Move(get_step(src, EAST)))
				offset_x = 0
				failed_x = TRUE
				velocity_x *= -bounce_factor
				velocity_y *= lateral_bounce_factor
			else
				offset_x--
				last_offset_x--
		else if(offset_x < 0 && velocity_x < 0)
			dir = WEST
			if(!Move(get_step(src, WEST)))
				offset_x = 0
				failed_x = TRUE
				velocity_x *= -bounce_factor
				velocity_y *= lateral_bounce_factor
			else
				offset_x++
				last_offset_x++
		else
			failed_x = TRUE
		if(offset_y > 0 && velocity_y > 0)
			dir = NORTH
			if(!Move(get_step(src, NORTH)))
				offset_y = 0
				failed_y = TRUE
				velocity_y *= -bounce_factor
				velocity_x *= lateral_bounce_factor
			else
				offset_y--
				last_offset_y--
		else if(offset_y < 0 && velocity_y < 0)
			dir = SOUTH
			if(!Move(get_step(src, SOUTH)))
				offset_y = 0
				failed_y = TRUE
				velocity_y *= -bounce_factor
				velocity_x *= lateral_bounce_factor
			else
				offset_y++
				last_offset_y++
		else
			failed_y = TRUE
		if(failed_x && failed_y)
			break
	// prevents situations where you go "wtf I'm clearly right next to it" as you enter a stationary spacepod
	if(velocity_x == 0)
		if(offset_x > 0.5)
			if(Move(get_step(src, EAST)))
				offset_x--
				last_offset_x--
			else
				offset_x = 0
		if(offset_x < -0.5)
			if(Move(get_step(src, WEST)))
				offset_x++
				last_offset_x++
			else
				offset_x = 0
	if(velocity_y == 0)
		if(offset_y > 0.5)
			if(Move(get_step(src, NORTH)))
				offset_y--
				last_offset_y--
			else
				offset_y = 0
		if(offset_y < -0.5)
			if(Move(get_step(src, SOUTH)))
				offset_y++
				last_offset_y++
			else
				offset_y = 0
	dir = NORTH //So that the matrix is always consistent
	var/matrix/mat_from = new()
	mat_from.Turn(last_angle)
	var/matrix/mat_to = new()
	mat_to.Turn(angle)
	var/matrix/targetAngle = new() //Indicate where the ship wants to go.
	targetAngle.Turn(desired_angle)
	if(resize > 0)
		for(var/i = 0, i < resize, i++) //We have to resize by 0.5 to shrink. So shrink down by a factor of "resize"
			mat_from.Scale(0.5,0.5)
			mat_to.Scale(0.5,0.5)
			targetAngle.Scale(0.5,0.5) //Scale down their movement indicator too so it doesnt look comically big
	if(pilot?.client && desired_angle && !move_by_mouse)//Preconditions: Pilot is logged in and exists, there is a desired angle, we are NOT moving by mouse (dont need to see where we're steering if it follows mousemovement)
		vector_overlay.transform = targetAngle
		vector_overlay.alpha = 255
	else
		vector_overlay.alpha = 0
		targetAngle = null
	transform = mat_from
	pixel_x = last_offset_x*32
	pixel_y = last_offset_y*32
	animate(src, transform=mat_to, pixel_x = offset_x*32, pixel_y = offset_y*32, time = time*10, flags=ANIMATION_END_NOW)
	if(last_target)
		var/target_angle = Get_Angle(src,last_target)
		var/matrix/final = matrix()
		final.Turn(target_angle)
		if(last_fired)
			last_fired.transform = final
	else if(last_fired)
		last_fired.transform = mat_to

	for(var/mob/living/M in operators)
		var/client/C = M.client
		if(!C)
			continue
		C.pixel_x = last_offset_x*32
		C.pixel_y = last_offset_y*32
		animate(C, pixel_x = offset_x*32, pixel_y = offset_y*32, time = time*10, flags=ANIMATION_END_NOW)
	user_thrust_dir = 0
	update_icon()

/obj/structure/overmap/Bumped(atom/movable/A)
	if(istype(A, /obj/structure/overmap/fighter))
		var/obj/structure/overmap/fighter/F = A
		F.docking_act(src)
		return FALSE
	if(brakes) //No :)
		return FALSE
	if(A.dir & NORTH)
		velocity_y += bump_impulse
	if(A.dir & SOUTH)
		velocity_y -= bump_impulse
	if(A.dir & EAST)
		velocity_x += bump_impulse
	if(A.dir & WEST)
		velocity_x -= bump_impulse
	return ..()

/obj/structure/overmap/Bump(atom/A)
	var/bump_velocity = 0
	if(dir & (NORTH|SOUTH))
		bump_velocity = abs(velocity_y) + (abs(velocity_x) / 15)
	else
		bump_velocity = abs(velocity_x) + (abs(velocity_y) / 15)
	if(istype(A, /obj/machinery/door/airlock)) // try to open doors
		var/obj/machinery/door/D = A
		if(!D.operating)
			if(D.allowed(D.requiresID() ? pilot : null))
				spawn(0)
					D.open()
			else
				D.do_animate("deny")
	var/atom/movable/AM = A
	if(istype(AM) && !AM.anchored && bump_velocity > 1)
		step(AM, dir)
	// if a bump is that fast then it's not a bump. It's a collision.
	if(bump_velocity > 10 && !ismob(A))
		var/strength = bump_velocity / 10
		strength = strength * strength
		strength = min(strength, 5) // don't want the explosions *too* big
		// wew lad, might wanna slow down there
		explosion(A, -1, round((strength - 1) / 2), round(strength))
		message_admins("[key_name_admin(pilot)] has impacted a spacepod into [A] with velocity [bump_velocity]")
		take_damage(strength*10, BRUTE, "melee", TRUE)
		log_game("[key_name(pilot)] has impacted a spacepod into [A] with velocity [bump_velocity]")
		visible_message("<span class='danger'>The force of the impact causes a shockwave</span>")
	else if(isliving(A) && bump_velocity > 5)
		var/mob/living/M = A
		M.apply_damage(bump_velocity * 2)
		take_damage(bump_velocity, BRUTE, "melee", FALSE)
		playsound(M.loc, "swing_hit", 1000, 1, -1)
		M.Knockdown(bump_velocity * 2)
		M.visible_message("<span class='warning'>The force of the impact knocks [M] down!</span>","<span class='userdanger'>The force of the impact knocks you down!</span>")
		log_combat(pilot, M, "impacted", src, "with velocity of [bump_velocity]")
	return ..()

/obj/structure/overmap/proc/fire_projectile(proj_type, atom/target, homing = FALSE, speed=10, explosive = FALSE) //Fire one shot. Used for big, hyper accelerated shots rather than PDCs
	var/fx = cos(90 - angle)
	var/fy = sin(90 - angle)
	var/sx = fy
	var/sy = -fx
	var/new_offset = sprite_size/4
	var/ox = (offset_x * 32) + new_offset
	var/oy = (offset_y * 32) + new_offset
	var/list/origins = list(list(ox + fx - sx, oy + fy - sy))
	for(var/list/origin in origins)
		var/this_x = origin[1]
		var/this_y = origin[2]
		var/turf/T = get_turf(src)
		while(this_x > 16)
			T = get_step(T, EAST)
			this_x -= 32
		while(this_x < -16)
			T = get_step(T, WEST)
			this_x += 32
		while(this_y > 16)
			T = get_step(T, NORTH)
			this_y -= 32
		while(this_y < -16)
			T = get_step(T, SOUTH)
			this_y += 32
		if(!T)
			continue
		var/obj/item/projectile/proj = new proj_type(T)
		proj.starting = T
		if(gunner)
			proj.firer = gunner
		proj.def_zone = "chest"
		proj.original = target
		proj.pixel_x = round(this_x)
		proj.pixel_y = round(this_y)
		if(isovermap(target) && explosive) //If we're firing a torpedo, the enemy's PDCs need to worry about it.
			var/obj/structure/overmap/OM = target
			OM.torpedoes_to_target += proj //We're firing a torpedo, their PDCs will need to shoot it down, so notify them of its existence
		if(homing)
			proj.set_homing_target(target)
		spawn()
			proj.fire(angle)
			proj.set_pixel_speed(speed)

/obj/structure/overmap/proc/fire_projectiles(proj_type, target) // if spacepods of other sizes are added override this or something
	var/fx = cos(90 - angle)
	var/fy = sin(90 - angle)
	var/sx = fy
	var/sy = -fx
	var/new_offset = sprite_size/4
	var/ox = (offset_x * 32) + new_offset
	var/oy = (offset_y * 32) + new_offset
	var/list/origins = list(list(ox + fx*new_offset - sx*new_offset, oy + fy*new_offset - sy*new_offset), list(ox + fx*new_offset + sx*new_offset, oy + fy*new_offset + sy*new_offset))
	for(var/list/origin in origins)
		var/this_x = origin[1]
		var/this_y = origin[2]
		var/turf/T = get_turf(src)
		while(this_x > 16)
			T = get_step(T, EAST)
			this_x -= 32
		while(this_x < -16)
			T = get_step(T, WEST)
			this_x += 32
		while(this_y > 16)
			T = get_step(T, NORTH)
			this_y -= 32
		while(this_y < -16)
			T = get_step(T, SOUTH)
			this_y += 32
		if(!T)
			continue
		var/obj/item/projectile/proj = new proj_type(T)
		proj.starting = T
		if(gunner)
			proj.firer = gunner
		proj.def_zone = "chest"
		proj.original = target
		proj.pixel_x = round(this_x)
		proj.pixel_y = round(this_y)
		spawn()
			proj.fire(angle)

/obj/structure/overmap/proc/fire_lateral_projectile(proj_type,target,speed=null)
	var/turf/T = get_turf(src)
	var/obj/item/projectile/proj = new proj_type(T)
	proj.starting = T
	if(gunner)
		proj.firer = gunner
	proj.def_zone = "chest"
	proj.original = target
	proj.pixel_x = round(pixel_x)
	proj.pixel_y = round(pixel_y)
	var/theangle = Get_Angle(src,target)
	spawn()
		proj.fire(theangle)
		if(speed)
			proj.set_pixel_speed(speed)
