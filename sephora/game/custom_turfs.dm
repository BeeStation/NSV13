/turf/closed/wall/r_wall/ship
	icon = 'sephora/icons/turf/reinforced_wall.dmi'
	name = "Duranium hull"
	desc = "A large hull segment designed to create vessels and structures capable of supporting life in even the most hazardous places."
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	smooth = TRUE
	canSmoothWith = list(/turf/closed/wall/ship,/obj/machinery/door,/obj/structure/window,/turf/closed/wall/r_wall/ship)

/turf/open/floor/carpet/ship
	name = "nanoweave carpet"
	desc = "A padded piece of hull plating which can make a space based installation feel more homely."
	icon = 'sephora/icons/turf/dark_carpet.dmi'
	icon_state = "dark_carpet"
	canSmoothWith = list(/turf/open/floor/carpet/ship)

/obj/structure/window/reinforced/fulltile/ship
	name = "Nanocarbon reinforced window"
	desc = "A heavyset window reinforced with tiny carbon structures which is designed to take a beating."
	icon = 'sephora/icons/obj/structures/windows.dmi'
	icon_state = "rwindow"
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	smooth = TRUE
	canSmoothWith = list(/obj/structure/window/reinforced/fulltile/ship,/turf/closed/wall/ship,/turf/closed/wall/r_wall/ship)

/obj/structure/fluff/support_beam
	name = "Support beam"
	desc = "A large metal support which helps hold the ship together."
	icon = 'sephora/icons/obj/structures/ship_structures.dmi'
	icon_state = "support_beam"
	density = FALSE

/turf/open/floor/plasteel/ship
	name = "durasteel hull plating"
	icon = 'sephora/icons/turf/floors.dmi'
	icon_state = "durasteel"

/turf/open/floor/plasteel/ship/riveted
	name = "riveted steel hull plating"
	icon_state = "riveted"

/turf/open/floor/plasteel/ship/padded
	name = "padded steel hull plating"
	icon_state = "padded"

/turf/open/floor/plasteel/ship/techfloor //Ported from eris
	name = "embossed hull plating"
	icon_state = "eris_techfloor"

/turf/open/floor/plasteel/ship/techfloor/alt
	name = "embossed hull plating"
	icon_state = "eris_techfloor_alt"