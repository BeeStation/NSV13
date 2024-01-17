// stany ikon przetłumaczone
// lub powstałe na potrzeby akili
// w pliku
// aquila/icons/obj/status_display.dmi
#define AQ_STATES list("redalert")

/obj/machinery/status_display/set_picture(state)
	if(state in AQ_STATES)
		icon = 'aquila/icons/obj/status_display.dmi'
	else
		icon = 'icons/obj/status_display.dmi'

	..(state)
