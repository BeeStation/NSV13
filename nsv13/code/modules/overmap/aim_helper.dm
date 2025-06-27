/obj/structure/overmap/onMouseDrag(src_object, over_object, src_location, over_location, params, mob/M)
	// Handle pilots dragging their mouse
	if(M == pilot)
		if(move_by_mouse && can_move() && !pilot.incapacitated())
			desired_angle = getMouseAngle(params, M)

	if(!over_object)
		return
	// If we're the pilot but not the gunner, don't update gunner-specific information
	if(!LAZYFIND(gauss_gunners, M) && M != gunner)
		return

	// Handle gunners dragging their mouse
	if(LAZYFIND(gauss_gunners, M)) // Anyone with overmap_gunning should also be in gauss_gunners
		var/datum/component/overmap_gunning/user_gun = M.GetComponent(/datum/component/overmap_gunning)
		user_gun.onMouseDrag(src_object, over_object, src_location, over_location, params, M)
		return TRUE
	//This aim stuff could use just being on the weapon datums, right? Might be messy to implement though, leaving that for now.
	if(aiming)
		var/datum/overmap_ship_weapon/aimed_weapon = controlled_weapon_datum[M]
		aiming_target = over_object
		if(aimed_weapon)
			var/real_aim_angle = overmap_angle(get_center(), over_location)
			last_aiming_angle = real_aim_angle
			if(aimed_weapon.weapon_aim_flags & OSW_AIMING_BEAM)
				lastangle = real_aim_angle
			else if((aimed_weapon.weapon_aim_flags & OSW_SIDE_AIMING_BEAM))
				if((((overmap_angle(src, over_location) - angle)%360)+360)%360 <= 180)
					lastangle = (angle + 90) % 360
				else
					lastangle = (angle + 270) % 360
			else
				stop_aiming()
				return
			draw_beam(aimed_weapon = aimed_weapon)
		else
			stop_aiming()
			return
	else
		autofire_target = over_object

/obj/structure/overmap/proc/onMouseDown(object, location, params, mob/M)
	if(istype(object, /atom/movable/screen) && !istype(object, /atom/movable/screen/click_catcher))
		return
	if(!object)
		return
	if((object in M.contents) || (object == M))
		return
	var/datum/component/overmap_gunning/user_gun = M.GetComponent(/datum/component/overmap_gunning)
	if(user_gun)
		user_gun?.onMouseDown(object)
		return TRUE
	if(M != gunner)
		return
	var/datum/overmap_ship_weapon/aimed_weapon = controlled_weapon_datum[M]
	if(aimed_weapon)
		if(aimed_weapon.weapon_aim_flags & (OSW_AIMING_BEAM|OSW_SIDE_AIMING_BEAM))
			aiming_target = object
			var/real_aim_angle =  overmap_angle(get_center(), location)
			last_aiming_angle = real_aim_angle
			if(aimed_weapon.weapon_aim_flags & OSW_AIMING_BEAM)
				lastangle = real_aim_angle
			else if(aimed_weapon.weapon_aim_flags & OSW_SIDE_AIMING_BEAM) //If the weapon fires from the sides, we want the aiming laser to lock to the sides
				if((((overmap_angle(get_center(), location) - angle)%360)+360)%360 <= 180)
					lastangle = (angle + 90) % 360
				else
					lastangle = (angle + 270) % 360
			start_aiming(params, M, aimed_weapon)
		else
			autofire_target = object

/obj/structure/overmap/proc/onMouseUp(object, location, params, mob/M)
	if(istype(object, /atom/movable/screen) && !istype(object, /atom/movable/screen/click_catcher))
		return
	var/datum/component/overmap_gunning/user_gun = M.GetComponent(/datum/component/overmap_gunning)
	if(user_gun)
		user_gun?.onMouseUp(object)
		return TRUE
	if(M != gunner)
		return
	autofire_target = null
	stop_aiming()
	if(!object)
		return
	lastangle = overmap_angle(get_center(), location)
	var/datum/overmap_ship_weapon/aimed_weapon = controlled_weapon_datum[M]
	if(aimed_weapon && istype(aimed_weapon))
		if(aimed_weapon.weapon_aim_flags & (OSW_AIMING_BEAM|OSW_SIDE_AIMING_BEAM))
			fire_weapon(object, M, aimed_weapon)

/obj/structure/overmap
	var/next_beam = 0
	///The real user aim that was aimed at last
	var/last_aiming_angle = 0


/obj/structure/overmap/Move(atom/newloc, direct)
	. = ..()
	if(!.)
		return
	if(!aiming || ai_controlled || !gunner || !controlled_weapon_datum[gunner]) //LL-OSW WIP - if you ever make aiming beams linked to the weapon datum, this has to go too.
		return
	var/datum/overmap_ship_weapon/aimed_weapon = controlled_weapon_datum[gunner]
	if(aimed_weapon.weapon_aim_flags & (OSW_AIMING_BEAM|OSW_SIDE_AIMING_BEAM))
		draw_beam(aimed_weapon = aimed_weapon, force_update = TRUE)


//LL-OSW WIP One day aimed_angle should replace lastangle and all those other vars on the overmap so multiple people can use it. Tracers potentially a var on OSW?
/**
 * Draws this ship's aiming beam
 * * draws using lastangle as angle, however last_aiming_angle is used for checks.
 * * force_update will cause the beam to be drawn bypassing delay or angular distance checks.
 * * aimed_weapon is the overmap weapon datum of the aiming weapon and used for behavior.
 */
/obj/structure/overmap/proc/draw_beam(force_update = FALSE, datum/overmap_ship_weapon/aimed_weapon)
	var/diff = abs(aiming_lastangle - lastangle)
	if(!check_user())
		return
	if(world.time < next_beam || (diff < AIMING_BEAM_ANGLE_CHANGE_THRESHOLD && !force_update))
		return
	next_beam = world.time + 0.05 SECONDS
	if(aimed_weapon && !aimed_weapon.check_valid_fire_angle(passed_angle = last_aiming_angle))
		QDEL_LIST(current_tracers) //Only draw beam if we can fire right now.
		return
	aiming_lastangle = lastangle
	var/obj/item/projectile/beam/overmap/aiming_beam/P = new
	P.gun = src
	P.color = "#99ff99"
	P.preparePixelProjectileOvermap(aiming_target, src)
	P.layer = BULLET_HOLE_LAYER
	P.fire(lastangle)

/obj/structure/overmap/proc/check_user(automatic_cleanup = TRUE)
	if(!istype(gunner) || gunner.incapacitated())
		if(automatic_cleanup)
			stop_aiming()
		return FALSE
	return TRUE

/obj/structure/overmap/proc/start_aiming(params, mob/M, datum/overmap_ship_weapon/aimed_weapon)
	aiming = TRUE
	draw_beam(TRUE, aimed_weapon)

/obj/structure/overmap/proc/stop_aiming()
	aiming = FALSE
	QDEL_LIST(current_tracers)
	aiming_target = null

/obj/structure/overmap/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/item/projectile/beam/overmap/aiming_beam))
		var/obj/item/projectile/beam/overmap/aiming_beam/AB = mover
		if(src == AB.gun)
			return TRUE
	return ..()


/obj/item/projectile/beam/overmap/aiming_beam
	name = "aiming beam"
	icon = null
	hitsound = null
	hitsound_wall = null
	damage = 0				//Handled manually.
	nodamage = TRUE
	damage_type = BURN
	flag = "energy"
	range = 40	//We don't need to cover 2/3rds of the system with our beam if we can barely see 30 tiles far.
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
