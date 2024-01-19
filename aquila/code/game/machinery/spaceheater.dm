/obj/machinery/space_heater
	var/datum/looping_sound/thermal/soundloop

/obj/machinery/space_heater/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)

/obj/machinery/space_heater/update_icon()
	. = ..()
	if(on)
		soundloop?.start()
	else
		soundloop?.stop()

/obj/machinery/space_heater/Destroy()
	QDEL_NULL(soundloop)
	. = ..()
