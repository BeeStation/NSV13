#define MS_CLOSED 		0
#define MS_UNSECURE 	1
#define MS_OPEN	 		2

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
	name = "Fighter"
	desc = "A space faring fighter craft."
	icon = 'nsv13/icons/overmap/nanotrasen/fighter.dmi'
	icon_state = "fighter"
	brakes = TRUE
	armor = list("melee" = 80, "bullet" = 50, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 80) //temp to stop easy destruction from small arms
	bound_width = 64 //Change this on a per ship basis
	bound_height = 96
	mass = MASS_TINY
	sprite_size = 32
	damage_states = TRUE
	faction = "nanotrasen"
	max_integrity = 120 //Really really squishy!
	torpedoes = 0
	speed_limit = 6 //We want fighters to be way more maneuverable
	weapon_safety = TRUE //This happens wayy too much for my liking. Starts OFF.
	var/maint_state = MS_CLOSED
	var/prebuilt = FALSE
	var/a_eff = 0
	var/f_eff = 0
	var/max_torpedoes = 2 //Tiny payload.
	var/mag_lock = FALSE //Mag locked by a launch pad. Cheaper to use than locate()
	var/max_passengers = 0 //Maximum capacity for passengers, INCLUDING pilot (EG: 1 pilot, 4 passengers).
	var/docking_mode = FALSE
	var/warning_cooldown = FALSE
	var/canopy_breached = FALSE //Canopy will breach if you take too much damage, causing your air to leak out.
	var/docking_cooldown = FALSE
	var/list/munitions = list()

/obj/machinery/computer/ship/fighter_launcher
	name = "Mag-cat control console"
	desc = "A computer which is capable of remotely activating fighter launch / arrestor systems."
	req_access = list()
	req_one_access_txt = "69"
	var/list/launchers = list()

/obj/machinery/computer/ship/fighter_launcher/proc/get_launchers()
	launchers = list()
	var/area/AR = get_area(src)
	for(var/obj/structure/fighter_launcher/FL in AR)
		launchers += FL

/obj/machinery/computer/ship/fighter_launcher/attack_hand(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(!has_overmap())
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>A warning flashes across [src]'s screen: Unable to locate thrust parameters, no registered ship stored in microprocessor.</span>")
		return
	get_launchers()
	var/dat = "<html>"
	dat += "<h1>Fighter launch systems:</h2><br>"
	for(var/obj/structure/fighter_launcher/FL in launchers)
		dat += "<h2>[FL]:</h2><br>"
		if(FL.mag_locked && FL.ready)
			dat += "<a href='?src=[REF(src)];launch=[REF(FL)]'>Launch: [FL.mag_locked]</a><br>"
			dat += "<a href='?src=[REF(src)];release=[REF(FL)]'>Release: [FL.mag_locked]</a><br>"
		else
			dat += "<p>[FL] 's status: IDLE.</p><br>"
	dat += "<h2>Pre-flight checklist:</h2><br>"
	dat += "<ul>Fuel check</ul><br>"
	dat += "<ul>Fighter canopy check</ul><br>"
	dat += "<ul>Fighter orientation check</ul><br>"
	dat += "<ul>Exit doors check</ul><br>"
	dat += "</html>"
	var/datum/browser/popup = new(user, "[name]", name, 400, 600)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/ship/fighter_launcher/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	if(href_list["launch"])
		var/obj/structure/fighter_launcher/FL = locate(href_list["launch"])
		if(!FL)
			return
		FL.start_launch()
		playsound(src, 'nsv13/sound/effects/computer/alarm_2.ogg', 100, 1)
		to_chat(usr, "<span class='notice'>Fighter launch sequence initiated.</span>")
	if(href_list["release"])
		var/obj/structure/fighter_launcher/FL = locate(href_list["release"])
		if(!FL)
			return
		FL.abort_launch()
		playsound(src, 'nsv13/sound/effects/computer/alarm_3.ogg', 100, 1)
		to_chat(usr, "<span class='warning'>Fighter launch sequence aborted. Magnetic interlocks disabled for 15 seconds.</span>")
	attack_hand(usr)

/obj/structure/fighter_launcher //Fighter launch track! This is both an arrestor and an assisted launch system for ease of use.
	name = "electromagnetic catapult"
	desc = "A large rail which uses a electromagnetic technology to accelerate fighters to extreme speeds. This state of the art piece of machinery acts as both an arrestor and an assisted fighter launch system."
	icon = 'nsv13/icons/overmap/nanotrasen/fighter.dmi'
	icon_state = "launcher_map" //Icon to show which way theyre pointing
	bound_width = 96
	bound_height = 96
	pixel_x = 38
	anchored = TRUE
	density = FALSE
	var/obj/structure/overmap/fighter/mag_locked = null
	var/obj/structure/overmap/linked = null
	var/ready = TRUE

/obj/structure/fighter_launcher/Initialize()
	. = ..()
	icon_state = "launcher"
	linkup()
	addtimer(CALLBACK(src, .proc/linkup), 15 SECONDS)//Just in case we're not done initializing

/obj/structure/overmap/fighter/can_brake()
	if(mag_lock)
		if(pilot)
			to_chat(pilot, "<span class='warning'>WARNING: Ship is magnetically arrested by an arrestor. Awaiting decoupling by fighter technicians.</span>")
		return FALSE
	return TRUE

/obj/structure/overmap/fighter/can_move()
	if(mag_lock)
		if(pilot)
			to_chat(pilot, "<span class='warning'>WARNING: Ship is magnetically arrested by an arrestor. Awaiting decoupling by fighter technicians.</span>")
		return FALSE
	return TRUE

/obj/structure/fighter_launcher/Crossed(atom/movable/AM)
	. = ..()
	if(istype(AM, /obj/structure/overmap/fighter) && !mag_locked && ready) //Are we able to catch this ship?
		var/obj/structure/overmap/fighter/OM = AM
		mag_locked = AM
		visible_message("<span class='warning'>CLUNK.</span>")
		OM.brakes = TRUE
		OM.velocity_x = 0
		OM.velocity_y = 0 //Full stop.
		OM.mag_lock = TRUE
		var/turf/center = get_turf(src)
		switch(dir)
			if(NORTH || EAST || WEST)
				center = get_turf(src)
			if(SOUTH)
				center = get_turf(locate(x,y-1,z))
		OM.forceMove(get_turf(center)) //"Catch" them like an arrestor.
		var/obj/structure/overmap/link = get_overmap()
		link?.relay('nsv13/sound/effects/ship/freespace2/shockwave.wav')
		shake_people(OM)
		switch(dir) //Make sure theyre facing the right way so they dont FACEPLANT INTO THE WALL.
			if(NORTH)
				OM.desired_angle = 0
			if(SOUTH)
				OM.desired_angle = 180
		if(!linked)
			linkup()


/obj/structure/fighter_launcher/proc/shake_people(var/obj/structure/overmap/OM)
	if(OM?.operators.len)
		for(var/mob/M in OM.operators)
			shake_camera(M, 10, 1)
			to_chat(M, "<span class='warning'>You feel a sudden jolt!</span>")
			if(iscarbon(M))
				var/mob/living/carbon/L = M
				if(HAS_TRAIT(L, TRAIT_SEASICK))
					to_chat(L, "<span class='warning'>You can feel your head start to swim...</span>")
					if(prob(40)) //Rough landing huh...
						L.adjust_disgust(40)
					else
						L.adjust_disgust(30)

/obj/structure/fighter_launcher/proc/start_launch()
	if(!mag_locked || !ready)
		return
	mag_locked.relay('nsv13/sound/effects/ship/fighter_launch.ogg')
	addtimer(CALLBACK(src, .proc/finish_launch), 10 SECONDS)

/obj/structure/fighter_launcher/proc/abort_launch()
	if(!mag_locked)
		return
	if(mag_locked.pilot)
		to_chat(mag_locked.pilot, "<span class='warning'>Launch aborted by operator.</span>")
	mag_locked.release_maglock()
	mag_locked = null
	icon_state = "launcher_charge"
	ready = FALSE
	addtimer(CALLBACK(src, .proc/recharge), 15 SECONDS) //Give them time to get out of there.

/obj/structure/fighter_launcher/proc/finish_launch()
	icon_state = "launcher_charge"
	mag_locked.prime_launch() //Gets us ready to move at PACE.
	var/obj/structure/overmap/our_overmap = get_overmap()
	if(our_overmap)
		our_overmap.relay('nsv13/sound/effects/ship/fighter_launch_short.ogg')
	spawn(0)
		shake_people(mag_locked)
	switch(dir) //Just handling north / south..FOR NOW!
		if(NORTH) //PILOTS. REMEMBER TO FACE THE RIGHT WAY WHEN YOU LAUNCH, OR YOU WILL HAVE A TERRIBLE TIME.
			mag_locked.velocity_y = 20
		if(SOUTH)
			mag_locked.velocity_y = -20
	ready = FALSE
	mag_locked = null
	addtimer(CALLBACK(src, .proc/recharge), 10 SECONDS) //Stops us from catching the fighter right after we launch it.

//Code that handles fighter - overmap transference.

/obj/structure/fighter_launcher/proc/linkup()
	linked = get_overmap()
	if(linked) //If we have a linked overmap, translate our position into a point where fighters should be returning to our Z-level.
		switch(dir)
			if(NORTH)
				linked.docking_points += get_turf(locate(x, 250, z))
			if(SOUTH)
				linked.docking_points += get_turf(locate(x, 10, z))
			if(EAST)
				linked.docking_points += get_turf(locate(250, y, z))
			if(WEST)
				linked.docking_points += get_turf(locate(10, y, z))

/obj/structure/overmap/fighter/proc/ready_for_transfer()
	if(docking_cooldown)
		return
	if(is_station_level(z)) //AKA, we're on the ship. Havent added away mission support yet.
		if(y > 250)
			return TRUE
		if(y < 10)
			return TRUE
		if(x > 250)
			return TRUE
		if(x < 10)
			return TRUE
	return FALSE

/obj/structure/fighter_launcher/proc/recharge()
	ready = TRUE
	icon_state = "launcher"


/obj/structure/overmap/fighter/proc/release_maglock()
	brakes = FALSE
	mag_lock = FALSE

/obj/structure/overmap/fighter/proc/prime_launch()
	release_maglock()
	speed_limit = 20 //Let them accelerate to hyperspeed due to the launch, and temporarily break the speed limit.
	addtimer(VARSET_CALLBACK(src, speed_limit, initial(speed_limit)), 5 SECONDS) //Give them 5 seconds of super speed mode before we take it back from them

/obj/structure/overmap/fighter/verb/cycle_docking_mode()
	set name = "Toggle Docking Mode"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check())
		return
	docking_mode = !docking_mode
	to_chat(usr, "<span class='notice'>Docking mode [docking_mode ? "engaged" : "disengaged"].</span>")

/obj/structure/overmap/fighter/proc/check_overmap_elegibility() //What we're doing here is checking if the fighter's hitting the bounds of the Zlevel. If they are, we need to transfer them to overmap space.
	if(ready_for_transfer())
		for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
			if(OM.main_overmap)
				forceMove(get_turf(OM))
				resize = 1 //Scale down!
				docking_cooldown = TRUE
				addtimer(VARSET_CALLBACK(src, docking_cooldown, FALSE), 5 SECONDS) //Prevents jank.
				if(pilot)
					to_chat(pilot, "<span class='notice'>Docking mode disabled. Use the 'Ship' verbs tab to re-enable docking mode, then fly into an allied ship to complete docking proceedures.</span>")
					docking_mode = FALSE
				return TRUE

/obj/structure/overmap/fighter/proc/transfer_from_overmap(obj/structure/overmap/OM)
	if(docking_cooldown)
		return
	if(OM.docking_points.len)
		resize = 0 //Scale up!
		var/turf/T = get_turf(pick(OM.docking_points))
		forceMove(T)
		if(pilot)
			to_chat(pilot, "<span class='notice'>Docking complete.</span>")
			docking_mode = FALSE
		docking_cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, docking_cooldown, FALSE), 5 SECONDS) //Prevents jank.
		return TRUE

/obj/structure/overmap/fighter/take_damage()
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

/obj/structure/overmap/fighter/update_icon()
	. =..()
	if(canopy_breached)
		add_overlay(image(icon = icon, icon_state = "canopy_breach", dir = 1))

/obj/structure/overmap/fighter/ai
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	prebuilt = TRUE
	faction = "nanotrasen"

/obj/structure/overmap/fighter/ai/syndicate
	faction = "syndicate"

/obj/structure/overmap/fighter/prebuilt
	prebuilt = TRUE

/obj/structure/overmap/fighter/prebuilt/raptor
	name = "Raptor"
	desc = "This craft is Nanotrasen's offering in the field of search and rescue. It has room for multiple people and allows for deployment of troops, supplies, and more across different ships."
	icon = 'nsv13/icons/overmap/nanotrasen/carrier.dmi'
	icon_state = "carrier"
	damage_states = FALSE
	max_passengers = 5 //Raptors can fit multiple people
	max_integrity = 150 //Squishy!

/obj/structure/overmap/return_air()
	return cabin_air

/obj/structure/overmap/slowprocess()
	. = ..()
	if(cabin_air && cabin_air.volume > 0)
		var/delta = cabin_air.temperature - T20C
		cabin_air.temperature -= max(-10, min(10, round(delta/4,0.1)))
	if(internal_tank && cabin_air)
		var/datum/gas_mixture/tank_air = internal_tank.return_air()
		var/release_pressure = ONE_ATMOSPHERE
		var/cabin_pressure = cabin_air.return_pressure()
		var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
		var/transfer_moles = 0
		if(pressure_delta > 0) //cabin pressure lower than release pressure
			if(tank_air.return_temperature() > 0)
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
				cabin_air.merge(removed)
		else if(pressure_delta < 0) //cabin pressure higher than release pressure
			var/turf/T = get_turf(src)
			var/datum/gas_mixture/t_air = T.return_air()
			pressure_delta = cabin_pressure - release_pressure
			if(t_air)
				pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
			if(pressure_delta > 0) //if location pressure is lower than cabin pressure
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
				if(T)
					T.assume_air(removed)
				else //just delete the cabin gas, we're in space or some shit
					qdel(removed)

/obj/structure/overmap/fighter/slowprocess()
	. = ..()
	if(canopy_breached) //Leak.
		var/datum/gas_mixture/removed = cabin_air.remove(5)
		qdel(removed)

/obj/structure/overmap/remove_air(amount)
	return cabin_air.remove(amount)

/obj/structure/overmap/fighter/Initialize()
	.=..()
	if(prebuilt)
		prebuilt_setup()
	dradis = new /obj/machinery/computer/ship/dradis/internal(src) //Fighters need a way to find their way home.
	dradis?.soundloop?.stop()
	update_stats()
	fuel_setup()
	obj_integrity = max_integrity
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/check_overmap_elegibility) //Used to smoothly transition from ship to overmap

/obj/structure/overmap/fighter/proc/prebuilt_setup()
	name = new_prebuilt_fighter_name() //pulling from NSV13 ship name list currently
	var/list/components = list(/obj/item/twohanded/required/fighter_component/empennage,
							/obj/item/twohanded/required/fighter_component/wing,
							/obj/item/twohanded/required/fighter_component/wing,
							/obj/item/twohanded/required/fighter_component/landing_gear,
							/obj/item/twohanded/required/fighter_component/cockpit,
							/obj/item/twohanded/required/fighter_component/armour_plating,
							/obj/item/twohanded/required/fighter_component/fuel_tank,
							/obj/item/fighter_component/avionics,
							/obj/item/fighter_component/fuel_lines,
							/obj/item/fighter_component/targeting_sensor,
							/obj/item/twohanded/required/fighter_component/engine,
							/obj/item/twohanded/required/fighter_component/engine,
							/obj/item/twohanded/required/fighter_component/primary_cannon)
	munitions += new /obj/structure/munition/fast(src)
	munitions += new /obj/structure/munition/fast(src)
	for(var/item in components)
		new item(src)
	torpedoes = munitions.len
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)

/obj/structure/overmap/fighter/proc/update_stats() //PLACEHOLDER JANK SYSTEM
	var/obj/item/twohanded/required/fighter_component/armour_plating/sap = get_part(/obj/item/twohanded/required/fighter_component/armour_plating)
	var/obj/item/fighter_component/targeting_sensor/sts = get_part(/obj/item/fighter_component/targeting_sensor)
	var/obj/item/fighter_component/fuel_lines/sfl = get_part(/obj/item/fighter_component/fuel_lines)
	var/senc = 0
	var/sens = 0
	var/sene = 0
	for(var/obj/item/twohanded/required/fighter_component/engine/sen in contents)
		senc++
		sens = sens + sen.speed
		sene = sene + sen.consumption
	if(senc > 0)
		sens = sens / senc
		sene = sene / senc
	if(sfl?.fuel_efficiency > 0)
		f_eff = sene + sfl.fuel_efficiency / 2
	a_eff = sts.weapon_efficiency
	max_integrity = initial(max_integrity) * sap.armour

/obj/structure/overmap/fighter/proc/fuel_setup()
	qdel(reagents)
	var/obj/item/twohanded/required/fighter_component/fuel_tank/sft = get_part(/obj/item/twohanded/required/fighter_component/fuel_tank)
	create_reagents(sft?.capacity)

//obj/structure/overmap/fighter/slowprocess()
//	if(reagents?.total_volume/reagents.maximum_volume*(100) < 10 && piloted) //too much spam currently - fix me
//		visible_message("<span class=userdanger>BINGO FUEL!</span>")

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
			to_chat(user, "<span class='notice'>You start pry open the maintenance hatch on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You pry open the maintenance hatch on [src].</span>")
				maint_state = MS_OPEN
				return TRUE
		if(MS_OPEN)
			to_chat(user, "<span class='notice'>You start replace the maintenance hatch on [src]...</span>")
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
	if(istype(A, /obj/structure/munition))
		if(maint_state == MS_OPEN)
			var/munition_count = munitions.len
			if(munition_count < max_torpedoes)
				to_chat(user, "<span class='notice'>You start adding [A] to [src]...</span>")
				if(!do_after(user, 2 SECONDS, target=src))
					return
				to_chat(user, "<span class='notice'>You add [A] to [src].</span>")
				A.forceMove(src)
				munitions += A
				torpedoes ++
				playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)  //placeholder
		else
			to_chat(user, "<span class='notice'>You require [src] to be in maintenance mode to load munitions!.</span>")
			return

/obj/structure/overmap/fighter/fire_torpedo(atom/target)
	if(ai_controlled) //AI ships don't have interiors
		if(torpedoes <= 0)
			return
		fire_projectile(/obj/item/projectile/bullet/torpedo, target, homing = TRUE, speed=1, explosive = TRUE)
		torpedoes --
		return
	var/proj_type = null //If this is true, we've got a launcher shipside that's been able to fire.
	var/proj_speed = 1
	if(!munitions.len)
		return
	torpedoes = munitions.len
	var/obj/structure/munition/thirtymillimetertorpedo = pick(munitions)
	proj_type = thirtymillimetertorpedo.torpedo_type
	proj_speed = thirtymillimetertorpedo.speed
	munitions -= thirtymillimetertorpedo
	qdel(thirtymillimetertorpedo)
	torpedoes = munitions.len
	if(proj_type)
		var/sound/chosen = pick('nsv13/sound/effects/ship/torpedo.ogg','nsv13/sound/effects/ship/freespace2/m_shrike.wav','nsv13/sound/effects/ship/freespace2/m_stiletto.wav','nsv13/sound/effects/ship/freespace2/m_tsunami.wav','nsv13/sound/effects/ship/freespace2/m_wasp.wav')
		relay_to_nearby(chosen)
		if(proj_type == /obj/item/projectile/bullet/torpedo/dud) //Some brainlet MAA loaded an incomplete torp
			fire_projectile(proj_type, target, homing = FALSE, speed=proj_speed, explosive = TRUE)
		else
			fire_projectile(proj_type, target, homing = TRUE, speed=proj_speed, explosive = TRUE)
	else
		to_chat(gunner, "<span class='warning'>DANGER: Launch failure! Torpedo tubes are not loaded.</span>")

/obj/structure/overmap/fighter/attackby(obj/item/W, mob/user, params)   //fueling and changing equipment
	add_fingerprint(user)
	if (istype(W, /obj/item/card/id)||istype(W, /obj/item/pda) && operators.len)
		if(!allowed(user))
			var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
			playsound(src, sound, 100, 1)
			to_chat(user, "<span class='warning'>Access denied</span>")
			return
		if(alert("Eject all current occupants from [src]?",name,"Yes","No") == "Yes" && Adjacent(user))
			to_chat(user, "<span class='warning'>Ejecting all current occupants from [src] and activating inertial dampeners...</span>")
			brakes = TRUE
			for(var/mob/M in operators)
				stop_piloting(M)
				to_chat(M, "<span class='warning'>[user] has forcibly ejected you from [src]!.</span>")
	if(maint_state == MS_OPEN)
		if(istype(W, /obj/item/fighter_component/fuel_lines) && !get_part(/obj/item/fighter_component/fuel_lines))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			update_stats()
		else if(istype(W, /obj/item/twohanded/required/fighter_component/fuel_tank) && !get_part(/obj/item/twohanded/required/fighter_component/fuel_tank))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			fuel_setup()
		else if(istype(W, /obj/item/fighter_component/targeting_sensor) && !get_part(/obj/item/fighter_component/targeting_sensor))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			update_stats()
		else if(istype(W, /obj/item/twohanded/required/fighter_component/armour_plating) && !get_part(/obj/item/twohanded/required/fighter_component/armour_plating))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			update_stats()
		else if(istype(W, /obj/item/twohanded/required/fighter_component/engine))
			var/e = 0
			for(var/obj/item/twohanded/required/fighter_component/engine/en in contents)
				e++
			if(e < 2)
				to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
				if(!do_after(user, 2 SECONDS, target=src))
					return
				to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
				W.forceMove(src)
				update_stats()
		else if(istype(W, /obj/item/reagent_containers))
			var/obj/item/reagent_containers/R = W
			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "<span class='notice'>[src]'s fuel tank is full!</span>")
				return
			R.reagents.trans_to(src, R.amount_per_transfer_from_this, transfered_by = user)
			to_chat(user, "<span class='notice'>You refuel [src] with [W].</span>")

/obj/structure/overmap/fighter/attack_hand(mob/user)
	.=..()
	dradis?.linked = src
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(maint_state == MS_OPEN)
		display_maint_popup(user)
		return TRUE
	else if(maint_state < MS_UNSECURE) //temp behaviour - button will break control of fighter
		if(alert("Enter what seat?",name,"Pilot seat","Passenger seat") !="Passenger seat")
			if(!pilot)
				to_chat(user, "<span class='notice'>You begin climbing into [src]'s cockpit...</span>")
				if(!do_after(user, 5 SECONDS, target=src))
					return
				to_chat(user, "<span class='notice'>You climb into [src]'s cockpit.</span>")
				user.forceMove(src)
				start_piloting(user, "all_positions")
				dradis?.soundloop?.start()
				mobs_in_ship += user
				SEND_SOUND(user, sound('nsv13/sound/effects/ship/cockpit.ogg', repeat = TRUE, wait = 0, volume = 100, channel=CHANNEL_SHIP_ALERT))
				return TRUE
		else
			if(mobs_in_ship.len < max_passengers)
				to_chat(user, "<span class='notice'>You begin climbing into one of [src]'s passenger seats..</span>")
				if(!do_after(user, 5 SECONDS, target=src))
					return
				to_chat(user, "<span class='notice'>You climb into one of [src]'s passenger seats.</span>")
				user.forceMove(src)
				start_piloting(user, "observer")
				mobs_in_ship += user
				SEND_SOUND(user, sound('nsv13/sound/effects/ship/cockpit.ogg', repeat = TRUE, wait = 0, volume = 100, channel=CHANNEL_SHIP_ALERT))
				return TRUE

/obj/structure/overmap/fighter/stop_piloting(mob/living/M)
	if(!is_station_level(z))
		to_chat(M, "<span class='warning'>DANGER: You may not exit [src] while flying alongside other large ships.</span>")
		return FALSE //No jumping out into the overmap :)
	operators -= M
	mobs_in_ship -= M
	LAZYREMOVE(M.mousemove_intercept_objects, src)
	if(M.click_intercept == src)
		M.click_intercept = null
	if(M == pilot)
		pilot = null
		if(helm)
			playsound(helm, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
		dradis?.soundloop?.stop()
	if(M == gunner)
		if(tactical)
			playsound(tactical, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
		gunner = null
	if(M.client)
		M.client.check_view()
	M.stop_sound_channel(CHANNEL_SHIP_ALERT)
	M.overmap_ship = null
	M.cancel_camera()
	M.remote_control = null
	M.forceMove(get_turf(src))
	return TRUE

/obj/structure/overmap/fighter/proc/display_maint_popup(mob/user)
	user.set_machine(src)
	var/dat
	dat += "<h2> Overview: </h2><br>"
//HP, fuel etc go here
	dat += "<p>Structural Integrity: [obj_integrity/max_integrity*(100)]%</p><br>"
	dat += "<p>Fuel Capacity: [reagents?.total_volume/reagents.maximum_volume*(100)]%</p><br>"
	dat += "<h2> Payload: </h2><br>"
//Guns, ammo and torpedos
	var/atom/movable/pw = get_part(/obj/item/twohanded/required/fighter_component/primary_cannon)
	if(pw == null)
		dat += "<p><b>PRIMARY WEAPON NOT INSTALLED</font></p><br>"
	else
		dat += "<a href='?src=[REF(src)]:primary_weapon=1'>[pw?.name]</a><br>"
	dat += "<p>Ammo Capacity:</p>"
	var/t = 0
	for(var/obj/structure/munition/mu in contents)
		dat += "<a href='?src=[REF(src)];torpedo=1'>[mu?.name]</a><br>"
		t++
	switch(t)
		if(1)
			dat += "<p><b>ONE TORPEDO PYLON EMPTY</font></p><br>"
		if(0)
			dat += "<p><b>TWO TORPEDO PYLONS EMPTY</font></p><br>"
	dat += "<h2> Components: </h2>"
	var/atom/movable/ap = get_part(/obj/item/twohanded/required/fighter_component/armour_plating)
	if(ap == null)
		dat += "<p><b>ARMOUR PLATING NOT INSTALLED</font></p><br>"
	else
		dat += "<a href='?src=[REF(src)];armour_plating=1'>[ap?.name]</a><br>"
	var/atom/movable/ft = get_part(/obj/item/twohanded/required/fighter_component/fuel_tank)
	if(ft == null)
		dat += "<p><b>FUEL TANK NOT INSTALLED</font></p><br>"
	else
		dat += "<a href='?src=[REF(src)];fuel_tank=1'>[ft?.name]</a><br>"
	var/atom/movable/fl = get_part(/obj/item/fighter_component/fuel_lines)
	if(fl == null)
		dat += "<p><b>FUEL LINES NOT INSTALLED</font></p><br>"
	else
		dat += "<a href='?src=[REF(src)];fuel_lines=1'>[fl?.name]</a><br>"
	var/atom/movable/ts = get_part(/obj/item/fighter_component/targeting_sensor)
	if(ts == null)
		dat += "<p><b>TARGETING SENSOR NOT INSTALLED</font></p><br>"
	else
		dat += "<a href='?src=[REF(src)];targeting_sensor=1'>[ts?.name]</a><br>"
	var/engine_count = 0
	for(var/obj/item/twohanded/required/fighter_component/engine/en in contents)
		dat += "<a href='?src=[REF(src)];engine=1'>[en?.name]</a><br>"
		engine_count++
	switch(engine_count)
		if(1)
			dat += "<p><b>ONE ENGINE NOT INSTALLED</font></p><br>"
		if(0)
			dat += "<p><b>TWO ENGINES NOT INSTALLED</font></p><br>"
	if(internal_tank)
		dat += "<a href='?src=[REF(src)];remove_tank=1'>Atmospherics supply tank: [internal_tank.name]</a><br>"
	else
		dat += "<p><b>Internal air tank not installed.</p><br>"
	var/datum/browser/popup = new(user, "fighter", name, 400, 600)
	popup.set_content(dat)
	popup.open()

/obj/structure/overmap/fighter/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr
	var/atom/movable/ap = get_part(/obj/item/twohanded/required/fighter_component/armour_plating)
	var/atom/movable/ft = get_part(/obj/item/twohanded/required/fighter_component/fuel_tank)
	var/atom/movable/fl = get_part(/obj/item/fighter_component/fuel_lines)
	var/atom/movable/ts = get_part(/obj/item/fighter_component/targeting_sensor)
	var/atom/movable/en = get_part(/obj/item/twohanded/required/fighter_component/engine)
	var/atom/movable/pw = get_part(/obj/item/twohanded/required/fighter_component/primary_cannon)
	var/atom/movable/tr = get_part(/obj/structure/munition)
	if(href_list["armour_plating"])
		if(ap)
			to_chat(user, "<span class='notice'>You start uninstalling [ap.name] from [src].</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You uninstall [ap.name] from [src].</span>")
			ap?.forceMove(get_turf(src))
			update_stats()
			attack_hand(user) //Refresh UI.
	if(href_list["fuel_tank"])
		if(ft)
			to_chat(user, "<span class='notice'>You start uninstalling [ft.name] from [src].</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You uninstall [ft.name] from [src].</span>")
			ft?.forceMove(get_turf(src))
			update_stats()
			attack_hand(user) //Refresh UI.
	if(href_list["fuel_lines"])
		if(fl)
			to_chat(user, "<span class='notice'>You start uninstalling [fl.name] from [src].</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You uninstall [fl.name] from [src].</span>")
			fl?.forceMove(get_turf(src))
			update_stats()
			attack_hand(user) //Refresh UI.
	if(href_list["targeting_sensor"])
		if(ts)
			to_chat(user, "<span class='notice'>You start uninstalling [ts.name] from [src].</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You uninstall [ts.name] from [src].</span>")
			ts?.forceMove(get_turf(src))
			update_stats()
			attack_hand(user) //Refresh UI.
	if(href_list["engine"])
		if(en)
			to_chat(user, "<span class='notice'>You start uninstalling [en.name] from [src].</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You uninstall [en.name] from [src].</span>")
			en?.forceMove(get_turf(src))
			update_stats()
			attack_hand(user) //Refresh UI.
	if(href_list["primary_weapon"])
		if(pw)
			to_chat(user, "<span class='notice'>You start uninstalling [pw.name] from [src].</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You uninstall [pw.name] from [src].</span>")
			pw?.forceMove(get_turf(src))
			update_stats()
			attack_hand(user) //Refresh UI.
	if(href_list["torpedo"])
		if(tr)
			to_chat(user, "<span class='notice'>You start uninstalling [tr.name] from [src].</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You uninstall [tr.name] from [src].</span>")
			tr?.forceMove(get_turf(src))
			munitions -= tr
			torpedoes = munitions.len
			attack_hand(user) //Refresh UI.
	if(href_list["remove_tank"])
		if(!internal_tank)
			return
		to_chat(user, "<span class='notice'>You start uninstalling [internal_tank.name] from [src].</span>")
		if(!do_after(user, 5 SECONDS, target=src))
			return
		to_chat(user, "<span class='notice'>You uninstall [internal_tank.name] from [src].</span>")
		internal_tank?.forceMove(get_turf(src))
		internal_tank = null
		attack_hand(user) //Refresh UI.

/obj/structure/overmap/fighter/on_reagent_change()
	.=..()
	for(var/datum/reagent/G in reagents.reagent_list)
		if(G.name != "Plasma Spiked Fuel")
			visible_message("<span class=warning>Warning: contaminant detected in fuel mix, dumping tank contents.</span>")
			reagents.clear_reagents()
			new /obj/effect/decal/cleanable/oil(loc)

/obj/structure/overmap/fighter/proc/eject()
	var/obj/structure/overmap/escapepod/ep = new /obj/structure/overmap/escapepod (loc, 1)
	var/atom/movable/hu = get_part(/mob/living/carbon/human) //Lmao karmic stop objectifying people
	hu.forceMove(ep)
	qdel(src)

/obj/structure/overmap/fighter/Destroy() //incomplete
	.=..()
	visible_message("<span class=userdanger>EJECT! EJECT! EJECT!</span>")
	playsound(src, 'sound/effects/alert.ogg', 100, TRUE)
	sleep(10)
	visible_message("<span class=userdanger>Auto-Ejection Sequence Enabled! Escape Pod Launched!</span>")
	//injuring pilot goes here
	eject()

/obj/structure/overmap/escapepod
	name = "Escape Pod"
	desc = "An escape pod launched from a space faring vessel."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "smmop"

#undef MS_CLOSED
#undef MS_UNSECURE
#undef MS_OPEN
