/obj/machinery/rnd/production
	var/datum/looping_sound/lathe/soundloop

/obj/machinery/rnd/production/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)

/obj/machinery/rnd/production/Destroy()
	QDEL_NULL(soundloop)
	return ..()
