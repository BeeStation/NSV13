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
/// Multiplies power draw by this value every tick it remains active. Higher values will make power use increase faster
#define PYLON_ACTIVE_EXPONENT 1.02

/// how many ticks of being active are required before we start to overheat
#define ACTIVE_TIME_WARNING 90

///FTL DRIVE PYLON///
/obj/machinery/atmospherics/components/binary/ftl/drive_pylon
	name = "\improper FTL Drive Pylon"
	desc = "Words about the spinny boy"
	icon = 'nsv13/icons/obj/machinery/FTL_pylon.dmi'
	icon_state = "pylon"
	pixel_x = -16
	pixel_y = -16
	density = TRUE
	anchored = TRUE
	idle_power_usage = 500

	var/shielded = TRUE // is the shield down?
	var/animation_timer = null
	var/active_time = 0 // how many ticks have we been fully active for
	var/active_time_warning = 60
	var/pylon_state = PYLON_STATE_OFFLINE
	var/capacitor = 0
	var/mol_per_capacitor = 10
	var/max_charge_rate = 1 // amount of capacitors that can be charged per tick
	var/req_capacitor = 5 // amount of capacitors charged


/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/process()
	if(!on)
		return
	if(pylon_state != PYLON_STATE_ACTIVE && capacitor >= req_capacitor)
		pylon_state = PYLON_STATE_ACTIVE
		update_icon()

	switch(pylon_state)
		if(PYLON_STATE_ACTIVE)
			min_power_draw = round(min_power_draw * PYLON_ACTIVE_EXPONENT + 300) // Active pylons slowly but exponentially require more charge to stay stable. Don't leave them on when you don't need to
			active_time++
		if(PYLON_STATE_OFFLINE)
			min_power_draw = 200

		if(PYLON_STATE_STARTING) //pop the lid
			min_power_draw = 5000
			update_icon()

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
			min_power_draw = 20000

		if(PYLON_STATE_SPOOLING) //spinning intensifies
			var/datum/gas_mixture/air1 = airs[1]
			var/ftl_fuel = air1.get_moles(/datum/gas/frameshifted_plasma)
			if(ftl_fuel < 0.25)
				if(capacitor > 0)
					capacitor -= min((1 / rand(2, 5)), capacitor)
				else
					pylon_state = PYLON_STATE_STARTING
					update_icon()
				continue
			min_power_draw = 50000 // 50KW
			air1.adjust_moles(/datum/gas/frameshifted_plasma, -0.25)
			consume_fuel()

		if(PYLON_STATE_SHUTDOWN) //halt the spinning, close the lid
			min_power_draw = 500
			active_time = 0
			shutdown_timer = addtimer(VARSET_CALLBACK(src, pylon_state, PYLON_STATE_OFFLINE), 10 SECONDS)
			return PROCESS_KILL

	power_drain()

/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/proc/consume_fuel()
	var/datum/gas_mixture/air1 = airs[1] // FTL fuel
	var/grid_power = min(C.surplus(), current_power_draw)
	if(grid_power < min_power_draw)
		return FALSE
	if(prob(30))
		tesla_zap(src, 2,  1000)
	var/input_fuel = min(air1.get_moles(/datum/gas/frameshifted_plasma), max_charge_rate * mol_per_capacitor)
	capacitor += (input_fuel * get_efficiency(current_power_draw)) / mol_per_capacitor
	air1.adjust_moles(/datum/gas/frameshifted_plasma, -input_fuel)
	return TRUE

/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/proc/toggle_shield()
	if(timeleft(animation_timer))
		return
	shielded = !shielded
	if(shielded)
		update_icon("pylon_shield_closing")
	else
		update_icon("pylon_shield_opening")


/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/update_icon(anim_stat)
	cut_overlays()
	. = list()
	if(anim_stat)
		. += anim_stat
	else if(shielded) // the last frame of the shield animation is static (doesn't loop) so we only need to do this if we didn't update with an animation
		. += "pylon_shield"
	switch(pylon_state)
		if(PYLON_STATE_OFFLINE)
			. += "pylon_gyro"
		if(PYLON_STATE_STARTING)
			. += "pylon_gyro_on"
		if(PYLON_STATE_SPOOLING)
			. += "pylon_gyro_on_medium"
		if(PYLON_STATE_ACTIVE)
			. += "pylon_gyro_on_fast"
			. += "pylon_arcing"
	if(active_time > ACTIVE_TIME_WARNING)
		. += "pylon_overheat"
	add_overlay(.)

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

#undef PYLON_ACTIVE_EXPONENT
