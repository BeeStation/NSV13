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
	layer = WALL_OBJ_LAYER

/**

ATTENTION ADMINS. This proc is important, EXTREMELY important. In fact, welcome to your new religion.

This proc is to be used when someone gets stuck in an overmap ship, gauss, WHATEVER. You should no longer have to use the ancient chimp technique to unfuck people, use this instead, way cleaner, AND no monkies to boot!

*/
#define VV_HK_UNFUCK_OVERMAP "unFuckOvermap"

/mob/living/proc/unfuck_overmap()
	if(overmap_ship)
		overmap_ship.stop_piloting(src)
	for(var/datum/action/innate/camera_off/overmap/fuckYOU in actions)
		if(!istype(fuckYOU))
			continue
		qdel(fuckYOU) //Because this is a thing. Sure. Ok buddy.
	sleep(1) //Ok, are they still scuffed? Time to manually fix them...
	if(!overmap_ship)
		return //OK cool we're done here.
	remote_control = null
	overmap_ship = null
	cancel_camera()
	focus = src
	if(!client)
		return //Early return instead of possibly making 4 worthless reads. Is this a dumb microopt? Yes.
	client.pixel_x = 0
	client.pixel_y = 0
	client.overmap_zoomout = 0
	client.view_size.resetToDefault()

/mob/living/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_UNFUCK_OVERMAP, "Unfuck Overmap")

/mob/living/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_UNFUCK_OVERMAP])
		if(!check_rights(NONE))
			return
		unfuck_overmap()

/obj/structure/overmap
	var/last_process = 0
	var/processing_failsafe = FALSE //Has the game lagged to shit and we need to handle our own processing until it clears up?
	var/obj/vector_overlay/vector_overlay
	var/pixel_collision_size_x = 0
	var/pixel_collision_size_y = 0
	var/matrix/vector/offset
	var/matrix/vector/last_offset
	var/matrix/vector/position
	var/matrix/vector/velocity
	var/matrix/vector/overlap // Will be subtracted from the ships offset as soon as possible, then set to 0
	var/list/collision_positions = list() //See the collisions doc for how these work. Theyre a pain in the ass.
	var/datum/component/physics2d/physics2d = null

/// This makes us not drift like normal objects in space do
/obj/structure/overmap/Process_Spacemove(movement_dir = 0)
	return 1

/// Helper proc to get the actual center of the ship, if the ship's hitbox is placed in the bottom left corner like they usually are.
/obj/structure/overmap/proc/get_center()
	RETURN_TYPE(/turf)
	return (bound_height > 32 && bound_height > 32) ? get_turf(locate((src.x+(pixel_collision_size_x/32)/2), src.y+((pixel_collision_size_y/32)/2), z)) : get_turf(src)
	/*
	if(bound_width <= 64)
		return get_turf(src)
	return locs[round(locs.len / 2)+1]
	*/

/obj/structure/overmap/proc/get_pixel_bounds()
	for(var/turf/T in obounds(src, pixel_x + pixel_collision_size_x/4, pixel_y + pixel_collision_size_y/4, pixel_x  + -pixel_collision_size_x/4, pixel_y + -pixel_collision_size_x/4) )//Forms a zone of 4 quadrants around the desired overmap using some math fuckery.
		to_chat(world, "FOO!")
		T.SpinAnimation()

/obj/structure/overmap/proc/show_bounds()
	for(var/turf/T in locs)
		T.SpinAnimation()

/obj/effect/overmap_hitbox_marker
	name = "Hitbox display"
	icon = 'nsv13/icons/overmap/default.dmi'
	icon_state = "hitbox_marker"

/obj/effect/overmap_hitbox_marker/Initialize(mapload, pixel_x, pixel_y, pixel_z, pixel_w)
	. = ..()
	src.pixel_x = pixel_x
	src.pixel_y = pixel_y
	src.pixel_z = pixel_z
	src.pixel_w = pixel_w

//Method to show the hitbox of your current ship to see if youve set it up correctly
/obj/structure/overmap/proc/display_hitbox()
	if(!collision_positions.len)
		return

	for(var/matrix/vector/point in collision_positions)
		var/obj/effect/overmap_hitbox_marker/H = new(src, point.a, point.e, abs(pixel_z), abs(pixel_w))
		vis_contents += H

/obj/structure/overmap/proc/can_move()
	return TRUE //Placeholder for everything but fighters. We can later extend this if / when we want to code in ship engines.

#define RELEASE_PRESSURE ONE_ATMOSPHERE

/obj/structure/overmap/proc/slowprocess()
	set waitfor = FALSE
	//SS Crit Timer
	if(structure_crit)
		if(world.time > last_critprocess + 1 SECONDS)
			last_critprocess = world.time
			handle_critical_failure_part_1()
	disruption = max(0, disruption - 1)
	if(hullburn > 0)
		hullburn = max(0, hullburn - 1)
		take_damage(hullburn_power, BURN, "fire", FALSE, TRUE) //If you want a ship to be resistant to hullburn, just give it fire armor.
		if(hullburn == 0)
			hullburn_power = 0
	ai_process()
	if(!cabin_air)
		return
	//Atmos stuff, this updates once every tick
	if(cabin_air.return_volume() > 0)
		var/delta = cabin_air.return_temperature() - T20C
		cabin_air.set_temperature(cabin_air.return_temperature() - max(-10, min(10, round(delta/4,0.1))))
	if(internal_tank)
		var/datum/gas_mixture/tank_air = internal_tank.return_air()
		var/cabin_pressure = cabin_air.return_pressure()
		var/pressure_delta = min(RELEASE_PRESSURE - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
		var/transfer_moles = 0
		if(pressure_delta > 0) //cabin pressure lower than release pressure
			if(tank_air.return_temperature() > 0)
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
				cabin_air.merge(removed)
		else if(pressure_delta < 0) //cabin pressure higher than release pressure
			var/turf/T = get_center()
			if(!T)
				return
			var/datum/gas_mixture/t_air = T.return_air()
			pressure_delta = cabin_pressure - RELEASE_PRESSURE
			if(t_air)
				pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
			if(pressure_delta > 0) //if location pressure is lower than cabin pressure
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
				T.assume_air(removed)

#undef RELEASE_PRESSURE

/obj/structure/overmap/process()
	set waitfor = FALSE
	var/time = min(world.time - last_process, 10)
	time /= 10 // fuck off deciseconds - I don't even know what you were thinking here Monster, but okay.
	last_process = world.time
	if(world.time > last_slowprocess + 0.7 SECONDS)
		last_slowprocess = world.time
		slowprocess(time SECONDS)
	last_offset.copy(offset)
	var/last_angle = angle
	if(!move_by_mouse && !ai_controlled)
		desired_angle = angle + keyboard_delta_angle_left + keyboard_delta_angle_right + movekey_delta_angle
		movekey_delta_angle = 0
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

	var/velocity_mag = velocity.ln() // magnitude
	if(velocity_mag > 0 && !SSmapping.level_trait(src.z, ZTRAIT_OVERMAP))
		var/drag = 0
		var/has_gravity = get_center()?.has_gravity()
		for(var/turf/T in locs)
			if(isspaceturf(T))
				continue
			drag += 0.001
			var/floating = (movement_type & FLYING)
			if(has_gravity && velocity_mag >= 4)
				floating = TRUE // Count them as "flying" if theyre going fast enough indoors. If you slow down, you start to scrape due to no lift or something
			var/datum/gas_mixture/env = T.return_air()
			var/pressure = env.return_pressure()
			drag += velocity_mag * pressure * 0.001 // 1 atmosphere should shave off 10% of velocity per tile
			if(pressure >= 10) //Space doesn't have air resistance or much gravity, so we'll assume theyre floating if theyre in space.
				if((!floating && has_gravity)) // brakes are a kind of magboots okay?
					drag += 0.5 // some serious drag. Damn.
					if(velocity_mag <= 2 && istype(T, /turf/open/floor) && prob(30))
						var/turf/open/floor/TF = T
						TF.make_plating() // pull up some floor tiles. Stop going so damn slow, ree.
						take_damage(3, BRUTE, "melee", FALSE)

		if(velocity_mag > 20)
			drag = max(drag, (velocity_mag - 20) / time)
		if(drag)
			var/drag_factor = 1 - CLAMP(drag * time / velocity_mag, 0, 1)
			velocity.a *= drag_factor
			velocity.e *= drag_factor
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
		var/forward_thrust = -((fx * velocity.a) + (fy * velocity.e)) / time
		var/right_thrust = -((sx * velocity.a) + (sy * velocity.e)) / time
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
	velocity.a = clamp(velocity.a, -speed_limit, speed_limit)
	velocity.e = clamp(velocity.e, -speed_limit, speed_limit)

	velocity.a += thrust_x * time //And speed us up based on how long we've been thrusting (up to a point)
	velocity.e += thrust_y * time
	if(inertial_dampeners) //An optional toggle to make capital ships more "fly by wire" and help you steer in only the direction you want to go.
		var/side_movement = (sx*velocity.a) + (sy*velocity.e)
		var/friction_impulse = ((mass / 10) + side_maxthrust) * time //Weighty ships generate more space friction
		var/clamped_side_movement = CLAMP(side_movement, -friction_impulse, friction_impulse)
		velocity.a -= clamped_side_movement * sx
		velocity.e -= clamped_side_movement * sy

	offset._set(offset.a + velocity.a * time, offset.e +  velocity.e * time, TRUE)

	position._set(x * 32 + offset.a * 32, y * 32 + offset.e * 32)

	if(physics2d)
		physics2d.update(position.a, position.e, angle)

	// alright so now we reconcile the offsets with the in-world position.
	while((offset.a != 0 && velocity.a != 0) || (offset.e != 0 && velocity.e != 0))
		var/failed_x = FALSE
		var/failed_y = FALSE
		if(offset.a > 0 && velocity.a > 0)
			dir = EAST
			if(!Move(get_step(src, EAST)))
				offset.a = 0
				failed_x = TRUE
				velocity.a *= -bounce_factor
				velocity.e *= lateral_bounce_factor
			else
				offset.a--
				last_offset.a--
		else if(offset.a < 0 && velocity.a < 0)
			dir = WEST
			if(!Move(get_step(src, WEST)))
				offset.a = 0
				failed_x = TRUE
				velocity.a *= -bounce_factor
				velocity.e *= lateral_bounce_factor
			else
				offset.a++
				last_offset.a++
		else
			failed_x = TRUE
		if(offset.e > 0 && velocity.e > 0)
			dir = NORTH
			if(!Move(get_step(src, NORTH)))
				offset.e = 0
				failed_y = TRUE
				velocity.e *= -bounce_factor
				velocity.a *= lateral_bounce_factor
			else
				offset.e--
				last_offset.e--
		else if(offset.e < 0 && velocity.e < 0)
			dir = SOUTH
			if(!Move(get_step(src, SOUTH)))
				offset.e = 0
				failed_y = TRUE
				velocity.e *= -bounce_factor
				velocity.a *= lateral_bounce_factor
			else
				offset.e++
				last_offset.e++
		else
			failed_y = TRUE
		if(failed_x && failed_y)
			break
	// prevents situations where you go "wtf I'm clearly right next to it" as you enter a stationary spacepod
	if(velocity.a == 0)
		if(offset.a > 0.5)
			if(Move(get_step(src, EAST)))
				offset.a--
				last_offset.a--
			else
				offset.a = 0
		if(offset.a < -0.5)
			if(Move(get_step(src, WEST)))
				offset.a++
				last_offset.a++
			else
				offset.a = 0
	if(velocity.e == 0)
		if(offset.e > 0.5)
			if(Move(get_step(src, NORTH)))
				offset.e--
				last_offset.e--
			else
				offset.e = 0
		if(offset.e < -0.5)
			if(Move(get_step(src, SOUTH)))
				offset.e++
				last_offset.e++
			else
				offset.e = 0
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
	if(pilot?.client && desired_angle && !move_by_mouse && vector_overlay)//Preconditions: Pilot is logged in and exists, there is a desired angle, we are NOT moving by mouse (dont need to see where we're steering if it follows mousemovement)
		vector_overlay.transform = targetAngle
		vector_overlay.alpha = 255
	else
		vector_overlay?.alpha = 0
		targetAngle = null
	transform = mat_from

	pixel_x = last_offset.a*32
	pixel_y = last_offset.e*32

	animate(src, transform=mat_to, pixel_x = offset.a*32, pixel_y = offset.e*32, time = time*10, flags=ANIMATION_END_NOW)
	/*
	if(last_target)
		var/target_angle = Get_Angle(src,last_target)
		var/matrix/final = matrix()
		final.Turn(target_angle)
		if(last_fired)
			last_fired.transform = final
	else if(last_fired)
		last_fired.transform = mat_to
	*/ //We don't use these overlays for now, but we may wish to later.

	for(var/mob/living/M as() in operators)
		var/client/C = M.client
		if(!C)
			continue
		C.pixel_x = last_offset.a*32
		C.pixel_y = last_offset.e*32
		animate(C, pixel_x = offset.a*32, pixel_y = offset.e*32, time = time*10, flags=ANIMATION_END_NOW)
	user_thrust_dir = 0
	update_icon()
	if(autofire_target && !aiming)
		if(!gunner) //Just...just no. If we don't have this, you can get shot to death by your own fighter after youve already left it :))
			autofire_target = null
			return
		fire(autofire_target)

	// Lock handling
	for(var/obj/structure/overmap/OM in target_painted)
		if(target_painted[OM]) // Datalink target, something else is handling tracking for us
			continue
		if(overmap_dist(src, OM) < max(dradis ? dradis.sensor_range * 2 : SENSOR_RANGE_DEFAULT, OM.sensor_profile) && OM.is_sensor_visible(src))
			target_last_tracked[OM] = world.time // We can see the target, update tracking time
			continue
		if(target_last_tracked[OM] + target_loss_time < world.time)
			if(gunner)
				to_chat(gunner, "<span class='warning'>Target [OM] lost.</span>")
			dump_lock(OM) // We lost the track

/obj/structure/overmap/small_craft/collide(obj/structure/overmap/other, datum/collision_response/c_response, collision_velocity)
	addtimer(VARSET_CALLBACK(src, layer, ABOVE_MOB_LAYER), 0.5 SECONDS)
	layer = LOW_OBJ_LAYER // Stop us from just bumping right into them after we bounce
	if(docking_act(other))
		return
	return ..()

/obj/structure/overmap/proc/collide(obj/structure/overmap/other, datum/collision_response/c_response, collision_velocity)
	//No colliders. But we still get a lot of info anyways!
	if(!c_response)
		handle_cloak(CLOAK_TEMPORARY_LOSS)

		var/src_vel_mag = src.velocity.ln()
		var/other_vel_mag = other.velocity.ln()
		//I mean, the angle between the two objects is very likely to be the angle of incidence innit
		var/col_angle = ATAN2((other.position.a + other.pixel_collision_size_x / 2) - (src.position.a + src.pixel_collision_size_x / 2), (other.position.e + other.pixel_collision_size_y / 2) - (src.position.e + pixel_collision_size_y / 2))

		//Debounce
		if(((cos(src.velocity.angle() - col_angle) * src_vel_mag) - (cos(other.velocity.angle() - col_angle) * other_vel_mag)) < 0)
			return

		// Elastic collision equations
		var/new_src_vel_x = ((																			\
			(src_vel_mag * cos(src.velocity.angle() - col_angle) * (src.mass - other.mass)) +			\
			(2 * other.mass * other_vel_mag * cos(other.velocity.angle() - col_angle))					\
		) / (src.mass + other.mass)) * cos(col_angle) + (src_vel_mag * sin(src.velocity.angle() - col_angle) * cos(col_angle + 90))

		var/new_src_vel_y = ((																			\
			(src_vel_mag * cos(src.velocity.angle() - col_angle) * (src.mass - other.mass)) +			\
			(2 * other.mass * other_vel_mag * cos(other.velocity.angle() - col_angle))					\
		) / (src.mass + other.mass)) * sin(col_angle) + (src_vel_mag * sin(src.velocity.angle() - col_angle) * sin(col_angle + 90))

		var/new_other_vel_x = ((																		\
			(other_vel_mag * cos(other.velocity.angle() - col_angle) * (other.mass - src.mass)) +		\
			(2 * src.mass * src_vel_mag * cos(src.velocity.angle() - col_angle))						\
		) / (other.mass + src.mass)) * cos(col_angle) + (other_vel_mag * sin(other.velocity.angle() - col_angle) * cos(col_angle + 90))

		var/new_other_vel_y = ((																		\
			(other_vel_mag * cos(other.velocity.angle() - col_angle) * (other.mass - src.mass)) +		\
			(2 * src.mass * src_vel_mag * cos(src.velocity.angle() - col_angle))						\
		) / (other.mass + src.mass)) * sin(col_angle) + (other_vel_mag * sin(other.velocity.angle() - col_angle) * sin(col_angle + 90))

		src.velocity._set(new_src_vel_x, new_src_vel_y)
		other.velocity._set(new_other_vel_x, new_other_vel_y)

		var/bonk = src_vel_mag//How much we got bonked
		var/bonk2 = other_vel_mag //Vs how much they got bonked
		//Prevent ultra spam.
		if(!impact_sound_cooldown && (bonk > 2 || bonk2 > 2))
			bonk *= 5 //The rammer gets an innate penalty, to discourage ramming metas.
			bonk2 *= 5
			take_quadrant_hit(bonk, projectile_quadrant_impact(other)) //This looks horrible, but trust me, it isn't! Probably!. Armour_quadrant.dm for more info
			other.take_quadrant_hit(bonk2, projectile_quadrant_impact(src)) //This looks horrible, but trust me, it isn't! Probably!. Armour_quadrant.dm for more info

			log_game("[key_name(pilot)] has impacted an overmap ship into [other] with velocity [bonk]")

		return TRUE

	//Update the colliders before we do any kind of calc.
	if(physics2d)
		physics2d.update(position.a, position.e, angle)
	if(other.physics2d)
		other.physics2d.update(other.position.a, other.position.e, angle)
	var/matrix/vector/point_of_collision = physics2d?.collider2d.get_collision_point(other.physics2d?.collider2d)
	check_quadrant(point_of_collision)

	//So what this does is it'll calculate a vector (overlap_vector) that makes the two objects no longer colliding, then applies extra velocity to make the collision smooth to avoid teleporting. If you want to tone down collisions even more
	//Be sure that you change the 0.25/32 bit as well, otherwise, if the cancelled out vector is too large compared to the speed jump, you just get teleportation and it looks really jank ~K
	if (point_of_collision)
		var/col_angle = c_response.overlap_normal.angle()
		var/src_vel_mag = src.velocity.ln()
		var/other_vel_mag = other.velocity.ln()

		// Elastic collision equations
		var/new_src_vel_x = ((																			\
			(src_vel_mag * cos(src.velocity.angle() - col_angle) * (src.mass - other.mass)) +			\
			(2 * other.mass * other_vel_mag * cos(other.velocity.angle() - col_angle))					\
		) / (src.mass + other.mass)) * cos(col_angle) + (src_vel_mag * sin(src.velocity.angle() - col_angle) * cos(col_angle + 90))

		var/new_src_vel_y = ((																			\
			(src_vel_mag * cos(src.velocity.angle() - col_angle) * (src.mass - other.mass)) +			\
			(2 * other.mass * other_vel_mag * cos(other.velocity.angle() - col_angle))					\
		) / (src.mass + other.mass)) * sin(col_angle) + (src_vel_mag * sin(src.velocity.angle() - col_angle) * sin(col_angle + 90))

		var/new_other_vel_x = ((																		\
			(other_vel_mag * cos(other.velocity.angle() - col_angle) * (other.mass - src.mass)) +		\
			(2 * src.mass * src_vel_mag * cos(src.velocity.angle() - col_angle))						\
		) / (other.mass + src.mass)) * cos(col_angle) + (other_vel_mag * sin(other.velocity.angle() - col_angle) * cos(col_angle + 90))

		var/new_other_vel_y = ((																		\
			(other_vel_mag * cos(other.velocity.angle() - col_angle) * (other.mass - src.mass)) +		\
			(2 * src.mass * src_vel_mag * cos(src.velocity.angle() - col_angle))						\
		) / (other.mass + src.mass)) * sin(col_angle) + (other_vel_mag * sin(other.velocity.angle() - col_angle) * sin(col_angle + 90))

		src.velocity._set(new_src_vel_x*bounce_factor, new_src_vel_y*bounce_factor)
		other.velocity._set(new_other_vel_x*other.bounce_factor, new_other_vel_y*other.bounce_factor)
	var/matrix/vector/output = c_response.overlap_vector * (0.25 / 32)
	src.offset -= output
	other.offset += output

/obj/structure/overmap/Bumped(atom/movable/A)
	if(brakes || isovermap(A)) //No :)
		return FALSE
	handle_cloak(CLOAK_TEMPORARY_LOSS)
	if(A.dir & NORTH)
		velocity.e += bump_impulse
	if(A.dir & SOUTH)
		velocity.e -= bump_impulse
	if(A.dir & EAST)
		velocity.a += bump_impulse
	if(A.dir & WEST)
		velocity.a -= bump_impulse
	return ..()

/obj/structure/overmap/Bump(atom/movable/A, datum/collision_response/c_response)
	var/bump_velocity = 0
	if(dir & (NORTH|SOUTH))
		bump_velocity = abs(velocity.e) + (abs(velocity.a) / 10)
	else
		bump_velocity = abs(velocity.a) + (abs(velocity.e) / 10)
	if(istype(A, /obj/machinery/door/airlock) && should_open_doors) // try to open doors
		var/obj/machinery/door/D = A
		if(!D.operating)
			if(D.allowed(D.id_scan_hacked() ? pilot : null))
				spawn(0)
					D.open()
			else
				D.do_animate("deny")
	if(layer < A.layer) //Allows ships to "Layer under" things and not hit them. Especially useful for fighters.
		return ..()
	// if a bump is that fast then it's not a bump. It's a collision.
	if(istype(A, /obj/structure/overmap))
		collide(A, c_response, bump_velocity)
		return FALSE
	if(isprojectile(A)) //Clears up some weirdness with projectiles doing MEGA damage.
		return ..()
	handle_cloak(CLOAK_TEMPORARY_LOSS)
	if(bump_velocity >= 3 && !impact_sound_cooldown && isobj(A)) //Throttled collision damage a bit
		var/obj/O = A
		var/strength = bump_velocity
		strength = strength * strength
		strength = min(strength, 5) // don't want the explosions *too* big
		// wew lad, might wanna slow down there
		message_admins("[key_name_admin(pilot)] has impacted an overmap ship into [A] with velocity [bump_velocity]")
		take_damage(strength*10, BRUTE, "melee", TRUE)
		O.take_damage(strength*5, BRUTE, "melee", TRUE)
		log_game("[key_name(pilot)] has impacted an overmap ship into [A] with velocity [bump_velocity]")
		visible_message("<span class='danger'>The force of the impact causes a shockwave</span>")
	var/atom/movable/AM = A
	if(istype(AM) && !AM.anchored && bump_velocity > 1)
		step(AM, dir)
	if(isliving(A) && bump_velocity > 2)
		var/mob/living/M = A
		M.apply_damage(bump_velocity * 2)
		take_damage(bump_velocity, BRUTE, "melee", FALSE)
		playsound(M.loc, "swing_hit", 1000, 1, -1)
		M.Knockdown(bump_velocity * 2)
		M.visible_message("<span class='warning'>The force of the impact knocks [M] down!</span>","<span class='userdanger'>The force of the impact knocks you down!</span>")
		log_combat(pilot, M, "impacted", src, "with velocity of [bump_velocity]")
	return ..()

/obj/structure/overmap/proc/fire_projectile(proj_type, atom/target, speed=null, user_override=null, lateral=FALSE, ai_aim = FALSE, miss_chance=5, max_miss_distance=5, broadside=FALSE) //Fire one shot. Used for big, hyper accelerated shots rather than PDCs
	if(!z || QDELETED(src))
		return FALSE
	var/turf/T = get_center()
	var/obj/item/projectile/proj = new proj_type(T)
	if(ai_aim && !proj.can_home && !proj.hitscan)
		target = calculate_intercept(target, proj, miss_chance=miss_chance, max_miss_distance=max_miss_distance)
	proj.starting = T
	if(user_override)
		proj.firer = user_override
	else if(gunner)
		proj.firer = gunner
	else
		proj.firer = src
	proj.def_zone = "chest"
	proj.original = target
	proj.overmap_firer = src
	proj.pixel_x = round(pixel_x)
	proj.pixel_y = round(pixel_y)
	proj.faction = faction
	if(physics2d && physics2d.collider2d)
		proj.setup_collider()
	if(proj.can_home)	// Handles projectile homing and alerting the target
		if(!isturf(target))
			proj.set_homing_target(target)
		else if((length(target_painted) > 0))
			if(!target_lock) // no selected target, fire at the first one in our list
				proj.set_homing_target(target_painted[1])
			else if(target_painted.Find(target_lock)) // Fire at a manually selected target
				proj.set_homing_target(target_lock)
			else // something fucked up, dump the lock
				target_lock = null
		if(isovermap(proj.homing_target))
			var/obj/structure/overmap/overmap_target = proj.homing_target
			overmap_target.on_missile_lock(src, proj)

	LAZYINITLIST(proj.impacted) //The spawn call after this might be causing some issues so the list should exist before async actions.

	spawn()
		proj.preparePixelProjectileOvermap(target, src, null, round((rand() - 0.5) * proj.spread), lateral=lateral)
		proj.fire()
		if(!lateral)
			proj.setAngle(src.angle)
		if(broadside)
			if(angle2dir_ship(overmap_angle(src, target) - angle) == SOUTH)
				proj.setAngle(src.angle + rand(90 - proj.spread, 90 + proj.spread))
			else
				proj.setAngle(src.angle + rand(270 - proj.spread, 270 + proj.spread))
		//Sometimes we want to override speed.
		if(speed)
			proj.set_pixel_speed(speed)
	//	else
	//		proj.set_pixel_speed(proj.speed)
	return proj

//Jank as hell. This needs to happen to properly set the visual offset :/
/obj/item/projectile/proc/preparePixelProjectileOvermap(obj/structure/overmap/target, obj/structure/overmap/source, params, spread = 0, lateral=TRUE)
	var/turf/curloc = source.get_center()
	var/turf/targloc = istype(target, /obj/structure/overmap) ? target.get_center() : get_turf(target)
	trajectory_ignore_forcemove = TRUE
	doMove(curloc)
	trajectory_ignore_forcemove = FALSE
	starting = curloc
	original = target
	if(!lateral)
		setAngle(source.angle)

	if(isliving(source) && params)
		var/list/calculated = calculate_projectile_angle_and_pixel_offsets(source, params)
		p_x = calculated[2]
		p_y = calculated[3]

		if(lateral)
			setAngle(calculated[1] + spread)
	else if(targloc && curloc)
		yo = targloc.y - curloc.y
		xo = targloc.x - curloc.x
		if(lateral)
			setAngle(overmap_angle(src, targloc) + spread)
	else
		stack_trace("WARNING: Projectile [type] fired without either mouse parameters, or a target atom to aim at!")
		qdel(src)

/// This makes us not drift like normal objects in space do
/obj/structure/overmap/Process_Spacemove(movement_dir = 0)
	return 1
