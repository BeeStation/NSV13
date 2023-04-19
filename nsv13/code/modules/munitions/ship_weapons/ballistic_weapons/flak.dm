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
	magazine_type = /obj/item/ammo_box/magazine/nsv/flak

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

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/temp_visual/flak/proc/on_entered(datum/source, atom/movable/AM) //Here, we check if the bullet that hit us is from a friendly ship. If it's from an enemy ship, we explode as we've been flak'd down.
	SIGNAL_HANDLER

	if(!isprojectile(AM) && !istype(AM, /obj/structure/overmap))
		return
	//Distance from the "center" of the flak effect.
	var/dist = get_dist(locs[1], AM)
	var/severity = (dist > 0) ? 1/dist : 1
	var/obj/item/projectile/P = AM
	if(P.faction != faction) //Stops flak from FFing
		if(istype(AM, /obj/item/projectile/guided_munition))
			P.take_damage(severity*30, BRUTE, "overmap_light")
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
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))

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

/obj/item/projectile/guided_munition/on_entered(datum/source, atom/movable/AM) //Here, we check if the bullet that hit us is from a friendly ship. If it's from an enemy ship, we explode as we've been flak'd down.
	. = ..()

	if(!isprojectile(AM))
		return

	var/obj/item/projectile/P = AM //This is hacky, refactor check_faction to unify both of these. I'm bodging it for now.
	if(P.damage <= 0 || P.nodamage)
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
