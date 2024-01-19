/obj/machinery/power/generator
	var/datum/looping_sound/generator/soundloop


/obj/machinery/power/generator/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)

/obj/machinery/power/generator/Destroy()
	QDEL_NULL(soundloop)
	. = ..()
