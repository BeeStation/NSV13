#define MS_CLOSED 		0
#define MS_UNSECURE 	1
#define MS_OPEN	 		2

#define NO_IGNITION 1
#define NO_FUEL_PUMP 2
#define NO_BATTERY 3
#define NO_APU 4
#define APU_SPUN 5
#define FLIGHT_READY 6
#define NO_FUEL 7

//Fighter


/*||
FIGHTER PRE-LAUNCH CHECKLIST:
(Before moving to tube)
1: CHECK FUEL
2: CHECK SYSTEM INTEGRITY
(After moving to tube)
3: CHECK FIGHTER IS FACING THE RIGHT WAY FOR ITS LAUNCH TUBE
4: CHECK FIGHTER IS SECURELY LOCKED ONTO MAG TRACK
5: ENSURE EXIT DOORS ARE OPEN
After going through this checklist, you're ready to go!
*/

/obj/structure/overmap/fighter
	name = "Fighter - PARENT"
	desc = "THIS IS A PARENT STRUCTURE AND SHOULD NOT BE SPAWNED"
	icon = 'nsv13/icons/overmap/nanotrasen/fighter.dmi'
	icon_state = "fighter"
	brakes = TRUE
	armor = list("melee" = 80, "bullet" = 50, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 80) //temp to stop easy destruction from small arms
	bound_width = 64 //Change this on a per ship basis
	bound_height = 64
	mass = MASS_TINY
	sprite_size = 32
	damage_states = TRUE
	faction = "nanotrasen"
	max_integrity = 120 //Really really squishy!
	torpedoes = 0
	missiles = 0
	speed_limit = 6 //We want fighters to be way more maneuverable
	weapon_safety = TRUE //This happens wayy too much for my liking. Starts OFF.
	pixel_w = -16
	pixel_z = -20
	req_one_access = list(ACCESS_FIGHTER)
	collision_positions = list(new /datum/vector2d(-2,-16), new /datum/vector2d(-13,-3), new /datum/vector2d(-13,10), new /datum/vector2d(-6,15), new /datum/vector2d(8,15), new /datum/vector2d(15,10), new /datum/vector2d(12,-9), new /datum/vector2d(4,-16), new /datum/vector2d(1,-16))
	var/maint_state = MS_CLOSED
	var/prebuilt = FALSE
	var/fuel_consumption = 0
	var/max_torpedoes = 0
	var/max_missiles = 0
	var/max_cannon = 0
	var/max_countermeasures = 0
	var/countermeasures = 0
	var/obj/structure/fighter_launcher/mag_lock = null //Mag locked by a launch pad. Cheaper to use than locate()
	var/max_passengers = 0 //Maximum capacity for passengers, INCLUDING pilot (EG: 1 pilot, 4 passengers).
	var/max_cargo = 0 //Maximum number of crates you've loaded in
	var/list/allowed_cargo = list(/obj/machinery/nuclearbomb, /obj/structure/closet, /obj/structure/ore_box) //Typepath whitelist for storing stuff in a raptor.
	var/list/cargo = list() //cargo you've got in here.
	var/docking_mode = FALSE
	var/warning_cooldown = FALSE
	var/canopy_breached = FALSE //Canopy will breach if you take too much damage, causing your air to leak out.
	var/docking_cooldown = FALSE
	var/list/mun_cannon = list()
	var/list/mun_torps = list()
	var/list/mun_missiles = list()
	var/list/mun_countermeasures = list()
	var/obj/structure/overmap/last_overmap = null //Last overmap we were attached to
	var/canopy_open = TRUE //Is the canopy open?
	var/flight_state = NO_IGNITION
	var/warmup_cooldown = FALSE //So you cant blitz the fighter ignition in 2 seconds
	var/ejecting = FALSE
	var/throttle_lock = FALSE
	var/has_escape_pod = /obj/structure/overmap/fighter/escapepod
	var/obj/structure/overmap/fighter/escapepod/escape_pod
	var/list/components = null
	var/master_caution = FALSE
	var/start_emagged = FALSE //Do we start emagged? This is so that syndie fighters can shoot people shipside
	var/installing = FALSE //Are we currently having parts installed?
	var/chassis = 0 //Which chassis we are for part checking

	//The following vars are a temporary hackjob until the weapons rework is complete. Please rework this when we can! ~Kmc
	var/ftl_goal = 0 //0 initially if it doesn't have an FTL.
	var/ftl_progress = 0 //For use of this, see ftl_drive.dm . Sabres are currently the only fighters that can FTL jump.
	var/max_ftl_range = 80 //light years. 80 means the two targets have to be at least reasonably close together
	var/spooling_ftl = FALSE

/obj/structure/overmap/fighter/apply_weapons()
	weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/light_cannon(src)
	weapon_types[FIRE_MODE_MISSILE] = new/datum/ship_weapon/missile_launcher(src)
	weapon_types[FIRE_MODE_TORPEDO] = new/datum/ship_weapon/torpedo_launcher(src)

/obj/structure/overmap/fighter/Initialize()
	. = ..()
	for(var/X in allowed_cargo)
		for(var/Y in subtypesof(X))
			allowed_cargo += Y
	if(start_emagged)
		obj_flags ^= EMAGGED

/**
Fighter emagging!
You can no longer fire fighter weapons on a ship so easily...
You need to fire emag the fighter's IFF board. This makes it list as "ENEMY" on DRADIS and allows it to be shot down by ANY other fighter, INCLUDING Syndicate ships too!
*/

/obj/structure/overmap/fighter/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	if(alert("Do you want to nullify [src]'s safeties and IFF chip? (THIS IS VERY OBVIOUS)",name,"Yes","No") == "Yes" && Adjacent(user))
		to_chat(user, "<span class='warning'>You override [src]'s IFF chip. It will now register as rogue on all local DRADIS systems (Including Syndicate ones)....</span>")
		faction = name //Yep. This means ANYONE can shoot it down.
		obj_flags |= EMAGGED

/obj/structure/overmap/fighter/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	..()
	var/canopy_warn_threshold = max_integrity/10*4 //Get 40% of max_integrity
	var/canopy_breach_threshold = max_integrity/10*3 //Get 30% of max_integrity
	if(obj_integrity <= canopy_breach_threshold && !canopy_breached)
		relay('nsv13/sound/effects/ship/cockpit_breach.ogg') //We're leaking air!
		to_chat(pilot, "<span class='warning'>DANGER: CANOPY BREACH DETECTED. STRUCTURAL INTEGRITY FAILURE IMMINENT</span>")
		canopy_breached = TRUE
		sleep(3 SECONDS)
		relay('nsv13/sound/effects/ship/reactor/gasmask.ogg', "<span class='warning'>The air around you rushes out of the breached canopy!</span>", loop = TRUE, channel = CHANNEL_SHIP_ALERT)
		return
	if(obj_integrity <= canopy_warn_threshold && !canopy_breached && !warning_cooldown)
		relay('nsv13/sound/effects/computer/alarm_4.ogg')
		to_chat(pilot, "<span class='warning'>DANGER: CANOPY BREACH IMMINENT.</span>")
		warning_cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, warning_cooldown, FALSE), 5 SECONDS)
		return
	if(damage_amount > max_integrity/2) //Taking a single hit that does over 50% of your max HP is BAD
		var/destroyed = pick(1, 2, 3, 4) //May as well go AWOL at this point, MAA is going to lynch you
		for(var/I = 0, I < destroyed, I++)
			burnout_component()
		return
	else if(damage_amount >= 50)
		if(prob(20))
			burnout_component()
		return

/obj/structure/overmap/fighter/proc/burnout_component()
	if(src == /obj/structure/overmap/fighter/escapepod)
		return
	var/list/candidate_list = list()
	for(var/obj/item/fighter_component/candidate in contents)
		if(candidate.burntout == FALSE)
			candidate_list = list(candidate)
	var/obj/item/fighter_component/selection = pick(candidate_list)
	selection.burn_out()
	set_master_caution(TRUE)
	update_stats()
	if(selection == /obj/item/fighter_component/secondary/utility/passenger_compartment_module)
		relay('nsv13/sound/effects/ship/reactor/gasmask.ogg', "<span class='warning'>The air around you rushes out of the breached passenger compartment!</span>", loop = TRUE, channel = CHANNEL_SHIP_ALERT)

/obj/structure/overmap/fighter/emp_act(severity)
	. = ..()
	if(pilot)
		to_chat(pilot, "<span class='danger'>Warning: Electromagnetic surge detected. System stability compromised.</span>")
	if(. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			take_damage(50)
		if(2)
			take_damage(40)
	update_icon()
	if(prob(30)) //EMP malfunctions aren't fun, alright?
		toggle_canopy()
	if(prob(20))
		brakes = !brakes
	if(prob(10))
		weapon_safety = !weapon_safety
	if(severity >= 2 && prob(5) && flight_state > NO_IGNITION) //And let's be REALLY mean.
		brakes = TRUE
		flight_state = NO_IGNITION
		playsound(src, 'nsv13/sound/effects/ship/rcs.ogg', 100, TRUE)
		visible_message("<span class='warning'>[src]'s engine fizzles out violently!</span>")
		to_chat(pilot, "<span class='danger'>DANGER: INVALID MEMORY ADDRESS IN MODULE FLIGHTCOMP03x1500. INITIATING EMERGENCY SYSTEM SHUTDOWN.</span>")
		stop_relay(CHANNEL_SHIP_ALERT)

/obj/structure/overmap/fighter/update_icon()
	. =..()
	if(canopy_breached)
		add_overlay(image(icon = icon, icon_state = "canopy_breach", dir = 1))
	else if(canopy_open)
		add_overlay("canopy_open")

/obj/structure/overmap/fighter/slowprocess()
	. = ..()
	use_fuel()
	if(canopy_breached) //Leak air if the canopy is breached.
		var/datum/gas_mixture/removed = cabin_air.remove(5)
		qdel(removed)

	var/obj/item/fighter_component/secondary/utility/passenger_compartment_module/pc = get_part(/obj/item/fighter_component/secondary/utility/passenger_compartment_module)
	if(pc?.burntout)
		var/datum/gas_mixture/removed = cabin_air.remove(5)
		qdel(removed)

	var/obj/item/fighter_component/fuel_tank/ft = get_part(/obj/item/fighter_component/fuel_tank)
	if(ft?.burntout)
		if(ft.reagents.total_volume > (ft.reagents.maximum_volume / 4))
			ft.reagents.remove_reagent(/datum/reagent/aviation_fuel, 5)

	var/obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank/aft = get_part(/obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank)
	if(aft?.burntout)
		if(aft.reagents.total_volume > (aft.reagents.maximum_volume / 4))
			aft.reagents.remove_reagent(/datum/reagent/aviation_fuel, 5)

/obj/structure/overmap/fighter/return_air()
	if(!canopy_open && !canopy_breached)
		return cabin_air
	return loc.return_air()

/obj/structure/overmap/fighter/remove_air(amount)
	return cabin_air?.remove(amount)

/obj/structure/overmap/fighter/return_analyzable_air()
	return cabin_air

/obj/structure/overmap/fighter/return_temperature()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		. = t_air.return_temperature()
	return

/obj/structure/overmap/fighter/portableConnectorReturnAir()
	return return_air()

/obj/structure/overmap/fighter/assume_air(datum/gas_mixture/giver)
	var/datum/gas_mixture/t_air = return_air()
	return t_air.merge(giver)

/obj/structure/overmap/fighter/Initialize()
	.=..()
	if(prebuilt)
		prebuilt_setup()
	dradis = new /obj/machinery/computer/ship/dradis/internal(src) //Fighters need a way to find their way home.
	dradis.linked = src
	obj_integrity = max_integrity
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/check_overmap_elegibility) //Used to smoothly transition from ship to overmap
	add_overlay(image(icon = icon, icon_state = "canopy_open", dir = SOUTH))
	update_stats()

/obj/structure/overmap/fighter/proc/prebuilt_setup()
	name = new_prebuilt_fighter_name() //pulling from NSV13 ship name list currently
	for(var/item in components)
		new item(src)
	update_stats()
	for(var/I = 0, I < max_torpedoes, I++)
		mun_torps += new /obj/item/ship_weapon/ammunition/torpedo(src)
	for(var/I = 0, I < max_missiles, I++)
		mun_missiles += new /obj/item/ship_weapon/ammunition/missile(src)
	for(var/I = 0, I < max_countermeasures, I++)
		mun_countermeasures += new /obj/item/ship_weapon/ammunition/countermeasure_charge(src)
	torpedoes = mun_torps.len
	missiles = mun_missiles.len
	countermeasures = mun_countermeasures.len
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	var/obj/item/fighter_component/fuel_tank/ft = get_part(/obj/item/fighter_component/fuel_tank)
	var/obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank/aft = get_part(/obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank)
	var/obj/item/fighter_component/secondary/utility/rbs_reagent_tank/rrt = get_part(/obj/item/fighter_component/secondary/utility/rbs_reagent_tank)
	ft?.fuel_setup()
	aft?.fuel_setup()
	rrt?.reagent_setup()

/obj/structure/overmap/fighter/proc/update_stats() //PLEASE SOMEONE MAKE A LESS JANK SYSTEM
	//Get all the possible components that we need variables from
	var/obj/item/fighter_component/armour_plating/ap = get_part(/obj/item/fighter_component/armour_plating)
	var/obj/item/fighter_component/engine/en = get_part(/obj/item/fighter_component/engine)
//	var/obj/item/fighter_component/targeting_sensor/ts = get_part(/obj/item/fighter_component/targeting_sensor)
	var/obj/item/fighter_component/countermeasure_dispenser/cd = get_part(/obj/item/fighter_component/countermeasure_dispenser)
	var/obj/item/fighter_component/secondary/sy = get_part(/obj/item/fighter_component/secondary)
	var/obj/item/fighter_component/primary/py = get_part(/obj/item/fighter_component/primary)
	var/obj/item/fighter_component/secondary/utility/passenger_compartment_module/pc = get_part(/obj/item/fighter_component/secondary/utility/passenger_compartment_module)

	//Assign variables
	if(ap)
		max_integrity = initial(max_integrity) * ap?.armour
	else
		max_integrity = initial(max_integrity)
	if(obj_integrity > max_integrity)
		obj_integrity = max_integrity
	if(en)
		speed_limit = initial(speed_limit) * en?.speed
	if(en?.burntout)
		speed_limit = speed_limit/2
	fuel_consumption = en?.consumption
//	??? = ts?.targeting_speed
	max_countermeasures = cd?.countermeasure_capacity
	max_missiles = sy?.missile_capacity
	max_torpedoes = sy?.torpedo_capacity
	max_cannon = py?.ammo_capacity
	max_passengers = pc?.passenger_capacity
	if(py)
		var/path_one = new py.weapon_type_path_one(src)
		if(path_one)
			weapon_types[FIRE_MODE_PDC] = path_one
		else
			return
		if(py.weapon_type_path_two)
			var/path_two = new py.weapon_type_path_two(src)
			if(path_two)
				weapon_types[FIRE_MODE_FIGHTER_SLOT_TWO] = path_two

/obj/structure/overmap/fighter/proc/fuel_setup()
	var/obj/item/fighter_component/fuel_tank/fft = get_part(/obj/item/fighter_component/fuel_tank)
	fft.fuel_setup()

/obj/item/fighter_component/fuel_tank/proc/fuel_setup()
	reagents.add_reagent(/datum/reagent/aviation_fuel, fuel_capacity)

/obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank/proc/fuel_setup()
	reagents.add_reagent(/datum/reagent/aviation_fuel, aux_capacity)

/obj/item/fighter_component/secondary/utility/rbs_reagent_tank/proc/reagent_setup()
	var/obj/item/reagent_containers/rbs_welder_tank/WT = locate(/obj/item/reagent_containers/rbs_welder_tank) in contents
	var/obj/item/reagent_containers/rbs_foamer_tank/FT = locate(/obj/item/reagent_containers/rbs_foamer_tank) in contents
	var/foam_division = rbs_capacity / 5
	WT.reagents.add_reagent(/datum/reagent/fuel, rbs_capacity)
	FT.reagents.add_reagent(/datum/reagent/aluminium, foam_division * 3)
	FT.reagents.add_reagent(/datum/reagent/foaming_agent, foam_division)
	FT.reagents.add_reagent(/datum/reagent/toxin/acid/fluacid, foam_division)

//Fighter Maintenance
/obj/structure/overmap/fighter/proc/get_part(type)
	if(!type)
		return
	var/atom/movable/desired = locate(type) in contents
	return desired

/obj/structure/overmap/fighter/wrench_act(mob/user, obj/item/tool) //opening hatch p1
	. = FALSE
	if(maint_state == MS_CLOSED && pilot)
		to_chat(user, "<span class='warning'>You cannot start maintenance while a pilot is in [src]!</span>")
		return TRUE
	else if(maint_state == MS_CLOSED && !pilot)
		to_chat(user, "<span class='notice'>You start unsecuring the maintenance hatch on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You unsecure the maintenance hatch on [src].</span>")
			maint_state = MS_UNSECURE
			return TRUE
	else if(maint_state == MS_UNSECURE)
		to_chat(user, "<span class='notice'>You start securing the maintenance hatch on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You secure the maintenance hatch on [src].</span>")
			maint_state = MS_CLOSED
			return TRUE

/obj/structure/overmap/fighter/crowbar_act(mob/user, obj/item/tool) //opening hatch p2
	. = FALSE
	switch(maint_state)
		if(MS_UNSECURE)
			to_chat(user, "<span class='notice'>You start prying open the maintenance hatch on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You pry open the maintenance hatch on [src].</span>")
				maint_state = MS_OPEN
				return TRUE
		if(MS_OPEN)
			to_chat(user, "<span class='notice'>You start replacing the maintenance hatch on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You replace the maintenance hatch on [src].</span>")
				maint_state = MS_UNSECURE
				return TRUE

/obj/structure/overmap/fighter/welder_act(mob/user, obj/item/tool)
	. = FALSE
	if(maint_state < MS_UNSECURE)
		to_chat(user, "<span class='notice'>You need to open [src]'s maintenance hatch with a crowbar before effecting repairs..</span>")
		return
	if(obj_integrity/max_integrity*100 >= 100 && user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='notice'>[src] isn't in need of repairs.</span>")
		return TRUE
	else if(maint_state != MS_OPEN && obj_integrity/max_integrity*100 >= 51 && user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='notice'>You start welding some dents out of [src]'s hull...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You weld some dents out of [src]'s hull.</span>")
			obj_integrity += min(10, max_integrity-obj_integrity)
			if(obj_integrity == max_integrity)
				to_chat(user, "<span class='notice'>[src] is fully repaired.</span>")
				canopy_breached = FALSE
			return TRUE
	else if(maint_state == MS_OPEN && obj_integrity/max_integrity*100 >= 51 && user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='notice'>You need to close [src]'s maintenance panel to begin hull repairs.</span>")
		return TRUE
	else if(maint_state == MS_OPEN && obj_integrity/max_integrity*100 <= 50 && user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='notice'>You start repairing the inner components of [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You repair the inner components of [src].</span>")
			obj_integrity += min(10, max_integrity-obj_integrity)
			if(obj_integrity == max_integrity)
				to_chat(user, "<span class='notice'>[src]'s inner components are fully repaired.</span>")
				canopy_breached = FALSE
			return TRUE
	else if(maint_state == MS_OPEN && obj_integrity/max_integrity*100 <= 50 && user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='notice'>You must open the maintenance panel to repair the inner components of [src].</span>")
		return TRUE

/obj/structure/overmap/fighter/MouseDrop_T(obj/structure/A, mob/user)
	. = ..()
	if(istype(A, /obj/machinery/portable_atmospherics/canister))
		if(maint_state != MS_OPEN)
			to_chat(user, "<span class='warning'>[src] is not in maintenance mode!</span>")
			return
		if(internal_tank)
			to_chat(user, "<span class='warning'>[src] already has an internal tank!</span>")
			return
		to_chat(user, "<span class='notice'>You begin inserting the canister into [src]</span>")
		if(do_after_mob(user, list(A, src), 50))
			to_chat(user, "<span class='notice'>You insert the canister into [src]</span>")
			A.forceMove(src)
			internal_tank = A
		return
	else if(istype(A, /obj/item/ship_weapon/ammunition/torpedo))
		if(maint_state == MS_OPEN)
			var/munition_count = mun_torps.len
			if(munition_count < max_torpedoes)
				to_chat(user, "<span class='notice'>You start adding [A] to [src]...</span>")
				if(!do_after(user, 5 SECONDS, target=src))
					return
				to_chat(user, "<span class='notice'>You add [A] to [src].</span>")
				A.forceMove(src)
				mun_torps += A
				torpedoes ++
				playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)  //placeholder
		else
			to_chat(user, "<span class='notice'>You require [src] to be in maintenance mode to load munitions!.</span>")
			return
	else if(istype(A, /obj/item/ship_weapon/ammunition/missile))
		if(maint_state == MS_OPEN)
			var/munition_count = mun_missiles.len
			if(munition_count < max_missiles)
				to_chat(user, "<span class='notice'>You start adding [A] to [src]...</span>")
				if(!do_after(user, 5 SECONDS, target=src))
					return
				to_chat(user, "<span class='notice'>You add [A] to [src].</span>")
				A.forceMove(src)
				mun_missiles += A
				missiles ++
				playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)  //placeholder
		else
			to_chat(user, "<span class='notice'>You require [src] to be in maintenance mode to load munitions!.</span>")
			return

	else if(LAZYFIND(allowed_cargo, A.type))
		if(cargo.len >= max_cargo)
			to_chat(user, "<span class='notice'>[src] cannot hold any [max_cargo > 0 ? "more cargo" : "cargo"].</span>")
			return
		if(!do_after(user, 5 SECONDS, target=src) || A.anchored)
			return
		to_chat(user, "<span class='warning'>You load [A] into [src]'s cargo hold...</span>")
		A.forceMove(src)
		cargo += A
		playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)  //placeholder

/obj/structure/overmap/fighter/MouseDrop_T(mob/living/M, mob/user) //Passengers get in via dragging themselves
	.=..()
	if(istype(M, /mob/living))
		if(max_passengers <= 0)
			return
		if(canopy_open == FALSE)
			to_chat(user, "<span class='notice'>][src]'s cabin must be open to access the passenger seats.</span>")
			return
		if(mobs_in_ship.len < max_passengers)
			to_chat(user, "<span class='notice'>You begin climbing into one of [src]'s passenger seats.</span>")
			if(!do_after(user, 5 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You climb into one of [src]'s passenger seats.</span>")
			user.forceMove(src)
			start_piloting(user, "observer")
			mobs_in_ship += user
			if(user?.client?.prefs.toggles & SOUND_AMBIENCE && flight_state >= FLIGHT_READY) //Disable ambient sounds to shut up the noises.
				SEND_SOUND(user, sound('nsv13/sound/effects/fighters/cockpit.ogg', repeat = TRUE, wait = 0, volume = 100, channel=CHANNEL_SHIP_ALERT))
			return TRUE
		if(mobs_in_ship.len >= max_passengers)
			to_chat(user, "<span class='notice'>[src]'s passenger compartment is full!.</span>")
			return

/obj/structure/overmap/fighter/fire_torpedo(atom/target)
	if(ai_controlled) //AI ships don't have interiors
		return ..()
	var/proj_type = null //If this is true, we've got a launcher shipside that's been able to fire.
	var/proj_speed = 1
	if(!mun_torps || !mun_torps.len)
		return
	var/obj/item/ship_weapon/ammunition/torpedo/thirtymillimetertorpedo = pick_n_take(mun_torps)
	proj_type = thirtymillimetertorpedo.projectile_type
	qdel(thirtymillimetertorpedo)
	if(thirtymillimetertorpedo && proj_type)
		var/sound/chosen = pick('nsv13/sound/effects/ship/torpedo.ogg','nsv13/sound/effects/ship/freespace2/m_shrike.wav','nsv13/sound/effects/ship/freespace2/m_stiletto.wav','nsv13/sound/effects/ship/freespace2/m_tsunami.wav','nsv13/sound/effects/ship/freespace2/m_wasp.wav')
		relay_to_nearby(chosen)
		if(proj_type == /obj/item/projectile/guided_munition/torpedo/dud) //Some brainlet MAA loaded an incomplete torp
			fire_projectile(proj_type, target, homing = FALSE, speed=proj_speed, explosive = TRUE)
		else
			fire_projectile(proj_type, target, homing = TRUE, speed=proj_speed, explosive = TRUE)
	else
		to_chat(gunner, "<span class='warning'>DANGER: Launch failure! Torpedo tubes are not loaded.</span>")

/obj/structure/overmap/fighter/fire_missile(atom/target)
	if(ai_controlled) //AI ships don't have interiors
		return ..()
	var/proj_type = null //If this is true, we've got a launcher shipside that's been able to fire.
	var/proj_speed = 1
	if(!mun_missiles | !mun_missiles.len)
		return
	var/obj/item/ship_weapon/ammunition/thirtymillimetermissile = pick_n_take(mun_missiles)
	proj_type = thirtymillimetermissile.projectile_type
	qdel(thirtymillimetermissile)
	if(thirtymillimetermissile && proj_type)
		var/sound/chosen = pick('nsv13/sound/effects/ship/torpedo.ogg','nsv13/sound/effects/ship/freespace2/m_shrike.wav','nsv13/sound/effects/ship/freespace2/m_stiletto.wav','nsv13/sound/effects/ship/freespace2/m_tsunami.wav','nsv13/sound/effects/ship/freespace2/m_wasp.wav')
		relay_to_nearby(chosen)
		if(proj_type == /obj/item/projectile/guided_munition/missile/dud) //Some brainlet MAA loaded an incomplete torp
			fire_projectile(proj_type, target, homing = FALSE, speed=proj_speed, explosive = TRUE)
		else
			fire_projectile(proj_type, target, homing = TRUE, speed=proj_speed, explosive = TRUE)
	else
		to_chat(gunner, "<span class='warning'>DANGER: Launch failure! Missile tubes are not loaded.</span>")

/obj/structure/overmap/fighter/proc/force_eject()
	brakes = TRUE
	if(!canopy_open)
		canopy_open = TRUE
		playsound(src, 'nsv13/sound/effects/fighters/canopy.ogg', 100, 1)
	for(var/mob/M in operators)
		stop_piloting(M)
		to_chat(M, "<span class='warning'>You have been remotely ejected from [src]!.</span>")

/obj/structure/overmap/fighter/attackby(obj/item/W, mob/user, params)   //fueling and changing equipment
	add_fingerprint(user)
	if(istype(W, /obj/item/card/id)||istype(W, /obj/item/pda) && operators.len)
		if(!allowed(user))
			var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
			playsound(src, sound, 100, 1)
			to_chat(user, "<span class='warning'>Access denied</span>")
			return
		if(alert("Eject all current occupants from [src]?",name,"Yes","No") == "Yes" && Adjacent(user))
			to_chat(user, "<span class='warning'>Ejecting all current occupants from [src] and activating inertial dampeners...</span>")
			force_eject()
	if(maint_state == MS_OPEN)
		if(installing)
			to_chat(user, "<span class='notice'>You're already installing something into [src]!.</span>")
			return
		if(istype(W, /obj/item/fighter_component/fuel_tank) && !get_part(/obj/item/fighter_component/fuel_tank))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			installing = TRUE
			if(!do_after(user, 10 SECONDS, target=src) || !Adjacent(user))
				installing = FALSE
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			fuel_setup()
			installing = FALSE
		else if(istype(W, /obj/item/fighter_component/avionics) && !get_part(/obj/item/fighter_component/avionics))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			installing = TRUE
			if(!do_after(user, 10 SECONDS, target=src) || !Adjacent(user))
				installing = FALSE
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			update_stats()
			installing = FALSE
		else if(istype(W, /obj/item/fighter_component/apu) && !get_part(/obj/item/fighter_component/apu))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			installing = TRUE
			if(!do_after(user, 10 SECONDS, target=src) || !Adjacent(user))
				installing = FALSE
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			update_stats()
			installing = FALSE
		else if(istype(W, /obj/item/fighter_component/armour_plating) && !get_part(/obj/item/fighter_component/armour_plating))
			var/obj/item/fighter_component/armour_plating/AP = W
			if(AP.for_chassis != chassis)
				to_chat(user, "<span class='warning'>[AP] won't fit in this chassis!</span>")
				return
			to_chat(user, "<span class='notice'>You start installing [AP] in [src]...</span>")
			installing = TRUE
			if(!do_after(user, 10 SECONDS, target=src) || !Adjacent(user))
				installing = FALSE
				return
			to_chat(user, "<span class='notice'>You install [AP] in [src].</span>")
			AP.forceMove(src)
			update_stats()
			installing = FALSE
		else if(istype(W, /obj/item/fighter_component/targeting_sensor) && !get_part(/obj/item/fighter_component/targeting_sensor))
			var/obj/item/fighter_component/targeting_sensor/TS = W
			if(TS.for_chassis != chassis)
				to_chat(user, "<span class='warning'>[TS] won't fit in this chassis!</span>")
				return
			to_chat(user, "<span class='notice'>You start installing [TS] in [src]...</span>")
			installing = TRUE
			if(!do_after(user, 10 SECONDS, target=src) || !Adjacent(user))
				installing = FALSE
				return
			to_chat(user, "<span class='notice'>You install [TS] in [src].</span>")
			TS.forceMove(src)
			update_stats()
			installing = FALSE
		else if(istype(W, /obj/item/fighter_component/primary) && !get_part(/obj/item/fighter_component/primary))
			var/obj/item/fighter_component/primary/PY = W
			if(PY.for_chassis != chassis)
				to_chat(user, "<span class='warning'>[PY] won't fit in this chassis!</span>")
				return
			to_chat(user, "<span class='notice'>You start installing [PY] in [src]...</span>")
			installing = TRUE
			if(!do_after(user, 10 SECONDS, target=src) || !Adjacent(user))
				installing = FALSE
				return
			to_chat(user, "<span class='notice'>You install [PY] in [src].</span>")
			PY.forceMove(src)
			update_stats()
			installing = FALSE
		else if(istype(W, /obj/item/fighter_component/secondary) && !get_part(/obj/item/fighter_component/secondary))
			var/obj/item/fighter_component/secondary/SY = W
			if(SY.for_chassis != chassis)
				to_chat(user, "<span class='warning'>[SY] won't fit in this chassis!</span>")
				return
			to_chat(user, "<span class='notice'>You start installing [SY] in [src]...</span>")
			installing = TRUE
			if(!do_after(user, 10 SECONDS, target=src) || !Adjacent(user))
				installing = FALSE
				return
			to_chat(user, "<span class='notice'>You install [SY] in [src].</span>")
			SY.forceMove(src)
			update_stats()
			installing = FALSE
		else if(istype(W, /obj/item/fighter_component/engine) && !get_part(/obj/item/fighter_component/engine))
			var/obj/item/fighter_component/engine/EN = W
			if(EN.for_chassis != chassis)
				to_chat(user, "<span class='warning'>[EN] won't fit in this chassis!</span>")
				return
			to_chat(user, "<span class='notice'>You start installing [EN] in [src]...</span>")
			installing = TRUE
			if(!do_after(user, 10 SECONDS, target=src) || !Adjacent(user))
				installing = FALSE
				return
			to_chat(user, "<span class='notice'>You install [EN] in [src].</span>")
			EN.forceMove(src)
			update_stats()
			installing = FALSE
		else if(istype(W, /obj/item/fighter_component/countermeasure_dispenser) && !get_part(/obj/item/fighter_component/countermeasure_dispenser))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			installing = TRUE
			if(!do_after(user, 10 SECONDS, target=src) || !Adjacent(user))
				installing = FALSE
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			update_stats()
			installing = FALSE
		else if(istype(W, /obj/item/ship_weapon/ammunition/countermeasure_charge))
			if(mun_countermeasures.len < max_countermeasures)
				to_chat(user, "<span class='notice'>You start loading [W] into [src]...</span>")
				installing = TRUE
				if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
					installing = FALSE
					return
				to_chat(user, "<span class='notice'>You load [W] into [src].</span>")
				W.forceMove(src)
				mun_countermeasures += W
				installing = FALSE

/obj/structure/overmap/fighter/attack_hand(mob/user)
	.=..()
	dradis?.linked = src
	update_overmap()
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(maint_state == MS_OPEN)
		ui_interact(user)
		return TRUE
	if(maint_state == MS_UNSECURE)
		to_chat(user, "<span class='warning'>[src]'s maintenance panel is insecure.</span>")
		return
	if(!canopy_open)
		to_chat(user, "<span class='warning'>[src]'s canopy isn't open.</span>")
		return
	if(maint_state < MS_UNSECURE)
		if(!pilot)
			to_chat(user, "<span class='notice'>You begin climbing into [src]'s cockpit...</span>")
			if(!do_after(user, 5 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You climb into [src]'s cockpit.</span>")
			user.forceMove(src)
			start_piloting(user, "all_positions")
			ui_interact(user)
			mobs_in_ship += user
			if(user?.client?.prefs.toggles & SOUND_AMBIENCE && flight_state >= FLIGHT_READY) //Disable ambient sounds to shut up the noises.
				SEND_SOUND(user, sound('nsv13/sound/effects/fighters/cockpit.ogg', repeat = TRUE, wait = 0, volume = 50, channel=CHANNEL_SHIP_ALERT))
			return TRUE

/obj/structure/overmap/fighter/stop_piloting(mob/living/M, force=FALSE)
	if(!SSmapping.level_trait(loc.z, ZTRAIT_BOARDABLE) && !force)
		to_chat(M, "<span class='warning'>DANGER: You may not exit [src] while flying alongside other large ships.</span>")
		return FALSE //No jumping out into the overmap :)
	if(!canopy_open && !force)
		to_chat(M, "<span class='warning'>[src]'s canopy isn't open.</span>")
		if(prob(50))
			playsound(src, 'sound/effects/glasshit.ogg', 75, 1)
			to_chat(M, "<span class='warning'>You bump your head on [src]'s canopy.</span>")
			visible_message("<span class='warning'>You hear a muffled thud.</span>")
		return
	mobs_in_ship -= M
	. = ..()
	M.stop_sound_channel(CHANNEL_SHIP_ALERT)
	M.forceMove(get_turf(src))
	return TRUE


/obj/structure/overmap/fighter/Destroy()
	if(operators && operators.len && ispath(has_escape_pod))
		relay('nsv13/sound/effects/computer/alarm_3.ogg', "<span class=userdanger>EJECT! EJECT! EJECT!</span>")
		relay_to_nearby('nsv13/sound/effects/ship/fighter_launch_short.ogg')
		visible_message("<span class=userdanger>Auto-Ejection Sequence Enabled! Escape Pod Launched!</span>")
		ejecting = FALSE
		eject()
		sleep(2)
		for(var/atom/X in contents) //Pilot unable to eject. Murder them.
			QDEL_NULL(X)
		return ..()
	. = ..()

/obj/structure/overmap/fighter/proc/eject()
	if(ispath(has_escape_pod))
		escape_pod = new /obj/structure/overmap/fighter/escapepod(get_turf(src))
		escape_pod.name = "[name] - escape pod"
		escape_pod.faction = faction
		transfer_occupants_to(escape_pod)
		escape_pod.desired_angle = 0
		escape_pod.user_thrust_dir = NORTH
		escape_pod = null
		return TRUE
	else
		if(pilot) to_chat(pilot, "<span class='warning'>This ship is not equipped with an escape pod! Unable to eject.</span>")
		return FALSE

/obj/structure/overmap/fighter/proc/transfer_occupants_to(obj/structure/overmap/what)
	if(!operators.len)
		return
	for(var/mob/M in operators)
		var/mob/last_pilot = pilot
		stop_piloting(M, force=TRUE)
		M.forceMove(what)
		if(M == last_pilot && !what.pilot) //Let the pilot fly the new ship, unless it already has a pilot.
			what.start_piloting(M, "pilot")
			what.mobs_in_ship += M
			what.attack_hand(M) //Pop up the UI panel.
			continue
		what.start_piloting(M, "observer") //So theyre unable to fly the pod
		what.mobs_in_ship += M
	what.relay('nsv13/sound/effects/fighters/cockpit.ogg', "<span class='warning'>You hear a loud noise as [what]'s engine kicks in.</span>", loop=TRUE, channel = CHANNEL_SHIP_ALERT)

/** CHEATSHEET FOR LAZY PEOPLE
Fighter bootup sequence components.
Steps:
Hit ignition switch
Fuel pump switch
Engage battery
Engage APU
Disengage throttle lock
Throttle up VERY gently with brakes on so that engine takes over but you're still not moving.
Disengage APU to let engines take over powergen
Flight ready.
Shutdown sequence:
Throttle off + brakes on
Throttle lock on
Disengage battery
Disengage fuel pump (or engine gets flooded)
Turn off ignition
If you run out of fuel:
Activate the brakes and begin a shutdown of your fighter. Once you have received more fuel, begin startup sequence as expected. If you run out of fuel, you will be stuck adrift. It is highly recommended that you RTB when you hit 100 fuel as you'll have 30 seconds or so more burn time before you fizzle out.
How to make fuel:
1 part hydrogen : 1 part carbon to make hydrocarbon. Mix hydrocarbon and welding fuel to produce tyrosene
*/

/obj/structure/overmap/fighter/proc/toggle_canopy()
	canopy_open = !canopy_open
	playsound(src, 'nsv13/sound/effects/fighters/canopy.ogg', 100, 1)

/obj/structure/overmap/fighter/verb/show_control_panel()
	set name = "Show control panel"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check())
		return
	ui_interact(usr)

/obj/structure/overmap/fighter/verb/cycle_docking_mode()
	set name = "Toggle Docking Mode"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check())
		return
	docking_mode = !docking_mode
	to_chat(usr, "<span class='notice'>Docking mode [docking_mode ? "engaged" : "disengaged"].</span>")

/obj/structure/overmap/fighter/verb/change_name()
	set name = "Change name"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check())
		return
	var/new_name = stripped_input(usr, message="What do you want to name \
		your fighter? Keep in mind that particularly terrible names may be \
		rejected by your employers.", max_length=MAX_CHARTER_LEN)
	if(!new_name || length(new_name) <= 0)
		return
	message_admins("[key_name_admin(usr)] renamed a fighter to [new_name] [ADMIN_LOOKUPFLW(src)].")
	name = new_name

/obj/structure/overmap/fighter/key_down(key, client/user)
	.=..()
	switch(key)
		if("C" || "c")
			fire_countermeasure()
		if("T" || "t")
			relinquish_target_lock()

/obj/structure/overmap/fighter/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	if(user != pilot && maint_state != MS_OPEN)
		return
	if(user != pilot && maint_state == MS_OPEN)
		ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
		if(!ui)
			ui = new(user, src, ui_key, "FighterMaintenance", name, 560, 800, master_ui, state)
			ui.open()
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		if(maint_state == MS_CLOSED)
			state = GLOB.contained_state
			ui = new(user, src, ui_key, "FighterControls", name, 560, 800, master_ui, state)
			ui.open()

/obj/structure/overmap/fighter/can_move()
	var/obj/item/fighter_component/engine/engine = get_part(/obj/item/fighter_component/engine)
	if(!istype(src, /obj/structure/overmap/fighter/escapepod))
		if(!engine)
			if(pilot)
				to_chat(pilot, "<span class='warning'>WARNING: This fighter doesn't have any engines!</span>")
			return FALSE
	if(flight_state == NO_FUEL)
		return FALSE
	if(mag_lock)
		return FALSE
	if(flight_state != FLIGHT_READY || throttle_lock)
		return FALSE
	return TRUE

/obj/structure/overmap/fighter/proc/check_start() //See if we can kick off the engine off of the APU.
	if(!throttle_lock)
		playsound(src, 'nsv13/sound/effects/fighters/startup.ogg', 100, FALSE)
		visible_message("<span class='warning'>[src]'s engine bursts into life!</span>")
		flight_state = FLIGHT_READY
		add_overlay("engine_start")
		relay('nsv13/sound/effects/fighters/cockpit.ogg', "<span class='warning'>You hear a loud noise as [src]'s engine kicks in.</span>", loop=TRUE, channel = CHANNEL_SHIP_ALERT)
		return TRUE
	relay('nsv13/sound/effects/fighters/master_caution.ogg', "<span class='warning'>WARNING: Engine ignition failure.</span>")
	playsound(src, 'nsv13/sound/effects/ship/rcs.ogg', 100, TRUE)
	visible_message("<span class='warning'>[src]'s engine fizzles out!</span>")
	flight_state = NO_IGNITION
	return FALSE

/obj/structure/overmap/fighter/proc/set_master_caution(state)
	var/master_caution_switch = state
	if(master_caution_switch)
		to_chat(usr, "<span class='warning'>WARNING: Master caution.</span>")
		relay('nsv13/sound/effects/fighters/master_caution.ogg', null, loop=TRUE, channel=CHANNEL_HEARTBEAT)
		master_caution = TRUE
	else
		stop_relay(CHANNEL_HEARTBEAT) //CONSIDER MAKING OWN CHANNEL
		master_caution = FALSE

/obj/structure/overmap/fighter/proc/get_fuel()
	var/obj/item/fighter_component/fuel_tank/ft = get_part(/obj/item/fighter_component/fuel_tank)
	if(!ft)
		return 0
	var/return_amt = 0
	for(var/datum/reagent/aviation_fuel/F in ft.reagents.reagent_list)
		if(!istype(F))
			continue
		return_amt += F.volume
	return return_amt

/obj/structure/overmap/fighter/proc/get_aux_fuel()
	var/obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank/aft = get_part(/obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank)
	if(!aft)
		return 0
	var/return_amt = 0
	for(var/datum/reagent/aviation_fuel/F in aft.reagents.reagent_list)
		if(!istype(F))
			continue
		return_amt += F.volume
	return return_amt

/obj/structure/overmap/fighter/proc/get_rbs_welder()
	var/obj/item/fighter_component/secondary/utility/rbs_reagent_tank/rbs = get_part(/obj/item/fighter_component/secondary/utility/rbs_reagent_tank)
	if(!rbs)
		return 0
	var/return_amt = 0
	var/obj/item/reagent_containers/rbs_welder_tank/WT = locate(/obj/item/reagent_containers/rbs_welder_tank) in rbs.contents
	for(var/datum/reagent/fuel/F in WT.reagents.reagent_list)
		if(!istype(F))
			continue
		return_amt += F.volume
	return return_amt

/obj/structure/overmap/fighter/proc/get_rbs_foamer()
	var/obj/item/fighter_component/secondary/utility/rbs_reagent_tank/rbs = get_part(/obj/item/fighter_component/secondary/utility/rbs_reagent_tank)
	if(!rbs)
		return 0
	var/return_amt = 0
	var/obj/item/reagent_containers/rbs_foamer_tank/FT = locate(/obj/item/reagent_containers/rbs_foamer_tank) in rbs.contents
	return_amt += FT.reagents.total_volume
	return return_amt

/obj/structure/overmap/fighter/proc/set_fuel(amount)
	var/obj/item/fighter_component/fuel_tank/ft = get_part(/obj/item/fighter_component/fuel_tank)
	if(!ft)
		return FALSE
	for(var/datum/reagent/aviation_fuel/F in ft.reagents.reagent_list)
		if(!istype(F))
			continue
		F.volume = amount
	return amount

/obj/structure/overmap/fighter/proc/use_fuel()
	if(flight_state < APU_SPUN) //No fuel? don't spam them with master cautions / use any fuel
		return FALSE
	var/amount = (user_thrust_dir) ? fuel_consumption+0.25 : fuel_consumption //When you're thrusting : fuel consumption doubles. Idling is cheap.
	var/obj/item/fighter_component/fuel_tank/ft = get_part(/obj/item/fighter_component/fuel_tank)
	if(!ft)
		flight_state = NO_FUEL
		set_master_caution(TRUE)
		return FALSE
	ft.reagents.remove_reagent(/datum/reagent/aviation_fuel, amount)
	if(get_fuel() >= amount)
		return TRUE
	if(flight_state < NO_FUEL) //Stops people from getting spammed
		flight_state = NO_FUEL
		set_master_caution(TRUE)
	return FALSE

/obj/structure/overmap/fighter/proc/empty_fuel_tank()//Debug purposes, for when you need to drain a fighter's tank entirely.
	var/obj/item/fighter_component/fuel_tank/ft = get_part(/obj/item/fighter_component/fuel_tank)
	if(!ft)
		return FALSE
	ft.reagents.clear_reagents()
	say("Fuel tank emptied!")

/obj/structure/overmap/fighter/proc/get_max_fuel()
	var/obj/item/fighter_component/fuel_tank/ft = get_part(/obj/item/fighter_component/fuel_tank)
	if(!ft)
		return 0
	return ft.reagents.maximum_volume

/obj/structure/overmap/fighter/proc/get_max_aux_fuel()
	var/obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank/aft = get_part(/obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank)
	if(!aft)
		return 0
	return aft.reagents.maximum_volume

/obj/structure/overmap/fighter/proc/get_max_rbs()
	var/obj/item/fighter_component/secondary/utility/rbs_reagent_tank/rbs = get_part(/obj/item/fighter_component/secondary/utility/rbs_reagent_tank)
	if(!rbs)
		return 0
	var/obj/item/reagent_containers/rbs_welder_tank/WT = locate(/obj/item/reagent_containers/rbs_welder_tank) in rbs.contents
	return WT.reagents.maximum_volume

//UI

/obj/structure/overmap/fighter/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(ui == "fighter_controls")
		if(!in_range(src, usr) || !pilot || usr != pilot) //Topic check
			return
	if(ui == "fighter_maintenance")
		if(!in_range(src, usr))
			return
	if(warmup_cooldown)
		to_chat(usr, "You need to wait for [src] to finish its last action.</span>")
		return
	var/atom/movable/target = locate(params["id"])
	switch(action)
		if("examine")
			if(!target)
				return
			to_chat(usr, "<span class='notice'>[target.desc]</span>")
		if("eject_p")
			if(!target)
				return
			to_chat(usr, "<span class='notice'>You start uninstalling [target.name] from [src].</span>")
			if(!do_after(usr, 5 SECONDS, target=src))
				return
			to_chat(usr, "<span class='notice>You uninstall [target.name] from [src].</span>")
			if(istype(target, /obj/item/ship_weapon/ammunition/countermeasure_charge))
				mun_countermeasures -= target
			target?.forceMove(get_turf(src))
			update_stats()
		if("kick")
			if(!target)
				return
			if(!allowed(usr) || usr != pilot)
				return
			var/mob/living/L = target
			to_chat(L, "<span class='warning'>You have been kicked out of [src] by the pilot.</span>")
			canopy_open = FALSE
			toggle_canopy()
			stop_piloting(L)
		if("ignition")
			if(flight_state > NO_FUEL_PUMP)
				if(!throttle_lock)
					to_chat(usr, "You cannot shut down [src]'s engines without first engaging the throttle lock.</span>")
					return
				to_chat(usr, "You start flipping switches and perfoming a controlled shutdown...</span>")
				relay('nsv13/sound/effects/fighters/powerswitch.ogg')
				if(do_after(usr, 5 SECONDS, target=src))
					flight_state = NO_IGNITION
					playsound(src, 'nsv13/sound/effects/ship/rcs.ogg', 100, TRUE)
					visible_message("<span class='warning'>[src]'s engine fizzles out!</span>")
					stop_relay(CHANNEL_SHIP_ALERT)
				return
			to_chat(usr, "You flip the ignition switch.</span>")
			flight_state = NO_FUEL_PUMP
			relay('nsv13/sound/effects/fighters/powerswitch.ogg')
		if("fuel_pump")
			if(flight_state >= NO_BATTERY)
				to_chat(usr, "You can't flip this switch without first deactivating the battery.</span>")
				return
			if(flight_state == NO_FUEL_PUMP)
				to_chat(usr, "You flip the master fuel pump switch.</span>")
				flight_state = NO_BATTERY
				playsound(src, 'nsv13/sound/effects/fighters/warmup.ogg', 100, FALSE)
		if("battery")
			if(flight_state >= NO_APU)
				to_chat(usr, "You can't flip this switch without first disengaging the APU.</span>")
				return
			if(flight_state == NO_BATTERY)
				to_chat(usr, "You flip the battery switch.</span>")
				flight_state = NO_APU
		if("apu")
			if(!throttle_lock || flight_state >= APU_SPUN)
				to_chat(usr, "You can't flip this switch without first engaging the throttle lock or when in flight.</span>")
				return
			if(flight_state < NO_APU)
				to_chat(usr, "You can't flip this switch without first engaging the battery.</span>")
				return
			var/obj/item/fighter_component/apu/au = get_part(/obj/item/fighter_component/apu)
			if(au.burntout)
				to_chat(usr, "The sharp smell of ozone and burning plastic fills the air.</span>")
				return
			to_chat(usr, "You flip the APU switch.</span>")
			flight_state = APU_SPUN
			playsound(src, 'nsv13/sound/effects/fighters/apu_start.ogg', 100, FALSE)
			addtimer(VARSET_CALLBACK(src, warmup_cooldown, FALSE), 15 SECONDS)
			addtimer(CALLBACK(src, .proc/check_start), 16 SECONDS) //Throttle up now....
			return
		if("throttle_lock")
			to_chat(usr, "You flip the throttle lock switch.</span>")
			throttle_lock = !throttle_lock
		if("canopy_lock")
			toggle_canopy()
		if("eject")
			if(is_station_level(loc.z) || SSmapping.level_trait(loc.z, ZTRAIT_BOARDABLE))
				if(!canopy_open)
					canopy_open = TRUE
					playsound(src, 'nsv13/sound/effects/fighters/canopy.ogg', 100, 1)
				to_chat(usr, "<span class='notice'>You jump out of [src] in one smooth motion.</span>")
				stop_piloting(usr)
				return
			if(!ejecting)
				to_chat(usr, "<span class='notice'>WARNING AUTO-EJECT SEQUENCE COMMENCING IN T-5 SECONDS. USE THIS SWITCH AGAIN TO CANCEL THIS ACTION.</span>")
				relay('nsv13/sound/effects/fighters/switch.ogg')
				relay('nsv13/sound/effects/ship/general_quarters.ogg')
				addtimer(CALLBACK(src, .proc/eject), 10 SECONDS)
				ejecting = TRUE
				return
			else
				to_chat(usr, "<span class='notice'>WARNING AUTO-EJECT SEQUENCE CANCELLED.</span>")
				relay('nsv13/sound/effects/fighters/switch.ogg')
				ejecting = FALSE
				return
		if("docking_mode")
			to_chat(usr, "<span class='notice'>You [docking_mode ? "disengage" : "engage"] [src]'s docking computer.</span>")
			docking_mode = !docking_mode
			relay('nsv13/sound/effects/fighters/switch.ogg')
			return //Dodge the cooldown because these actions should be instant
		if("brakes")
			toggle_brakes()
			relay('nsv13/sound/effects/fighters/switch.ogg')
			return //Dodge the cooldown because these actions should be instant
		if("inertial_dampeners")
			toggle_inertia()
			relay('nsv13/sound/effects/fighters/switch.ogg')
			return //Dodge the cooldown because these actions should be instant
		if("weapon_safety")
			toggle_safety()
			relay('nsv13/sound/effects/fighters/switch.ogg')
			return //Dodge the cooldown because these actions should be instant
		if("target_lock")
			relinquish_target_lock()
			relay('nsv13/sound/effects/fighters/switch.ogg')
			return //Dodge the cooldown because these actions should be instant
		if("mag_release")
			if(!mag_lock)
				return
			mag_lock.abort_launch()
		if("master_caution")
			set_master_caution(FALSE)
			return
		if("deploy_countermeasure")
			fire_countermeasure()
			return
		if("remove_munition")
			var/atom/movable/muni = locate(params["target"])
			to_chat(usr, "<span class='notice'>You start unloading [muni.name] from [src].</span>")
			if(!do_after(usr, 5 SECONDS, target=src))
				return
			to_chat(usr, "<span class='notice'>You unload [muni.name] from [src].</span>")
			if(istype(muni, /obj/item/ship_weapon/ammunition/torpedo))
				mun_torps -= muni
			else if(istype(muni, /obj/item/ship_weapon/ammunition/missile))
				mun_missiles -= muni
			muni?.forceMove(get_turf(src))
			return
		if("show_dradis")
			dradis.attack_hand(usr)
			return
		if("carg")
			if(!target)
				return
			to_chat(usr, "<span class='notice'>You start unloading [target.name] from [src].</span>")
			if(!do_after(usr, 3 SECONDS, target=src) || !target)
				return
			cargo -= target
			target.forceMove(get_turf(src))
			return
	relay('nsv13/sound/effects/fighters/switch.ogg')

/obj/structure/overmap/fighter/ui_data(mob/user)
	var/list/data = list()
	data["ignition"] = FALSE
	data["fuel_pump"] = FALSE
	data["battery"] = FALSE
	data["apu"] = FALSE
	data["throttle_lock"] = throttle_lock
	data["docking_mode"] = docking_mode
	data["canopy_lock"] = canopy_open
	data["brakes"] = brakes
	data["inertial_dampeners"] = inertial_dampeners
	data["weapon_safety"] = weapon_safety
	data["target_lock"] = target_lock != null ? TRUE : FALSE
	data["max_integrity"] = max_integrity
	data["integrity"] = obj_integrity
	data["max_fuel"] = get_max_fuel()
	data["fuel"] = get_fuel()
	data["mag_locked"] = (mag_lock != null) ? TRUE : FALSE
	data["rwr"] = (enemies.len) ? TRUE : FALSE
	if(flight_state > NO_IGNITION)
		data["ignition"] = TRUE
	if(flight_state > NO_FUEL_PUMP)
		data["fuel_pump"] = TRUE
	if(flight_state > NO_BATTERY)
		data["battery"] = TRUE
	if(flight_state == APU_SPUN)
		data["apu"] = TRUE
	//Maintenance UI
	var/list/hardpoints_info = list()
	var/list/occupants_info = list()
	for(var/atom/movable/AM in contents)
		if(isliving(AM))
			var/mob/living/L = AM
			var/list/occupant_info = list()
			occupant_info["name"] = L.name
			occupant_info["id"] = "\ref[L]"
			occupant_info["afk"] = (L.mind) ? "Active" : "Inactive (SSD)"
			occupants_info[++occupants_info.len] = occupant_info
			continue
		if(!istype(AM, /obj/item/fighter_component))
			continue
		var/list/hardpoint_info = list()
		var/obj/item/fighter_component/FC = AM
		hardpoint_info["name"] = AM.name
		hardpoint_info["id"] = "\ref[AM]"
		hardpoint_info["burntout"] = FC.burntout
		hardpoints_info[++hardpoints_info.len] = hardpoint_info
	data["hardpoints_info"] = hardpoints_info
	data["occupants_info"] = occupants_info
	data["max_countermeasures"] = max_countermeasures
	data["current_countermeasures"] = mun_countermeasures.len
	data["master_caution"] = master_caution
	data["max_torpedoes"] = max_torpedoes
	data["current_torpedoes"] = mun_torps.len
	data["max_missiles"] = max_missiles
	data["current_missiles"] = mun_missiles.len
	if(get_max_aux_fuel())
		data["max_aux_fuel"] = get_max_aux_fuel()
		data["aux_fuel"] = get_aux_fuel()
	if(get_max_rbs())
		data["max_rbs"] = get_max_rbs()
		data["rbs_welder"] = get_rbs_welder()
		data["rbs_foamer"] = get_rbs_foamer()
	data["max_passengers"] = max_passengers
	data["passengers"] = mobs_in_ship.len
	data["flight_state"] = flight_state
	data["loaded_munitions"] = list()
	var/list/munitions = list()
	for(var/obj/item/ship_weapon/ammunition/M in mun_missiles)
		var/list/torp_info = list()
		torp_info["name"] = M.name
		torp_info["mun_id"] = "\ref[M]"
		munitions[++munitions.len] = torp_info
	for(var/obj/item/ship_weapon/ammunition/M in mun_torps)
		var/list/torp_info = list()
		torp_info["name"] = M.name
		torp_info["mun_id"] = "\ref[M]"
		munitions[++munitions.len] = torp_info
	data["loaded_munitions"] = munitions
	data["has_cargo"] = (cargo.len >= 1)
	var/list/cargo_info = list()
	if(cargo.len)
		for(var/atom/movable/F in cargo)
			var/list/info = list()
			info["name"] = F.name
			var/contentslist = "Contents:"
			for(var/atom/movable/FF in F.contents)
				contentslist += "[FF.name],"//lazy variable names go me
			info["contents"] = contentslist
			info["crate_id"] = "\ref[F]"
			cargo_info[++cargo_info.len] = info
	data["cargo"] = cargo.len
	data["max_cargo"] = max_cargo
	data["can_unload"] = !SSmapping.level_trait(z, ZTRAIT_OVERMAP) //Hmm gee I wonder why.
	data["cargo_info"] = cargo_info
	return data

#undef NO_IGNITION
#undef NO_FUEL_PUMP
#undef NO_BATTERY
#undef NO_APU
#undef APU_SPUN
#undef FLIGHT_READY
#undef NO_FUEL

#undef MS_CLOSED
#undef MS_UNSECURE
#undef MS_OPEN
