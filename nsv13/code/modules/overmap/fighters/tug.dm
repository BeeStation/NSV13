/obj/vehicle/sealed/car/realistic/fighter_tug
	name = "M575 Aircraft Tug"
	desc = "A variant of an armoured personnel carrier which is able to tow fighters around. <b>Ctrl</b> click it to grab the hitch"
	icon = 'nsv13/icons/obj/vehicles.dmi'
	icon_state = "tug"
	max_integrity = 150
	armor = list("melee" = 50, "bullet" = 40, "laser" = 40, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	enter_delay = 20
	max_occupants = 4

	movedelay = 0.6 SECONDS
	key_type = /obj/item/key/fighter_tug
	key_type_exact = TRUE
	engine_sound = 'nsv13/sound/vehicles/tug_engine.ogg'
	pixel_x = -16
	pixel_y = -19
	layer = HIGH_OBJ_LAYER
	//Movement speed variables, configure these per car.
	max_acceleration = 2
	max_turnspeed = 40
	turnspeed = 40
	static_traction = 9.8 //How good are the tyres?. THis behaves somewhat like acceleration, but it shouldnt be more efficient than 9.8, which is the gravity on earth
	kinetic_traction = 5 //if you are moving sideways and the static traction wasnt enough to kill it, you skid and you will have less traction, but allowing you to drift. KINETIC IE moving traction
	var/datum/gas_mixture/cabin_air //Cabin air mix used for small ships like fighters (see overmap/fighters/fighters.dm)
	var/obj/machinery/portable_atmospherics/canister/internal_tank //Internal air tank reference. Used mostly in small ships. If you want to sabotage a fighter, load a plasma tank into its cockpit :)
	var/ready = TRUE
	var/launch_dir = EAST

/obj/vehicle/sealed/car/realistic/fighter_tug/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			take_damage(30)
			if(prob(40))
				abort_launch()
		if(2)
			take_damage(25)
			if(prob(20))
				abort_launch()

/obj/vehicle/sealed/car/realistic/fighter_tug/Destroy()
	abort_launch()
	. = ..()

/obj/vehicle/sealed/car/realistic/fighter_tug/attack_hand(mob/user)
	ui_interact(user)

/obj/vehicle/sealed/car/realistic/fighter_tug/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.contained_state) // Remember to use the appropriate state.
  ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
  if(!ui)
    ui = new(user, src, ui_key, "fighter_tug", name, 300, 300, master_ui, state)
    ui.open()

/obj/vehicle/sealed/car/realistic/fighter_tug/ui_data(mob/user)
	var/list/data = list()
	var/obj/structure/overmap/loaded = locate(/obj/structure/overmap/fighter) in contents
	data["loaded"] = (loaded) ? TRUE : FALSE
	data["loaded_name"] = (loaded) ? loaded.name : "No fighter loaded"
	data["ready"] = ready
	data["launch_dir"] = dir2text(launch_dir)
	return data

/obj/vehicle/sealed/car/realistic/fighter_tug/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!LAZYFIND(return_drivers(), ui.user))
		to_chat(ui.user, "<span class='warning'>You can't reach the controls from back here...</span>")
		return
	switch(action)
		if("launch")
			start_launch()
		if("launch_dir")
			launch_dir = input(ui.user, "Set fighter launch direction", "[name]", launch_dir) as null|anything in GLOB.cardinals
			if(!launch_dir)
				launch_dir = initial(launch_dir)
		if("load")
			var/obj/structure/overmap/load = locate(/obj/structure/overmap/fighter) in contents
			if(load)
				abort_launch()
				return
			load()
	update_icon() // Not applicable to all objects.

/obj/vehicle/sealed/car/realistic/fighter_tug/after_add_occupant(mob/M)
	. = ..()
	ui_interact(M)

/obj/vehicle/sealed/car/realistic/fighter_tug/proc/can_launch_fighters()
	return TRUE

/obj/vehicle/sealed/car/realistic/fighter_tug/proc/load()
	var/obj/structure/overmap/load = locate(/obj/structure/overmap/fighter) in orange(1, src)
	if(!load)
		return
	hitch(load)

/obj/vehicle/sealed/car/realistic/fighter_tug/Initialize()
	. = ..()
	set_light(3)
	add_overlay("hitch")

/obj/vehicle/sealed/car/realistic/fighter_tug/proc/hitch(obj/structure/overmap/fighter/target)
	LAZYADD(vis_contents, target)
	playsound(src, 'nsv13/sound/effects/ship/freespace2/crane_1.wav', 100, FALSE)
	visible_message("<span class='warning'>[target] is loaded onto [src]</span>")
	target.forceMove(src)
	target.mag_lock = src
	target.shake_animation()

/obj/vehicle/sealed/car/realistic/fighter_tug/process(time)
	. = ..()
	for(var/obj/structure/overmap/fighter/target in contents)
		target.desired_angle = 0
		target.angle = 0

/obj/vehicle/sealed/car/realistic/fighter_tug/proc/start_launch()
	if(!ready)
		return
	canmove = FALSE
	playsound(src.loc, 'nsv13/sound/effects/ship/fighter_launch.ogg', 100, FALSE)
	add_overlay("launcher_charge")
	for(var/obj/structure/overmap/fighter/target in contents)
		target.relay('nsv13/sound/effects/ship/fighter_launch.ogg')
		ready = FALSE
		addtimer(CALLBACK(src, .proc/finish_launch), 10 SECONDS)

/obj/vehicle/sealed/car/realistic/fighter_tug/proc/finish_launch()
	ready = TRUE
	density = FALSE
	var/stored_layer = layer
	layer = LOW_OBJ_LAYER
	for(var/obj/structure/overmap/fighter/target in contents)
		abort_launch(silent=TRUE)
		sleep(0.5)
		target.prime_launch() //Gets us ready to move at PACE.
		switch(launch_dir) //Just handling north / south..FOR NOW!
			if(NORTH) //PILOTS. REMEMBER TO FACE THE RIGHT WAY WHEN YOU LAUNCH, OR YOU WILL HAVE A TERRIBLE TIME.
				target.desired_angle = 0
				target.angle = target.desired_angle
				target.velocity_y = 20
			if(SOUTH)
				target.desired_angle = 180
				target.angle = target.desired_angle
				target.velocity_y = -20
			if(EAST)
				target.desired_angle = 90
				target.angle = target.desired_angle
				target.velocity_x = 20
			if(WEST)
				target.desired_angle = -90
				target.angle = target.desired_angle
				target.velocity_x = -20
		var/obj/structure/overmap/our_overmap = get_overmap()
		if(our_overmap)
			our_overmap.relay('nsv13/sound/effects/ship/fighter_launch_short.ogg')
		sleep(1 SECONDS)
		density = TRUE
		layer = stored_layer
	canmove = TRUE

/obj/vehicle/sealed/car/realistic/fighter_tug/proc/abort_launch(silent=FALSE)
	for(var/obj/structure/overmap/fighter/target in contents)
		if(!silent)
			visible_message("<span class='warning'>[target] drops down off of [src]!</span>")
			playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
			target.shake_animation()
		LAZYREMOVE(vis_contents, target)
		target.forceMove(get_turf(src))
		target.mag_lock = null

/obj/item/key/fighter_tug
	name = "fighter tug key"
	desc = "A small grey key with an inscription on it 'keep away from clown'."
	icon = 'nsv13/icons/obj/vehicles32.dmi'
	icon_state = "key"
	w_class = WEIGHT_CLASS_TINY

//Atmos handling copypasta

/obj/vehicle/sealed/car/realistic/fighter_tug/Initialize()
	. = ..()
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.add_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
	cabin_air.gases[/datum/gas/oxygen][MOLES] = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.gases[/datum/gas/nitrogen][MOLES] = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)


/obj/vehicle/sealed/car/realistic/fighter_tug/return_air()
	return cabin_air

/obj/vehicle/sealed/car/realistic/fighter_tug/remove_air(amount)
	return cabin_air.remove(amount)

/obj/vehicle/sealed/car/realistic/fighter_tug/return_analyzable_air()
	return cabin_air

/obj/vehicle/sealed/car/realistic/fighter_tug/return_temperature()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		. = t_air.return_temperature()
	return

/obj/vehicle/sealed/car/realistic/fighter_tug/portableConnectorReturnAir()
	return return_air()

/obj/vehicle/sealed/car/realistic/fighter_tug/assume_air(datum/gas_mixture/giver)
	var/datum/gas_mixture/t_air = return_air()
	return t_air.merge(giver)

/obj/vehicle/sealed/car/realistic/fighter_tug/slowprocess()
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