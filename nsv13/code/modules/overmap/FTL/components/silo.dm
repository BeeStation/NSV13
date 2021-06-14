#define SILO_LEAK_PRESSURE (25 * ONE_ATMOSPHERE)
#define SILO_EXPLODE_PRESSURE (27 * ONE_ATMOSPHERE)

/obj/machinery/atmospherics/components/binary/ftl/silo
	name = "\improper Nucleium-Plasma Frame Refiner"
	desc = "An incredibly advanced and power hungry machine capable of folding matter into itself. Usually used in the production of FTL drive fuel."
	icon = 'nsv13/icons/obj/machinery/FTL_silo.dmi'
	icon_state = "silo"
	max_integrity = 600
	var/max_pressure = 30 * ONE_ATMOSPHERE
	var/outputting = FALSE
	var/volume = 1000
	var/conversion_limit = 10 // max amount of moles that can be converted (input) per tick
	var/conversion_ratio = 0.5 // base input/output ratio. Effected by power efficiency
	var/target_power_draw = 0
	var/target_conversion = 0 // 0-100, refining capacity percentage
	var/pressure_integrity = 4
	var/explosion_chance = 0 // Chance of vessel exploding, increases after passing SILO_EXPLODE_PRESSURE

/obj/machinery/atmospherics/components/binary/ftl/silo/New()
	..()
	air_contents = new(volume)
	air_contents.set_temperature(T20C)
	update_parents()

/obj/machinery/atmospherics/components/binary/ftl/silo/Destroy()
	if(air_contents?.total_moles())
		var/turf/T = get_turf(src)
		T.assume_air(air_contents)
		T.air_update_turf()
		QDEL_NULL(air_contents)
	return ..()

/obj/machinery/atmospherics/components/binary/ftl/silo/proc/transmute_fuel()
	if(!cable)
		return FALSE
	var/datum/gas_mixture/air1 = airs[1] // nucleium, hopefully
	var/input_fuel = min(air1.get_moles(/datum/gas/nucleium), conversion_limit)
	var/grid_power = min(cable.surplus(), current_power_draw)
	if(input_fuel < 0.1 || grid_power < min_power_draw)
		return FALSE
	air_contents.adjust_moles(/datum/gas/frameshifted_plasma, input_fuel * (conversion_ratio * get_efficiency(grid_power)))
	air_contents.set_temperature(air_contents.temperature_share(air1))
	air1.adjust_moles(/datum/gas/nucleium, -input_fuel)
	return TRUE

/obj/machinery/atmospherics/components/binary/ftl/silo/process_atmos()

	// PRESSURE! Pushing down on me
	var/i_pressure = air_contents.return_pressure() // internal pressure
	if(i_pressure > SILO_EXPLODE_PRESSURE)
		if(prob(explosion_chance))
			var/turf/T = get_turf(src)
			var/multiplier = 1
			if(air_contents.get_moles(/datum/gas/frameshifted_plasma) > 400) // something something rapid spacetime expansion creating a frame drag effect
				multiplier = 1.5
			T.assume_air(air_contents)
			air_contents.clear()
			var/V2 = round(2 + (i_pressure - SILO_EXPLODE_PRESSURE) / 300) * multiplier // Every 300 kpa over the threshold will increase the range by one
			explosion(T, V2/4, V2/2, V2, V2*1.5, ignorecap = TRUE) // >:)
			qdel(src)
		else
			explosion_chance++
		return
	if(explosion_chance > 0)
		explosion_chance--
	if(i_pressure > SILO_LEAK_PRESSURE)
		if(prob(40))
			switch(rand(1, 3))
				if(1)
					audible_message("<span class='danger'>\The [src] resonates an ominous creak.</span>")
				if(2)
					visible_message("<span class ='danger>\The [src] shakes violently!</span>")
				if(3)
					visible_message("<span class ='danger>\The [src]'s chassis begins to bulge.</span>")
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
	if(!on || !is_operational())
		return
	if(target_conversion)
		transmute_fuel()
	if(outputting)
		var/datum/gas_mixture/OP = airs[2]
		var/o_pressure = OP.return_pressure() // output pressure
		if(o_pressure > MAX_OUTPUT_PRESSURE)
			return
		if(air_contents.pump_gas_to(OP, clamp(outputting, 0, MAX_OUTPUT_PRESSURE - o_pressure)))
			update_parents()
