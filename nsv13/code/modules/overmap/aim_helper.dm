/obj/structure/overmap/proc/onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	if(aiming)
		process_aim(params, mob)
		draw_beam()
	return ..()

/obj/structure/overmap/proc/onMouseDown(object, location, params, mob/mob)
	if(istype(mob))
		set_user(mob)
	if(istype(object, /obj/screen) && !istype(object, /obj/screen/click_catcher))
		return
	if((object in mob.contents) || (object == mob))
		return
	if(fire_mode == FIRE_MODE_RAILGUN)
		start_aiming(object, location, params, mob)
	return ..()

/obj/structure/overmap/proc/onMouseUp(object, location, params, mob/M)
	if(istype(object, /obj/screen) && !istype(object, /obj/screen/click_catcher))
		return
	process_aim(params, M)
	stop_aiming()
	QDEL_LIST(current_tracers)
	return ..()

/obj/structure/overmap/proc/delay_penalty(amount)
	aiming_time_left = CLAMP(aiming_time_left + amount, 0, aiming_time)

/obj/structure/overmap/proc/draw_beam(force_update = FALSE)
	var/diff = abs(aiming_lastangle - lastangle)
	check_user()
	if(diff < AIMING_BEAM_ANGLE_CHANGE_THRESHOLD && !force_update)
		return
	aiming_lastangle = lastangle
	var/obj/item/projectile/beam/overmap/aiming_beam/P = new
	P.gun = src
	if(aiming_time)
		var/percent = ((100/aiming_time)*aiming_time_left)
		P.color = rgb(255 * percent,255 * ((100 - percent) / 100),0)
	else
		P.color = rgb(0, 255, 0)
	var/turf/curloc = get_turf(src)
	var/turf/targloc = get_turf(gunner.client.mouseObject)
	if(!istype(targloc))
		if(!istype(curloc))
			return
		targloc = get_turf_in_angle(lastangle, curloc, 10)
	P.preparePixelProjectile(targloc, src, gunner.client.mouseParams, 0)
	P.fire(lastangle)

/obj/structure/overmap/proc/do_aim_processing()
	if(!aiming)
		last_tracer_process = world.time
		return
	check_user()
	aiming_time_left = max(0, aiming_time_left - (world.time - last_tracer_process))
	draw_beam(TRUE)
	last_tracer_process = world.time

/obj/structure/overmap/proc/check_user(automatic_cleanup = TRUE)
	if(!istype(gunner) || gunner.incapacitated())
		if(automatic_cleanup)
			stop_aiming()
			set_user(null)
		return FALSE
	return TRUE

/obj/structure/overmap/proc/process_aim(params, mob)
	if(istype(gunner) && gunner.client && gunner.client.mouseParams)
		var/mouse_angle = getMouseAngle(params, mob)
		gunner.setDir(angle2dir_cardinal(mouse_angle))
		var/difference = abs(closer_angle_difference(lastangle, mouse_angle))
		delay_penalty(difference * aiming_time_increase_angle_multiplier)
		lastangle = mouse_angle

/obj/structure/overmap/proc/start_aiming()
	aiming_time_left = aiming_time
	aiming = TRUE
	process_aim()
	draw_beam(TRUE)

/obj/structure/overmap/proc/stop_aiming(mob/user)
	set waitfor = FALSE
	aiming_time_left = aiming_time
	aiming = FALSE
	QDEL_LIST(current_tracers)

/obj/structure/overmap/proc/set_user(mob/living/user)
	if(user == gunner)
		return
	stop_aiming(gunner)

/obj/structure/overmap/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/item/projectile/beam/overmap/aiming_beam))
		return TRUE
	. = ..()


/obj/item/projectile/beam/overmap/aiming_beam
	name = "aiming beam"
	icon = null
	hitsound = null
	hitsound_wall = null
	damage = 0				//Handled manually.
	nodamage = TRUE
	damage_type = BURN
	flag = "energy"
	range = 150
	jitter = 10
	var/obj/structure/overmap/gun
	icon_state = ""
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/tracer/aiming
	reflectable = REFLECT_FAKEPROJECTILE
	hitscan_light_range = 0
	hitscan_light_intensity = 0
	hitscan_light_color_override = "#99ff99"
	var/constant_tracer = TRUE

/obj/item/projectile/beam/overmap/aiming_beam/generate_hitscan_tracers(cleanup = TRUE, duration = 5, impacting = TRUE, highlander)
	set waitfor = FALSE
	if(isnull(highlander))
		highlander = constant_tracer
	if(highlander && istype(gun))
		var/list/obj/item/projectile/beam/overmap/aiming_beam/new_tracers = list()
		for(var/datum/point/p in beam_segments)
			if((pixel_length_between_points(p, beam_segments[p]) / world.icon_size) >= 100) // I hate this but it works
				new_tracers += generate_tracer_between_points(p, beam_segments[p], tracer_type, color, 0, hitscan_light_range, hitscan_light_color_override, hitscan_light_intensity)
		if(new_tracers.len)
			QDEL_LIST(gun.current_tracers)
			gun.current_tracers += new_tracers
	else
		for(var/datum/point/p in beam_segments)
			generate_tracer_between_points(p, beam_segments[p], tracer_type, color, duration, hitscan_light_range, hitscan_light_color_override, hitscan_light_intensity)
	if(cleanup)
		QDEL_LIST(beam_segments)
		beam_segments = null
		QDEL_NULL(beam_index)
