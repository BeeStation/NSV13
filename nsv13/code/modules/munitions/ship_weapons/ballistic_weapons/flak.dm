/obj/item/ammo_box/magazine/pdc/flak
	name = "40mm flak rounds"
	icon_state = "flak"
	ammo_type = /obj/item/ammo_casing/flak
	caliber = "mm40"
	max_ammo = 150

/obj/item/ammo_box/magazine/pdc/update_icon()
	if(ammo_count() > 10)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_empty"

/obj/item/ammo_casing/flak
	name = "mm40 flak round casing"
	desc = "A mm40 bullet casing."
	projectile_type = /obj/item/projectile/bullet/pdc_round
	caliber = "mm40"

/obj/machinery/ship_weapon/pdc_mount/flak
	name = "Flak loading rack"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "pdc"
	desc = "Seegson's all-in-one flak targeting computer and ammunition loader for defensive flak screens. These weapons, while crude, are still extremely effective, though rarely seen on smaller patrol craft due to their high running costs."
	anchored = TRUE
	density = FALSE
	pixel_y = 26
	maintainable = FALSE
	bang = FALSE
	safety = FALSE

//	circuit = /obj/item/circuitboard/machine/pdc_mount

	fire_mode = FIRE_MODE_FLAK
	magazine_type = /obj/item/ammo_box/magazine/pdc/flak

	auto_load = TRUE
	semi_auto = TRUE
	maintainable = FALSE
	max_ammo = 150

	// We're fully automatic, so just the loading sound is enough
	mag_load_sound = 'sound/weapons/autoguninsert.ogg'
	mag_unload_sound = 'sound/weapons/autoguninsert.ogg'
	feeding_sound = null
	fed_sound = null
	chamber_sound = null

	load_delay = 50
	unload_delay = 50

	// No added delay between shots or for feeding rounds
	feed_delay = 0
	chamber_delay_rapid = 0
	chamber_delay = 0
	bang = FALSE

/obj/machinery/ship_weapon/pdc_mount/flak/animate_projectile(atom/target)
	var/obj/item/projectile/bullet/B = ..()
	if(istype(B, /obj/item/projectile/bullet/flak))
		var/obj/item/projectile/bullet/flak/F = B
		F.steps_left = get_overmap().get_flak_range(target)

/obj/structure/overmap/proc/get_flak_range(atom/target)
	if(!target)
		target = src
	var/dist = (get_dist(src, target) / 1.5)
	var/minimum_safe_distance = pixel_collision_size_y / 32
	return (dist >= minimum_safe_distance) ? dist : minimum_safe_distance //Stops you flak-ing yourself

/obj/effect/temp_visual/flak
	icon = 'nsv13/goonstation/icons/effects/explosions/80x80.dmi'
	icon_state = "explosion"
	duration = 2.5 SECONDS
	bound_height = 96
	bound_width = 96
	alpha = 10
	var/faction = null
	var/flak_range = 2 //AOE where flak hits torpedoes. May need to buff this a bit.

/obj/effect/temp_visual/flak/Initialize(mapload, faction)
	. = ..()
	if(prob(50))
		icon = 'nsv13/goonstation/icons/effects/explosions/96x96.dmi'
	src.faction = faction
	animate(src, alpha = 255, time = rand(0, 2 SECONDS))

/obj/effect/temp_visual/flak/Crossed(atom/movable/AM) //Here, we check if the bullet that hit us is from a friendly ship. If it's from an enemy ship, we explode as we've been flak'd down.
	. = ..()
	if(!isprojectile(AM) && !istype(AM, /obj/structure/overmap))
		return
	//Distance from the "center" of the flak effect.
	var/dist = get_dist(locs[1], AM)
	dist = CLAMP(dist, 1, dist)
	var/severity = 1/dist
	var/obj/item/projectile/P = AM
	if(P.faction != faction) //Stops flak from FFing
		if(istype(AM, /obj/item/projectile/guided_munition))
			P.take_damage(severity*50, BRUTE, "overmap_light")
		if(isovermap(AM))
			P.take_damage(severity*20, BRUTE, "overmap_light")

/obj/item/projectile/bullet
	obj_integrity = 500 //Flak doesn't shoot this down....

/obj/item/projectile/bullet/flak
	icon_state = "bolter"
	name = "flak round"
	damage = 2
	flag = "overmap_light"
	alpha = 100
	var/steps_left = 10 //Flak range, AKA how many tiles can we move before we go kaboom
	var/exploded = FALSE

/obj/item/projectile/bullet/flak/Initialize(mapload, range=10)
	. = ..()
	steps_left = range
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/check_range)

/obj/item/projectile/bullet/flak/proc/explode()
	if(exploded)
		return FALSE
	if(!faction)
		if(ismob(firer))
			var/mob/living/M = firer
			faction = M.overmap_ship.faction
		else
			var/obj/structure/overmap/OM = firer
			if(istype(OM))
				faction = OM.faction
	alpha = 0 //We can keep going, who cares.
	exploded = TRUE
	var/turf/cached = get_turf(src)
	for(var/I = 0, I < rand(2,5), I++)
		var/edir = pick(GLOB.alldirs)
		new /obj/effect/temp_visual/flak(get_turf(get_step(cached, edir)), faction)

/obj/item/projectile/bullet/flak/on_hit(atom/target, blocked = 0)
	explode()
	. = ..()

/obj/item/projectile/bullet/flak/proc/check_range()
	steps_left --
	if(steps_left <= 0)
		explode()

/obj/item/projectile/guided_munition/Crossed(atom/movable/AM) //Here, we check if the bullet that hit us is from a friendly ship. If it's from an enemy ship, we explode as we've been flak'd down.
	. = ..()

	if(!isprojectile(AM))
		return

	var/obj/item/projectile/P = AM //This is hacky, refactor check_faction to unify both of these. I'm bodging it for now.
	if(P.damage <= 0)
		return

	if(isprojectile(AM) && P.faction != faction) //Because we could be in the same faction and collide with another bullet. Let's not blow ourselves up ok?
		if(obj_integrity <= P.damage) //Tank the hit, take some damage
			qdel(P)
			explode()
		else
			qdel(P)
			take_damage(P.damage)
			new /obj/effect/temp_visual/impact_effect(get_turf(src), rand(0,20), rand(0,20))

/obj/item/projectile/guided_munition/ex_act(severity)
	explode()

/obj/item/projectile/guided_munition/proc/explode()
	if(firer)
		var/obj/structure/overmap/OM
		if(ismob(firer))
			var/mob/checking = firer
			OM = checking.overmap_ship
		else
			OM = firer

		var/sound/chosen = pick('nsv13/sound/effects/ship/torpedo_detonate.ogg','nsv13/sound/effects/ship/freespace2/impacts/boom_2.wav','nsv13/sound/effects/ship/freespace2/impacts/boom_3.wav','nsv13/sound/effects/ship/freespace2/impacts/subhit.wav','nsv13/sound/effects/ship/freespace2/impacts/subhit2.wav','nsv13/sound/effects/ship/freespace2/impacts/m_hit.wav','nsv13/sound/effects/ship/freespace2/impacts/hit_1.wav')
		OM.relay_to_nearby(chosen)
	new shotdown_effect_type(get_turf(src)) //Exploding effect
	qdel(src)
	return FALSE
/*
	var/found_target = FALSE //Have we found a torpedo to shoot down? If we can't find a torpedo to shoot, look for enemy ships in range.
	if(torpedoes_to_target.len)  //Are there any torpedoes we need to worry about? Torpedoes enter this list as theyre shot (when they target us).
		for(var/atom/target in torpedoes_to_target) //Check through the torpedoes that our PDCs need to target
			if(!target || QDELETED(target)) //Clear null bullets that may have runtimed
				torpedoes_to_target -= target
				continue
			var/target_range = get_dist(target,src)
			if(target_range <= initial(weapon_range)) //The torpedo is in range, let's target it!
				found_target = TRUE
				if(prob(pdc_miss_chance)) //Gives them a chance to actually hit a torpedo, so it's not a perfect smokescreen.
					var/turf/T = get_turf(pick(orange(4,target))) //Pick a random tile within 6 turfs, this isn't a flat out miss 100% of the time though
					fire_weapon(T, mode=FIRE_MODE_PDC, lateral=TRUE)
				else
					if(!target || QDELETED(target))
						continue
					fire_weapon(target, mode=FIRE_MODE_PDC, lateral=TRUE)
	if(!found_target) //Can't see a torpedo to shoot, try find an enemy ship to shoot
		for(var/obj/structure/overmap/ship in GLOB.overmap_objects)
			if(!ship || !istype(ship, /obj/structure/overmap))
				continue
			if(ship == src || ship.faction == faction || ship.wrecked) //No friendly fire, don't blow up wrecks that the crew may wish to loot.
				continue
			var/target_range = get_dist(ship,src)
			if(target_range > initial(weapon_range)) //If the target is out of PDC range, don't shoot. This prevents OP shit like spamming torps AND PDC flak all over a target.
				continue
			if(!QDELETED(ship) && isovermap(ship))
				fire_weapon(ship, mode=FIRE_MODE_PDC, lateral=TRUE)

*/
