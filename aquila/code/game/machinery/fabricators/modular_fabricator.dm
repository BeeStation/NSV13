
/obj/machinery/modular_fabricator
	var/soundloop_type
	var/datum/looping_sound/soundloop

/obj/machinery/modular_fabricator/autolathe
	soundloop_type = /datum/looping_sound/lathe

/obj/machinery/modular_fabricator/exosuit_fab
	soundloop_type = /datum/looping_sound/lathe

/obj/machinery/modular_fabricator/Initialize(mapload)
	. = ..()
	if(soundloop_type)
		soundloop = new soundloop_type(src, FALSE)

/obj/machinery/modular_fabricator/Destroy()
	if(soundloop)
		QDEL_NULL(soundloop)
	. = ..()
