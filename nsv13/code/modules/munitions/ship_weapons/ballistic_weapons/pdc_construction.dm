/obj/item/wallframe/pdc_frame
	name = "PDC loading rack frame"
	desc = "Used for building PDC loading racks."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm_bitem"
	result_path = /obj/structure/frame/machine/ship_weapon/pdc_mount

/obj/structure/frame/machine/ship_weapon/pdc_mount
	name = "PDC loading rack frame"
	desc = "Used for building PDC loading racks."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm_bitem"
	pixel_y = 26
	density = FALSE

/obj/structure/frame/machine/ship_weapon/pdc_mount/New(loc, ndir, nbuild)
	. = ..()
	if(ndir)
		setDir(ndir)

	if(nbuild)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir == 1 ? -24 : 24) : 0

	update_icon()

/obj/structure/frame/machine/ship_weapon/pdc_mount/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/circuitboard/machine) && !istype(P, /obj/item/circuitboard/machine/pdc_mount))// Only accept our specific circuitboard
		to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
		return TRUE
	. = ..()
	icon_state = initial(icon_state)
