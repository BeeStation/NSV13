#define PYLON_STATE_OFFLINE 0
#define PYLON_STATE_STARTING 1
#define PYLON_STATE_WARMUP 2
#define PYLON_STATE_SPOOLING 3
#define PYLON_STATE_SHUTDOWN 4
#define PYLON_STATE_ACTIVE 5

#define ENABLE_SUCCESS 1
#define ENABLE_FAIL_POWER 2
#define ENABLE_FAIL_COOLDOWN 3


/// Not to be confused with the minimuim. This is what the wattage is held to the power of.
/// Lower values will make returns more diminishing quicker
#define PYLON_EFFICIENCY_BASE 0.05
/// Lowest possible pylon efficiency
#define PYLON_EFFICIENCY_MIN 65

///FTL DRIVE PYLON///

/obj/machinery/atmospherics/components/unary/ftl_drive_pylon
	name = "\improper FTL Drive Pylon"
	desc = "Words about the spinny boy"
	icon = 'nsv13/icons/obj/machinery/FTL_pylon.dmi'
	icon_state = "pylon"
	pixel_x = -16
	pixel_y = -16
	density = TRUE
	anchored = TRUE
//	idle_power_usage = 250
//	active_power_usage = 5000 // peak usage - this gets changed per state
	var/shutdown_timer = null // shutdown timer, if any
	var/targ_power_draw = 0
	var/current_power_draw = 0
	var/min_power_draw = 0
	var/obj/structure/cable/C // connected cable
	var/burn_limit = 5 // max amount of moles that can be used per tick
	var/pylon_state = PYLON_STATE_OFFLINE
	var/capacitor = 0
	var/req_capacitor = 5 // amount of capacitor charges needed to fully spool up the pylon
	var/debug = FALSE // disables power requirements


/obj/machinery/atmospherics/components/unary/ftl_drive_pylon/process()
	if(!on)
		pylon_state = PYLON_STATE_OFFLINE
		return
	switch(pylon_state)
		if(PYLON_STATE_ACTIVE)
			min_power_draw = 70000 // 70KW
			consume_fuel()

		if(PYLON_STATE_OFFLINE) //here we begin the startup proceedure
			min_power_draw = 250

		if(PYLON_STATE_STARTING) //pop the lid
			min_power_draw = 500

		if(PYLON_STATE_WARMUP) //start the spin
			var/datum/gas_mixture/air1 = airs[1]
			var/ftl_fuel = air1.get_moles(/datum/gas/frameshifted_plasma)

			if(ftl_fuel < 0.01)
				pylon_state = PYLON_STATE_STARTING
				update_icon()
				continue

			air1.adjust_moles(/datum/gas/frameshifted_plasma, -0.01)
			if(prob(20))
				var/datum/effect_system/spark_spread/S = new /datum/effect_system/spark_spread
				S.set_up(6, 0, src)
				S.start()
			update_icon()
			min_power_draw = 2000

		if(PYLON_STATE_SPOOLING) //spinning intensifies
			var/datum/gas_mixture/air1 = airs[1]
			var/ftl_fuel = air1.get_moles(/datum/gas/frameshifted_plasma)
			if(ftl_fuel < 0.25)
				if(capacitor > 0)
					capacitor--
				else
					pylon_state = PYLON_STATE_STARTING
					update_icon()
				continue
			air1.adjust_moles(/datum/gas/frameshifted_plasma, -0.25)
			update_icon()
			min_power_draw = 50000 // 50KW
			if(capacitor < req_capacitor)
				capacitor ++
				if(prob(30))
					tesla_zap(src, 2,  1000)
				update_icon()
			else
				pylon_state = PYLON_STATE_ACTIVE

		if(PYLON_STATE_SHUTDOWN) //halt the spinning, close the lid
			min_power_draw = 500
			shutdown_timer = addtimer(VARSET_CALLBACK(src, on, FALSE), 10 SECONDS)
			return PROCESS_KILL
	power_drain()

/obj/machinery/atmospherics/components/unary/ftl_drive_pylon/proc/try_enable()
	var/turf/T = get_turf(src)
	C = T.get_cable_node()
	if(!C)
		return ENABLE_FAIL_POWER
	on = TRUE
	if(shutdown_timer)
		return ENABLE_FAIL_COOLDOWN
	START_PROCESSING(SSmachines, src)
	return ENABLE_SUCCESS

/obj/machinery/atmospherics/components/unary/ftl_drive_pylon/proc/consume_fuel()
	var/datum/gas_mixture/air1 = airs[1] // FTL fuel
	var/input_fuel = min(air1.get_moles(/datum/gas/frameshifted_plasma), burn_limit)
	var/grid_power = min(C.surplus(), current_power_draw)
	if(input_fuel < 0.1 || grid_power < min_power_draw)
		return FALSE
	air2.adjust_moles(/datum/gas/frameshifted_plasma, input_fuel / get_efficiency(grid_power))
	air2.set_temperature(air1.return_temperature())
	air1.adjust_moles(/datum/gas/nucleium, -input_fuel)
	return TRUE

/obj/machinery/atmospherics/components/unary/ftl_silo/proc/get_efficiency(power)
	return max((power ** PYLON_EFFICIENCY_BASE - 1) * 100, PYLON_EFFICIENCY_MIN)

/obj/machinery/atmospherics/components/unary/ftl_drive_pylon/proc/power_drain()
	if(debug)
		return TRUE
	var/turf/T = get_turf(src)
	C = T.get_cable_node()
	if(!C)
		pylon_state = PYLON_STATE_SHUTDOWN
		return
	current_power_draw = max(targ_power_draw, min_power_draw)
	if(current_power_draw > C.surplus())
		visible_message("<span class='warning'>\The [src] lets out ghostly metallic hum as it's power light flickers.</span>")
		pylon_state = PYLON_STATE_SHUTDOWN
		return
	C.add_load(current_power_draw)

#undef PYLON_STATE_OFFLINE
#undef PYLON_STATE_STARTING
#undef PYLON_STATE_WARMUP
#undef PYLON_STATE_SPOOLING
#undef PYLON_STATE_ACTIVE
#undef PYLON_STATE_SHUTDOWN

#undef ENABLE_SUCCESS
#undef ENABLE_FAIL_POWER
#undef ENABLE_FAIL_COOLDOWN

#undef PYLON_EFFICIENCY_BASE
#undef PYLON_EFFICIENCY_MIN
