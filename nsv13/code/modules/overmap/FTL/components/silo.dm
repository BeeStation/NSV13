#define SILO_MODE_IDLE 0
#define SILO_MODE_CONVERT 1
#define SILO_MODE_OUTPUT 2

#define SILO_LEAK_PRESSURE (25 * ONE_ATMOSPHERE)
#define SILO_EXPLODE_PRESSURE (27 * ONE_ATMOSPHERE)

// Lower values will make increased power efficiency returns diminish quicker
#define EFFICIENCY_BASE 0.05

// Lowest possible conversion efficiency
#define EFFICIENCY_MIN 65

/obj/machinery/atmospherics/components/binary/silo
	name = "\improper Nucleium-Plasma Frame Refiner"
	desc = "An incredibly advanced (and power hungry) refinery capable of folding plasma into itself. Commonly used in the production of Nucleium."
	icon = 'nsv13/icons/obj/machinery/FTL_silo.dmi'
	icon_state = "silo"
	max_integrity = 600
	pixel_x = -32
	bound_x = -32
	bound_width = 96
	initialize_directions = WEST|EAST
	density = TRUE
	layer = ABOVE_MOB_LAYER
	var/mode = SILO_MODE_IDLE
	var/lastmode = SILO_MODE_CONVERT
	var/conversion_limit = 10 // max amount of moles that can be converted (input) per tick
	var/conversion_ratio = 0.5 // base input/output ratio. Effected by power efficiency

	var/min_power_draw = 70000 // min power use required for function in watts
	var/target_power_draw = 0 // desired power use
	var/current_power_draw = 0 // power used last tick

	var/pressure_integrity = 15
	var/explosion_chance = 0 // Chance of vessel exploding, increases after passing SILO_EXPLODE_PRESSURE
	var/noleak = FALSE // Whether to perform atmos leaking on destruction, should be enabled if contents have already been emptied by other means (i.e explosion)

	var/mutable_appearance/bulb
	var/mutable_appearance/mode_ring


	var/obj/structure/cable/cable
	var/datum/gas_mixture/air_contents

/obj/machinery/atmospherics/components/binary/silo/Initialize()
	. = ..()
	air_contents = new(10000)
	air_contents.set_temperature(T20C)

	var/turf/T = get_turf(src)
	cable = T.get_cable_node()
	update_parents()
	START_PROCESSING(SSmachines, src)
	add_overlay("screen_on")


/obj/machinery/atmospherics/components/binary/silo/Destroy()
	STOP_PROCESSING(SSmachines, src)
	qdel(bulb)
	qdel(mode_ring)
	if(noleak)
		QDEL_NULL(air_contents)
		return ..()
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

/obj/machinery/atmospherics/components/binary/silo/SetInitDirections()
	initialize_directions = initial(initialize_directions)

/obj/machinery/atmospherics/components/binary/silo/proc/transmute_fuel()
	var/datum/gas_mixture/input = airs[1]
	if(!cable)
		return FALSE
	var/input_trit = min(input.get_moles(GAS_TRITIUM), 70)
	var/input_fuel = min(input.get_moles(GAS_PLASMA), conversion_limit)
	if(input_fuel < 0.1)
		return FALSE
	var/transmutated = input_fuel * (conversion_ratio * get_efficiency())
	if(input_trit)
		transmutated *= 0.5 * (input_trit ** 0.725) + 1
		input.adjust_moles(GAS_TRITIUM, -input_trit)
	air_contents.adjust_moles(GAS_NUCLEIUM, transmutated)
	air_contents.set_temperature(air_contents.temperature_share(input))
	input.adjust_moles(GAS_PLASMA, -input_fuel)
	return TRUE

/obj/machinery/atmospherics/components/binary/silo/proc/get_efficiency()
	var/grid_power = min(cable.surplus(), current_power_draw)
	return max((grid_power ** EFFICIENCY_BASE - 1) * 100, EFFICIENCY_MIN)

/obj/machinery/atmospherics/components/binary/silo/proc/power_drain()
	if(min_power_draw <= 0)
		return TRUE
	if(!cable || cable.loc != loc) // in case we or the cable (somehow) moved
		var/turf/T = get_turf(src)
		cable = T.get_cable_node()
		if(!cable)
			return FALSE

	current_power_draw = max(target_power_draw, min_power_draw)
	if(current_power_draw > cable.surplus())
		visible_message("<span class='warning'>\The [src] lets out a metallic rumble as it's power light flickers.</span>")
		return FALSE
	cable.add_load(current_power_draw)
	return TRUE

// Handles power draw
/obj/machinery/atmospherics/components/binary/silo/process()
	if(mode == SILO_MODE_CONVERT && !power_drain())
		mode = SILO_MODE_IDLE
		current_power_draw = 0

/obj/machinery/atmospherics/components/binary/silo/process_atmos()
	// PRESSURE! Pushing down on me!
	var/i_pressure = air_contents.return_pressure()
	if(pressure_integrity <= 0 || i_pressure >= SILO_EXPLODE_PRESSURE)
		if(prob(explosion_chance))
			kaboom(i_pressure) // Pushing down on you!
			return
		else
			explosion_chance += 5
			if(prob(30))
				playsound(src, 'nsv13/sound/effects/metal_clang.ogg', 100, TRUE, 6)
	else if(explosion_chance > 0)
		explosion_chance -= min(5, explosion_chance)
	switch(i_pressure)
		if(SILO_LEAK_PRESSURE to INFINITY)
			bulb.icon_state = "status_alert"
			switch(rand(1, 10))
				if(1 to 2)
					visible_message("<span class='danger>\The [src]'s chassis begins to bulge.</span>")
				if(3)
					visible_message("<span class='danger>\The [src] shakes violently!</span>")
				if(4)
					audible_message("<span class='danger'>\The [src] resonates an ominous creak.</span>")
				if(5 to 6)
					playsound(src, 'nsv13/sound/effects/rbmk/alarm.ogg', 100, TRUE)
					var/turf/T = get_turf(src)
					var/datum/gas_mixture/leak = air_contents.remove_ratio(rand(0.05, 0.15))
					T.assume_air(leak)
					qdel(leak)
					playsound(src, 'sound/effects/spray.ogg', 100, TRUE)
					if(pressure_integrity > 0)
						pressure_integrity--
		if(SILO_LEAK_PRESSURE * 0.75 to SILO_LEAK_PRESSURE)
			bulb.icon_state = "status_alert"
		if(SILO_LEAK_PRESSURE * 0.5 to SILO_LEAK_PRESSURE * 0.75)
			bulb.icon_state = "status_caution"
		else
			bulb.icon_state = "status_ok"

	// Actual refining stuff lmao
	if(!is_operational())
		return
	switch(mode)
		if(SILO_MODE_CONVERT)
			transmute_fuel()

		if(SILO_MODE_OUTPUT)
			var/datum/gas_mixture/output = airs[2]
			var/o_pressure = output.return_pressure() // output pressure
			if(o_pressure > MAX_OUTPUT_PRESSURE)
				return
			var/transfer_moles = (MAX_OUTPUT_PRESSURE - o_pressure) * output.return_volume()/(air_contents.return_temperature() * R_IDEAL_GAS_EQUATION)
			if(air_contents.transfer_to(output, transfer_moles))
				update_parents()

/obj/machinery/atmospherics/components/binary/silo/proc/kaboom(pressure)
	var/turf/T = get_turf(src) // defaultis to our own turf incase we're unable to find a valid candidate
	var/turf/open/floor/newT
	for(var/i in 1 to 6) // a fun way to roll the dice
		newT = locate(x + rand(-20, 20), y + rand(-20, 20), z)
		if(newT && istype(newT) && newT.air?.return_pressure())
			T = newT
			break
	var/multiplier = 1
	if(air_contents.get_moles(GAS_NUCLEIUM) > 400) // something something spacetime expansion
		multiplier = 1.5
	playsound(src, 'nsv13/sound/effects/metal_clang.ogg', 100, FALSE, 6)
	if(T != loc)
		do_sparks(5, FALSE, T)
		playsound(T, 'nsv13/sound/effects/metal_clang.ogg', 100, FALSE, 6)
	T.assume_air(air_contents)
	air_contents.clear()
	var/V2 = round(2 + (pressure - SILO_LEAK_PRESSURE) / 200) * multiplier // Every 200 kpa over the threshold will increase the range by one
	noleak = TRUE
	explosion(T, V2/4, V2/2, V2, V2*1.5, ignorecap = TRUE) // >:)
	if(!QDELETED(src)) // In case we somehow survive the 'splosion
		qdel(src)

/obj/machinery/atmospherics/components/binary/silo/attack_hand(mob/user)
	ui_interact(user)
	return ..()

/obj/machinery/atmospherics/components/binary/silo/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	ui = new(user, src, "FTLSilo")
	ui.open()

/obj/machinery/atmospherics/components/binary/silo/ui_act(action, params, datum/tgui/ui)
	. = ..()
	playsound(src, 'nsv13/sound/effects/computer/scroll_start.ogg', 100, 1)
	switch(action)
		if("toggle_power")
			if(mode == SILO_MODE_IDLE)
				mode = lastmode
			else
				lastmode = mode
				mode = SILO_MODE_IDLE
			visible_message("<span class='notice'>Refinery [mode ? "starting" : "shutting down"]</span>")
		if("target_power")
			target_power_draw = round(max(text2num(params["target"]), min_power_draw) * 1000, 1)
		if("toggle_mode")
			if(mode == SILO_MODE_CONVERT)
				mode = SILO_MODE_OUTPUT
			else if(mode == SILO_MODE_OUTPUT)
				mode = SILO_MODE_CONVERT

/obj/machinery/atmospherics/components/binary/silo/ui_data(mob/user)
	var/list/data = list()
	data["active"] = mode != SILO_MODE_IDLE
	data["converting"] = mode == SILO_MODE_CONVERT
	data["target_power"] = round(target_power_draw / 1000, 1) // converts to KW
	data["current_power"] = round(current_power_draw / 1000, 1)
	data["min_power"] = min_power_draw
	data["max_power"] = cable?.surplus()
	data["pressure"] = air_contents.return_pressure() / SILO_LEAK_PRESSURE
	data["integrity"] = pressure_integrity / initial(pressure_integrity)
	if(!cable)
		data["stat"] = "Power Error"
	else
		switch(mode)
			if(SILO_MODE_IDLE)
				data["stat"] = "Idle"
			if(SILO_MODE_CONVERT)
				data["stat"] = "Refining"
			if(SILO_MODE_OUTPUT)
				data["stat"] = "Draining"
	return data

/obj/machinery/atmospherics/components/binary/silo/proc/set_mode(new_mode)
	if(mode == new_mode)
		return
	mode = new_mode
	switch(mode)
		if(SILO_MODE_IDLE)
			mode_ring.icon_state = "idle"
		if(SILO_MODE_CONVERT)
			mode_ring.icon_state = "transmute"
		if(SILO_MODE_OUTPUT)
			mode_ring.icon_state = "output"

#undef SILO_MODE_IDLE
#undef SILO_MODE_CONVERT
#undef SILO_MODE_OUTPUT
#undef SILO_LEAK_PRESSURE
#undef SILO_EXPLODE_PRESSURE
#undef EFFICIENCY_BASE
#undef EFFICIENCY_MIN
