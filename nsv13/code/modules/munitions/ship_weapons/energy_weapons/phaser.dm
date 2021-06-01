/obj/machinery/ship_weapon/energy
	name = "Burst phaser MK2"
	desc = "A coaxial laser system, capable of firing controlled laser bursts at a target."
	icon ='nsv13/icons/obj/energy_weapons.dmi'
	icon_state = "phase_cannon"
	fire_mode = FIRE_MODE_RED_LASER //Shot by the pilot.
	ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo
	bound_width = 64
	pixel_x = -32
	pixel_y = -32
	maintainable = FALSE //Laser do shoot good and reliably.
	safety = FALSE //Ready to go right from the start.
	idle_power_usage =  2500
	var/active = FALSE
	var/charge = 0
	var/charge_rate = 25000 //How quickly do we charge?
	var/charge_per_shot = 50000 //How much power per shot do we have to use?
	var/max_charge = 250000 //5 shots before it has to recharge.
	var/power_modifier = 0 //Power youre inputting into this thing.
	var/power_modifier_cap = 3 //Which means that your guns are spitting bursts that do 60 damage.
	var/energy_weapon_type = /datum/ship_weapon/pdc_mount/burst_phaser

/obj/machinery/ship_weapon/energy/lazyload()
	active = TRUE
	power_modifier = 1
	. = ..()
	//Comedy.
	sleep(10)
	charge = max_charge

//Designed to be spammed like crazy, but can be buffed to do extremely solid damage when you overclock the guns.
/obj/item/projectile/beam/laser/phaser
	damage = 10
	flag = "overmap_light"

/obj/machinery/ship_weapon/energy/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EnergyWeapons")
		ui.open()

/obj/machinery/ship_weapon/energy/ui_act(action, params)

	if(..())
		return
	var/value = text2num(params["input"])
	switch(action)
		if("power")
			power_modifier = value
		if("activeToggle")
			active = !active
	return

/obj/machinery/ship_weapon/energy/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/ship_weapon/energy/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/ship_weapon/energy/attack_robot(mob/user)
	ui_interact(user)

/obj/machinery/ship_weapon/energy/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["progress"] = charge
	data["goal"] = max_charge
	data["chargeRate"] = charge_rate
	data["maxChargeRate"] = initial(charge_rate)*power_modifier_cap
	data["powerAlloc"] = power_modifier
	data["maxPower"] = power_modifier_cap //Hard cap for now. Allow them to increase this via stock parts when??
	data["active"] = active
	return data

/obj/machinery/ship_weapon/energy/update()
	if(!safety)
		if(src in weapon_type.weapons["loaded"])
			return
		LAZYADD(weapon_type.weapons["loaded"] , src)
	else
		if(src in weapon_type.weapons["loaded"])
			LAZYREMOVE(weapon_type.weapons["loaded"] , src)

/obj/machinery/ship_weapon/energy/fire(atom/target, shots = weapon_type.burst_size, manual = TRUE)
	set waitfor = FALSE //As to not hold up any feedback messages.
	if(can_fire(shots))
		if(manual)
			linked.last_fired = overlay

		for(var/i = 0, i < shots, i++)
			do_animation()
			state = 5

			local_fire()
			overmap_fire(target)
			charge -= charge_per_shot

			after_fire()
		return TRUE
	return FALSE

/obj/machinery/ship_weapon/energy/set_position(obj/structure/overmap/OM) //Use this to tell your ship what weapon category this belongs in
	for(var/I = FIRE_MODE_PDC; I <= MAX_POSSIBLE_FIREMODE; I++) //We should ALWAYS default to PDCs.
		var/datum/ship_weapon/SW = OM.weapon_types[I]
		if(!SW)
			continue
		if(istype(SW, energy_weapon_type)) //Does this ship have a weapon type registered for us? Prevents phantom weapon groups.
			OM.add_weapon(src)
			return TRUE
	OM.weapon_types[fire_mode] = new energy_weapon_type(OM)
	OM.add_weapon(src)

/obj/machinery/ship_weapon/energy/can_fire(shots = weapon_type.burst_size)
	if (maint_state != MSTATE_CLOSED) //Are we in maintenance?
		return FALSE
	if(charge < charge_per_shot*shots) //Do we have enough ammo?
		return FALSE
	else
		return TRUE

/obj/machinery/ship_weapon/energy/get_max_ammo()
	return max_charge

/obj/machinery/ship_weapon/energy/get_ammo()
	return charge

/obj/item/projectile/beam/laser/heavylaser/phaser
	name = "phaser beam"
	damage = 200
	flag = "overmap_heavy"
	hitscan = TRUE //Extremely powerful in ship combat
	icon_state = "omnilaser"
	light_color = LIGHT_COLOR_BLUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo
	tracer_type = /obj/effect/projectile/tracer/disabler
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	impact_type = /obj/effect/projectile/impact/disabler

/obj/machinery/ship_weapon/energy/beam
	name = "Phase Cannon"
	desc = "An extremely powerful directed energy weapon which is capable of delivering a devastating beam attack."
	icon_state = "ion_cannon"
	fire_mode = FIRE_MODE_BLUE_LASER
	energy_weapon_type = /datum/ship_weapon/phaser
	charge_rate = 75000 //How quickly do we charge?
	charge_per_shot = 500000 //How much power per shot do we have to use? By default, half a megawatt.
	max_charge = 1000000 //1 MW as base. This puppy needs a lot of power to use, but does a crapload of damage
	power_modifier_cap = 5 //Allows you to do insanely powerful oneshot lasers. Maximum theoretical damage of 500.

/obj/machinery/ship_weapon/energy/beam/animate_projectile(atom/target)
	var/obj/item/projectile/P = ..()
	P.damage *= power_modifier

/obj/machinery/ship_weapon/energy/process()
	charge_rate = initial(charge_rate) * power_modifier
	max_charge = initial(max_charge) * power_modifier
	charge_per_shot = max(initial(charge_per_shot) * power_modifier, 10) //No getting infinite ammo by setting power mod to 0 :))
	if(charge >= max_charge)
		charge = max_charge //Time to fricking ignore thermodynamics gamers!
		idle_power_usage = 0 //No power draw when fully charged
		return
	if(!active)
		idle_power_usage = 0
		return
	else
		idle_power_usage = 1000
	if(idle_power_usage <= 0 || !try_use_power(charge_rate))
		return
	charge += charge_rate

//Well hey! here's this piece of code again...
/obj/machinery/ship_weapon/energy/proc/try_use_power(amount) // Although the machine may physically be powered, it may not have enough power to sustain a shield.
	if(!powered())
		return FALSE
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


/obj/machinery/ship_weapon/energy/beam/admin //ez weapon for quickly testing.
	charge_per_shot = 0
