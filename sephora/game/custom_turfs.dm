/turf/closed/wall/r_wall/ship
	icon = 'sephora/icons/turf/reinforced_wall.dmi'
	name = "Duranium hull"
	desc = "A large hull segment designed to create vessels and structures capable of supporting life in even the most hazardous places."
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	smooth = TRUE
	canSmoothWith = list(/turf/closed/wall/ship,/obj/machinery/door,/obj/structure/window,/turf/closed/wall/r_wall/ship)
	sheet_type = /obj/item/stack/sheet/duranium

/obj/structure/girder/attackby(obj/item/W, mob/user, params) //Time to add support for our walls..
	var/obj/item/stack/sheet/S = W
	if(istype(W, /obj/item/stack/sheet/duranium))
		if(S.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two sheets of [W] to finish a wall!</span>")
			return
		if(!S.turf_type)
			to_chat(user, "<span class='warning'>You can't build anything with [W].</span>")
			return
		if (do_after(user, 40, target = src))
			if(S.get_amount() < 2)
				return
			S.use(2)
			to_chat(user, "<span class='notice'>You add the hull plating.</span>")
			var/turf/T = get_turf(src)
			T.PlaceOnTop(S.turf_type)
			transfer_fingerprints_to(T)
			qdel(src)
			return
	. = ..()
	if(istype(W, /obj/item/stack/sheet/durasteel))
		if(S.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two sheets of [W] to finish a wall!</span>")
			return
		if(!S.turf_type)
			to_chat(user, "<span class='warning'>You can't build anything with [W].</span>")
			return
		if (do_after(user, 40, target = src))
			if(S.get_amount() < 2)
				return
			S.use(2)
			to_chat(user, "<span class='notice'>You add the hull plating.</span>")
			var/turf/T = get_turf(src)
			T.PlaceOnTop(S.turf_type)
			transfer_fingerprints_to(T)
			qdel(src)
			return
	. = ..()

/obj/machinery/door/airlock/ship
	name = "Airtight hatch"
	icon = 'sephora/icons/obj/machinery/doors/standard.dmi'
	desc = "A durasteel bulkhead which opens and closes. Hope you're good at hatch hopping"
	icon_state = "closed"
	overlays_file = null
//	doorOpen = 'DS13/sound/effects/tng_airlock.ogg'
//	doorClose = 'DS13/sound/effects/tng_airlock.ogg'
//	doorDeni = 'DS13/sound/effects/denybeep.ogg'

/turf/open/floor/carpet/ship
	name = "nanoweave carpet"
	desc = "A padded piece of hull plating which can make a space based installation feel more homely."
	icon = 'sephora/icons/turf/dark_carpet.dmi'
	icon_state = "dark_carpet"
	floor_tile = /obj/item/stack/tile/carpet/ship
	canSmoothWith = list(/turf/open/floor/carpet/ship)

/obj/item/stack/tile/carpet/ship
	name = "nanoweave carpet tile"
	singular_name = "nanoweave carpet tile"
	desc = "A regular nanoweave carpet tile"
	icon = 'sephora/icons/turf/dark_carpet.dmi'
	icon_state = "dark_carpet_tile"
	resistance_flags = FLAMMABLE
	turf_type = /turf/open/floor/carpet/ship

/obj/structure/window/reinforced/fulltile/ship
	name = "Nanocarbon reinforced window"
	desc = "A heavyset window reinforced with tiny carbon structures which is designed to take a beating."
	icon = 'sephora/icons/obj/structures/windows.dmi'
	icon_state = "rwindow"
	glass_type = /obj/item/stack/sheet/nanocarbon_glass
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
	floor_tile = /obj/item/stack/tile/plasteel/ship

/obj/item/stack/tile/plasteel/ship
	name = "durasteel hull plating tile"
	singular_name = "durasteel hull plating tile"
	desc = "A regular durasteel hull plating tile"
	icon = 'sephora/icons/turf/floors.dmi'
	icon_state = "durasteel_tile"
	turf_type = /turf/open/floor/plasteel/ship

/turf/open/floor/plasteel/ship/riveted
	name = "riveted steel hull plating"
	icon_state = "riveted"
	floor_tile = /obj/item/stack/tile/plasteel/ship/riveted

/obj/item/stack/tile/plasteel/ship/riveted
	name = "riiveted steel hull plating tile"
	singular_name = "riveted steel hull plating tile"
	desc = "A regular riveted steel hull plating tile"
	icon_state = "riveted_tile"
	turf_type = /turf/open/floor/plasteel/ship/riveted

/turf/open/floor/plasteel/ship/padded
	name = "padded steel hull plating"
	icon_state = "padded"
	floor_tile = /obj/item/stack/tile/plasteel/padded

/obj/item/stack/tile/plasteel/padded
	name = "padded steel hull plating tile"
	singular_name = "padded steel hull plating tile"
	desc = "A regular padded steel hull plating tile"
	icon = 'sephora/icons/turf/floors.dmi'
	icon_state = "padded_tile"
	turf_type = /turf/open/floor/plasteel/ship/padded

/turf/open/floor/plasteel/ship/techfloor //Ported from eris
	name = "embossed hull plating"
	icon_state = "eris_techfloor"
	floor_tile = /obj/item/stack/tile/plasteel/ship/techfloor

/obj/item/stack/tile/plasteel/ship/techfloor
	name = "embossed hull plating tile"
	singular_name = "embossed hull plating tile"
	desc = "A regular embossed hull plating tile"
	icon = 'sephora/icons/turf/floors.dmi'
	icon_state = "eris_techfloor_tile"
	turf_type = /turf/open/floor/plasteel/ship/techfloor

/turf/open/floor/plasteel/ship/techfloor/alt
	name = "embossed hull plating"
	icon_state = "eris_techfloor_alt"
	floor_tile = /obj/item/stack/tile/plasteel/ship/techfloor/alt

/obj/item/stack/tile/plasteel/ship/techfloor/alt
	name = "embossed hull plating tile"
	singular_name = "embossed hull plating tile"
	desc = "A regular embossed hull plating tile"
	icon = 'sephora/icons/turf/floors.dmi'
	icon_state = "eris_techfloor_alt_tile"
	turf_type = /turf/open/floor/plasteel/ship/techfloor/alt
