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
	pixel_w = -26
	pixel_z = -28
	var/maint_state = MS_CLOSED
	var/prebuilt = FALSE
	var/weapon_efficiency = 0
	var/fuel_consumption = 0
	var/max_torpedoes = 6 //Decent payload.
	var/mag_lock = FALSE //Mag locked by a launch pad. Cheaper to use than locate()
	var/max_passengers = 0 //Maximum capacity for passengers, INCLUDING pilot (EG: 1 pilot, 4 passengers).
	var/docking_mode = FALSE
	var/warning_cooldown = FALSE
	var/canopy_breached = FALSE //Canopy will breach if you take too much damage, causing your air to leak out.
	var/docking_cooldown = FALSE
	var/list/munitions = list()
	var/obj/structure/overmap/last_overmap = null //Last overmap we were attached to
	var/canopy_open = TRUE //Is the canopy open?
	var/flight_state = NO_IGNITION
	var/warmup_cooldown = FALSE //So you cant blitz the fighter ignition in 2 seconds
	var/ejecting = FALSE
	var/throttle_lock = FALSE

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
		switch(dir) //Do some fuckery to make sure the fighter lines up on the pad in a halfway sensible manner.
			if(NORTH)
				center = get_turf(locate(x+1,y+1,z))
			if(SOUTH)
				center = get_turf(locate(x+1,y+1,z))
			if(EAST)
				center = get_turf(locate(x+2,y,z))
			if(WEST)
				center = get_turf(locate(x+2,y,z))
		OM.forceMove(get_turf(center)) //"Catch" them like an arrestor.
		var/obj/structure/overmap/link = get_overmap()
		link?.relay('nsv13/sound/effects/fighters/magcat.ogg')
		shake_people(OM)
		switch(dir) //Make sure theyre facing the right way so they dont FACEPLANT INTO THE WALL.
			if(NORTH)
				OM.desired_angle = 0
			if(SOUTH)
				OM.desired_angle = 180
			if(EAST)
				OM.desired_angle = 90
			if(WEST)
				OM.desired_angle = -90
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
		if(EAST)
			mag_locked.velocity_x = 20
		if(WEST)
			mag_locked.velocity_x = -20
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
	if(SSmapping.level_trait(z, ZTRAIT_BOARDABLE)) //AKA, we're on the ship or mining level. Havent added away mission support yet.
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

/obj/structure/overmap/fighter/proc/check_overmap_elegibility() //What we're doing here is checking if the fighter's hitting the bounds of the Zlevel. If they are, we need to transfer them to overmap space.
	if(ready_for_transfer())
		var/obj/structure/overmap/OM = null
		if(last_overmap)
			OM = last_overmap
			last_overmap = null
		else
			for(var/obj/structure/overmap/O in GLOB.overmap_objects)
				if(O.main_overmap)
					OM = O
		if(!OM)
			return FALSE
		forceMove(get_turf(OM))
		docking_cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, docking_cooldown, FALSE), 5 SECONDS) //Prevents jank.
		resize = 1 //Scale down!
		pixel_w = -20
		pixel_z = -40
		if(pilot)
			to_chat(pilot, "<span class='notice'>Docking mode disabled. Use the 'Ship' verbs tab to re-enable docking mode, then fly into an allied ship to complete docking proceedures.</span>")
			docking_mode = FALSE
		return TRUE

/obj/structure/overmap/fighter/proc/update_overmap()
	var/area/A = get_area(src)
	if(A.linked_overmap)
		last_overmap = A.linked_overmap

/obj/structure/overmap/fighter/proc/docking_act(obj/structure/overmap/OM)
	if(mass < OM.mass && OM.docking_points.len && docking_mode) //If theyre smaller than us,and we have docking points, and they want to dock
		transfer_from_overmap(OM)

/obj/structure/overmap/fighter/proc/transfer_from_overmap(obj/structure/overmap/OM)
	if(docking_cooldown)
		return
	if(OM.docking_points.len)
		last_overmap = OM
		docking_cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, docking_cooldown, FALSE), 5 SECONDS) //Prevents jank.
		resize = 0 //Scale up!
		pixel_w = initial(pixel_w)
		pixel_z = initial(pixel_z)
		var/turf/T = get_turf(pick(OM.docking_points))
		forceMove(T)
		if(pilot)
			to_chat(pilot, "<span class='notice'>Docking complete.</span>")
			docking_mode = FALSE
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
	else if(canopy_open)
		add_overlay("canopy_open")

/obj/structure/overmap/fighter/ai
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	weapon_safety = FALSE
	prebuilt = TRUE
	faction = "nanotrasen"

/obj/structure/overmap/fighter/ai/syndicate
	name = "Syndicate interceptor"
	desc = "A space faring fighter craft."
	icon = 'nsv13/icons/overmap/syndicate/syn_fighter.dmi'
	icon_state = "fighter"
	brakes = FALSE
	max_integrity = 100 //Super squishy!
	bound_width = 32 //Change this on a per ship basis
	bound_height = 32
	sprite_size = 32
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

/obj/structure/overmap/fighter/prebuilt/raptor/docking_act(obj/structure/overmap/OM)
	if(docking_cooldown)
		return
	if(mass < OM.mass && OM.docking_points.len && docking_mode) //If theyre smaller than us,and we have docking points, and they want to dock
		transfer_from_overmap(OM)
	if(mass >= OM.mass && docking_mode) //Looks like theyre smaller than us, and need rescue.
		if(istype(OM, /obj/structure/overmap/fighter/prebuilt/escapepod)) //Can we take them aboard?
			if(OM.operators.len <= max_passengers+1-OM.mobs_in_ship.len) //Max passengers + 1 to allow for one raptor crew rescuing another. Imagine that theyre being cramped into the footwell or something.
				docking_cooldown = TRUE
				addtimer(VARSET_CALLBACK(src, docking_cooldown, FALSE), 5 SECONDS) //Prevents jank.
				var/obj/structure/overmap/fighter/prebuilt/escapepod/ep = OM
				relay_to_nearby('nsv13/sound/effects/ship/boarding_pod.ogg')
				to_chat(pilot,"<span class='warning'>Extending docking armatures...</span>")
				ep.transfer_occupants_to(src)
				qdel(ep)
			else
				if(pilot)
					to_chat(pilot,"<span class='warning'>[src]'s passenger cabin is full, you'd need [max_passengers+1-OM.mobs_in_ship.len] more seats to retrieve everyone!</span>")

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
	use_fuel()
	if(canopy_breached || (canopy_open && pilot)) //Leak.
		var/datum/gas_mixture/removed = cabin_air.remove(5)
		qdel(removed)

/obj/structure/overmap/fighter/return_air()
	if(!canopy_open && !canopy_breached)
		return cabin_air
	return loc.return_air()

/obj/structure/overmap/fighter/remove_air(amount)
	return cabin_air.remove(amount)

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
	dradis?.soundloop?.stop()
	update_stats()
	fuel_setup()
	obj_integrity = max_integrity
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/check_overmap_elegibility) //Used to smoothly transition from ship to overmap
	RegisterSignal(src, COMSIG_AREA_ENTERED, .proc/update_overmap) //Used to smoothly transition from ship to overmap
	add_overlay(image(icon = icon, icon_state = "canopy_open", dir = SOUTH))

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
	for(var/I = 0, I <= max_torpedoes, I++)
		munitions += new /obj/item/ship_weapon/ammunition/torpedo/fast(src)
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
		sens = sens + sen?.speed
		sene = sene + sen?.consumption
	if(senc > 0)
		sens = sens / senc
		sene = sene / senc
	if(sfl?.fuel_efficiency > 0)
		fuel_consumption = sene + sfl?.fuel_efficiency / 2
	weapon_efficiency = sts?.weapon_efficiency
	max_integrity = initial(max_integrity) * sap?.armour

/obj/structure/overmap/fighter/proc/fuel_setup()
	var/obj/item/twohanded/required/fighter_component/fuel_tank/sft = get_part(/obj/item/twohanded/required/fighter_component/fuel_tank)
	sft.fuel_setup()

/obj/item/twohanded/required/fighter_component/fuel_tank/proc/fuel_setup()
	create_reagents(capacity, DRAINABLE | AMOUNT_VISIBLE)
	reagents.add_reagent(/datum/reagent/aviation_fuel, capacity)

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
	if(istype(A, /obj/item/ship_weapon/ammunition/torpedo))
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
	var/obj/item/ship_weapon/ammunition/torpedo/thirtymillimetertorpedo = pick(munitions)
	proj_type = thirtymillimetertorpedo.projectile_type
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
		display_maint_popup(user)
		return TRUE
	if(!canopy_open)
		to_chat(user, "<span class='warning'>[src]'s canopy isn't open.</span>")
		return
	if(maint_state < MS_UNSECURE)
		if(alert("Enter what seat?",name,"Pilot seat","Passenger seat") !="Passenger seat")
			if(!pilot)
				to_chat(user, "<span class='notice'>You begin climbing into [src]'s cockpit...</span>")
				if(!do_after(user, 5 SECONDS, target=src))
					return
				to_chat(user, "<span class='notice'>You climb into [src]'s cockpit.</span>")
				user.forceMove(src)
				start_piloting(user, "all_positions")
				ui_interact(user)
				if(user?.client?.prefs.toggles & SOUND_AMBIENCE) //Disable ambient sounds to shut up the noises.
					dradis?.soundloop?.start()
				mobs_in_ship += user
				if(user?.client?.prefs.toggles & SOUND_AMBIENCE && flight_state >= FLIGHT_READY) //Disable ambient sounds to shut up the noises.
					SEND_SOUND(user, sound('nsv13/sound/effects/fighters/cockpit.ogg', repeat = TRUE, wait = 0, volume = 50, channel=CHANNEL_SHIP_ALERT))
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
				if(user?.client?.prefs.toggles & SOUND_AMBIENCE && flight_state >= FLIGHT_READY) //Disable ambient sounds to shut up the noises.
					SEND_SOUND(user, sound('nsv13/sound/effects/fighters/cockpit.ogg', repeat = TRUE, wait = 0, volume = 100, channel=CHANNEL_SHIP_ALERT))
				return TRUE

/obj/structure/overmap/fighter/stop_piloting(mob/living/M, force=FALSE)
	if(!SSmapping.level_trait(z, ZTRAIT_BOARDABLE) && !force)
		to_chat(M, "<span class='warning'>DANGER: You may not exit [src] while flying alongside other large ships.</span>")
		return FALSE //No jumping out into the overmap :)
	if(!canopy_open)
		to_chat(M, "<span class='warning'>[src]'s canopy isn't open.</span>")
		if(prob(50))
			playsound(src, 'sound/effects/glasshit.ogg', 75, 1)
			to_chat(M, "<span class='warning'>You bump your head on [src]'s canopy.</span>")
			visible_message("<span class='warning'>You hear a muffled thud.</span>")
		return
	M.focus = M
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
	var/mob/camera/aiEye/remote/overmap_observer/eyeobj = M.remote_control
	if(eyeobj?.off_action)
		qdel(eyeobj.off_action)
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
	dat += "<h2> Payload: </h2><br>"
//Guns, ammo and torpedos
	var/atom/movable/pw = get_part(/obj/item/twohanded/required/fighter_component/primary_cannon)
	if(pw == null)
		dat += "<p><b>PRIMARY WEAPON NOT INSTALLED</font></p><br>"
	else
		dat += "<a href='?src=[REF(src)]:primary_weapon=1'>[pw?.name]</a><br>"
	dat += "<p>Ammo Capacity:</p>"
	var/unfilled_slots = max_torpedoes
	for(var/obj/item/ship_weapon/ammunition/torpedo/mu in contents)
		dat += "<a href='?src=[REF(src)];torpedo=1'>[mu?.name]</a><br>"
		unfilled_slots--
	if(unfilled_slots > 0)
		dat += "<p><b>[num2text(unfilled_slots)] TORPEDO PYLONS EMPTY</font></p><br>"
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
	var/atom/movable/tr = get_part(/obj/item/ship_weapon/ammunition/torpedo)
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

/obj/structure/overmap/fighter/Destroy()
	if(operators.len && !istype(src, /obj/structure/overmap/fighter/prebuilt/escapepod))
		relay('nsv13/sound/effects/computer/alarm_3.ogg', "<span class=userdanger>EJECT! EJECT! EJECT!</span>")
		relay_to_nearby('nsv13/sound/effects/ship/fighter_launch_short.ogg')
		visible_message("<span class=userdanger>Auto-Ejection Sequence Enabled! Escape Pod Launched!</span>")
		eject()
		sleep(20)
	. = ..()

/obj/structure/overmap/fighter/proc/eject()
	if(istype(src, /obj/structure/overmap/fighter/prebuilt/escapepod))
		return FALSE
	var/obj/structure/overmap/fighter/prebuilt/escapepod/ep = new /obj/structure/overmap/fighter/prebuilt/escapepod(get_turf(src))
	ep.set_fuel(get_fuel()) //No infinite tyrosene for you!
	transfer_occupants_to(ep)
	ep.desired_angle = pick(0,360)
	ep.user_thrust_dir = NORTH
	qdel(src)

/obj/structure/overmap/fighter/prebuilt/escapepod
	name = "Escape Pod"
	desc = "An escape pod launched from a space faring vessel. It only has very limited thrusters and is thus very slow."
	icon = 'nsv13/icons/overmap/nanotrasen/escape_pod.dmi'
	icon_state = "escape_pod"
	damage_states = FALSE
	bound_width = 32 //Change this on a per ship basis
	bound_height = 32
	pixel_z = 0
	pixel_w = 0
	mass = MASS_TINY
	max_integrity = 100 //Able to withstand more punishment so that people inside it don't get yeeted as hard
	speed_limit = 2 //This, for reference, will feel suuuuper slow, but this is intentional
	max_torpedoes = 0
	flight_state = FLIGHT_READY
	canopy_open = FALSE

/obj/structure/overmap/fighter/prebuilt/escapepod/attack_hand(mob/user)
	return

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

/obj/structure/overmap/fighter/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	if(user != pilot)
		return
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "fighter_controls", name, 560, 600, master_ui, state)
		ui.open()

/obj/structure/overmap/fighter/can_move()
	var/obj/item/twohanded/required/fighter_component/engine/engine = get_part(/obj/item/twohanded/required/fighter_component/engine)
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
	if(user_thrust_dir)
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

/obj/structure/overmap/fighter/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!in_range(src, usr) || !pilot || usr != pilot) //Topic check
		return
	if(warmup_cooldown)
		to_chat(usr, "You need to wait for [src] to finish its last action.</span>")
		return
	switch(action)
		if("ignition")
			if(flight_state >= NO_FUEL_PUMP)
				to_chat(usr, "You can't flip the ignition switch without first deactivating the fuel pump.</span>")
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
			to_chat(usr, "You flip the APU switch.</span>")
			flight_state = APU_SPUN
			playsound(src, 'nsv13/sound/effects/fighters/apu_start.ogg', 100, FALSE)
			addtimer(VARSET_CALLBACK(src, warmup_cooldown, FALSE), 15 SECONDS)
			addtimer(CALLBACK(src, .proc/check_start), 16 SECONDS) //Throttle up now....
			return
		if("throttle_lock")
			to_chat(usr, "You flip the throttle lock switch.</span>")
			throttle_lock = !throttle_lock
		if("shutdown")
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
		if("canopy_lock")
			toggle_canopy()
		if("eject")
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
		if("weapon_safety")
			toggle_safety()
			relay('nsv13/sound/effects/fighters/switch.ogg')
			return //Dodge the cooldown because these actions should be instant
		if("target_lock")
			relinquish_target_lock()
			relay('nsv13/sound/effects/fighters/switch.ogg')
			return //Dodge the cooldown because these actions should be instant
	warmup_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, warmup_cooldown, FALSE), 3 SECONDS)
	relay('nsv13/sound/effects/fighters/switch.ogg')

/obj/structure/overmap/fighter/proc/get_fuel()
	var/obj/item/twohanded/required/fighter_component/fuel_tank/sft = get_part(/obj/item/twohanded/required/fighter_component/fuel_tank)
	if(!sft)
		return 0
	var/return_amt = 0
	for(var/datum/reagent/aviation_fuel/F in sft.reagents.reagent_list)
		if(!istype(F))
			continue
		return_amt += F.volume
	return return_amt

/obj/structure/overmap/fighter/proc/set_fuel(amount)
	var/obj/item/twohanded/required/fighter_component/fuel_tank/sft = get_part(/obj/item/twohanded/required/fighter_component/fuel_tank)
	if(!sft)
		return FALSE
	for(var/datum/reagent/aviation_fuel/F in sft.reagents.reagent_list)
		if(!istype(F))
			continue
		F.volume = amount
	return amount

/obj/structure/overmap/fighter/proc/set_master_caution(state)
	var/master_caution = state
	if(master_caution)
		relay('nsv13/sound/effects/fighters/master_caution.ogg', "<span class='warning'>WARNING: Master caution.</span>", loop=FALSE, channel=CHANNEL_BUZZ)
	else
		stop_relay(CHANNEL_BUZZ)

/obj/structure/overmap/fighter/proc/use_fuel()
	if(flight_state < APU_SPUN) //No fuel? don't spam them with master cautions / use any fuel
		return FALSE
	var/amount = fuel_consumption
	var/obj/item/twohanded/required/fighter_component/fuel_tank/sft = get_part(/obj/item/twohanded/required/fighter_component/fuel_tank)
	if(!sft)
		flight_state = NO_FUEL
		set_master_caution(TRUE)
		return FALSE
	sft.reagents.remove_reagent(/datum/reagent/aviation_fuel, amount)
	if(get_fuel() >= amount)
		set_master_caution(FALSE)
		return TRUE
	if(flight_state < NO_FUEL) //Stops people from getting spammed
		flight_state = NO_FUEL
		set_master_caution(TRUE)
	return FALSE

/obj/structure/overmap/fighter/proc/empty_fuel_tank()//Debug purposes, for when you need to drain a fighter's tank entirely.
	var/obj/item/twohanded/required/fighter_component/fuel_tank/sft = get_part(/obj/item/twohanded/required/fighter_component/fuel_tank)
	if(!sft)
		return FALSE
	sft.reagents.clear_reagents()
	say("Fuel tank emptied!")

/obj/structure/overmap/fighter/proc/get_max_fuel()
	var/obj/item/twohanded/required/fighter_component/fuel_tank/sft = get_part(/obj/item/twohanded/required/fighter_component/fuel_tank)
	if(!sft)
		return 0
	return sft.reagents.maximum_volume

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
	data["weapon_safety"] = weapon_safety
	data["target_lock"] = target_lock != null ? TRUE : FALSE
	data["max_integrity"] = max_integrity
	data["integrity"] = obj_integrity
	data["max_fuel"] = get_max_fuel()
	data["fuel"] = get_fuel()
	if(flight_state > NO_IGNITION)
		data["ignition"] = TRUE
	if(flight_state > NO_FUEL_PUMP)
		data["fuel_pump"] = TRUE
	if(flight_state > NO_BATTERY)
		data["battery"] = TRUE
	if(flight_state == APU_SPUN)
		data["apu"] = TRUE
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
