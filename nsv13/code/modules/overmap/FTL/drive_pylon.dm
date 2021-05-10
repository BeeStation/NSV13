#define PYLON_STATE_OFFLINE 0
#define PYLON_STATE_STARTING 1
#define PYLON_STATE_WARMUP 2
#define PYLON_STATE_SPOOLING 3
#define PYLON_STATE_SHUTDOWN 4
#define PYLON_STATE_ACTIVE 5

#define ENABLE_SUCCESS 1
#define ENABLE_FAIL_POWER 2
#define ENABLE_FAIL_COOLDOWN 3

#define MAX_WASTE_PRESSURE 7500

/// Multiplies power draw by this value every tick it remains active. Higher values will make power use increase faster
#define PYLON_ACTIVE_EXPONENT 1.02

/// how many ticks of being active are required before we start to overheat
#define active_time_safe 90

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
	var/gyro_speed = 0
	var/obj/structure/pylon_shield = null
	var/active_time = 0 // how many ticks have we been fully active for
	var/active_time_safe = 60
	var/internal_temp = 20 // celsius
	var/pylon_state = PYLON_STATE_OFFLINE
	var/capacitor = 0 // capacitors charged
	var/mol_per_capacitor = 10
	var/max_charge_rate = 1 // amount of capacitors that can be charged per tick
	var/req_capacitor = 5 // amount of capacitors required to be charged for the pylon to be active

/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/Initialize()
	pylon_shield = new(loc, src)
	vis_contents += pylon_shield

/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/process()
	if(!on)
		return
	if(pylon_state != PYLON_STATE_ACTIVE && capacitor >= req_capacitor)
		set_state(PYLON_STATE_ACTIVE)
	switch(pylon_state)
		if(PYLON_STATE_ACTIVE)
			min_power_draw = round(min_power_draw * PYLON_ACTIVE_EXPONENT + 300) // Active pylons slowly but exponentially require more charge to stay stable. Don't leave them on when you don't need to
			active_time++
			internal_heat += rand(2, 4)

		if(PYLON_STATE_STARTING) //pop the lid
			min_power_draw = 5000
			gyro_speed++
			if(gyro_speed >= 10)
				set_state(PYLON_STATE_WARMUP)

		if(PYLON_STATE_WARMUP) //start the spin
			var/datum/gas_mixture/air1 = airs[1]
			var/ftl_fuel = air1.get_moles(/datum/gas/frameshifted_plasma)

			if(ftl_fuel < 0.01)
				set_state(PYLON_STATE_STARTING)
				continue

			air1.adjust_moles(/datum/gas/frameshifted_plasma, -0.01)
			if(prob(20))
				var/datum/effect_system/spark_spread/S = new /datum/effect_system/spark_spread
				S.set_up(6, 0, src)
				S.start()
			min_power_draw = 20000
			gyro_speed++
			internal_heat += 5
			if(gyro_speed >= 25)
				set_state(PYLON_STATE_SPOOLING)

		if(PYLON_STATE_SPOOLING) //spinning intensifies
			var/datum/gas_mixture/air1 = airs[1]
			var/ftl_fuel = air1.get_moles(/datum/gas/frameshifted_plasma)
			if(ftl_fuel < 0.25)
				if(capacitor > 0)
					capacitor -= min((1 / rand(2, 5)), capacitor)
				else
					set_state(PYLON_STATE_STARTING)
				continue
			min_power_draw = 50000 // 50KW
			consume_fuel()
			if(gyro_speed < 25)
				set_state(PYLON_STATE_SHUTDOWN)

		if(PYLON_STATE_SHUTDOWN) //halt the spinning, close the lid
			min_power_draw = 0
			active_time -= active_time / gyro_speed
			capacitor -= round(capacitor / gyro_speed, 0.1)
			if(internal_heat > initial(internal_heat))
				internal_heat -= round(internal_heat / gyro_speed)
			gyro_speed--
			if(gyro_speed <= 0)
				finalalize_shutdown()

	if(!power_drain() || pylon_shield?.closed)
		set_state(PYLON_STATE_SHUTDOWN)

/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/try_enable()
	if(pylon_state = PYLON_STATE_SHUTDOWN)
		return ENABLE_FAIL_COOLDOWN
	return ..()

/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	if(pylon_shield?.closed)
		if(damage_type == BURN)
			damage_amount = 0
		else
			damage_amount /= 2
	return ..()

/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/proc/finalalize_shutdown()
	set_state(PYLON_STATE_OFFLINE)
	min_power_draw = 0
	gyro_speed = 0
	active_time = 0
	capacitor = 0
	STOP_PROCESSING(SSmachines, src)

/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/proc/consume_fuel()
	var/datum/gas_mixture/air1 = airs[1] // FTL fuel
	var/grid_power = min(C.surplus(), current_power_draw)
	if(grid_power < min_power_draw)
		return FALSE
	if(prob(30))
		tesla_zap(src, 2,  1000)
	var/input_fuel = min(air1.get_moles(/datum/gas/frameshifted_plasma), max_charge_rate * mol_per_capacitor)
	var/delta = KELVIN_TO_CELSIUS(air1.return_temperature()) - internal_heat
	internal_heat += delta
	capacitor += (input_fuel * get_efficiency(current_power_draw)) / mol_per_capacitor
	air1.adjust_moles(/datum/gas/frameshifted_plasma, -input_fuel)
	var/output = air2
	if(output.return_pressure() < MAX_WASTE_PRESSURE)
		var/turf/T = get_turf(src)
		output = T.air_contents
	output.adjust_moles(/datum/gas/plasma, input_fuel / 3)
	output.adjust_moles(/datum/gas/nucleium, input_fuel / 10)
	output.set_temperature(CELSIUS_TO_KELVIN(internal_heat))
	return TRUE

/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/proc/toggle_shield()
	if(!pylon_shield)
		return FALSE
	pylon_shield.toggle()

/// Small proc but it saves having an icon update after every varset xD
/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/proc/set_state(nstate)
	if(pylon_state == nstate)
		return
	pylon_state = nstate
	update_icon()

/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/Destroy()
	if(pylon_shield)
		QDEL_NULL(pylon_shield)
	return ..()

/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/update_icon()
	cut_overlays()
	var/list/ov = list()
	switch(pylon_state)
		if(PYLON_STATE_OFFLINE)
			ov += "pylon_gyro"
		if(PYLON_STATE_STARTING)
			ov += "pylon_gyro_on"
		if(PYLON_STATE_SPOOLING)
			ov += "pylon_gyro_on_medium"
		if(PYLON_STATE_ACTIVE)
			ov += "pylon_gyro_on_fast"
			ov += "pylon_arcing"
	if(active_time > active_time_safe)
		ov += "pylon_overheat"
	add_overlay(ov)

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

/obj/structure/pylon_shield
	name = "pylon shield"
	desc = "A thick piece of shielding designed to protect the sensitive internals of a drive pylon when not in use."
	icon = 'nsv13/icons/obj/machinery/FTL_pylon.dmi'
	icon_state = "pylon_shield"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	armor = list("melee" = 20, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 70, "stamina" = 0)
	max_integrity = 300
	var/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/pylon
	var/temp_factor = 1.1
	var/max_temp = 2600
	var/closed = TRUE

/obj/structure/pylon_shield/New(loc, pylon)
	..()
	if(!pylon)
		qdel(src)
		return
	src.pylon = pylon

/obj/structure/pylon_shield/proc/toggle()
	closed = !closed
	if(closed)
		icon_state = "pylon_shield"
		flick("pylon_shield_closing", src)
		if(pylon?.pylon_state != PYLON_STATE_OFFLINE)
			START_PROCESSING(SSobj, src)
	else
		icon_state = "pylon_shield_open"
		flick("pylon_shield_opening", src)
	playsound(src, 'sound/machines/blastdoor.ogg', 30, 1)

/obj/structure/pylon_shield/process()
	if(!pylon || pylon.pylon_state == PYLON_STATE_OFFLINE || pylon.pylon_state == PYLON_STATE_SHUTDOWN)
		return PROCESS_KILL
	pylon.internal_temp *= temp_factor
	if(pylon.internal_temp > max_temp)
		obj_integrity -= rand(5, 15)

/obj/structure/pylon_shield/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(pylon?.internal_temp > max_temp)
		visible_message("<span class ='danger'>\The [src] melts away from the extreme heat, exposing \the [pylon]'s sensitive internals!")
		playsound(src, 'sound/items/welder.ogg', 100, 1)
	return ..()
