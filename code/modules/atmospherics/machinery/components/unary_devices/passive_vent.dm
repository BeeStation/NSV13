/obj/machinery/atmospherics/components/unary/passive_vent
	icon_state = "passive_vent_map-2"

	name = "passive vent"
	desc = "It is an open vent."
	can_unwrench = TRUE

	level = 1
	layer = GAS_SCRUBBER_LAYER

	pipe_state = "pvent"

/obj/machinery/atmospherics/components/unary/passive_vent/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		var/image/cap = getpipeimage(icon, "vent_cap", initialize_directions, piping_layer = piping_layer)
		add_overlay(cap)
	icon_state = "passive_vent"

/obj/machinery/atmospherics/components/unary/passive_vent/process_atmos()
	..()
	var/datum/gas_mixture/environment = loc.return_air()
	var/datum/gas_mixture/air_contents = airs[1]

	var/environment_pressure = environment.return_pressure()

	var/pressure_delta = min(50*ONE_ATMOSPHERE, (air_contents.return_pressure() - environment.return_pressure()))

	if((environment.return_temperature() || air_contents.return_temperature()) && pressure_delta > 0.5)
		if(environment_pressure < air_contents.return_pressure())
			var/air_temperature = (environment.return_temperature() > 0) ? environment.return_temperature() : air_contents.return_temperature()
			var/transfer_moles = CLAMP((pressure_delta * environment.return_volume()) / (air_temperature * R_IDEAL_GAS_EQUATION),0, 50*ONE_ATMOSPHERE)
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)
			loc.assume_air(removed)
			air_update_turf()
		else
			if(air_contents.return_pressure() >= 50*ONE_ATMOSPHERE)//Sanity checks
				return FALSE
			var/air_temperature = (air_contents.return_temperature() > 0) ? air_contents.return_temperature() : environment.return_temperature()
			var/output_volume = air_contents.return_volume()
			var/transfer_moles = (pressure_delta * output_volume) / (air_temperature * R_IDEAL_GAS_EQUATION)
			transfer_moles = min(transfer_moles, environment.total_moles() * air_contents.return_volume()/environment.return_volume())
			var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)
			if(isnull(removed))
				return
			air_contents.merge(removed)
			air_update_turf()
	update_parents()

/obj/machinery/atmospherics/components/unary/passive_vent/can_crawl_through()
	return TRUE

/obj/machinery/atmospherics/components/unary/passive_vent/layer1
	piping_layer = 1
	icon_state = "passive_vent_map-1"

/obj/machinery/atmospherics/components/unary/passive_vent/layer3
	piping_layer = 3
	icon_state = "passive_vent_map-3"
