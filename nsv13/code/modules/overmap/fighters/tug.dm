/obj/vehicle/sealed/car/realistic/fighter_tug
	name = "\improper M575 Aircraft Tug"
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
	default_hardpoints = list(/obj/item/vehicle_hardpoint/engine/pathetic, /obj/item/vehicle_hardpoint/wheels/heavy) //What does it start with, if anything.
	var/ready = TRUE
	var/list/loaded = list() //Loaded fighters

/obj/vehicle/sealed/car/realistic/fighter_tug/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			if(prob(40))
				abort_launch()
		if(2)
			if(prob(20))
				abort_launch()

/obj/vehicle/sealed/car/realistic/fighter_tug/Destroy()
	abort_launch()
	. = ..()

/obj/vehicle/sealed/car/realistic/fighter_tug/ui_state(mob/user)
	return GLOB.contained_state

/obj/vehicle/sealed/car/realistic/fighter_tug/ui_interact(mob/user, datum/tgui/ui)
  ui = SStgui.try_update_ui(user, src, ui)
  if(!ui)
    ui = new(user, src, "FighterTug")
    ui.open()

/obj/vehicle/sealed/car/realistic/fighter_tug/ui_data(mob/user)
	var/list/data = ..()
	var/obj/structure/overmap/tugged = locate(/obj/structure/overmap/fighter) in contents
	data["loaded"] = (tugged) ? TRUE : FALSE
	data["loaded_name"] = (tugged) ? tugged.name : "No fighter loaded"
	data["ready"] = ready
	return data

/obj/vehicle/sealed/car/realistic/fighter_tug/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!isliving(usr))
		return FALSE
	var/list/drivers = return_drivers()
	if(!LAZYFIND(drivers, ui.user))
		to_chat(ui.user, "<span class='warning'>You can't reach the controls from back here...</span>")
		return
	var/target_name = params["target"]
	switch(action)
		if("launch")
			start_launch()
		if("load")
			var/obj/structure/overmap/load = locate(/obj/structure/overmap/fighter) in loaded
			if(load)
				abort_launch()
				return
			load()
		if("remove_hardpoint")
			remove_hardpoint(target_name, ui.user)
		if("interact")
			interact_with_hardpoint(target_name, ui.user)
	update_icon() // Not applicable to all objects.

/obj/vehicle/sealed/car/realistic/fighter_tug/proc/can_launch_fighters()
	return TRUE

/obj/vehicle/sealed/car/realistic/fighter_tug/proc/load()
	var/obj/structure/overmap/load = locate(/obj/structure/overmap/fighter) in orange(get_turf(get_step(src, angle2dir(angle))), 1)
	if(!load)
		load = locate(/obj/structure/overmap/fighter) in orange(1, src) //Failing a dir check, try this
		return
	hitch(load)

/obj/vehicle/sealed/car/realistic/fighter_tug/Initialize()
	. = ..()
	set_light(5)

/obj/vehicle/sealed/car/realistic/fighter_tug/proc/hitch(obj/structure/overmap/fighter/target)
	if(!target || LAZYFIND(loaded, target) || target.mag_lock)//No sucking
		return FALSE
	loaded += target
	STOP_PROCESSING(SSphysics_processing, target)
	target.forceMove(src)
	vis_contents += target
	playsound(src, 'nsv13/sound/effects/ship/freespace2/crane_1.wav', 100, FALSE)
	visible_message("<span class='warning'>[target] is loaded onto [src]</span>")
	target.forceMove(src)
	target.mag_lock = src
	target.shake_animation()

/obj/vehicle/sealed/car/realistic/fighter_tug/process(time)
	. = ..()
	for(var/obj/structure/overmap/fighter/target in loaded)
		if(target.loc != src)
			vis_contents -= target
			loaded -= target
			target.mag_lock = null
			continue
		target.desired_angle = 0
		target.angle = 0
		for(var/mob/living/M in target.operators)
			var/mob/camera/ai_eye/remote/overmap_observer/eyeobj = M.remote_control
			eyeobj.forceMove(get_turf(src))
			if(M.client)
				M.client.pixel_x = pixel_x
				M.client.pixel_y = pixel_y

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
		dir = angle2dir(angle)
		target.desired_angle = 0
		if(dir & NORTH) //PILOTS. REMEMBER TO FACE THE RIGHT WAY WHEN YOU LAUNCH, OR YOU WILL HAVE A TERRIBLE TIME.
			target.desired_angle += 0
			target.angle = target.desired_angle
			target.velocity.y = 20
		if(dir & SOUTH)
			target.desired_angle += 180
			target.angle = target.desired_angle
			target.velocity.y = -20
		if(dir & EAST)
			target.desired_angle += 90
			target.angle = target.desired_angle
			target.velocity.x = 20
		if(dir & WEST)
			target.desired_angle -= 90
			target.velocity.x = -20
		target.angle = target.desired_angle
		var/obj/structure/overmap/our_overmap = get_overmap()
		if(our_overmap)
			our_overmap.relay('nsv13/sound/effects/ship/fighter_launch_short.ogg')
		sleep(1 SECONDS)
		density = TRUE
		layer = stored_layer
	canmove = TRUE

/obj/vehicle/sealed/car/realistic/fighter_tug/proc/abort_launch(silent=FALSE)
	for(var/obj/structure/overmap/fighter/target in loaded)
		if(!silent)
			visible_message("<span class='warning'>[target] drops down off of [src]!</span>")
			playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
			target.shake_animation()
		vis_contents -= target
		loaded -= target
		var/turf/targetLoc = get_turf(get_step(src, angle2dir(angle)))
		if(!istype(targetLoc, /turf/open))
			targetLoc = get_turf(src) //Prevents them yeeting fighters through walls.
		var/obj/structure/fighter_launcher/FL = locate(/obj/structure/fighter_launcher) in orange(targetLoc, 2)
		target.mag_lock = null
		if(FL)
			targetLoc = get_turf(FL)
		target.forceMove(targetLoc)
		START_PROCESSING(SSphysics_processing, target)

/obj/item/key/fighter_tug
	name = "fighter tug key"
	desc = "A small grey key with an inscription on it 'keep away from clown'."
	icon = 'nsv13/icons/obj/vehicles32.dmi'
	icon_state = "key"
	w_class = WEIGHT_CLASS_TINY
