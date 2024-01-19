/obj/machinery/computer
	var/datum/looping_sound/computer/soundloop


/obj/machinery/computer/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	soundloop = new(src, FALSE)

/obj/machinery/computer/Destroy()
	QDEL_NULL(soundloop)
	return ..()

