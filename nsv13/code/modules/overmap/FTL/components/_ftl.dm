// parent handler for drives and silos, saves some copy paste
/obj/machinery/atmospherics/components/binary/ftl
	name = "atmospheric FTL component"
	desc = "Yell at mappers if you see this."
	var/obj/structure/cable/cable // connected cable
	var/datum/gas_mixture/air_contents
	var/power_warning_sound = "an eerie clang"
	var/targ_power_draw = 0
	var/current_power_draw = 0
	var/min_power_draw = 0
	// Not to be confused with the minimuim efficiency. This is what the wattage is held to the power of.
	// Lower values will make returns diminish quicker
	var/efficiency_base = 0.05
	// Lowest possible efficiency
	var/min_efficiency = 65

/obj/machinery/atmospherics/components/binary/ftl/proc/get_efficiency(power)
	return max((power ** efficiency_base - 1) * 100, min_efficiency)

/obj/machinery/atmospherics/components/binary/ftl/proc/try_enable()
	var/turf/T = get_turf(src)
	cable = T.get_cable_node()
	if(!cable)
		return FALSE
	on = TRUE
	START_PROCESSING(SSmachines, src)
	return TRUE

/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/proc/power_drain()
	if(min_power_draw <= 0)
		return TRUE
	var/turf/T = get_turf(src)
	cable = T.get_cable_node()
	if(!cable)
		return FALSE
	current_power_draw = max(targ_power_draw, min_power_draw)
	if(current_power_draw > cable.surplus())
		visible_message("<span class='warning'>\The [src] lets out [power_warning_sound] as it's power light flickers.</span>")
		return FALSE
	cable.add_load(current_power_draw)
	return TRUE
