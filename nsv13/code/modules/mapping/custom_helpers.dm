/obj/effect/mapping_helpers/canister

/obj/effect/mapping_helpers/canister/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_mapping("[src] spawned outside of mapload!")
		return
	var/obj/machinery/portable_atmospherics/C = locate(/obj/machinery/portable_atmospherics) in loc
	var/obj/machinery/atmospherics/components/unary/portables_connector/P = locate(/obj/machinery/atmospherics/components/unary/portables_connector) in loc
	if(!C)
		log_mapping("[src] failed to find a canister at [AREACOORD(src)]")

	else if(!P)
		log_mapping("[src] failed to find a port at [AREACOORD(src)]")

	else
		addtimer(CALLBACK(C, /obj/machinery/portable_atmospherics.proc/connect, P), 2 SECONDS) //Make sure we have a pipenet first
