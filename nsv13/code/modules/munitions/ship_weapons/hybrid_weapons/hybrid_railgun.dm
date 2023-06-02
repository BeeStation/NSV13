//Highly Expensive to replace and maintain, hence limited to round start
//Use both power and physical projectiles
//Fires both Railgun Slugs and NAC Shells

/obj/machinery/ship_weapon/hybrid_rail
	name = "NT-ST049 'Sturm' coaxial railgun"
	desc = "Due to insufficient firepower, attempts were made at upgrading the NT-STC4 model railgun, providing an increased muzzle velocity, wider coverage arc and the ability to fire larger munitions. However the design proved ineffective long term due to extensive maintance costs and reliability issues compared with new advances in kinetically propelled munitions."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "OBC"
	max_integrity = 400 //Want these to last as you can't replace them
	bound_width = 128
	bound_height = 64
	pixel_y = -64
	fire_mode = FIRE_MODE_HYBRID_RAIL
	ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo //preset to slug
	max_ammo = 5 //preset to slug
	semi_auto = TRUE

	var/slug_shell = 0 //Use Slugs = 0. Use Shells = 1
	var/switching = 0 //Track if we are switching types

	var/alignment = 100 //Degrading stat used to alter projectile spread

	maintainable = TRUE //override this with hybrid version

	active_power_usage = 0 //Going to pull from a wire rather then APC
	idle_power_usage = 50 //we'll scale this with charge - if its charged, its gonna be leaking

	var/capacitor_charge = 0 //Current capacitor charge
	var/capacitor_max_charge = 400000 //Maximum charge required for firing - as determined by ammo type - preset to slug
	var/capacitor_current_charge_rate = 0 //Current charge rate - as determined by players
	var/capacitor_max_charge_rate = 200000 //Maximum rate of charge ie max power draw - 200kW

	var/projectile_velo = 5 //For our projectile - preset to slug

/obj/machinery/ship_weapon/hybrid_rail/examine(mob/user)
	.=..()
	if(slug_shell == 0)
		. += "<span class='notice'>Selected Munition: Slug type</span>"
	if(slug_shell == 1)
		. += "<span class='notice'>Selected Munition: Shell type</span>"

/obj/machinery/ship_weapon/hybrid_rail/process()
	if(capacitor_charge == capacitor_max_charge)
		active_power_usage = capacitor_charge / 10 //We still draw to maintain charge
	if(!try_use_power(active_power_usage))
		if(capacitor_charge > 0)
			capacitor_charge -= (capacitor_charge / capacitor_max_charge) * 500 //Slowly depletes capacitor if not maintaining power supply
			set_light(3, 4, LIGHT_COLOR_RED)
			if(capacitor_charge <= 0)
				capacitor_charge = 0
		return FALSE
	if(capacitor_current_charge_rate == 0)
		set_light(3, 4, LIGHT_COLOR_RED)
		return FALSE
	if(capacitor_charge < capacitor_max_charge)
		capacitor_charge += capacitor_current_charge_rate
		set_light(3, 4, LIGHT_COLOR_LIGHT_CYAN)
	if(capacitor_charge >= capacitor_max_charge)
		capacitor_charge = capacitor_max_charge
		set_light(3, 4, LIGHT_COLOR_LIGHT_CYAN)


/obj/machinery/ship_weapon/hybrid_rail/proc/try_use_power(amount) //Pulling power from wires rather then APCs
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(!C.powernet)
			return FALSE
		var/power_in_net = C.powernet.avail-C.powernet.load

		if(power_in_net && power_in_net >= amount)
			C.powernet.load += amount
			return TRUE
		return FALSE
	return FALSE

/obj/machinery/ship_weapon/hybrid_rail/proc/switch_munition()
	switching = FALSE
	capacitor_charge = 0 //Reset
	if(slug_shell == 0)	//change to using Shells
		slug_shell = 1
		ammo_type = /obj/item/ship_weapon/ammunition/naval_artillery
		max_ammo = 1
		projectile_velo = 2.5 //Not so great at handling shells
		capacitor_max_charge = 1000000 //1MW
		say("Cycling complete: Configuration - 800mm Shell Selected")

	else if(slug_shell == 1)	//change to using Slugs
		slug_shell = 0
		ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo
		max_ammo = 5
		projectile_velo = 5 //Designed for slugs
		capacitor_max_charge = 400000 //400kW
		say("Cycling complete: Configuration - 400mm Slug Selected")

/obj/machinery/ship_weapon/hybrid_rail/fire(atom/target, shots = weapon_type.burst_size, manual = TRUE)
	set waitfor = FALSE //As to not hold up any feedback messages.
	if(can_fire(target, shots))
		if(manual)
			linked.last_fired = overlay
		for(var/i = 0, i < shots, i++)
			do_animation()
			state = STATE_FIRING
			local_fire()
			overmap_fire(target)
			ammo -= chambered
			qdel(chambered)
			chambered = null
			capacitor_charge = 0
			if(ammo?.len)
				state = STATE_FED
				chamber(rapidfire = TRUE)
			else
				state = STATE_NOTLOADED
			after_fire()
	return FALSE

/obj/machinery/ship_weapon/hybrid_rail/can_fire(shots = weapon_type.burst_size)
	if((state < STATE_CHAMBERED) || !chambered)
		return FALSE
	if(state >= STATE_FIRING)
		return FALSE
	if(maintainable && malfunction) //Do we need maintenance?
		return FALSE
	if(ammo?.len < shots) //Do we have ammo?
		return FALSE
	if(capacitor_charge < capacitor_max_charge) //Is the capacitor charged?
		return FALSE
	if(alignment < 25)
		if(prob(25))
			misfire()
			return FALSE
	else
		return TRUE

/obj/machinery/ship_weapon/hybrid_rail/animate_projectile(atom/target)
	var/obj/item/ship_weapon/ammunition/T = chambered
	if(T)
		var/final_velo = projectile_velo - ((100 - alignment) / 100) //Misalignment slows projectiles
		linked.fire_projectile(T.projectile_type, target, FALSE, final_velo, null, TRUE)

/obj/machinery/ship_weapon/hybrid_rail/after_fire()
	if(maint_state != 0) //MSTATE_CLOSED
		tesla_zap(src, 4, 1000) //Munitions Officer definitely had the best uniform
		for(var/mob/living/carbon/C in orange(4, src))
			C.flash_act()
		for(var/mob/living/carbon/C in orange(12, src))
			to_chat(C, "<span class='danger'>Electricity arcs from the exposed firing mechanism.</span>")

	if(alignment <= 75)
		if(prob(50))
			do_sparks(4, FALSE, src)

	if(slug_shell)
		alignment -= rand(0, 8)
		if(alignment < 0)
			alignment = 0
	if(!slug_shell)
		alignment -= rand(0, 2)
		if(alignment < 0)
			alignment = 0
		if(!ammo.len)
			say("Autoloader has depleted all ammunition sources. Reload required.")
			return
	..()

/obj/machinery/ship_weapon/hybrid_rail/proc/misfire()
	maint_req -= 5
	if(maint_req < 0)
		maint_req = 0

	capacitor_charge = 0
	capacitor_current_charge_rate = 0
	say("Error in coil charging, dumping capacitor")
	for(var/mob/living/M in orange(1, src))
		if(iscarbon(M))
			if(ishuman(M))
				M.electrocute_act(20, "[name]", safety=1)
				return
			M.electrocute_act(20, "[name]")
			return
		else
			M.adjustFireLoss(20)
			M.visible_message("<span class='danger'>[M] was shocked by \the [name]!</span>", \
		"<span class='userdanger'>You feel a powerful shock coursing through your body!</span>", \
		"<span class='italics'>You hear a heavy electrical crack.</span>")

/obj/machinery/ship_weapon/hybrid_rail/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(maint_state < 2)
		to_chat(user, "<span class='notice'>You must first open the maintenance panel before realigning the magnetic coils.</span>")
	else
		to_chat(user, "<span class='notice'>You being realigning the magnetic coils.</span>")
		while(alignment < 100)
			if(!do_after(user, 5, target = src))
				return
			alignment += rand(1,2)
			if(alignment >= 100)
				alignment = 100
				break

/obj/machinery/ship_weapon/hybrid_rail/crowbar_act(mob/user, obj/item/tool)
	return //prevent deconstructing

/obj/machinery/ship_weapon/hybrid_rail/attackby(obj/item/I, mob/user)
	if(!linked)
		get_ship()
	if(switching && istype(I, /obj/item/ship_weapon/ammunition))
		to_chat(usr, "<span class='notice'>Error: Unable to load ordnance while cycling chamber configuration.</span>")
		return FALSE
	if(islist(ammo_type))
		for(var/at in ammo_type)
			if(istype(I, at))
				load(I, user)
				return TRUE

	if(ammo_type && istype(I, ammo_type))
		load(I, user)
		return TRUE
	else if(magazine_type && istype(I, magazine_type))
		load_magazine(I, user)
		return TRUE
	else if(istype(I, /obj/item/reagent_containers))
		oil(I, user)
		return TRUE
	return ..()

/obj/machinery/ship_weapon/hybrid_rail/attack_hand(mob/living/carbon/user)
	ui_interact(user)

/obj/machinery/ship_weapon/hybrid_rail/attack_ai(mob/user)
	.=..()
	ui_interact(user)

/obj/machinery/ship_weapon/hybrid_rail/attack_robot(mob/user)
	.=..()
	ui_interact(user)

/obj/machinery/ship_weapon/hybrid_rail/attack_ghost(mob/user)
	.=..()
	ui_interact(user)

/obj/machinery/ship_weapon/hybrid_rail/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HybridWeapons")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/ship_weapon/hybrid_rail/ui_act(action, params)
	if(..())
		return
	var/adjust = text2num(params["adjust"])
	switch(action)
		if("capacitor_current_charge_rate")
			capacitor_current_charge_rate = adjust
			active_power_usage = adjust
		if("toggle_load")
			if(state == STATE_LOADED)
				feed()
			else
				unload()
		if("chamber")
			chamber()
		if("toggle_safety")
			toggle_safety()
		if("switch_type")
			if(switching)
				to_chat(usr, "<span class='notice'>Error: Unable to comply, action already in process.</span>")
				return
			if(state == STATE_NOTLOADED && !loading)
				to_chat(usr, "<span class='notice'>Action queued: Cycling ordnance chamber configuration.</span>")
				switching = TRUE
				playsound(src, 'nsv13/sound/effects/ship/mac_hold.ogg', 100)
				addtimer(CALLBACK(src, PROC_REF(switch_munition)), 10 SECONDS)
			else
				to_chat(usr, "<span class='notice'>Error: Unable to alter selected ordnance type, eject loaded munitions.</span>")
	return

/obj/machinery/ship_weapon/hybrid_rail/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["loaded"] = (state > STATE_LOADED) ? TRUE : FALSE
	data["chambered"] = (state > STATE_FED) ? TRUE : FALSE
	data["safety"] = safety
	data["ammo"] = ammo.len
	data["max_ammo"] = max_ammo
	data["maint_req"] = maint_req
	data["max_maint_req"] = 25
	data["capacitor_charge"] = capacitor_charge
	data["capacitor_max_charge"] = capacitor_max_charge
	data["capacitor_current_charge_rate"] = capacitor_current_charge_rate
	data["capacitor_max_charge_rate"] = capacitor_max_charge_rate
	data["slug_shell"] = slug_shell
	data["alignment"] = alignment
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(C.powernet)
			data["available_power"] = C.powernet.avail-C.powernet.load
	return data

//Unsecured tech Disk
/obj/item/disk/design_disk/hybrid_rail_slugs
	name = "Defunct Railgun Techology Munitions Technology Disk"
	desc = "This disk is marked: Filed for relocation to nearest sigularity engine."
	icon_state = "datadisk2"
	max_blueprints = 2

/obj/item/disk/design_disk/hybrid_rail_slugs/Initialize(mapload)
	. = ..()
	var/datum/design/slug_cold_iron/A = new
	var/datum/design/slug_uranium/B = new
	blueprints[1] = A
	blueprints[2] = B
