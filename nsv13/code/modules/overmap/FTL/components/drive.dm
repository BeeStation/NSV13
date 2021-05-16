// Startup responses
#define CORE_BROKEN 0 // broken/no power
#define CORE_COOLDOWN 1 // we're on cooldown
#define CORE_ACTIVE 2 // we're already active
#define CORE_PYLON_ERROR 3 // No connected pylons
#define CORE_SUCCESS 4

/obj/machinery/ftl_core
	name = "\improper FTL framewarp core"
	desc = "A highly advanced system capable of using exotic energy to bend space around it, exotic energy must be supplied by drive pylons"
	icon = 'nsv13/icons/obj/machinery/FTL_drive.dmi'
	icon_state = "core_idle"
	var/link_id = "default"
	var/list/pylons = list() //connected pylons
	var/enabled = FALSE // Whether or not we should be charging
	var/charge = 0 // charge progress, 0-100
	var/cooldown = 0 // cooldown in process ticks
	var/charge_rate = 0.5 // how much charge is given per pylon
	var/obj/item/radio/radio //For engineering alerts.
	var/radio_key = /obj/item/encryptionkey/headset_eng

/obj/machinery/ftl_core/Initialize()
	. = ..()
	add_overlay("screen")
	get_pylons()

/obj/machinery/ftl_core/proc/get_pylons()
	for(var/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/P in GLOB.machines)
		if(link_id == P.link_id && P.get_overmap() == get_overmap())
			pylons += P

/obj/machinery/ftl_core/proc/check_pylons()
	if(!LAZYLEN(pylons) && !get_pylons())
		return FALSE
	return TRUE


/obj/machinery/ftl_core/proc/begin_charge()
	if(!is_operational() || !anchored)
		return CORE_BROKEN
	if(cooldown)
		return CORE_COOLDOWN
	if(charge)
		return CORE_ACTIVE
	if(!check_pylons())
		return CORE_PYLON_ERROR
	enabled = TRUE
	return CORE_SUCCESS

/obj/machinery/ftl_core/process()
	if(!enabled || !is_operational() || !anchored)
		return
	for(var/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/P in pylons)
		if(P.pylon_state == PYLON_STATE_ACTIVE)
			charge = min(charge + charge_rate, 100)
	if(charge == 100)


/obj/machinery/ftl_core/proc/announce_jump()
	radio.talk_into(src, "TRACKING: FTL signature detected. Tracking information updated.",engineering_channel)
	for(var/list/L in tracking)
		var/obj/structure/overmap/target = L["ship"]
		var/datum/star_system/target_system = SSstar_system.ships[target]["target_system"]
		var/datum/star_system/current_system = SSstar_system.ships[target]["current_system"]
		tracking[target] = list("name" = target.name, "current_system" = current_system.name, "target_system" = target_system.name)


