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
	name = "hyper accelerated tungsten slug"
	damage = 350
	speed = 0.5
	flag = "overmap_heavy"
	movement_type = FLYING | UNSTOPPABLE //Railguns punch straight through your ship
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo

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

/obj/item/projectile/guided_munition/torpedo
	icon_state = "torpedo"
	name = "plasma torpedo"
	speed = 3
	valid_angle = 120
	homing_turn_speed = 5
	damage = 200
	range = 250
	flag = "overmap_heavy"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo

/obj/item/projectile/guided_munition/torpedo/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/windup), 1 SECONDS)

/obj/item/projectile/guided_munition/torpedo/proc/windup()
	valid_angle = 360 //Torpedoes "wind up" to hit their target
	homing_turn_speed = 360
	sleep(0.7 SECONDS) //Let it get clear of the sender.
	valid_angle = initial(valid_angle)
	homing_turn_speed = initial(homing_turn_speed)

/obj/item/projectile/guided_munition/missile
	name = "conventional missile"
	icon_state = "conventional_missile"
	speed = 1
	damage = 75
	valid_angle = 90
	homing_turn_speed = 5
	range = 250
	flag = "overmap_light"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo

/obj/effect/temp_visual/overmap_explosion
	icon = 'nsv13/goonstation/icons/hugeexplosion.dmi'
	icon_state = "explosion"
	duration = 10

/obj/effect/temp_visual/overmap_explosion/alt
	icon = 'nsv13/goonstation/icons/hugeexplosion2.dmi'
	icon_state = "explosion"
	duration = 10

//Corvid or someone please refactor this to be less messy.
/obj/item/projectile/guided_munition/torpedo/on_hit(atom/target, blocked = FALSE)
	..()
	if(!check_faction(target))
		return FALSE 	 //Nsv13 - faction checking for overmaps. We're gonna just cut off real early and save some math if the IFF doesn't check out.
	if(istype(target, /obj/structure/overmap)) //Were we to explode on an actual overmap, this would oneshot the ship as it's a powerful explosion.
		var/obj/structure/overmap/OM = target
		OM.torpedoes_to_target -= src
		return BULLET_ACT_HIT
	var/obj/item/projectile/P = target //This is hacky, refactor check_faction to unify both of these. I'm bodging it for now.
	if(isprojectile(target) && P.faction != faction) //Because we could be in the same faction and collide with another bullet. Let's not blow ourselves up ok?
		return BULLET_ACT_HIT
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
