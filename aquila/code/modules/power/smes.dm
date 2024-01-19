/obj/machinery/power/smes
	var/datum/looping_sound/smes/soundloop

/obj/machinery/power/smes/Initialize()
	. = ..()
	soundloop = new(src, FALSE)

/obj/machinery/power/smes/Destroy()
	QDEL_NULL(soundloop)
	. = ..()

/obj/machinery/power/smes/update_icon()
	. = ..()
	if(outputting)
		soundloop?.start()
	else
		soundloop?.stop()
