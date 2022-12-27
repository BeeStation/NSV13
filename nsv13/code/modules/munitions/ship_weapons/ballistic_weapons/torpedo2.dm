//Here we define what an overmap object torpdeo is
/obj/structure/overmap/torpedo
	name = "Fly-by-Wire Torpedo" //This should be inherited from the actual type of torpedo fired
	desc = "A player guided torpedo" //Ditto
	icon = 'nsv13/icons/obj/projectiles_nsv.dmi'
	icon_state = "torpdeo" //Dittto
	sprite_size = 32
	pixel_collision_size_x = 32
	pixel_collision_size_y = 32
	var/arm_timer = null //Check for if we arm yet
	var/ai_driven = FALSE //Are we an AI torp?
	density = FALSE //Not true until it arms
	move_by_mouse = TRUE
	overmap_verbs = list()

	//IFF
	faction = "nanotrasen" //Dittto

	//Fuel Stats
	var/fuel = 30 SECONDS // The fuel load of our torpedo
	var/fuel_cutout = null //<insert mass effect scene here>

	//Defensive Stats
	armor = list("overmap_light" = 0, "overmap_medium" = 50, "overmap_heavy" = 95)
	obj_integrity = 150
	max_integrity = 150
	integrity_failure = 150

	//Offensive Stats
	var/obj/item/projectile/guided_munition/torpedo/warhead //This is where we retieve a lot of our data from
	var/obj/item/projectile/bullet/delayed_prime/relayed_projectile
	var/obj/effect/temp_visual/detonation
	var/damage_amount
	var/damage_type
	var/damage_penetration
	var/damage_flag

	//Performance Characteristics
	mass = MASS_TINY
	inertial_dampeners = TRUE //Even with this enabled, it is still quite slippery
	speed_limit = 8 //Faster than a fighter
	forward_maxthrust = 6
	backward_maxthrust = 0
	side_maxthrust = 0
	max_angular_acceleration = 25
	bump_impulse = 0
	bounce_factor = 0
	lateral_bounce_factor = 0

	var/obj/structure/overmap/OM = null //Our source

/obj/structure/overmap/torpedo/Initialize()
	.=..()
	arm_timer = world.time
	fuel_cutout = world.time + fuel

/obj/structure/overmap/torpedo/apply_weapons() //No weapons
	return

/obj/structure/overmap/torpedo/process()
	. = ..()

	if(ai_driven && !ai_controlled) //Causes torpedo to not instantly snap to target
		if(world.time >= arm_timer + 1 SECONDS)
			ai_controlled = TRUE

	if(!density) //If we aren't armed, we should arm
		if(world.time >= arm_timer + 2 SECONDS)
			density = TRUE

	if(world.time >= fuel_cutout)
		new detonation(src)
		release_pilot()
		qdel(src)

	user_thrust_dir = 1

/obj/structure/overmap/torpedo/Bump(atom/A)
	.=..()

	if(!density) //Not yet armed
		return

	if(istype(A, /obj/structure/overmap)) //Are we hitting an overmap entity rather than a projectile?
		var/obj/structure/overmap/O = A
		if(O.faction == faction) //We really need better faction handling code
			O.relay('sound/effects/clang.ogg')
			O.shake_everyone(10)
			release_pilot()
			qdel(src)

		else
			if(O.use_armour_quadrants) //tl;dr is this a big ship?
				var/impact_quadrant = null
				var/impact_angle = SIMPLIFY_DEGREES(get_angle(O, src) - angle) //On which quadrant did we strike them? Someone double check this is the correct orientation, please.
				switch(impact_angle)
					if(0 to 89)
						impact_quadrant = ARMOUR_FORWARD_PORT
					if(90 to 179)
						impact_quadrant = ARMOUR_AFT_PORT
					if(180 to 269)
						impact_quadrant = ARMOUR_AFT_STARBOARD
					if(270 to 360)
						impact_quadrant = ARMOUR_FORWARD_STARBOARD

				O.take_quadrant_hit(O.run_obj_armor(damage_amount, damage_type, damage_flag, null, damage_penetration), impact_quadrant)

			else
				O.take_damage(damage_amount, damage_type, damage_flag) //This proc should probably have an armour check

			O.relay_damage(relayed_projectile)
			new detonation(src)
			release_pilot()
			qdel(src)

/obj/structure/overmap/torpedo/proc/release_pilot()
	if(ai_controlled || ai_driven)
		return

	if(!pilot)
		return

	var/mob/living/carbon/human/C = pilot
	stop_piloting(C)

	if(ghost_controlled) //Ghost Ship Support
		OM.start_piloting(C, OVERMAP_USER_ROLE_PILOT | OVERMAP_USER_ROLE_GUNNER)

	else
		OM.start_piloting(C, OVERMAP_USER_ROLE_GUNNER)

/obj/structure/overmap/torpedo/can_brake()
	return FALSE

