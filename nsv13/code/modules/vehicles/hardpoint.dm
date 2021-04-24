/obj/vehicle/sealed/car/realistic
	var/list/hardpoints = list()
	var/list/valid_hardpoints = list()
	var/list/default_hardpoints = list(/obj/item/vehicle_hardpoint/engine, /obj/item/vehicle_hardpoint/wheels) //What does it start with, if anything.

/obj/item/vehicle_hardpoint
	name = "generic hardpoint"
	desc = "Yell at kmc"
	icon = 'nsv13/icons/obj/vehicles32.dmi'
	icon_state = "hitch"
	var/obj/vehicle/sealed/car/realistic/owner = null
	var/list/accepted_items = list() //What items do we take? CSV format, typepaths.
	var/list/stored_items = list()
	var/max_capacity = null//Is this a hardpoint that contains anything? EG people, crates? If so, this should not be null.
	var/ammo_count = 0
	var/max_ammo = null

//Method that determines if the hardpoint will accept an interaction with X object, based on its typepath.

/obj/item/vehicle_hardpoint/proc/can_hardpoint_intercept(atom/target, mob/user)
	if(target == user) //You can't, for example, stuff yourself into a cryostasis bed.
		return FALSE
	for(var/HPtype in accepted_items) //Find it in subtypes. Failing that, try find its direct type later on
		var/list/HPsubtypes = subtypesof(HPtype)
		if(LAZYFIND(HPsubtypes, target.type))
			return TRUE
	return LAZYFIND(accepted_items, target.type)

//Method that returns an icon state that should be overlayed onto the vehicle.
//@return an icon_state that should be present in your vehicle's icon file

/obj/item/vehicle_hardpoint/proc/overlay_state() //Override this if you have something like a luggage rack that fills with stuff or something.
	if(max_capacity)
		return "[initial(icon_state)]-[round(((stored_items.len / max_capacity) * 100) /25)]"
	return icon_state

//Method called by the vehicle's UI. This should allow the user to modify parameters for this hardpoint.

/obj/item/vehicle_hardpoint/proc/hardpoint_interact(mob/user)
	if(max_capacity)
		to_chat(user, "<span class='notice'>[src] is currently holding [stored_items.len] / [max_capacity] items.</span>")
		var/atom/movable/selection = null
		selection = input(user, "Remove Items loaded in [src]?", "[name]", selection) as null|anything in stored_items
		if(selection)
			to_chat(user, "<span class='notice'>You dump [selection] out of [src]</span>")
			selection.forceMove(get_turf(owner))
			stored_items -= selection
		return TRUE
	to_chat(user, "<span class='notice'>[desc]</span>")
	return FALSE

//Account for admin-tele or whatever.

/obj/item/vehicle_hardpoint/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if(max_capacity && stored_items)
		if(LAZYFIND(stored_items, AM))
			stored_items -= AM

//Method to handle adding an object to this hardpoint, whatever that means.

/obj/item/vehicle_hardpoint/proc/hardpoint_intercept(atom/movable/target, mob/user)
	update_icon()
	if(max_capacity)
		if(stored_items.len < max_capacity)
			LAZYADD(stored_items, target)
			target.forceMove(src)
			to_chat(user, "<span class='notice'>You load [target] into [src]...</span>")
			update_icon()
			return TRUE
	to_chat(user, "<span class='notice'>Nothing happens...</span>")

/obj/item/vehicle_hardpoint/update_icon()
	owner.update_icon()

//Removal / insertion procs.

/obj/item/vehicle_hardpoint/proc/on_insertion(obj/vehicle/sealed/car/realistic/target)
	owner = target //For whatever reason, if you need to reference the car.
	forceMove(owner)

/obj/item/vehicle_hardpoint/proc/on_removal(obj/vehicle/sealed/car/realistic/target)
	for(var/atom/movable/X in contents)
		X.forceMove(get_turf(owner))
	owner = null
	forceMove(get_turf(target))
	stored_items = list() //Just in case we had anything stored inside that shouldn't really be anymore.
	return


/obj/vehicle/sealed/car/realistic/attack_hand(mob/user)
	if(user.pulling)
		if(hardpoint_intercept(user.pulling, user)) //Allow hardpoints to intercept mousedrops. Used most commonly in the crateloader hardpoint.
			return
	ui_interact(user)

/obj/vehicle/sealed/car/realistic/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/vehicle_hardpoint))
		return apply_hardpoint(I, user)
	if(!hardpoint_intercept(I, user)) //Allow hardpoints to intercept mousedrops. Used most commonly in the crateloader hardpoint.
		. = ..()
	else
		return FALSE

//This determines whether an object needs to be passed over to a hardpoint for handling. If it does, it @returns true.

/obj/vehicle/sealed/car/realistic/proc/hardpoint_intercept(atom/target, mob/user)
	var/list/interceptors = list()
	for(var/type in hardpoints)
		var/obj/item/vehicle_hardpoint/HP = hardpoints[type]
		if(HP && HP.can_hardpoint_intercept(target, user))
			LAZYADD(interceptors, HP)
	var/obj/item/vehicle_hardpoint/HP = null
	if(interceptors.len > 1)
		HP = input(user, "Which hardpoint do you want to load [target] into?", "[name]", HP) as null|anything in interceptors
	else
		HP = (interceptors.len) ? interceptors[1] : null//No need to ask them if there's only one hardpoint that accepts this.
	if(HP)
		HP.hardpoint_intercept(target, user) //Alright, let the hardpoint take it from here.
		return TRUE
	else
		return FALSE
//Method to apply a hardpoint, calls on_insert on the hardpoint that you insert.

/obj/vehicle/sealed/car/realistic/proc/apply_hardpoint(obj/item/vehicle_hardpoint/HP, mob/user)
	if(get_hardpoint_by_type(HP.type)) //Let's make sure to account for subtypes, too.
		to_chat(user, "<span class='warning'>[src]'s slot for [HP] is full!</span>")
		return FALSE
	if(!LAZYFIND(valid_hardpoints, HP.type))
		to_chat(user, "<span class='warning'>You can't seem to find anywhere to put [HP].</span>")
		return FALSE
	to_chat(user, "<span class='warning'>You install [HP].</span>")
	hardpoints[HP.type] = HP
	HP.on_insertion(src)
	update_icon()

//Called by UI. Remove a hardpoint by its name. We have to use name rather than a ref because TGUI doesn't let us handle refs.

/obj/vehicle/sealed/car/realistic/proc/remove_hardpoint(target_name, mob/user)
	var/obj/item/vehicle_hardpoint/HP = get_hardpoint_by_name(target_name)
	if(!HP || !hardpoints[HP.type])
		return FALSE
	to_chat(user, "<span class='warning'>You uninstall [HP].</span>")
	hardpoints[HP.type] = null
	HP.on_removal(src)
	update_icon()

//Called by UI. Lets you interact with a hardpoint. This should a UI on the hardpoint, if necessary.
/obj/vehicle/sealed/car/realistic/proc/interact_with_hardpoint(target_name, mob/user)
	var/obj/item/vehicle_hardpoint/HP = get_hardpoint_by_name(target_name)
	if(!HP || !hardpoints[HP.type])
		return
	HP.hardpoint_interact(user)

/obj/vehicle/sealed/car/realistic/proc/get_hardpoint_by_name(target_name)
	for(var/HPtype in hardpoints)
		var/obj/item/target = hardpoints[HPtype]
		if(target && target.name == target_name)
			return target

//More specific location, accounting for subtypes of hardpoints. Lest we allow a car with two engines.

/obj/vehicle/sealed/car/realistic/proc/get_hardpoint_by_type(target_type)
	for(var/HPtype in hardpoints)
		var/obj/HP = hardpoints[HPtype]
		if(HP)
			var/list/allSubtypes = subtypesof(HP.type)
			if(LAZYFIND(allSubtypes, target_type))
				return TRUE
	return FALSE

/obj/vehicle/sealed/car/realistic/update_icon()
	cut_overlays()
	for(var/HPtype in hardpoints)
		var/obj/item/vehicle_hardpoint/HP = hardpoints[HPtype]
		if(HP)
			add_overlay(HP.overlay_state()) //Make sure to include overlays in your vehicle file for any hardpoints you want to attach!

//Hardpoint UI.
/obj/vehicle/sealed/car/realistic/ui_state(mob/user)
	return GLOB.contained_state

/obj/vehicle/sealed/car/realistic/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CarHardpoints")
		ui.open()

/obj/vehicle/sealed/car/realistic/ui_data(mob/user)
	var/list/data = list()
	data["hardpoints"] = list()
	for(var/HPtype in hardpoints)
		var/obj/item/vehicle_hardpoint/HP = hardpoints[HPtype]
		if(!HP)
			continue
		if(HP.max_capacity) //If it's a hardpoint that holds things, we'd best show its capacity as a UI bar. Else, just show its name or whatever.
			data["hardpoints"] += list(list("name" = HP.name, "capacity" = (HP.stored_items) ? HP.stored_items.len : 0, "max_capacity" = HP.max_capacity))
			continue
		if(HP.max_ammo) //If it's a hardpoint that uses ammo, let's show its ammo.
			data["hardpoints"] += list(list("name" = HP.name, "capacity" = HP.ammo_count, "max_capacity" = HP.max_ammo))
			continue
		//Otherwise. Let's just show its name and condition I guess.
		data["hardpoints"] += list(list("name" = HP.name, "capacity" = HP.obj_integrity, "max_capacity" = HP.max_integrity))
	data["contents"] = list()
	for(var/atom/movable/AM in contents)
		if(LAZYFIND(hardpoints, AM.type))
			var/obj/item/vehicle_hardpoint/HP = hardpoints[AM.type]
			for(var/atom/movable/stored in HP.contents)
				data["contents"] += list(list("name" = stored.name))
			continue //We already know about hardpoints. But we want to know what's in them.
		if(AM)
			data["contents"] += list(list("name" = AM.name))
	return data

/obj/vehicle/sealed/car/realistic/ui_act(action, params, datum/tgui/ui)
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
		if("remove_hardpoint")
			remove_hardpoint(target_name, ui.user)
		if("interact")
			interact_with_hardpoint(target_name, ui.user)


//Specific subtypes.

/obj/item/vehicle_hardpoint/crate_loader
	name = "C4RG-GNG Crate loader"
	desc = "A hardpoint allowing you to load crates into a vehicle, "
	icon_state = "crate_storage"
	max_capacity = 10 //Lots of crates!
	accepted_items = list(/obj/structure/closet/crate, /obj/item/storage) //What items do we take? CSV format, typepaths.

//Upgradable engines! Makes the car go faster.

/obj/item/vehicle_hardpoint/engine
	name = "V2 Engine"
	desc = "A very slow, but highly efficient micro generator, capable of affording a vehicle basic propulsion. It's not particularly flashy, but it gets the job done."
	icon_state = "engine"
	var/torque = 2
	var/topspeed = 7

/obj/item/vehicle_hardpoint/engine/pathetic
	name = "Speed Limited Engine"
	desc = "A very slow, but highly efficient micro generator, capable of affording a vehicle basic propulsion. It has had a speed limiter installed to prevent workplace accidents in the hangar bay."
	icon_state = "engine"
	torque = 1
	topspeed = 3

/obj/item/vehicle_hardpoint/engine/upgraded
	name = "V4 Turbocharged Engine"
	desc = "A powerful engine with high torque and a turbocharger, capable of affording a vehicle some considerable speed."
	icon_state = "engine_v4"
	torque = 4
	topspeed = 10

/obj/item/vehicle_hardpoint/engine/maxupgrade
	name = "V8 Turbocharged Engine"
	desc = "An extremely powerful, prototype engine, including a dump valve, turbocharger, phase of the moon sensor and electrostatic conversion matrix. This engine can make a car go EXTREMELY quickly, but may make the vehicle hard to control without sufficiently good tyres!."
	icon_state = "engine_v8"
	torque = 10
	topspeed = 70 //Don't make me regret this

/obj/item/vehicle_hardpoint/engine/on_insertion(obj/vehicle/sealed/car/realistic/target)
	. = ..()
	owner.canmove = TRUE
	owner.speed_limit = topspeed
	owner.max_acceleration = torque

/obj/item/vehicle_hardpoint/engine/on_removal(obj/vehicle/sealed/car/realistic/target)
	. = ..()
	target.speed_limit = 0
	target.max_acceleration = 0
	target.canmove = FALSE

/obj/item/vehicle_hardpoint/wheels
	name = "Basic Tyres"
	desc = "Some old, worn out tyres that aren't very effective. They'll keep you heading in a straight line, but don't ask too much more of them. These Tyres will skid a lot, especially at high speeds. Be careful with the accelerator."
	icon_state = "wheels"
	var/turnspeed = 40
	var/static_traction = 3 //How good are the tyres?. THis behaves somewhat like acceleration, but it shouldnt be more efficient than 9.8, which is the gravity on earth
	var/kinetic_traction = 1.5 //if you are moving sideways and the static traction wasnt enough to kill it, you skid and you will have less traction, but allowing you to drift. KINETIC IE moving traction

/obj/item/vehicle_hardpoint/wheels/heavy
	name = "Heavy Duty Tyres"
	desc = "A set of industrial tyres, with a wide tread designed to hold heavy weights. They'll keep you glued to the deck quite nicely, but may turn sluggishly. These are not designed for high speeds, and will cause you to skid a lot if you go too quickly."
	icon_state = "wheels_upgrade"
	turnspeed = 40
	static_traction = 9.8 //How good are the tyres?. THis behaves somewhat like acceleration, but it shouldnt be more efficient than 9.8, which is the gravity on earth
	kinetic_traction = 5 //if you are moving sideways and the static traction wasnt enough to kill it, you skid and you will have less traction, but allowing you to drift. KINETIC IE moving traction

/obj/item/vehicle_hardpoint/wheels/sports
	name = "Sports Tyres"
	desc = "A set of highly advanced, finely balanced sports tyres. These have solid traction, but are still somewhat loose, making the steering feel lighter and allowing you to drift the car more easily. These Tyres are tuned for racing, and will tolerate extremely high speeds."
	icon_state = "wheels_maxupgrade"
	turnspeed = 70
	static_traction = 5.5 //How good are the tyres?. THis behaves somewhat like acceleration, but it shouldnt be more efficient than 9.8, which is the gravity on earth
	kinetic_traction = 4 //if you are moving sideways and the static traction wasnt enough to kill it, you skid and you will have less traction, but allowing you to drift. KINETIC IE moving traction

/obj/item/vehicle_hardpoint/wheels/on_insertion(obj/vehicle/sealed/car/realistic/target)
	. = ..()
	owner.max_turnspeed = turnspeed
	owner.kinetic_traction = kinetic_traction
	owner.static_traction = static_traction

/obj/item/vehicle_hardpoint/wheels/on_removal(obj/vehicle/sealed/car/realistic/target)
	. = ..()
	target.max_turnspeed = 0
	target.kinetic_traction = 0
	target.static_traction = 0

/obj/item/vehicle_hardpoint/cryo_stasis
	name = "MGS4 Cryo Stasis Unit"
	desc = "An advanced, vehicle mounted cryo-stasis unit used to stabilise a patient."
	icon_state = "cryostasis"
	max_capacity = 1
	accepted_items = list(/mob/living) //Yes, i'm objectifying people. Upset?

/obj/item/vehicle_hardpoint/cryo_stasis/overlay_state()
	return (stored_items && stored_items.len) ? "[initial(icon_state)]-full" : initial(icon_state)

/obj/item/vehicle_hardpoint/cryo_stasis/hardpoint_intercept(mob/living/target, mob/user)
	update_icon()
	if(max_capacity)
		if(stored_items.len < max_capacity)
			LAZYADD(stored_items, target)
			target.forceMove(src)
			to_chat(user, "<span class='notice'>You load [target] into [src]...</span>")
			target.SetStasis(TRUE)
			target.ExtinguishMob()
			update_icon()
			return TRUE
	to_chat(user, "<span class='notice'>Nothing happens...</span>")
	return

/obj/item/vehicle_hardpoint/cryo_stasis/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if(isliving(AM))
		var/mob/living/M = AM
		M.SetStasis(FALSE)

//Research stuff
/datum/design/vehicle_crate_loader
	name = "Vehicle crate loading rack"
	desc = "A module which allows you to store crates and other small storage objects inside of cargo tugs."
	id = "vehicle_crate_loader"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000)
	build_path = /obj/item/vehicle_hardpoint/crate_loader
	category = list("Vehicles")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/vehicle_cryo_stasis
	name = "Vehicle cryo stasis module"
	desc = "A module which allows you to cryogenically suspend people inside of large vehicles, awaiting treatment by medical professionals."
	id = "vehicle_cryo_stasis"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 10000)
	build_path = /obj/item/vehicle_hardpoint/cryo_stasis
	category = list("Vehicles")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/pathetic_engine
	name = "Speed-Limited 'Safety' Engine"
	desc = "A basic engine for large vehicles. Comes pre-installed with a speed limiter to prevent high-speed automotive accidents or illicit races on the flight deck."
	id = "vehicle_engine_pathetic"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000)
	build_path = /obj/item/vehicle_hardpoint/engine/pathetic
	category = list("Vehicles")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/v2_engine
	name = "Basic engine"
	desc = "A basic engine for large vehicles."
	id = "vehicle_engine"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000)
	build_path = /obj/item/vehicle_hardpoint/engine
	category = list("Vehicles")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/v4_engine
	name = "Upgraded engine"
	desc = "A powerful engine for large vehicles."
	id = "vehicle_engine_upgraded"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/silver = 10000, /datum/material/copper=5000)
	build_path = /obj/item/vehicle_hardpoint/engine/upgraded
	category = list("Vehicles")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/v8_engine
	name = "V8 engine"
	desc = "An experimental, extremely powerful engine for large vehicles."
	id = "vehicle_engine_maxupgrade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/silver = 10000, /datum/material/copper=5000, /datum/material/diamond=10000)
	build_path = /obj/item/vehicle_hardpoint/engine/maxupgrade
	category = list("Vehicles")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/v1_wheels
	name = "Basic Tyres"
	desc = "Basic wheels for large vehicles."
	id = "vehicle_tyres"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000)
	build_path = /obj/item/vehicle_hardpoint/wheels
	category = list("Vehicles")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/v4_wheels
	name = "Heavy Duty Tyres"
	desc = "Heavy duty Tyres for large vehicles."
	id = "vehicle_tyres_upgraded"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/silver = 10000, /datum/material/copper=5000)
	build_path = /obj/item/vehicle_hardpoint/wheels/heavy
	category = list("Vehicles")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/v8_wheels
	name = "Sports Tyres"
	desc = "An experimental, extremely powerful engine for large vehicles."
	id = "vehicle_tyres_maxupgrade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/silver=10000, /datum/material/diamond=5000)
	build_path = /obj/item/vehicle_hardpoint/wheels/sports
	category = list("Vehicles")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE
