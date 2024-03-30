// in kPa
#define MAX_WASTE_OUTPUT_PRESSURE 5000
#define MAX_WASTE_STORAGE_PRESSURE 8000
#define POWER_FAIL_TOLERANCE 3 //! If more than this many cycles of power are missed, we shut down. If any stacks of this are present, it multiplies power drain of following cycles by the counter.

// Base temperature to heat waste gas by in celcius.
#define WASTE_GAS_HEAT 35

/// Multiplies power draw by this value every tick it remains active when spooled. Higher values will make power use increase faster
#define PYLON_ACTIVE_EXPONENT 1.01


///Thirring Drive PYLON///
/obj/machinery/atmospherics/components/binary/drive_pylon
	name = "\improper Thirring Drive Pylon"
	desc = "Produces exotic energy for a Thirring Drive. Requires Nucleium and electricity to spool up, avoid physical contact with gyroscopes."
	icon = 'nsv13/icons/obj/machinery/FTL_pylon.dmi'
	icon_state = "pylon"
	dir = NORTH
	density = TRUE
	anchored = TRUE
	idle_power_usage = 500
	layer = ABOVE_MOB_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/link_id = "default"
	var/gyro_speed = 0
	var/req_gyro_speed = 25
	var/shielded = FALSE
	var/obj/effect/pylon_shield/pylon_shield
	var/pylon_state = PYLON_STATE_OFFLINE
	var/capacitor = 0 // capacitors charged
	var/mol_per_capacitor = 10 // moles of nucleium required for each capacitor
	var/active_mol_use = 0.2 // moles of nucleium used per tick once the pylon have been activated
	var/max_charge_rate = 1 // max amount of capacitors that can be charged per tick
	var/req_capacitor = 5 // amount of capacitors required to be charged for the pylon to activate
	var/power_draw = 0
	var/heat_capacity = 5000
	var/datum/gas_mixture/air_contents
	var/obj/structure/cable/cable
	var/obj/machinery/computer/ship/ftl_core/ftl_drive
	///Stacking counter of how many times we have missed power demands. If we go over the defined tolerance, we shut down. Even below, we use [counter] times more power to make up for the loss.
	var/power_failure_counter = 0

/obj/machinery/atmospherics/components/binary/drive_pylon/Initialize(mapload)
	. = ..()
	initialize_shield()
	update_visuals(FALSE)
	air_contents = new(3000)
	air_contents.set_temperature(T20C)

/obj/machinery/atmospherics/components/binary/drive_pylon/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>This equipment should be preserved, it will be a useful resource to our masters in the future. Aborting.</span>")
	S.LoseTarget()
	return FALSE

/obj/machinery/atmospherics/components/binary/drive_pylon/process()
	if(!on)
		return PROCESS_KILL
	if(pylon_state == PYLON_STATE_SHUTDOWN) //halt the spinning
		power_draw = 0
		if(--gyro_speed <= 0)
			finalalize_shutdown()
		else
			capacitor -= round(capacitor / gyro_speed, 0.1)
		return
	if(!power_drain())
		set_state(PYLON_STATE_SHUTDOWN)
		return
	if(capacitor >= req_capacitor)
		set_state(PYLON_STATE_ACTIVE)

	var/datum/gas_mixture/input = airs[1]
	switch(pylon_state)
		if(PYLON_STATE_ACTIVE)
			if(shielded)
				active_mol_use = max(active_mol_use * PYLON_ACTIVE_EXPONENT, active_mol_use + 0.015) // Shielded pylons use less power but burn more fuel
				power_draw += round(100 * (active_mol_use / 10 + 1), 1) //Power scaling is considerably lower in exchange for a tangible cost.
			else
				power_draw = round(power_draw * PYLON_ACTIVE_EXPONENT + 300, 1) // Active pylons slowly but exponentially require more charge to stay stable. Don't leave them on when you don't need to
			var/rounded_mol_use = round(active_mol_use, 0.1)
			if(input.get_moles(GAS_NUCLEIUM) < rounded_mol_use)
				say("Insufficient FTL fuel, spooling down.")
				set_state(PYLON_STATE_SHUTDOWN)
				return
			input.adjust_moles(GAS_NUCLEIUM, -rounded_mol_use)
			var/outgoing_temp = T20C + WASTE_GAS_HEAT + round(power_draw / 1000 / log(power_draw), 1)
			if(shielded)
				outgoing_temp *= 2
			air_contents.adjust_moles_temp(GAS_PLASMA, rounded_mol_use, outgoing_temp) //Why did we have the whole piping stuff around output of this thing if we only ever ejected gas during the initial charge??

		if(PYLON_STATE_STARTING) //pop the lid
			power_draw = 5000
			if(++gyro_speed >= 10)
				if(input.get_moles(GAS_NUCLEIUM))
					set_state(PYLON_STATE_WARMUP)
				else
					say("Insufficient FTL fuel, spooling down.")
					set_state(PYLON_STATE_SHUTDOWN)

		if(PYLON_STATE_WARMUP) //start the spin
			var/ftl_fuel = input.get_moles(GAS_NUCLEIUM)

			if(ftl_fuel < 0.25)
				say("Insufficient FTL fuel, spooling down.")
				set_state(PYLON_STATE_SHUTDOWN)
				return

			input.adjust_moles(GAS_NUCLEIUM, -0.25)
			if(prob(20))
				var/datum/effect_system/spark_spread/S = new
				S.set_up(6, 0, src)
				S.start()
			power_draw = 20000
			if(++gyro_speed >= req_gyro_speed)
				set_state(PYLON_STATE_SPOOLING)

		if(PYLON_STATE_SPOOLING) //spinning intensifies
			var/ftl_fuel = input.get_moles(GAS_NUCLEIUM)
			if(ftl_fuel < 1)
				if(capacitor > 0)
					capacitor -= min(rand(0.25, 0.5), capacitor)
				else
					say("Insufficient FTL fuel, spooling down.")
					set_state(PYLON_STATE_SHUTDOWN)
				return
			power_draw = 50000 // 50KW
			consume_fuel()
			if(gyro_speed < req_gyro_speed)
				set_state(PYLON_STATE_SHUTDOWN)

/obj/machinery/atmospherics/components/binary/drive_pylon/proc/power_drain()
	var/turf/T = get_turf(src)
	if(!cable || get_turf(cable) != get_turf(src))
		if(cable)
			clear_cable_ref()
		var/obj/structure/cable/new_cable = T.get_cable_node()
		if(!new_cable)
			return FALSE
		cable = new_cable
		RegisterSignal(new_cable, COMSIG_PARENT_QDELETING, PROC_REF(clear_cable_ref))
	var/actual_power_draw = power_draw * (1 + power_failure_counter)
	if(actual_power_draw > cable.surplus())
		power_failure_counter++
		if(power_failure_counter > POWER_FAIL_TOLERANCE)
			visible_message("<span class='warning'>\The [src] lets out a metallic groan as its power indicator flickers.</span>")
			return FALSE
		visible_message("<span class='warning'>The power warning diode on [src] flashes [power_failure_counter > 1 ? "bright red" : "yellow"]!</span>")
	else
		power_failure_counter = max(0, power_failure_counter - 1)
	cable.add_load(clamp(actual_power_draw, 0, cable.surplus()))
	return TRUE

/obj/machinery/atmospherics/components/binary/drive_pylon/process_atmos()
	var/datum/gas_mixture/output = airs[2]
	var/i_pressure = air_contents.return_pressure()
	switch(i_pressure)
		if(MAX_WASTE_STORAGE_PRESSURE/3 to MAX_WASTE_STORAGE_PRESSURE/2)
			switch(rand(1, 10))
				if(1)
					playsound(src, 'nsv13/sound/effects/metal_clang.ogg', 100, TRUE)
				if(2)
					audible_message("<span class='warning'>\The [src] hisses quitely.</span>")
				if(3)
					audible_message("<span class='warning'>\The [src] lets out a metallic groan.</span>")
				else
		if(MAX_WASTE_STORAGE_PRESSURE/2 to MAX_WASTE_STORAGE_PRESSURE)
			switch(rand(1, 20))
				if(1)
					playsound(src, 'nsv13/sound/effects/metal_clang.ogg', 100, TRUE)
				if(3)
					playsound(src, 'sound/effects/bamf.ogg', 100, TRUE)
				if(4)
					playsound(src, 'sound/effects/bang.ogg', 100, TRUE)
				if(5)
					visible_message(src, "<span class='danger'>\The [src]'s chassis begins to bulge!</span>")
				if(6)
					audible_message(src, "<span class='alert'>You hear a high pitch hiss!</span>")
				if(7)
					playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', 100, TRUE)
				else

		if(MAX_WASTE_STORAGE_PRESSURE to INFINITY)
			var/turf/T = get_turf(src)
			T.assume_air(air_contents)
			QDEL_NULL(air_contents)
			explosion(T, 0, 1, 3)
			qdel(src)
			return
		else

	var/output_pressure = output.return_pressure()
	//When I arrived here, this file was terrible. Now, it is still terrible, but at least the nodes update. ~Delta
	if(output_pressure < MAX_WASTE_OUTPUT_PRESSURE)
		var/transfer_moles = (MAX_WASTE_OUTPUT_PRESSURE - output_pressure) * output.return_volume()/(air_contents.return_temperature() * R_IDEAL_GAS_EQUATION)
		air_contents.transfer_to(output, transfer_moles)
	update_parents() //Why would you not always be updating the gas input on a machine that consumes gas??

/obj/machinery/atmospherics/components/binary/drive_pylon/proc/try_enable()
	if(pylon_state == PYLON_STATE_SHUTDOWN)
		return FALSE
	var/turf/T = get_turf(src)
	var/obj/structure/cable/new_cable = T.get_cable_node()
	if(cable)
		clear_cable_ref()
	if(!new_cable)
		return FALSE
	cable = new_cable
	RegisterSignal(new_cable, COMSIG_PARENT_QDELETING, PROC_REF(clear_cable_ref))
	on = TRUE
	START_PROCESSING(SSmachines, src)
	set_state(PYLON_STATE_STARTING)
	return TRUE

/obj/machinery/atmospherics/components/binary/drive_pylon/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	if(shielded)
		if(damage_type == BURN)
			damage_amount = 0
		else
			damage_amount *= 0.5
	return ..()

/obj/machinery/atmospherics/components/binary/drive_pylon/proc/finalalize_shutdown()
	set_state(PYLON_STATE_OFFLINE)
	power_draw = 0
	gyro_speed = 0
	capacitor = 0
	active_mol_use = initial(active_mol_use)
	on = FALSE
	power_failure_counter = 0
	STOP_PROCESSING(SSmachines, src)

/// Main spool process, consumes nucleium and converts it into FTL capacitor power
/obj/machinery/atmospherics/components/binary/drive_pylon/proc/consume_fuel()
	var/datum/gas_mixture/input = airs[1]
//	if(prob(30))
//		tesla_zap(src, 2, 1000)
	var/input_fuel = min(input.get_moles(GAS_NUCLEIUM), max_charge_rate * mol_per_capacitor)
	capacitor += min(input_fuel / mol_per_capacitor, req_capacitor - capacitor)
	input.adjust_moles(GAS_NUCLEIUM, -input_fuel)
	var/datum/gas_mixture/waste = new
	waste.adjust_moles(GAS_PLASMA, input_fuel / 3)
	waste.adjust_moles(GAS_NUCLEIUM, input_fuel / 4)
	var/heat_increase = WASTE_GAS_HEAT + round(power_draw / 1000 / log(power_draw), 1) //???? This proc only ever happens while the pylon boots up, during which power use is basically CONSTANT??????
	if(shielded) // Closing shields greatly increases internal temperature gain
		heat_increase *= 2
	var/air_temperature = air_contents.return_temperature()
	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_energy = heat_capacity * (air_temperature + heat_increase) + air_heat_capacity * air_temperature // Thermodynamics and it's consequences have been a disaster for the humanity's programmers
	waste.set_temperature(combined_energy/(air_heat_capacity + heat_capacity)) // combined energy divided by combined heat capacity
	air_contents.merge(waste) //Why was this snowflaked before?? We already handle overfilled internal storage on atmos process.
	qdel(waste)

///Returns the current nucleium use of this machine in moles / machine tick (2 seconds). Not rounded.
/obj/machinery/atmospherics/components/binary/drive_pylon/proc/get_nucleium_use()
	switch(pylon_state)
		if(PYLON_STATE_SPOOLING)
			var/datum/gas_mixture/input = airs[1]
			return min(input.get_moles(GAS_NUCLEIUM), max_charge_rate * mol_per_capacitor)
		if(PYLON_STATE_ACTIVE)
			return active_mol_use
		else
			return 0

/obj/machinery/atmospherics/components/binary/drive_pylon/proc/toggle_shield()
	if(!pylon_shield) //somehow...
		initialize_shield()
	if(shielded)
		pylon_shield.icon_state = "pylon_shield_open"
		flick("pylon_shield_opening", pylon_shield)
	else
		pylon_shield.icon_state = "pylon_shield"
		flick("pylon_shield_closing", pylon_shield)
	playsound(src, 'sound/machines/blastdoor.ogg', 40, 1)
	shielded = !shielded

/// Use this when changing pylon states to avoid overlay cbt
/obj/machinery/atmospherics/components/binary/drive_pylon/proc/set_state(nstate)
	if(pylon_state == nstate) // to avoid needless icon updates
		return
	if(nstate == PYLON_STATE_SPOOLING)
		playsound(src, 'nsv13/sound/machines/FTL/AC_buzz.ogg', 150, FALSE, 3)
	pylon_state = nstate
	update_visuals()

/obj/machinery/atmospherics/components/binary/drive_pylon/Destroy()
	if(ftl_drive)
		ftl_drive.pylons -= src
		ftl_drive = null
	pylon_shield.pylon = null
	if(cable)
		clear_cable_ref()
	QDEL_NULL(pylon_shield)
	var/datum/gas_mixture/input = airs[1]
	var/datum/gas_mixture/output = airs[2]

	var/datum/gas_mixture/spill = air_contents.copy()
	spill.merge(input)
	spill.merge(output)

	QDEL_NULL(air_contents)
	if(spill.total_moles())
		var/turf/T = get_turf(src)
		T.assume_air(spill)

	qdel(spill)
	return ..()

///Clears the ref of the cable. Why this didn't have any measures for this before, I do not know.
/obj/machinery/atmospherics/components/binary/drive_pylon/proc/clear_cable_ref()
	UnregisterSignal(cable, COMSIG_PARENT_QDELETING)
	cable = null

/obj/machinery/atmospherics/components/binary/drive_pylon/return_analyzable_air()
	return airs + air_contents

/obj/machinery/atmospherics/components/binary/drive_pylon/proc/update_visuals(cut = TRUE)
	if(cut)
		cut_overlays()
	if(!pylon_shield) // Shouldn't be deleted but just in case
		initialize_shield()
	var/list/ov = list()
	switch(pylon_state)
		if(PYLON_STATE_OFFLINE)
			ov += "pylon_gyro"
		if(PYLON_STATE_STARTING, PYLON_STATE_WARMUP)
			ov += "pylon_gyro_on"
		if(PYLON_STATE_SPOOLING)
			ov += "pylon_gyro_on_medium"
		if(PYLON_STATE_ACTIVE)
			ov += "pylon_gyro_on_fast"
			ov += "pylon_arcing"
		if(PYLON_STATE_SHUTDOWN)
			ov += "pylon_gyro_on_medium"
	add_overlay(ov)

/obj/machinery/atmospherics/components/binary/drive_pylon/proc/initialize_shield()
	pylon_shield = new(loc)
	pylon_shield.layer = layer + 0.01
	pylon_shield.pylon = src
	vis_contents += pylon_shield

// ------------------ Debug pylon ------------------


/obj/machinery/atmospherics/components/binary/drive_pylon/hugbox
	name = "\improper Hugbox Drive Pylon"
	var/autoclear_waste = TRUE
	var/autoadd_input = TRUE

/obj/machinery/atmospherics/components/binary/drive_pylon/hugbox/try_enable()
	if(pylon_state == PYLON_STATE_SHUTDOWN)
		return FALSE
	on = TRUE
	START_PROCESSING(SSmachines, src)
	set_state(PYLON_STATE_STARTING)
	return TRUE

/obj/machinery/atmospherics/components/binary/drive_pylon/hugbox/power_drain()
	return TRUE

/obj/machinery/atmospherics/components/binary/drive_pylon/hugbox/process_atmos()
	if(autoadd_input)
		var/datum/gas_mixture/input = airs[1]
		input.set_moles(GAS_NUCLEIUM, 100)
	if(autoclear_waste)
		var/datum/gas_mixture/output = airs[2]
		output.clear()
	return ..()


// VFX

/obj/effect/pylon_shield
	name = "pylon shield"
	icon = 'nsv13/icons/obj/machinery/FTL_pylon.dmi'
	icon_state = "pylon_shield_open"
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	var/obj/machinery/atmospherics/components/binary/drive_pylon/pylon


/obj/effect/pylon_shield/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(pylon.pylon_state == PYLON_STATE_OFFLINE)
		to_chat(user, "<span class='info'>You poke the metallic [pylon.shielded ? "shield" : "gyros"].</span>")
	else
		to_chat(user, "<span class='info'>You don't think it would be wise to touch this right now.</span>")

#undef MAX_WASTE_OUTPUT_PRESSURE
#undef MAX_WASTE_STORAGE_PRESSURE
#undef WASTE_GAS_HEAT

#undef PYLON_ACTIVE_EXPONENT
#undef POWER_FAIL_TOLERANCE
