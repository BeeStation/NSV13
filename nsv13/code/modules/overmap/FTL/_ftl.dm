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
