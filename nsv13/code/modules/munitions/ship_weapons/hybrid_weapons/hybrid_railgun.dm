//Highly Expensive to replace and maintain, limited to Shrike for the sake of actually having unique ship characteristics
//Use both power and physical projectiles
//Fires both Railgun Slugs and Railgun Canisters

/obj/machinery/ship_weapon/hybrid_rail
	name = "NT-ST049 'Sturm' coaxial railgun"
	desc = "Due to insufficient firepower, attempts were made at upgrading the NT-STC4 model railgun, providing an increased muzzle velocity, wider coverage arc and the ability to fire larger munitions. However the design proved ineffective long term due to extensive maintance costs and reliability issues compared with new advances in kinetically propelled munitions."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "OBC"
	max_integrity = 400 //Want these to last as you can't replace them
	bound_width = 128
	bound_height = 64
	pixel_y = -64
	ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo/forged //preset to slug
	max_ammo = 5 //preset to slug
	semi_auto = TRUE
	weapon_datum_type = /datum/overmap_ship_weapon/hybrid_railgun

	var/slug_shell = 0 //Use Slugs = 0. Use Canisters = 1
	var/switching = 0 //Track if we are switching types
	var/alignment = 100 //Degrading stat used to alter projectile spread
	maintainable = TRUE //override this with hybrid version
	active_power_usage = 0 //Going to pull from a wire rather then APC
	idle_power_usage = 50 //we'll scale this with charge - if its charged, its gonna be leaking

	var/capacitor_charge = 0 //Current capacitor charge
	var/capacitor_max_charge = 400000 //Maximum charge required for firing - as determined by ammo type - preset to slug
	var/capacitor_current_charge_rate = 0 //Current charge rate - as determined by players
	var/capacitor_max_charge_rate = 200000 //Maximum rate of charge ie max power draw - 200kW
	var/functional_crit = FALSE
	var/repairing = FALSE //Is someone already repairing this?
	var/deletion_protection = TRUE //Used to prevent object disappearing when taking damage

/obj/machinery/ship_weapon/hybrid_rail/examine(mob/user)
	.=..()
	if(functional_crit)
		. += "<span class='danger'>The railgun is in a critical state and requires repairing to function!</span>"
		. += "<span class='notice'>Repair Status: [obj_integrity] / [max_integrity]</span>"
	if(slug_shell == 0)
		. += "<span class='notice'>Selected Munition: Slug type</span>"
	if(slug_shell == 1)
		. += "<span class='notice'>Selected Munition: Canister type</span>"

/obj/machinery/ship_weapon/hybrid_rail/process()
	if(!functional_crit)
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
	if(slug_shell == 0)	//change to using Canisters
		slug_shell = 1
		ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo_canister
		max_ammo = 1
		capacitor_max_charge = 1000000 //1MW
		say("Cycling complete: Configuration - 800mm Shell Selected")

	else if(slug_shell == 1)	//change to using Slugs
		slug_shell = 0
		ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo
		max_ammo = 5
		capacitor_max_charge = 400000 //400kW
		say("Cycling complete: Configuration - 400mm Slug Selected")

/obj/machinery/ship_weapon/hybrid_rail/fire(atom/target, shots = linked_overmap_ship_weapon.burst_size, manual = TRUE)
	if(functional_crit)
		return FALSE
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
			. = TRUE
		return TRUE //I don't know why it didn't return true if successful but I assume someone just forgot.
	return FALSE

/obj/machinery/ship_weapon/hybrid_rail/can_fire(atom/target, shots = linked_overmap_ship_weapon.burst_size) //Target is for the passed target variable, Shots is for the burst fire size
	if((state < STATE_CHAMBERED) || !chambered)
		return FALSE
	if(state >= STATE_FIRING)
		return FALSE
	if(maintainable && malfunction) //Do we need maintenance?
		return FALSE
	if(get_ammo() < shots)
		return FALSE
	if(capacitor_charge < capacitor_max_charge) //Is the capacitor charged?
		return FALSE
	if(istype(chambered, /obj/item/ship_weapon/ammunition/railgun_ammo/forged))
		var/obj/item/ship_weapon/ammunition/railgun_ammo/forged/F = chambered
		if(F.railgun_flags & RAIL_BLUESPACE)
			alignment -= rand(1, 10) //Additional misalignment due space magic
			if(prob(33))
				bluespace(target)
				return FALSE
	if(istype(chambered, /obj/item/ship_weapon/ammunition/railgun_ammo_canister))
		var/obj/item/ship_weapon/ammunition/railgun_ammo_canister/R = chambered
		if(R.railgun_flags & RAIL_BLUESPACE)
			alignment -= rand(1, 10) //Additional misalignment due space magic
			if(prob(33))
				bluespace(target)
				return FALSE
	if(alignment < 25)
		if(prob(25))
			misfire()
			return FALSE
	else
		return TRUE

/obj/machinery/ship_weapon/hybrid_rail/animate_projectile(atom/target)
	var/projectile_velocity = 0 //Velocity inherited from the material properties of the munition
	var/projectile_damage = 0 //Damage inherited from the material properties of the munition
	var/projectile_penetration = 0//Armour Penetration inherited from the material properties of the munition
	var/projectile_burn = 0 //Burn damage inherited from material and gas properties
	var/projectile_emp = 0 //EMP intensity inherited from material and gas properties
	var/projectile_flag = "overmap_heavy" //Inherited from material properties

	var/obj/item/ship_weapon/ammunition/C = chambered
	if(C)
		if(istype(C, /obj/item/ship_weapon/ammunition/railgun_ammo/forged))
			var/obj/item/ship_weapon/ammunition/railgun_ammo/forged/T = C
			projectile_velocity = (T.material_conductivity * 1.5) - ((100 - alignment) / 100) //ignoring the actual mass of the projectile here
			if(projectile_velocity < 0)
				projectile_velocity = 0.1
			projectile_damage = T.material_density * projectile_velocity
			if(projectile_damage < 0)
				projectile_damage = 0
			if(T.railgun_flags & RAIL_BANANA)
				projectile_flag = "overmap_light"
			else
				switch(T.material_hardness) //Linear projection of the Mohs scale, assuming hulls are made of fairly soft materials
					if(0 to 5)
						projectile_penetration = 0
					if(5 to 6)
						projectile_penetration = 5
					if(6 to 7)
						projectile_penetration = 10
					if(7 to 8)
						projectile_penetration = 15
					if(8 to 9)
						projectile_penetration = 20
					if(9 to 10)
						projectile_penetration = 25
			if(T.railgun_flags & RAIL_BURN)
				projectile_burn = 20
		if(istype(C, /obj/item/ship_weapon/ammunition/railgun_ammo_canister))
			var/obj/item/ship_weapon/ammunition/railgun_ammo_canister/T = C
			projectile_velocity = (T.material_conductivity * 1.5) - ((100 - alignment) / 100)
			if(projectile_velocity < 0)
				projectile_velocity = 0.1
			if(T.railgun_flags & RAIL_BANANA)
				projectile_flag = "overmap_light"
			else
				switch(T.material_hardness)
					if(0 to 5)
						projectile_penetration = 0
					if(5 to 6)
						projectile_penetration = 5
					if(6 to 7)
						projectile_penetration = 10
					if(7 to 8)
						projectile_penetration = 15
					if(8 to 9)
						projectile_penetration = 20
					if(9 to 10)
						projectile_penetration = 25
			var/gas_mix = 	T.canister_gas.get_moles(GAS_O2) + \
							T.canister_gas.get_moles(GAS_PLUOXIUM) * 1.25 + \
							T.canister_gas.get_moles(GAS_PLASMA) * 1.75 + \
							T.canister_gas.get_moles(GAS_CONSTRICTED_PLASMA) * 1.75 + \
							T.canister_gas.get_moles(GAS_TRITIUM) * 2.5 + \
							T.canister_gas.get_moles(GAS_NUCLEIUM) * 1.5
			switch(T.canister_gas.get_moles(GAS_NUCLEIUM))
				if(20 to 30)
					projectile_emp = 5
				if(30 to 40)
					projectile_emp = 10
				if(40 to 60)
					projectile_emp = 15
				if(60 to 80)
					projectile_emp = 20

			var/plasma_total = T.canister_gas.get_moles(GAS_PLASMA) + T.canister_gas.get_moles(GAS_CONSTRICTED_PLASMA)
			switch(plasma_total)
				if(10 to 20)
					projectile_burn = 10
				if(20 to 30)
					projectile_burn = 15
				if(30 to 40)
					projectile_burn = 20
				if(40 to 50)
					projectile_burn = 25
				if(50 to 60)
					projectile_burn = 30
				if(60 to 70)
					projectile_burn = 35
				if(70 to 80)
					projectile_burn = 40

			projectile_damage = ((((T.material_hardness * 0.25) * T.material_density) * projectile_velocity) * 0.2) + ((gas_mix * 4) * (T.material_charge / 100))

		var/P = linked.fire_projectile(C.projectile_type, target, pixel_speed=projectile_velocity)
		if(istype(P, /obj/item/projectile/bullet/railgun_forged))
			var/obj/item/projectile/bullet/railgun_forged/F = P
			F.damage = projectile_damage
			F.armour_penetration = projectile_penetration
			F.burn = projectile_burn
			F.emp = projectile_emp
			F.flag = projectile_flag
			//message_admins("DEBUG OUTPUT - Projectile: [C.name], Velocity: [projectile_velocity], Damage: [F.damage], Penetration: [F.armour_penetration], Burn: [F.burn], EMP: [F.emp], Flag: [F.flag], Faction: [F.faction]")

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
	obj_integrity -= 10
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

/obj/machinery/ship_weapon/hybrid_rail/proc/bluespace(target) //Mirror the proc in railgun_forge.dm
	var/obj/item/ship_weapon/ammunition/A = chambered
	ammo -= chambered
	chambered = null
	capacitor_charge = 0
	if(ammo?.len)
		state = STATE_FED
		chamber(rapidfire = TRUE)
	else
		state = STATE_NOTLOADED
	playsound(src, 'sound/magic/wand_teleport.ogg', 100, TRUE)

	var/bluespace_roll = rand(0, 100) //Random effect table here
	switch(bluespace_roll) //ADD MORE HERE PLEASE
		if(0 to 30) //Send to the aether
			qdel(A)
			return
		if(31 to 80) //Teleport somewhere randomly on the ship - hope this wasn't a charged canister
			var/turf/T = find_safe_turf()
			do_teleport(A, T)
		if(81 to 100)
			linked.railgun_bluespace_recoil(target)
		//if(1000) What if we shot Narsie by accident? :)

/obj/machinery/ship_weapon/hybrid_rail/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(maint_state < 2)
		to_chat(user, "<span class='notice'>You must first open the maintenance panel before realigning the magnetic coils.</span>")
	else
		to_chat(user, "<span class='notice'>You being realigning the magnetic coils.</span>")
		while(alignment < 100)
			if(!do_after(user, 5, target = src) || !Adjacent(user))
				return
			alignment += rand(1,2)
			if(alignment >= 100)
				alignment = 100
				break

/obj/machinery/ship_weapon/hybrid_rail/welder_act(mob/user, obj/item/tool)
	. = FALSE
	if(functional_crit)
		if(repairing)
			to_chat(user, "<span class='warning'>Someone's already repairing [src]!</span>")
			return TRUE
		to_chat(user, "<span class='notice'>You start repairing the railgun...</span>")
		repairing = TRUE
		while(obj_integrity < max_integrity)
			if(!tool.use_tool(src, user, 5 SECONDS, volume=100))
				repairing = FALSE
				return TRUE
			obj_integrity += 25
			if(obj_integrity >= max_integrity)
				obj_integrity = max_integrity
				functional_crit = FALSE
				icon_state = "OBC"
				break
		to_chat(user, "<span class='notice'>You finishing repairing the railgun.</span>")
		repairing = FALSE

/obj/machinery/ship_weapon/hybrid_rail/crowbar_act(mob/user, obj/item/tool)
	return //prevent deconstructing

/obj/machinery/ship_weapon/hybrid_rail/Destroy()
	if(deletion_protection) //Just var edit this to false if you want to actually delete it
		functional_crit = TRUE
		icon_state = "OBC_destroyed"
		obj_integrity = 0 //If not already there
		return QDEL_HINT_LETMELIVE
	else
		return ..()

/obj/machinery/ship_weapon/hybrid_rail/attackby(obj/item/I, mob/user)
	if(!linked)
		get_ship()
	if(functional_crit)
		to_chat(usr, "<span class='notice'>Error: Unable to load ordnance while railgun is in a critical state.</span>")
		return FALSE
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
	if(!functional_crit)
		ui_interact(user)

/obj/machinery/ship_weapon/hybrid_rail/attack_ai(mob/user)
	.=..()
	if(!functional_crit)
		ui_interact(user)

/obj/machinery/ship_weapon/hybrid_rail/attack_robot(mob/user)
	.=..()
	if(!functional_crit)
		ui_interact(user)

/obj/machinery/ship_weapon/hybrid_rail/attack_ghost(mob/user)
	.=..()
	if(!functional_crit)
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
	data["maint_req"] = maint_req
	data["capacitor_charge"] = capacitor_charge
	data["capacitor_max_charge"] = capacitor_max_charge
	data["capacitor_current_charge_rate"] = capacitor_current_charge_rate
	data["capacitor_max_charge_rate"] = capacitor_max_charge_rate
	data["slug_shell"] = slug_shell
	data["alignment"] = alignment
	data["obj_integ"] = obj_integrity
	data["max_obj_integ"] = max_integrity
	var/list/magazine = list()
	for(var/obj/item/ship_weapon/ammunition/railgun_ammo_canister/C in ammo)
		var/list/canister_stats = list()
		canister_stats["name"] = C.name
		canister_stats["conductivity"] = C.material_conductivity
		canister_stats["density"] = C.material_density
		canister_stats["hardness"] = C.material_hardness
		switch(C.material_charge)
			if(0)
				canister_stats["charge"] = "Null"
			if(1 to 33)
				canister_stats["charge"] = "Low"
			if(33 to 66)
				canister_stats["charge"] = "Moderate"
			if(66 to 100)
				canister_stats["charge"] = "High"
			if(100 to 150)
				canister_stats["charge"] = "Overcharged"
			if(150 to INFINITY)
				canister_stats["charge"] = "DANGER"
		switch(C.canister_integrity)
			if(0 to 20)
				canister_stats["integrity"] = "DANGER"
			if(20 to 50)
				canister_stats["integrity"] = "Degraded"
			if(50 to INFINITY)
				canister_stats["integrity"] = "Stable"
		magazine[++magazine.len] = canister_stats

	for(var/obj/item/ship_weapon/ammunition/railgun_ammo/forged/F in ammo)
		var/list/forged_stats = list()
		forged_stats["name"] = F.name
		forged_stats["conductivity"] = F.material_conductivity
		forged_stats["density"] = F.material_density
		forged_stats["hardness"] = F.material_hardness
		forged_stats["charge"] = "Null"
		forged_stats["integrity"] = "Stable"
		magazine[++magazine.len] = forged_stats
	data["magazine"] = magazine
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
