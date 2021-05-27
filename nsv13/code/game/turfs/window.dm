/obj/structure/window/fulltile
	alpha = 200
	color = "#94bbd1"
	smooth = SMOOTH_TRUE
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	icon_state = "window"
	icon = 'nsv13/icons/obj/window.dmi'

/obj/structure/window/reinforced/fulltile
	alpha = 200
	color = "#94bbd1"
	smooth = SMOOTH_TRUE
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	icon_state = "rwindow"
	icon = 'nsv13/icons/obj/window.dmi'

/obj/structure/window/plasma/fulltile
	alpha = 200
	color = "#EE82EE"
	smooth = SMOOTH_TRUE
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	icon_state = "window"
	icon = 'nsv13/icons/obj/window.dmi'

/obj/structure/window/plasma/reinforced/fulltile
	alpha = 200
	color = "#EE82EE"
	smooth = SMOOTH_TRUE
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	icon_state = "rwindow"
	icon = 'nsv13/icons/obj/window.dmi'

//"wall grilles" that smooth like regular walls do because why not

/obj/structure/grille/wall
	color = "#707070" //So close to being "nice" that it hurts.
	smooth = SMOOTH_TRUE
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	icon = 'nsv13/icons/obj/grille.dmi'
	canSmoothWith = list(/turf/closed/wall,/obj/machinery/door,/obj/structure/window/fulltile,/obj/structure/window/reinforced/fulltile, /obj/structure/window/plasma/fulltile, /obj/structure/falsewall)
