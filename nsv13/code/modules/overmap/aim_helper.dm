/obj/structure/overmap
	var/atom/autofire_target = null //Are we clicking and holding to shoot our guns?

/obj/structure/overmap/proc/onMouseDrag(src_object, over_object, src_location, over_location, params, mob/M)
	if(aiming)
		lastangle = getMouseAngle(params, M)
		draw_beam()
	else
		autofire_target = over_object


/obj/structure/overmap/proc/onMouseDown(object, location, params, mob/M)
	if(istype(object, /obj/screen) && !istype(object, /obj/screen/click_catcher))
		return
	if((object in M.contents) || (object == M))
		return
	if(fire_mode == FIRE_MODE_MAC || fire_mode == FIRE_MODE_BLUE_LASER)
		start_aiming(params, M)
	else
		autofire_target = object

/obj/structure/overmap/proc/onMouseUp(object, location, params, mob/M)
	if(istype(object, /obj/screen) && !istype(object, /obj/screen/click_catcher))
		return
	autofire_target = null
	lastangle = getMouseAngle(params, M)
	stop_aiming()
	if(fire_mode == FIRE_MODE_MAC || fire_mode == FIRE_MODE_BLUE_LASER)
		fire_weapon(object)
	QDEL_LIST(current_tracers)

/obj/structure/overmap
	var/next_beam = 0

/obj/structure/overmap/proc/draw_beam(force_update = FALSE)
	var/diff = abs(aiming_lastangle - lastangle)
	check_user()
	if(diff < AIMING_BEAM_ANGLE_CHANGE_THRESHOLD || world.time < next_beam && !force_update)
		return
	next_beam = world.time + 0.05 SECONDS
	aiming_lastangle = lastangle
	var/obj/item/projectile/beam/overmap/aiming_beam/P = new
	P.gun = src
	P.color = "#99ff99"
	var/turf/curloc = get_turf(src)
	var/turf/targloc = get_turf(gunner.client.mouseObject)
	if(!istype(targloc))
		if(!istype(curloc))
			return
		targloc = get_turf_in_angle(lastangle, curloc, 10)
	P.preparePixelProjectile(targloc, src, gunner.client.mouseParams, 0)
	P.layer = BULLET_HOLE_LAYER
	P.fire(lastangle)

/obj/structure/overmap/proc/check_user(automatic_cleanup = TRUE)
	if(!istype(gunner) || gunner.incapacitated())
		if(automatic_cleanup)
			stop_aiming()
		return FALSE
	return TRUE

/obj/structure/overmap/proc/start_aiming(params, mob/M)
	lastangle = getMouseAngle(params, M)
	aiming = TRUE
	draw_beam(TRUE)

/obj/structure/overmap/proc/stop_aiming()
	aiming = FALSE
	QDEL_LIST(current_tracers)

/obj/structure/overmap/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/item/projectile/beam/overmap/aiming_beam))
		var/obj/item/projectile/beam/overmap/aiming_beam/AB = mover
		if (src == AB.gun)
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
			// I don't know why these "dead zones" appear and override the normal lines, but there is a pattern, so I'm gonna use it
			if((p.x != 273) && (p.x != 7889) && (p.y != 273) && (p.y != 7889))
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
