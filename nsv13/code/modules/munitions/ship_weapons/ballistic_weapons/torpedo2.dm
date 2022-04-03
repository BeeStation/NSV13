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
	obj_integrity = 100
	max_integrity = 100
	integrity_failure = 100

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
	inertial_dampeners = FALSE //Could be fun
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
				var/impact_angle = SIMPLIFY_DEGREES(Get_Angle(O, src) - angle) //On which quadrant did we strike them?
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
	if(ai_controlled)
		return
 	
	if(!pilot)
		return
	
	var/mob/living/carbon/human/C = pilot
	stop_piloting(C)

	if(ghost_controlled) //Ghost Ship Support
		OM.start_piloting(C, "all_positions")

	else
		OM.start_piloting(C, "gunner")

/obj/structure/overmap/torpedo/can_brake()
	return FALSE

//The actual silo
/obj/machinery/ship_weapon/wgt
	name = "K9-WG VLS Silo"
	desc = "Words here"
	icon = 'nsv13/icons/obj/munitions/vls.dmi'
	icon_state = "loader"
	ammo_type = /obj/item/ship_weapon/ammunition/torpedo
	resistance_flags = FIRE_PROOF //It does normally contain fire.
	fire_mode = FIRE_MODE_WG_TORPEDO
	max_ammo = 1
	circuit = /obj/item/circuitboard/machine/wgt
	var/obj/structure/fluff/vls_hatch/hatch = null

/obj/machinery/ship_weapon/wgt/Initialize()
	. = ..()
	var/turf/T = SSmapping.get_turf_above(src)
	if(!T)
		return
	hatch = locate(/obj/structure/fluff/vls_hatch) in T

/obj/machinery/ship_weapon/wgt/feed()
	. = ..()
	if(!hatch)
		return
	hatch.toggle(1)

/obj/machinery/ship_weapon/wgt/local_fire()
	. = ..()
	if(!hatch)
		return
	hatch.toggle(0)

/obj/machinery/ship_weapon/wgt/unload_magazine()
	. = ..()
	if(!hatch)
		return
	hatch.toggle(0)

/obj/machinery/ship_weapon/wgt/overmap_fire(atom/T)
	if(weapon_type?.overmap_firing_sounds)
		overmap_sound()
	
	if(overlay)
		overlay.do_animation()
	
	//override below here
	if(weapon_type)
		//animate_projectile(target)

		var/obj/item/ship_weapon/ammunition/torpedo/ST = pick(ammo)
		var/obj/structure/overmap/torpedo/OMT = new(linked.loc)

		//Assign properties
		OMT.OM = linked
		OMT.angle = linked.angle
		OMT.faction = linked.faction
		OMT.warhead = ST.projectile_type
		var/obj/item/projectile/guided_munition/torpedo/PT = new OMT.warhead()
		OMT.name = PT.name
		OMT.icon_state = PT.icon_state
		OMT.damage_amount = PT.damage
		OMT.damage_type = PT.damage_type
		OMT.damage_penetration = PT.armour_penetration
		OMT.damage_flag = PT.flag
		OMT.relayed_projectile = PT.relay_projectile_type
		OMT.detonation = PT.impact_effect_type

		if(istype(ST, /obj/item/ship_weapon/ammunition/torpedo/ai_test))
			OMT.ai_controlled = TRUE
			OMT.ai_behaviour = AI_AGGRESSIVE
			OMT.ai_flags = AI_FLAG_MUNITION
			
			var/datum/star_system/target = linked.current_system
			var/datum/fleet/torpedo_holder/TT = new()
			target.fleets += TT
			TT.current_system = target	
			TT.faction = OMT.faction
			TT.add_ship(OMT, "fighters")


		else //Get in the seat
			var/mob/living/carbon/human/C = linked.gunner
			linked.stop_piloting(C)
			OMT.start_piloting(C, "pilot")

		//Clean up
		qdel(ST) //Don't need this anymore
		qdel(PT) //Whereever this is

/obj/machinery/ship_weapon/wgt/after_fire()
	if(maintainable)
		if(maint_req > 0)
			maint_req -= rand(5, 10) //Quite heavy on the maint
		else
			weapon_malfunction()
	update()

	atmos_spawn_air("o2=5;plasma=5;TEMP=500")
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, src)
	smoke.start()	

//Test torps
/obj/item/ship_weapon/ammunition/torpedo/ai_test/t1
	name = "AI Test Torp T1"
	desc = "Tier 1 test torpedo for AI control - WG Silo ONLY"
	projectile_type = /obj/item/projectile/guided_munition/torpedo

/obj/item/ship_weapon/ammunition/torpedo/ai_test/t2
	name = "AI Test Torp T2"
	desc = "Tier 2 test torpedo for AI control - WG Silo ONLY"
	projectile_type = /obj/item/projectile/guided_munition/torpedo/shredder
	icon_state = "hull_shredder"

//Torp Fleet
/datum/fleet/torpedo_holder
	name = "Torpedo Holder"
	size = 0
	allow_difficulty_scaling = FALSE
	taunts = list()
	greetings = list()
	fleet_trait = FLEET_TRAIT_DEFENSE
	reward = 0
	announce_status = FALSE
