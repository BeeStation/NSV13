#define PYLON_STATE_OFFLINE 0
#define PYLON_STATE_STARTING 1
#define PYLON_STATE_WARMUP 2
#define PYLON_STATE_SPOOLING 3
#define PYLON_STATE_SHUTDOWN 4
#define PYLON_STATE_ACTIVE 5

/obj/machinery/atmospherics/components/binary/ftl
	name = "atmospheric FTL component"
	desc = "yell at mappers."
	var/obj/structure/cable/C // connected cable
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
	return max((power ** base_efficiency - 1) * 100, min_efficiency)

/obj/machinery/atmospherics/components/binary/ftl/proc/try_enable()
	var/turf/T = get_turf(src)
	C = T.get_cable_node()
	if(!C)
		return ENABLE_FAIL_POWER
	on = TRUE
	START_PROCESSING(SSmachines, src)
	return ENABLE_SUCCESS

/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/proc/power_drain()
	if(min_power_draw <= 0)
		return TRUE
	var/turf/T = get_turf(src)
	C = T.get_cable_node()
	if(!C)
		return FALSE
	current_power_draw = max(targ_power_draw, min_power_draw)
	if(current_power_draw > C.surplus())
		visible_message("<span class='warning'>\The [src] lets out [power_warning_sound] as it's power light flickers.</span>")
		return FALSE
	C.add_load(current_power_draw)
	return TRUE














/*
#define CORE_MAXIMUM_CHARGE 1000

//FTL DRIVE CORE - zappy core where the FTL charge builds
/obj/machinery/power/ftl_drive_core
	name = "FTL Drive Core"
	desc = "Words about the core"
	icon = 'nsv13/icons/obj/machinery/FTL_drive.dmi'
	icon_state = "core_idle"
	pixel_x = -64
	density = TRUE
	anchored = TRUE
	var/capacitor_charge = 0
	var/decay_delay = 10
	var/decay_cycle = 0

/obj/machinery/power/ftl_drive_core/process()
	decay_cycle ++
	if(decay_cycle >=10)
		capacitor_charge -= max(round(decay_cycle / 25), 1)

//FTL DRIVE SILO - reinforced storage tank for FTL fuel
/obj/machinery/atmospherics/components/binary/ftl_drive_silo
	name = "FTL Drive Silo"
	desc = "Words about the vat"
	icon = 'nsv13/icons/obj/machinery/FTL_silo.dmi'
	icon_state = "silo"
	pixel_x = -32
	density = TRUE
	anchored = TRUE
	idle_power_usage = 50
	active_power_usage = 250
	max_integrity = 1000
	var/volume = 10000

/obj/machinery/atmospherics/components/binary/ftl_drive_silo/New()
	..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.volume = volume
	update_parents()

//FTL DRIVE MANIFOLD - required for normal use - TRAITOR TARGET - should not be touched unless in epsilon protocol - starts in the floor
/obj/machinery/ftl_drive_manifold
	name = "FTL Drive Manifold"
	desc = "Words about the manifold"
	icon = 'nsv13/icons/obj/machinery/FTL_pylon.dmi'
	icon_state = "pylon"
	density = FALSE
	anchored = TRUE
*/
