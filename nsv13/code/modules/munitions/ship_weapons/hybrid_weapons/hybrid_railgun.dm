//Highly Expensive to replace and maintain, hence limited to round start
//Use both power and physical projectiles
//Fires both Railgun Slugs and NAC Shells

/obj/machinery/ship_weapon/hybrid_rail
	name = "Hybrid Railgun"
	desc = "^"
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "OBC"
	bound_width = 128
	bound_height = 64
	pixel_y = -64
	fire_mode = FIRE_MODE_HYBRID_RAIL //temp - need its own firemode
	ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo //starting in railgun mode
	max_ammo = 5 //railgun mode
	semi_auto = TRUE

	var/slug_shell = 0 //Use Slugs = 0. Use Shells = 1
	var/switching = 0 //Track if we are switching types

	var/alignment = 100 //Degrading stat used to alter projectile spread

	maintainable = TRUE //override this with hybrid version

	active_power_usage = 0 //Going to pull from a wire rather then APC
	idle_power_usage = 50 //we'll scale this with charge - if its charged, its gonna be leaking

	var/capacitor_charge = 0 //Current capacitor charge
	var/capacitor_max_charge = 0 //Maximum charge required for firing - as determined by ammo type
	var/capacitor_current_charge_rate = 0 //Current charge rate - as determined by players
	var/capacitor_max_charge_rate = 200000 //Maximum rate of charge ie max power draw - 200kW
	var/available_power = 0 //Check the power net


/obj/machinery/ship_weapon/hybrid_rail/process()
	if(capacitor_charge >= capacitor_max_charge)
		capacitor_charge = capacitor_max_charge
		idle_power_usage = capacitor_charge / 10 //We still draw to maintain charge
		return
	if(!try_use_power(active_power_usage))
		if(capacitor_charge > 0)
			capacitor_charge -= (capacitor_charge / capacitor_max_charge)
			if(capacitor_charge <= 0)
				capacitor_charge = 0
		idle_power_usage = 0
		return

	capacitor_charge += capacitor_current_charge_rate

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
	if(slug_shell == 0)	//change to using Shells
		slug_shell = 1
		ammo_type = /obj/item/ship_weapon/ammunition/naval_artillery
		max_ammo = 1
		capacitor_max_charge = 1000000 //1MW
		say("Cycling complete: Configuration - ???mm Shell Selected")

	if(slug_shell == 1)	//change to using Slugs
		slug_shell = 0
		ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo
		max_ammo = 5
		capacitor_max_charge = 400000 //400kW
		say("Cycling complete: Configuration - 400mm Slug Selected")

/obj/machinery/ship_weapon/hybrid_rail/fire(atom/target,manual = TRUE)
	set waitfor = FALSE //As to not hold up any feedback messages.
	if(can_fire())
		if(manual)
			linked.last_fired = overlay
		do_animation()
		state = 5 //STATE_FIRING
		local_fire()
		overmap_fire(target)
		ammo -= chambered
		qdel(chambered)
		chambered = null
		capacitor_charge = 0
		if(ammo?.len)
			state = 3 //STATE_FED
			chamber(rapidfire = TRUE)
		else
			state = 1 //STATE_NOTLOADED
		after_fire()
	return FALSE

/obj/machinery/ship_weapon/hybrid_rail/can_fire()
	if((state < 4) || !chambered) //STATE_CHAMBERED
		return FALSE
	if(state >= 5) //STATE_FIRING
		return FALSE
	if(maintainable && malfunction) //Do we need maintenance?
		return FALSE
	if(ammo?.len) //Do we have ammo?
		return FALSE
	if(capacitor_charge < capacitor_max_charge) //Is the capacitor charged?
		return FALSE
	else
		return TRUE

/obj/machinery/ship_weapon/hybrid_rail/animate_projectile(atom/target)
	var/obj/item/projectile/P = linked.fire_lateral_projectile(weapon_type.default_projectile_type, target)
	P.spread = (100 - alignment) / 20 //Gotta keep them coils aligned

/obj/machinery/ship_weapon/hybrid_rail/after_fire()
	if(maint_state != 0) //MSTATE_CLOSED
		say("Electricity arcs from the exposed firing mechanism")
		tesla_zap(1000) //Munitions Officer definitely had the best uniform
		for(var/mob/living/carbon/C in orange(4, src))
			C.flash_act()

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

/*
/datum/surgery_step/heal/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	if(..())
		while((brutehealing && target.getBruteLoss()) || (burnhealing && target.getFireLoss()))
			if(!..())
				break
*/

/obj/machinery/computer/ship/munitions_computer/hybrid_rail
	name = "munitions control computer"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "munitions_console"
	density = TRUE
	anchored = TRUE
	req_access = list(ACCESS_MUNITIONS)
	circuit = /obj/item/circuitboard/computer/ship/munitions_computer
	var/obj/machinery/ship_weapon/SW //The one we're firing

/obj/machinery/computer/ship/munitions_computer/hybrid_rail/get_linked_weapon()
	if(!SW)
		var/opposite_dir = turn(dir, 180)
		var/atom/adjacent = locate(/obj/machinery/ship_weapon) in get_turf(get_step(src, opposite_dir)) //Look at what dir we're facing, find a gun in that turf
		if(adjacent && istype(adjacent, /obj/machinery/ship_weapon/hybrid_rail))
			SW = adjacent
			SW.linked_computer = src
			if(!SW.linked)
				SW.get_ship()

/obj/machinery/computer/ship/munitions_computer/hybrid_rail/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "HybridWeapon", name, 600, 350, master_ui, state)
		ui.open()

/obj/machinery/computer/ship/munitions_computer/hybrid_rail/ui_act(action, params)
	if(..())
		return
	var/value = text2num(params["input"])
	var/obj/item/multitool/tool = get_multitool(ui.user)
	playsound(src.loc,'nsv13/sound/effects/fighters/switch.ogg', 50, FALSE)
	switch(action)
		if("toggle_load")
			if(SW.state == STATE_LOADED)
				SW.feed()
			else
				SW.unload()
		if("chamber")
			SW.chamber()
		if("toggle_safety")
			SW.toggle_safety()
		//Sudo mode.
		if("fflush") //Flush multitool buffer. fflush that buffer
			if(!tool)
				return
			tool.buffer = null
		if("unlink")
			SW = null
		if("link")
			if(!tool)
				return
			var/obj/machinery/ship_weapon/hybrid_rail/T = tool.buffer
			if(T && istype(T))
				SW = T
		if("search")
			get_linked_weapon()
		if("switch_type")
			if(switching)
				to_chat(usr, "<span class='notice'>Error: Unable to comply, action already in process.</span>")
				return
			if(ammo.len == 0)
				to_chat(usr, "<span class='notice'>Action queued: Cycling ordnance chamber configuration.</span>")
				switching = TRUE
				addtimer(CALLBACK(src, .proc/switch_munition, 10 SECONDS))
			else
				to_chat(usr, "<span class='notice'>Error: Unable to alter selected ordnance type, eject loaded munitions.</span>")
	return

/obj/machinery/computer/ship/munitions_computer/hybrid_rail/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	var/obj/item/multitool/tool = get_multitool(user)
	data["capacitor_charge"] = capacitor_charge
	data["capacitor_max_charge"] = capacitor_max_charge
	data["capacitor_current_charge_rate"] = capacitor_current_charge_rate
	data["capacitor_max_charge_rate"] = capacitor_max_charge_rate
	data["available_power"] = available_power
	data["slug_shell"] = slug_shell
	data["max_ammo"] = max_ammo
	data["sudo_mode"] = (tool != null || SW == null) ? TRUE : FALSE //Hold a multitool to enter sudo mode and modify linkages.
	data["tool_buffer"] = (tool && tool.buffer != null) ? TRUE : FALSE
	data["tool_buffer_name"] = (tool && tool.buffer) ? tool.buffer.name : "/dev/null"
	data["has_linked_gun"] =  (SW) ? TRUE : FALSE
	data["linked_gun"] =  (SW && SW.name) ? SW.name : "NO WEAPON LINKED"
	data["loaded"] = (SW && SW.state > STATE_LOADED) ? TRUE : FALSE
	data["chambered"] = (SW && SW.state > STATE_FED) ? TRUE : FALSE
	data["safety"] = (SW) ? SW.safety : FALSE
	data["ammo"] = (SW) ? SW.ammo.len : 0
	data["max_ammo"] = (SW) ? SW.max_ammo : 0
	data["maint_req"] = (SW && SW.maintainable) ? SW.maint_req : 25
	data["max_maint_req"] = (SW) ? 25 : 0
	return data
