/obj/machinery/atmospherics/components/binary/ftl/silo
	name = "\improper Nucleium-Plasma Frame Refiner"
	desc = "An incredibly advanced and power hungry machine capable of folding matter into itself. Usually used in the production of FTL drive fuel."
	icon = 'nsv13/icons/obj/machinery/FTL_silo.dmi'
	icon_state = "silo"
	var/obj/structure/cable/C
	var/datum/gas_mixture/air_contents
	var/volume = 1000
	var/conversion_limit = 10 // max amount of moles that can be converted (input) per tick
	var/conversion_ratio = 0.5 // base input/output ratio. Effected by power efficiency
	var/min_power_draw = 0
	var/current_power_draw = 0
	var/target_power_draw = 0

/obj/machinery/atmospherics/components/binary/ftl/silo/New()
	..()
	var/datum/gas_mixture/air_contents = New(volume)
	air_contents.volume = volume
	air_contents.set_temperature(T20C)
	update_parents()

/obj/machinery/atmospherics/components/binary/ftl/silo/Destroy()
	var/turf/T = get_turf(src)
	T.assume_air(air_contents)
	T.air_update_turf()
	QDEL_NULL(air_contents)
	return ..()

/obj/machinery/atmospherics/components/binary/ftl/silo/proc/transmute_fuel()
	var/datum/gas_mixture/air1 = airs[1] // nucleium
	var/datum/gas_mixture/air2 = airs[2] // FTL fuel
	if(C && air2.return_pressure() > MAX_OUTPUT_PRESSURE)
		return FALSE
	var/input_fuel = min(air1.get_moles(/datum/gas/nucleium), conversion_limit)
	var/grid_power = min(C.surplus(), current_power_draw)
	if(input_fuel < 0.1 || grid_power < min_power_draw)
		return FALSE
	air2.adjust_moles(/datum/gas/frameshifted_plasma, input_fuel * (conversion_ratio * get_efficiency(grid_power))
	air2.set_temperature(air1.return_temperature())
	air1.adjust_moles(/datum/gas/nucleium, -input_fuel)
	return TRUE

/obj/machinery/atmospherics/components/binary/ftl/silo/proc/get_efficiency(power)
	return max((power ** SILO_EFFICIENCY_BASE - 1) * 100, SILO_EFFICIENCY_MIN)
