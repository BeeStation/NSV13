#define SILO_LEAK_PRESSURE (25 * ONE_ATMOSPHERE)
#define SILO_EXPLODE_PRESSURE (27 * ONE_ATMOSPHERE)

// Lower values will make increased power efficiency returns diminish quicker
#define EFFICIENCY_BASE 0.05

// Lowest possible conversion efficiency
#define EFFICIENCY_MIN 65

/obj/machinery/atmospherics/components/binary/silo
	name = "\improper Nucleium-Plasma Frame Refiner"
	desc = "An incredibly advanced and power hungry machine capable of folding matter into itself. Usually used in the production of FTL drive fuel."
	icon = 'nsv13/icons/obj/machinery/FTL_silo.dmi'
	icon_state = "silo"
	max_integrity = 600
	pixel_x = -32
	pixel_y = -32
	var/converting = FALSE
	var/outputting = FALSE
	var/conversion_limit = 10 // max amount of moles that can be converted (input) per tick
	var/conversion_ratio = 0.5 // base input/output ratio. Effected by power efficiency

	var/min_power_draw = 70000 // min power use required for function
	var/target_power_draw = 0 // desired power use
	var/current_power_draw = 0 // power used last tick

	var/pressure_integrity = 4
	var/explosion_chance = 0 // Chance of vessel exploding, increases after passing SILO_EXPLODE_PRESSURE

	var/obj/structure/cable/cable
	var/datum/gas_mixture/air_contents
	var/datum/gas_mixture/input
	var/datum/gas_mixture/output

/obj/machinery/atmospherics/components/binary/silo/New()
	..()
	input = airs[1]
	output = airs[2]
	air_contents = new(10000)
	air_contents.set_temperature(T20C)

	var/turf/T = get_turf(src)
	cable = T.get_cable_node()

	update_parents()

/obj/machinery/atmospherics/components/binary/silo/Destroy()
	if(air_contents.total_moles())
		var/turf/T = get_turf(src)
		T.assume_air(air_contents)
		T.air_update_turf()
		QDEL_NULL(air_contents)
	return ..()

/obj/machinery/atmospherics/components/binary/silo/proc/transmute_fuel()
	if(!cable)
		return FALSE
	var/input_fuel = min(input.get_moles(/datum/gas/nucleium), conversion_limit)
	if(input_fuel < 0.1)
		return FALSE
	air_contents.adjust_moles(/datum/gas/frameshifted_plasma, input_fuel * (conversion_ratio * get_efficiency()))
	air_contents.set_temperature(air_contents.temperature_share(input))
	input.adjust_moles(/datum/gas/nucleium, -input_fuel)
	return TRUE

/obj/machinery/atmospherics/components/binary/silo/proc/get_efficiency()
	var/grid_power = min(cable.surplus(), current_power_draw)
	return max((grid_power ** EFFICIENCY_BASE - 1) * 100, EFFICIENCY_MIN)

/obj/machinery/atmospherics/components/binary/silo/proc/power_drain()
	if(min_power_draw <= 0)
		return TRUE
	if(!cable)
		return FALSE
	if(cable.loc != loc)
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

// Handles power use
/obj/machinery/atmospherics/components/binary/silo/process()
	if(converting && !power_drain())
		converting = FALSE
		current_power_use = 0

/obj/machinery/atmospherics/components/binary/silo/process_atmos()
	// PRESSURE! Pushing down on me
	var/i_pressure = air_contents.return_pressure() // internal pressure
	if(i_pressure > SILO_EXPLODE_PRESSURE)
		if(prob(explosion_chance))
			kaboom(i_pressure)
		else
			explosion_chance += 0.5
		return
	if(explosion_chance > 0)
		explosion_chance--
	if(i_pressure > SILO_LEAK_PRESSURE)
		if(prob(40))
			switch(rand(1, 3))
				if(1)
					audible_message("<span class='danger'>\The [src] resonates an ominous creak.</span>")
				if(2)
					visible_message("<span class='danger>\The [src] shakes violently!</span>")
				if(3)
					visible_message("<span class='danger>\The [src]'s chassis begins to bulge.</span>")
		else
			if(prob(20))
				playsound(src, 'nsv13/sound/effects/rbmk/alarm.ogg', 100, TRUE)
			var/turf/T = get_turf(src)
			var/datum/gas_mixture/leak = air_contents.remove_ratio(rand(0.05, 0.15))
			T.assume_air(leak)
			qdel(leak)
			playsound(src, 'sound/effects/spray.ogg', 100, TRUE)
			if(pressure_integrity)
				pressure_integrity--

	// Actual refining stuff xD
	if(!is_operational())
		return
	if(converting)
		transmute_fuel()
	if(outputting)
		var/o_pressure = output.return_pressure() // output pressure
		if(o_pressure > MAX_OUTPUT_PRESSURE)
			return
		if(air_contents.pump_gas_to(output, clamp(output, 0, MAX_OUTPUT_PRESSURE - o_pressure)))
			update_parents()

/obj/machinery/atmospherics/components/binary/silo/proc/kaboom(pressure)
	var/turf/T = get_turf(src)
	var/multiplier = 1
	if(air_contents.get_moles(/datum/gas/frameshifted_plasma) > 400) // something something rapid spacetime expansion something frame drag
		multiplier = 1.5
	T.assume_air(air_contents)
	air_contents.clear()
	var/V2 = round(2 + (pressure - SILO_EXPLODE_PRESSURE) / 300) * multiplier // Every 300 kpa over the threshold will increase the range by one
	explosion(T, V2/4, V2/2, V2, V2*1.5, ignorecap = TRUE) // >:)
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
			converting = !converting
			visible_message("<span class='notice'>Transmutation process [converting ? "starting" : "shutting down"]</span>")
		if("target_power")
			target_power_draw = max(text2num(params["target"]), min_power_draw)

/obj/machinery/atmospherics/components/binary/silo/ui_data(mob/user)
	var/list/data = list()
	data["active"] = converting
	data["target_power"] = target_power_draw
	data["current_power"] = current_power_draw
	data["min_power"] = min_power_draw
	data["max_power"] = cable?.surplus()
	data["pressure"] = air_contents.return_pressure() / SILO_LEAK_PRESSURE
	data["stat"] = "Online"
	if(!cable)
		data["stat"] = "Power Failure"
	else if(!converting)
		data["stat"] = "Offline"
	return data
