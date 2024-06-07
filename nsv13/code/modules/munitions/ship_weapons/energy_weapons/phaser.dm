/obj/machinery/ship_weapon/energy
	name = "burst phaser MK2"
	desc = "A coaxial laser system, capable of firing controlled laser bursts at a target."
	icon ='nsv13/icons/obj/energy_weapons.dmi'
	icon_state = "phase_cannon"
	fire_mode = FIRE_MODE_RED_LASER //Shot by the pilot.
	ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo
	circuit = /obj/item/circuitboard/machine/burst_phaser
	bound_width = 64
	pixel_x = -32
	pixel_y = -32
	maintainable = FALSE //Laser do shoot good and reliably.
	safety = FALSE //Ready to go right from the start.
	idle_power_usage =  2500
	var/active = FALSE
	charge = 0
	charge_rate = 330000 //How quickly do we charge?
	charge_per_shot = 660000 //How much power per shot do we have to use?
	var/max_charge = 3300000 //5 shots before it has to recharge.
	var/power_modifier = 0 //Power youre inputting into this thing.
	var/power_modifier_cap = 3 //Which means that your guns are spitting bursts that do 60 damage.
	var/energy_weapon_type = /datum/ship_weapon/burst_phaser
	var/static_charge = FALSE //Controls whether power and energy cost scale with power modifier. True = no scaling
	var/alignment = 100 //stolen from railguns and the plasma gun
	var/freq = 100
	max_heat = 1000
	max_integrity = 1200 //don't blow up before we're ready
	obj_integrity = 1200
	heat_per_shot = 60
	var/max_freq = 100
	var/combo_target = "omega" //Randomized sequence for the recalibration minigame.
	var/list/letters = list("delta,", "omega,", "phi,")
	var/combo = null
	var/combocount = 0 //How far into the combo are they?
	var/overheat_sound = 'sound/effects/smoke.ogg'
	var/list/coolers = list()
	var/list/storages = list()
	var/cooling_amount = 0
	var/storage_amount = 0
	heat_rate = 20
	var/storage_rate = 100


/obj/machinery/ship_weapon/energy/beam
	name = "phase cannon"
	desc = "An extremely powerful directed energy weapon which is capable of delivering a devastating beam attack."
	icon_state = "ion_cannon"
	fire_mode = FIRE_MODE_BLUE_LASER
	energy_weapon_type = /datum/ship_weapon/phaser
	circuit = /obj/item/circuitboard/machine/phase_cannon
	charge_rate = 800000 // At power level 5, requires 3MW per tick to charge
	charge_per_shot = 4000000 // At power level 5, requires 20MW total to fire, takes about 12 seconds to gain 1 charge
	max_charge = 8000000 // Store 2 charges
	power_modifier_cap = 5 //Allows you to do insanely powerful oneshot lasers. Maximum theoretical damage of 500.
	max_heat = 2000
	heat_per_shot = 500
	heat_rate = 20
	storage_rate = 50

/obj/machinery/ship_weapon/energy/Initialize()
	. = ..()
	combo_target = "[pick(letters)][pick(letters)][pick(letters)][pick(letters)][pick(letters)]"  //actually making the random sequince


/obj/machinery/ship_weapon/energy/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The heatsink display reads <b>[(heat)]</b> out of <b>[(max_heat)]</b>.</span>"
		if(maint_state != MSTATE_CLOSED)
			. +=  "<span class='warning'>[src]'s realignment sequence is: [combo_target].</span>"




/obj/machinery/ship_weapon/energy/lazyload()
	active = TRUE
	power_modifier = 1
	. = ..()
	//Comedy.
	sleep(10)
	charge = max_charge

/obj/machinery/ship_weapon/energy/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EnergyWeapons")
		ui.open()
		ui.set_autoupdate(TRUE)

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
	data["alignment"] = alignment
	data["heat"] = heat
	data["maxheat"] = max_heat
	data["frequency"] = freq
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

/obj/machinery/ship_weapon/energy/set_position(obj/structure/overmap/OM) //Use this to tell your ship what weapon category this belongs in
	for(var/I = FIRE_MODE_ANTI_AIR; I <= MAX_POSSIBLE_FIREMODE; I++) //We should ALWAYS default to PDCs.
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
	if(overloaded) //have we overheated?
		return FALSE
	if(freq <=10) //is the frequincy of the weapon high enough to fire?
		overload()
		return FALSE
	if(alignment == 0)
		for(var/mob/living/M in get_hearers_in_view(7, src)) //burn out eyes in view
			if(M.stat != DEAD && M.get_eye_protection() < 2) //checks for eye protec
				M.flash_act(10)
				to_chat(M, "<span class='warning'>You have a second to watch the casing of the gun glow a dull red before it erupts in a blinding flash as it self-destructs</span>")   // stealing this from the plasmagun as well
		explosion(get_turf(src), 0, 1, 3, 5, flame_range = 4)
		overload()
	else
		return TRUE

/obj/machinery/ship_weapon/energy/get_max_ammo()
	return max_charge

/obj/machinery/ship_weapon/energy/get_ammo()
	return charge

/obj/machinery/ship_weapon/energy/beam/animate_projectile(atom/target)
	var/obj/item/projectile/P = ..()
	if(!static_charge)
		P.damage *= power_modifier
	P.damage *= (freq/100)

/obj/machinery/ship_weapon/energy/process()
	process_heat()
	if(overloaded)
		return
	charge_rate = initial(charge_rate) * power_modifier
	max_charge = initial(max_charge) * power_modifier
	if(!static_charge)
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

/obj/machinery/ship_weapon/energy/after_fire()
	if(maint_state != MSTATE_CLOSED) //MSTATE_CLOSED
		tesla_zap(src, 4, 1000) //Munitions Officer definitely had the best uniform
		for(var/mob/living/carbon/C in orange(4, src))
			C.flash_act()
		for(var/mob/living/carbon/C in orange(12, src))
			to_chat(C, "<span class='danger'>Electricity arcs from the exposed firing mechanism.</span>")
	handle_alignment()
	..()





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



/obj/machinery/ship_weapon/energy/proc/process_heat()//heat management. don't push your weapons too hard. actual heat generation is in _ship_weapons.dm
	for(var/obj/machinery/cooling/cooler/C in coolers)
		if(!(C.machine_stat & (BROKEN|NOPOWER|MAINT)))
			cooling_amount++
	for(var/obj/machinery/cooling/storage/C in storages)
		if(!(C.machine_stat & (BROKEN|NOPOWER|MAINT)))
			storage_amount++
	max_heat = initial(max_heat) + (storage_amount*storage_rate)
	if(heat > 0)
		heat = max((heat-cooling_amount*heat_rate),0)
	if(overloaded & (heat <= (max_heat/50)))
		overloaded = 0
	if(overloaded)
		return
	if(heat >= max_heat)
		overload()


/obj/machinery/ship_weapon/energy/proc/overload() //this is what happens when you can't control yourself
	playsound(src, malfunction_sound, 100, 1)
	playsound(src, overheat_sound, 100, 1)
	do_sparks(4, FALSE, src)
	overloaded = 1
	alignment = 0
	freq = 0
	say("WARNING! Critical heat density, emergency venting and shutdown initiated!")
	atmos_spawn_air("water_vapor=200;TEMP=1000")
	heat = max_heat
	charge = 0
	return

/obj/machinery/ship_weapon/energy/proc/handle_alignment() //this is the basic bad stuff that happens, don't fire when your gun is at 0 alignment, or it'll blow itself up
	var/turf/detonation_turf = get_turf(src)
	if(heat >= (3*(max_heat/4)))
		freq -= rand(1,4)
	if(alignment <= 75)
		if(prob(50))
			do_sparks(4, FALSE, src)
			freq -= rand(1,10)
	if(alignment <= 50)
		if(prob(45))
			do_sparks(4, FALSE, src)
			freq -= rand(1,10)
			playsound(src, malfunction_sound, 100, 1)
		if(prob(5))
			playsound(src, malfunction_sound, 100, 1)
			freq -= rand(1,10)
			explosion(detonation_turf, 0, 0, 2, 3, flame_range = 2)
	if(alignment <= 25)
		if(prob(25))
			do_sparks(4, FALSE, src)
			playsound(src, malfunction_sound, 100, 1)
			freq -= rand(1,10)
		if(prob(25))
			playsound(src, malfunction_sound, 100, 1)
			freq -= rand(1,10)
			explosion(detonation_turf, 0, 0, 3, 4, flame_range = 3)
		if(prob(50))
			var/list/shootat_turf = RANGE_TURFS(5,detonation_turf) - RANGE_TURFS(4, detonation_turf)
			var/obj/item/projectile/beam/laser/P = new(detonation_turf)
			//Shooting Code:
			P.range = 6
			P.preparePixelProjectile(pick(shootat_turf), detonation_turf)
			P.fire()
			freq -= rand(1,10)
	alignment = max(alignment-(rand(0, 4)),0)


	// dilithium crystal alignment minigame stolen from ds13
/obj/machinery/ship_weapon/energy/screwdriver_act(mob/user, obj/item/tool)
	. = ..()
	if(maint_state == MSTATE_UNBOLTED)
		.=TRUE
		var/sound/thesound = pick('nsv13/sound/effects/computer/beep.ogg','nsv13/sound/effects/computer/beep2.ogg','nsv13/sound/effects/computer/beep3.ogg','nsv13/sound/effects/computer/beep4.ogg','nsv13/sound/effects/computer/beep5.ogg','nsv13/sound/effects/computer/beep6.ogg','nsv13/sound/effects/computer/beep7.ogg','nsv13/sound/effects/computer/beep8.ogg','nsv13/sound/effects/computer/beep9.ogg','nsv13/sound/effects/computer/beep10.ogg','nsv13/sound/effects/computer/beep11.ogg','nsv13/sound/effects/computer/beep12.ogg',)
		SEND_SOUND(user, thesound)
		var/list/options = letters
		for(var/option in options)
			options[option] = image(icon = 'nsv13/icons/actions/engine_actions.dmi', icon_state = "[option]")
		var/dowhat = show_radial_menu(user,src,options)
		if(!dowhat)
			return
		combo += "[dowhat]"
		combocount ++
		to_chat(user, "<span class='warning'>You inputted [dowhat] into the command sequence.</span>")
		playsound(src, 'sound/machines/sm/supermatter3.ogg', 20, 1)
		if(combocount <= 4)
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom,screwdriver_act), user),2)   // *scream  addtimer(CALLBACK(object|null, GLOBAL_PROC_REF(type/path|procstring), arg1, arg2, ... argn), time, timertype)
		if(combocount >= 5) //Completed the sequence
			if(combo == combo_target)
				to_chat(user, "<span class='warning'>Realignment of weapon energy direction matrix complete.</span>")
				playsound(src, 'sound/machines/sm/supermatter1.ogg', 30, 1)
				freq = max_freq
				combo = null
				combocount = 0
			else
				to_chat(user, "<span class='warning'>Realignment failed. Continued failure risks dangerous heat overload. Rotating command sequence.</span>")
				playsound(src, 'nsv13/sound/effects/warpcore/overload.ogg', 100, 1)
				combo_target = "[pick(letters)][pick(letters)][pick(letters)][pick(letters)][pick(letters)]"
				heat = max(heat+(heat_per_shot*4),max_heat) //Penalty for fucking it up. You risk destroying the crystal... //well... actually overheating the gun
				combocount = 0
				combo = null

/obj/machinery/ship_weapon/energy/multitool_act(mob/living/user, obj/item/multitool/I)
	if(maint_state == MSTATE_CLOSED)
		if (istype(I))
			to_chat(user, "<span class='notice'>You log [src] in the multitool's buffer.</span>")
			I.buffer = src
			return TRUE
	if(maint_state == MSTATE_UNSCREWED)
		to_chat(user, "<span class='notice'>You must unbolt the protective casing before aligning the lenses!</span>")
	if(maint_state == MSTATE_UNBOLTED)
		. = TRUE
		to_chat(user, "<span class='notice'>You being aligning the lenses.</span>")
		while(alignment < 100)
			if(!do_after(user, 5, target = src))
				return
			alignment += rand(1,2)
			if(alignment >= 100)
				alignment = 100
				break





