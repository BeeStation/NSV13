// in kPa
#define MAX_WASTE_OUTPUT_PRESSURE 5000
#define MAX_WASTE_STORAGE_PRESSURE 8000

// Base temperature to heat waste gas by in celcius.
#define WASTE_GAS_HEAT 50

/// Multiplies power draw by this value every tick it remains active when spooled. Higher values will make power use increase faster
#define PYLON_ACTIVE_EXPONENT 1.01

/// Max power use before we start to overheat (watts)
#define POWER_USE_SAFE 100000

///Thirring Drive PYLON///
/obj/machinery/atmospherics/components/binary/drive_pylon
	name = "\improper Thirring Drive Pylon"
	desc = "Produces exotic energy for a Thirring Drive. Requires Nucleium and electricity to spool up, avoid physical contact with gyroscopes."
	icon = 'nsv13/icons/obj/machinery/FTL_pylon.dmi'
	icon_state = "pylon"
	bound_height = 64
	density = TRUE
	anchored = TRUE
	idle_power_usage = 500
	layer = ABOVE_MOB_LAYER
	var/link_id = "default"
	var/gyro_speed = 0
	var/req_gyro_speed = 25
	var/shielded = FALSE
	var/mutable_appearance/pylon_shield
	var/pylon_state = PYLON_STATE_OFFLINE
	var/capacitor = 0 // capacitors charged
	var/mol_per_capacitor = 10
	var/max_charge_rate = 1 // amount of capacitors that can be charged per tick
	var/req_capacitor = 5 // amount of capacitors required to be charged for the pylon to be active
	var/power_draw = 0
	var/datum/gas_mixture/air_contents
	var/obj/structure/cable/cable
	var/obj/machinery/computer/ship/ftl_core/ftl_drive

/obj/machinery/atmospherics/components/binary/drive_pylon/New()
	..()
	pylon_shield = mutable_appearance('nsv13/icons/obj/machinery/FTL_pylon.dmi', "pylon_shield_open", layer + 0.1)
	update_visuals()
	air_contents = new(3000)
	air_contents.set_temperature(T20C)

/obj/machinery/atmospherics/components/binary/drive_pylon/process()
	if(!on)
		return
	if(pylon_state != PYLON_STATE_SHUTDOWN)
		if(!power_drain())
			set_state(PYLON_STATE_SHUTDOWN)
			return
		if(capacitor >= req_capacitor)
			set_state(PYLON_STATE_ACTIVE)

	var/datum/gas_mixture/input = airs[1]

	switch(pylon_state)
		if(PYLON_STATE_ACTIVE)
			power_draw = round(power_draw * PYLON_ACTIVE_EXPONENT + 300) // Active pylons slowly but exponentially require more charge to stay stable. Don't leave them on when you don't need to

		if(PYLON_STATE_STARTING) //pop the lid
			power_draw = 5000
			if(++gyro_speed >= 10)
				if(input.get_moles(/datum/gas/nucleium))
					set_state(PYLON_STATE_WARMUP)
				else
					say("Insufficient FTL fuel, spooling down.")
					set_state(PYLON_STATE_SHUTDOWN)

		if(PYLON_STATE_WARMUP) //start the spin
			var/ftl_fuel = input.get_moles(/datum/gas/nucleium)

			if(ftl_fuel < 0.25)
				say("Insufficient FTL fuel, spooling down.")
				set_state(PYLON_STATE_SHUTDOWN)
				return

			input.adjust_moles(/datum/gas/nucleium, -0.25)
			if(prob(20))
				var/datum/effect_system/spark_spread/S = new /datum/effect_system/spark_spread
				S.set_up(6, 0, src)
				S.start()
			power_draw = 20000
			if(++gyro_speed >= req_gyro_speed)
				set_state(PYLON_STATE_SPOOLING)

		if(PYLON_STATE_SPOOLING) //spinning intensifies
			var/ftl_fuel = input.get_moles(/datum/gas/nucleium)
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

		if(PYLON_STATE_SHUTDOWN) //halt the spinning
			power_draw = 0
			if(--gyro_speed <= 0)
				finalalize_shutdown()
			else
				capacitor -= round(capacitor / gyro_speed, 0.1)

/obj/machinery/atmospherics/components/binary/drive_pylon/proc/power_drain()
	if(power_draw <= 0)
		return TRUE
	var/turf/T = get_turf(src)
	cable = T.get_cable_node()
	if(!cable)
		return FALSE
	if(power_draw > cable.surplus())
		visible_message("<span class='warning'>\The [src] lets out an eerie hum as it's power light flickers.</span>")
		return FALSE
	cable.add_load(power_draw)
	return TRUE

/obj/machinery/atmospherics/components/binary/drive_pylon/process_atmos()
	var/datum/gas_mixture/output = airs[2]
	var/i_pressure = air_contents.return_pressure()
	switch(i_pressure)
		if(0)
			return
		if(MAX_WASTE_STORAGE_PRESSURE/3 to MAX_WASTE_STORAGE_PRESSURE/2)
			switch(rand(1, 10))
				if(1)
					playsound(src, 'nsv13/sound/effects/metal_clang.ogg', rand(70,90), TRUE)
				if(2)
					audible_message("<span class='warning'>\The [src] hisses quitely.</span>")
				if(3)
					audible_message("<span class='warning'>\The [src] lets out a metallic groan.</span>")
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

		if(MAX_WASTE_STORAGE_PRESSURE to INFINITY)
			var/turf/T = get_turf(src)
			T.assume_air(air_contents)
			explosion(T, 0, 1, 3)
			QDEL_NULL(air_contents)
			if(!QDELETED(src))
				qdel(src)
			return
	var/output_pressure = output.return_pressure()
	if(output_pressure < MAX_WASTE_OUTPUT_PRESSURE)
		var/transfer_moles = (MAX_WASTE_OUTPUT_PRESSURE - output_pressure) * output.return_volume()/(air_contents.return_temperature() * R_IDEAL_GAS_EQUATION)
		air_contents.transfer_to(output, transfer_moles)
		update_parents()

/obj/machinery/atmospherics/components/binary/drive_pylon/proc/try_enable()
	if(pylon_state == PYLON_STATE_SHUTDOWN)
		return FALSE
	var/turf/T = get_turf(src)
	cable = T.get_cable_node()
	if(!cable)
		return FALSE
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
	on = FALSE
	STOP_PROCESSING(SSmachines, src)

/// Main spool process, consumes nucleium and converts it into FTL capacitor power
/obj/machinery/atmospherics/components/binary/drive_pylon/proc/consume_fuel()
	var/datum/gas_mixture/input = airs[1]
	var/datum/gas_mixture/output = airs[2]
//	if(prob(30))
//		tesla_zap(src, 2, 1000)
	var/input_fuel = min(input.get_moles(/datum/gas/nucleium), max_charge_rate * mol_per_capacitor)
	capacitor += min(input_fuel / mol_per_capacitor, req_capacitor - capacitor)
	input.adjust_moles(/datum/gas/nucleium, -input_fuel)
	var/datum/gas_mixture/waste = new
	waste.adjust_moles(/datum/gas/plasma, input_fuel / 3)
	waste.adjust_moles(/datum/gas/nucleium, input_fuel / 4)
	var/heat_increase = WASTE_GAS_HEAT + round(power_draw / 1000)
	if(shielded) // Closing shields greatly increases internal temperture gain
		heat_increase *= 2
	waste.set_temperature(input.return_temperature() + heat_increase)
	if(output.return_pressure() < MAX_WASTE_OUTPUT_PRESSURE)
		air_contents.merge(waste)
	else
		output.merge(waste)
	qdel(waste)

/obj/machinery/atmospherics/components/binary/drive_pylon/proc/toggle_shield()
	if(!pylon_shield) //somehow...
		pylon_shield = mutable_appearance('nsv13/icons/obj/machinery/FTL_pylon.dmi', "pylon_shield_open")
		add_overlay(pylon_shield)
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

/obj/machinery/atmospherics/components/binary/drive_pylon/proc/update_visuals()
	cut_overlays()
	if(QDELETED(pylon_shield)) // Shouldn't be deleted but just in case
		pylon_shield = mutable_appearance('nsv13/icons/obj/machinery/FTL_pylon.dmi', "pylon_shield_open")
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
	ov += pylon_shield
	add_overlay(ov)


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
		input.set_moles(/datum/gas/nucleium, 100)
	if(autoclear_waste)
		var/datum/gas_mixture/output = airs[2]
		output.clear()
	return ..()

#undef PYLON_STATE_OFFLINE
#undef PYLON_STATE_STARTING
#undef PYLON_STATE_WARMUP
#undef PYLON_STATE_SPOOLING
#undef PYLON_STATE_ACTIVE
#undef PYLON_STATE_SHUTDOWN

#undef MAX_WASTE_OUTPUT_PRESSURE
#undef MAX_WASTE_STORAGE_PRESSURE

#undef PYLON_ACTIVE_EXPONENT
#undef POWER_USE_SAFE
