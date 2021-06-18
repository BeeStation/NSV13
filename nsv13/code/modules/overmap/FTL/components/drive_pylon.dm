// in kPa
#define MAX_OUTPUT_PRESSURE 7500
#define MAX_WASTE_STORAGE_PRESSURE 10000

// How much to heat waste gas by, celcius
#define WASTE_GAS_HEAT 50

/// Multiplies power draw by this value every tick it remains active. Higher values will make power use increase faster
#define PYLON_ACTIVE_EXPONENT 1.02

/// how many ticks of being active are required before we start to overheat
#define ACTIVE_TIME_SAFE 90

///FTL DRIVE PYLON///
/obj/machinery/atmospherics/components/binary/drive_pylon
	name = "\improper FTL Drive Pylon"
	desc = "Used to power the main FTL manifold. Consumes frameshifted plasma and large amounts of electricity to spool up, do not touch gyros during operation."
	icon = 'nsv13/icons/obj/machinery/FTL_pylon.dmi'
	icon_state = "pylon"
	pixel_x = -32
	pixel_y = -32
	density = TRUE
	anchored = TRUE
	idle_power_usage = 500
	var/link_id = "default"
	var/gyro_speed = 0
	var/req_gyro_speed = 25
	var/shielded = FALSE
	var/mutable_appearance/pylon_shield
	var/active_time = 0 // how many ticks have we been fully active for
	var/pylon_state = PYLON_STATE_OFFLINE
	var/capacitor = 0 // capacitors charged
	var/mol_per_capacitor = 10
	var/max_charge_rate = 1 // amount of capacitors that can be charged per tick
	var/req_capacitor = 5 // amount of capacitors required to be charged for the pylon to be active
	var/power_draw = 0
	var/datum/gas_mixture/air_contents
	var/datum/gas_mixture/input // airs[1]
	var/datum/gas_mixture/output // airs[2]
	var/obj/structure/cable/cable

/obj/machinery/atmospherics/components/binary/drive_pylon/Initialize()
	. = ..()
	input = airs[1]
	output = airs[2]
	pylon_shield = mutable_appearance('nsv13/icons/obj/machinery/FTL_pylon.dmi', "pylon_shield_open")
	update_icon()
	air_contents = new(3000)
	air_contents.set_temperature(T20C)

/obj/machinery/atmospherics/components/binary/drive_pylon/process()
	if(!on)
		return
	if(!power_drain() && pylon_state != PYLON_STATE_SHUTDOWN)
		set_state(PYLON_STATE_SHUTDOWN)
		return
	if(pylon_state != PYLON_STATE_SHUTDOWN && capacitor >= req_capacitor)
		set_state(PYLON_STATE_ACTIVE)
	switch(pylon_state)
		if(PYLON_STATE_ACTIVE)
			power_draw = round(power_draw * PYLON_ACTIVE_EXPONENT + 300) // Active pylons slowly but exponentially require more charge to stay stable. Don't leave them on when you don't need to
			active_time++

		if(PYLON_STATE_STARTING) //pop the lid
			power_draw = 5000
			gyro_speed++
			if(gyro_speed >= 10)
				set_state(PYLON_STATE_WARMUP)

		if(PYLON_STATE_WARMUP) //start the spin
			var/ftl_fuel = input.get_moles(/datum/gas/frameshifted_plasma)

			if(ftl_fuel < 0.01)
				set_state(PYLON_STATE_STARTING)
				return

			input.adjust_moles(/datum/gas/frameshifted_plasma, -0.01)
			if(prob(20))
				var/datum/effect_system/spark_spread/S = new /datum/effect_system/spark_spread
				S.set_up(6, 0, src)
				S.start()
			power_draw = 20000
			gyro_speed++
			if(gyro_speed >= req_gyro_speed)
				set_state(PYLON_STATE_SPOOLING)

		if(PYLON_STATE_SPOOLING) //spinning intensifies
			var/ftl_fuel = input.get_moles(/datum/gas/frameshifted_plasma)
			if(ftl_fuel < 0.25)
				if(capacitor > 0)
					capacitor -= min(rand(0.25, 0.5)), capacitor)
				else
					set_state(PYLON_STATE_STARTING)
				return
			power_draw = 50000 // 50KW
			consume_fuel()
			if(gyro_speed < req_gyro_speed)
				set_state(PYLON_STATE_SHUTDOWN)

		if(PYLON_STATE_SHUTDOWN) //halt the spinning, close the lid
			power_draw = 0
			active_time -= active_time / gyro_speed
			capacitor -= round(capacitor / gyro_speed, 0.1)
			gyro_speed--
			if(gyro_speed <= 0)
				finalalize_shutdown()

/obj/machinery/atmospherics/components/binary/drive_pylon/proc/power_drain()
	if(power_draw <= 0)
		return TRUE
	var/turf/T = get_turf(src)
	cable = T.get_cable_node()
	if(!cable)
		return FALSE
	if(power_draw > cable.surplus())
		visible_message("<span class='warning'>\The [src] lets out an eerie clang as it's power light flickers.</span>")
		return FALSE
	cable.add_load(power_draw)
	return TRUE

/obj/machinery/atmospherics/components/binary/drive_pylon/process_atmos()
	var/i_pressure = air_contents.return_pressure()
	if(!i_pressure) // no point running other checks if we're pushing directly into output
		return
	if(i_pressure > MAX_WASTE_STORAGE_PRESSURE)
		var/turf/T = get_turf(src)
		T.assume_air(air_contents)
		explosion(T, 0, 1, 3)
		QDEL_NULL(air_contents)
		return
	var/datum/gas_mixture/output = airs[2]
	if(output.return_pressure() <= MAX_OUTPUT_PRESSURE)
		if(air_contents.pump_gas_to(output, MAX_OUTPUT_PRESSURE))
			update_parents()

/obj/machinery/atmospherics/components/binary/drive_pylon/try_enable()
	if(pylon_state == PYLON_STATE_SHUTDOWN)
		return FALSE
	var/turf/T = get_turf(src)
	cable = T.get_cable_node()
	if(!cable)
		return FALSE
	on = TRUE
	START_PROCESSING(SSmachines, src)
	pylon_state = PYLON_STATE_STARTING
	return TRUE

/obj/machinery/atmospherics/components/binary/drive_pylon/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	if(shielded)
		if(damage_type == BURN)
			damage_amount = 0
		else
			damage_amount /= 2
	return ..()

/obj/machinery/atmospherics/components/binary/drive_pylon/proc/finalalize_shutdown()
	set_state(PYLON_STATE_OFFLINE)
	power_draw = 0
	gyro_speed = 0
	active_time = 0
	capacitor = 0
	on = FALSE
	STOP_PROCESSING(SSmachines, src)

/obj/machinery/atmospherics/components/binary/drive_pylon/proc/consume_fuel()
	if(prob(30))
		tesla_zap(src, 2,  1000)
	var/input_fuel = min(input.get_moles(/datum/gas/frameshifted_plasma), max_charge_rate * mol_per_capacitor)
	capacitor += min(input_fuel / mol_per_capacitor, req_capacitor - capacitor)
	input.adjust_moles(/datum/gas/frameshifted_plasma, -input_fuel)
	var/datum/gas_mixture/waste = new
	waste.adjust_moles(/datum/gas/plasma, input_fuel / 3)
	waste.adjust_moles(/datum/gas/nucleium, input_fuel / 10)
	var/heat_increase = WASTE_GAS_HEAT
	if(shielded)
		heat_increase *= 1.5
	waste.set_temperature(input.return_temperature() + heat_increase)

	if(output.return_pressure() < MAX_OUTPUT_PRESSURE)
		air_contents.merge(waste)
	else
		output.merge(waste)
	qdel(waste) // merging doesn't delete the original merged gasmix

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
	playsound(src, 'sound/machines/blastdoor.ogg', 30, 1)
	shielded = !shielded

/// Use this when changing pylon states to avoid icon CBT
/obj/machinery/atmospherics/components/binary/drive_pylon/proc/set_state(nstate)
	if(pylon_state == nstate) // to avoid needless icon updates
		return
	pylon_state = nstate
	update_icon()

/obj/machinery/atmospherics/components/binary/drive_pylon/Destroy()
	QDEL_NULL(pylon_shield)
	var/turf/T = get_turf(src)
	if(T)
		T.assume_air(air_contents)
	QDEL_NULL(air_contents)
	return ..()

/obj/machinery/atmospherics/components/binary/drive_pylon/update_icon()
	cut_overlays()
	var/list/ov = list()
	switch(pylon_state)
		if(PYLON_STATE_OFFLINE)
			ov += "pylon_gyro"
		if(PYLON_STATE_STARTING)
			ov += "pylon_gyro_on"
		if(PYLON_STATE_WARMUP)
			ov += "pylon_gyro_on"
		if(PYLON_STATE_SPOOLING)
			ov += "pylon_gyro_on_medium"
		if(PYLON_STATE_ACTIVE)
			ov += "pylon_gyro_on_fast"
			ov += "pylon_arcing"
		if(PYLON_STATE_SHUTDOWN)
			ov += "pylon_gyro_on_medium"
	if(active_time > ACTIVE_TIME_SAFE)
		ov += "pylon_overheat"
	ov += pylon_shield
	add_overlay(ov)

#undef PYLON_STATE_OFFLINE
#undef PYLON_STATE_STARTING
#undef PYLON_STATE_WARMUP
#undef PYLON_STATE_SPOOLING
#undef PYLON_STATE_ACTIVE
#undef PYLON_STATE_SHUTDOWN

#undef MAX_WASTE_PRESSURE
#undef MAX_WASTE_STORAGE_PRESSURE

#undef PYLON_ACTIVE_EXPONENT
