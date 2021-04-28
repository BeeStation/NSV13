/// Not to be confused with the minimuim, or the pylon defines. This is what the wattage is held to the power of.
/// Lower values will make returns more diminishing quicker
#define SILO_EFFICIENCY_BASE 0.05
/// Lowest possible silo efficiency
#define SILO_EFFICIENCY_MIN 45

/obj/machinery/atmospherics/components/binary/ftl_silo
	name = "Nucleium-Plasma Frame Refiner"

/obj/machinery/atmospherics/components/binary/ftl_silo/proc/transmute_fuel()
	var/datum/gas_mixture/air1 = airs[1] // nucleium
	var/datum/gas_mixture/air2 = airs[2] // FTL fuel
	if(C && air2.return_pressure() > MAX_OUTPUT_PRESSURE)
		return FALSE
	var/input_fuel = min(air1.get_moles(/datum/gas/nucleium), conversion_limi)
	var/grid_power = min(C.surplus(), current_power_draw)
	if(input_fuel < 0.1 || grid_power < min_power_draw)
		return FALSE
	air2.adjust_moles(/datum/gas/frameshifted_plasma, input_fuel / get_efficiency(grid_power))
	air2.set_temperature(air1.return_temperature())
	air1.adjust_moles(/datum/gas/nucleium, -input_fuel)
	return TRUE

/obj/machinery/atmospherics/components/unary/ftl_silo/proc/get_efficiency(power)
	return max((power ** SILO_EFFICIENCY_BASE - 1) * 100, SILO_EFFICIENCY_MIN)
