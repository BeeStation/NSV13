/obj/effect/landmark/zebra_interlock_point
	name = "Condition zebra interlock helper"
	icon = 'nsv13/icons/effects/mapping_helpers.dmi'
	icon_state = "zebra_interlock"


/obj/effect/landmark/zebra_interlock_point/Initialize(mapload)
	. = ..()
	for(var/obj/machinery/door/firedoor/FD in get_turf(src))
		FD.RegisterSignal(SSdcs, COMSIG_GLOB_SECURITY_ALERT_CHANGE, /obj/machinery/door/firedoor/proc/on_alert_level_change, override=TRUE) //In case you have a zebra spawner on a window, this instance of alert level change will override the old one.

/obj/machinery/door/firedoor/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_SECURITY_ALERT_CHANGE, PROC_REF(on_alert_level_change), override=TRUE) //Condition zebra means all window firelocks should drop.

/obj/machinery/door/firedoor/open()
	. = ..()
	var/level = GLOB.security_level
	if(level == SEC_LEVEL_ZEBRA) //Zebra is a special case. Nothing else triggers this behaviour.
		addtimer(CALLBACK(src, PROC_REF(close)), 3 SECONDS) //Snap shut again if zebra's still active.

/obj/machinery/door/firedoor/proc/on_alert_level_change(level)
	SIGNAL_HANDLER

	if(!is_station_level(z))
		return

	if(level == SEC_LEVEL_ZEBRA) //Zebra is a special case. Nothing else triggers this behaviour.
		spawn()
			close()
	else
		var/area/A = get_area(src)
		if((A.fire) || is_holding_pressure())
			return
		spawn()
			open()
