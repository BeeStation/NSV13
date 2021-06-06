/**

Misc projectile types, effects, think of this as the special FX file.

*/

/obj/item/projectile/bullet/pdc_round
	icon_state = "pdc"
	name = "teflon coated tungsten round"
	damage = 10
	flag = "overmap_light"
	spread = 5

/obj/item/projectile/bullet/pdc_round/heavy
	damage = 10
	flag = "overmap_heavy"
	spread = 5

/obj/item/projectile/bullet/mac_round
	icon_state = "railgun"
	name = "artillery round"
	damage = 350
	speed = 1.85
	//Not easily stopped.
	obj_integrity = 300
	max_integrity = 300
	homing_turn_speed = 2.5
	flag = "overmap_heavy"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo
	var/homing_benefit_time = 0 SECONDS //NAC shells have a very slight homing effect.

/obj/item/projectile/bullet/mac_round/prehit(atom/target)
	if(isovermap(target))
		var/obj/structure/overmap/OM = target
		var/cache_move_type = movement_type
		if(OM.mass <= MASS_TINY)
			movement_type = FLYING | UNSTOPPABLE //Small things don't stop us.
		else
			movement_type = cache_move_type //But large things do.
	. = ..()

/obj/item/projectile/bullet/mac_round/Initialize()
	. = ..()
	if(homing_benefit_time)
		spawn(0)
			sleep(homing_benefit_time)
			set_homing_target(null)

/obj/item/projectile/bullet/mac_round/ap
	damage = 200
	armour_penetration = 70
	icon_state = "railgun_ap"
	movement_type = FLYING | UNSTOPPABLE //Railguns punch straight through your ship

/obj/item/projectile/bullet/mac_round/magneton
	speed = 1.5
	damage = 275
	homing_benefit_time = 2.5 SECONDS
	homing_turn_speed = 30

//Improvised ammunition, does terrible damage but is cheap to produce
/obj/item/projectile/bullet/mac_round/cannonshot
	name = "cannonball"
	damage = 75
	icon_state = "cannonshot"

/obj/item/projectile/bullet/railgun_slug
	icon_state = "mac"
	name = "tungsten slug"
	damage = 150
	speed = 1
	homing_turn_speed = 2
	flag = "overmap_heavy"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo

/obj/item/projectile/bullet/railgun_slug/Initialize()
	. = ..()
	sleep(0.25)
	set_homing_target(null)

/obj/item/projectile/bullet/gauss_slug
	icon_state = "gaussgun"
	name = "tungsten round"
	damage = 35
	obj_integrity = 500 //Flak doesn't shoot this down....
	flag = "overmap_heavy"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo

/obj/item/projectile/bullet/light_cannon_round
	icon_state = "pdc"
	name = "light cannon round"
	damage = 10
	spread = 2
	flag = "overmap_light"

/obj/item/projectile/bullet/heavy_cannon_round
	icon_state = "pdc"
	name = "heavy cannon round"
	damage = 8.5
	spread = 5
	flag = "overmap_heavy" //This really needs a dual armour flag and more tuning

/obj/item/projectile/guided_munition
	obj_integrity = 100
	max_integrity = 100
	armor = list("overmap_light" = 25, "overmap_heavy" = 0)

/obj/item/projectile/guided_munition/torpedo
	icon_state = "torpedo"
	name = "plasma torpedo"
	speed = 2.75
	valid_angle = 150
	homing_turn_speed = 30
	damage = 200
	range = 250
	armor = list("overmap_light" = 60, "overmap_heavy" = 10)
	flag = "overmap_heavy"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo
	spread = 5 //Helps them not get insta-bonked when launching

/obj/item/projectile/guided_munition/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/windup), 1 SECONDS)

/obj/item/projectile/guided_munition/proc/windup()
	valid_angle = 360 //Torpedoes "wind up" to hit their target
	homing_turn_speed *= 5
	homing_turn_speed = CLAMP(homing_turn_speed, 0, 360)
	sleep(0.7 SECONDS) //Let it get clear of the sender.
	valid_angle = initial(valid_angle)
	homing_turn_speed = initial(homing_turn_speed)

/obj/item/projectile/guided_munition/missile
	name = "triton cruise missile"
	icon_state = "conventional_missile"
	speed = 1
	damage = 150
	valid_angle = 120
	homing_turn_speed = 25
	range = 250
	flag = "overmap_heavy"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo
	spread = 5 //Helps them not get insta-bonked when launching

/obj/effect/temp_visual/overmap_explosion
	icon = 'nsv13/goonstation/icons/hugeexplosion.dmi'
	icon_state = "explosion"
	duration = 10

/obj/effect/temp_visual/overmap_explosion/alt
	icon = 'nsv13/goonstation/icons/hugeexplosion2.dmi'
	icon_state = "explosion"
	duration = 10

//Corvid or someone please refactor this to be less messy.
/obj/item/projectile/guided_munition/on_hit(atom/target, blocked = FALSE)
	..()
	if(!check_faction(target))
		return FALSE 	 //Nsv13 - faction checking for overmaps. We're gonna just cut off real early and save some math if the IFF doesn't check out.
	if(istype(target, /obj/structure/overmap)) //Were we to explode on an actual overmap, this would oneshot the ship as it's a powerful explosion.
		return BULLET_ACT_HIT
	var/obj/item/projectile/P = target //This is hacky, refactor check_faction to unify both of these. I'm bodging it for now.
	if(isprojectile(target) && P.faction != faction) //Because we could be in the same faction and collide with another bullet. Let's not blow ourselves up ok?
		if(obj_integrity <= P.damage) //Tank the hit, take some damage
			qdel(P)
			explode()
			return BULLET_ACT_HIT
		else
			qdel(P)
			take_damage(P.damage)
			return FALSE //Didn't take the hit
	if(!isprojectile(target)) //This is lazy as shit but is necessary to prevent explosions triggering on the overmap when two bullets collide. Fix this shit please.
		explosion(target, 2, 4, 4)
	return BULLET_ACT_HIT

/obj/item/projectile/guided_munition/torpedo/nuclear/on_hit(atom/target, blocked = FALSE)
	..()
	if(!check_faction(target))
		return FALSE 	 //Nsv13 - faction checking for overmaps. We're gonna just cut off real early and save some math if the IFF doesn't check out.
	if(istype(target, /obj/structure/overmap)) //Were we to explode on an actual overmap, this would oneshot the ship as it's a powerful explosion.
		return BULLET_ACT_HIT
	var/obj/item/projectile/P = target //This is hacky, refactor check_faction to unify both of these. I'm bodging it for now.
	if(isprojectile(target) && P.faction != faction) //Because we could be in the same faction and collide with another bullet. Let's not blow ourselves up ok?
		return BULLET_ACT_HIT
	if(!isprojectile(target))
		explosion(target, GLOB.MAX_EX_DEVESTATION_RANGE, GLOB.MAX_EX_HEAVY_RANGE, GLOB.MAX_EX_LIGHT_RANGE, GLOB.MAX_EX_FLASH_RANGE)
	return BULLET_ACT_HIT

/obj/item/projectile/guided_munition/torpedo/check_faction(atom/movable/A)
	var/obj/item/projectile/P = A //Lazy but w/e
	//If it's a projectile and not sharing our faction, blow it up.
	if(isprojectile(A) && P.faction != faction)
		new /obj/effect/temp_visual/impact_effect/torpedo(get_turf(src)) //Exploding effect
		var/sound/chosen = pick('nsv13/sound/effects/ship/torpedo_detonate.ogg','nsv13/sound/effects/ship/freespace2/impacts/boom_2.wav','nsv13/sound/effects/ship/freespace2/impacts/boom_3.wav','nsv13/sound/effects/ship/freespace2/impacts/subhit.wav','nsv13/sound/effects/ship/freespace2/impacts/subhit2.wav','nsv13/sound/effects/ship/freespace2/impacts/m_hit.wav','nsv13/sound/effects/ship/freespace2/impacts/hit_1.wav')
		var/obj/structure/overmap/OM = firer || null
		if(OM && istype(OM))
			OM?.relay_to_nearby(chosen)
		qdel(src)
		return FALSE
	var/obj/structure/overmap/OM = A
	if(!istype(OM))
		return TRUE
	if(faction != OM.faction)
		return TRUE
