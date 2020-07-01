/turf/closed/wall/ship
	icon = 'nsv13/icons/turf/interior_wall.dmi'
	icon_state = "solid"
	name = "Durasteel hull"
	desc = "A large hull segment designed to create vessels and structures capable of supporting life in even the most hazardous places."
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	smooth = TRUE
	sheet_type = /obj/item/stack/sheet/durasteel
	hardness = 20

/obj/structure/falsewall/durasteel
	icon = 'nsv13/icons/turf/interior_wall.dmi'
	name = "Durasteel hull"
	desc = "A large hull segment designed to create vessels and structures capable of supporting life in even the most hazardous places."
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	smooth = TRUE
	walltype = /turf/closed/wall/ship

/turf/closed/wall/r_wall/ship
	icon = 'nsv13/icons/turf/reinforced_wall.dmi'
	icon_state = "solid"
	name = "Duranium hull"
	desc = "A large hull segment designed to create vessels and structures capable of supporting life in even the most hazardous places."
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	smooth = TRUE
	color = null
	sheet_type = /obj/item/stack/sheet/duranium
	sheet_amount = 2
	girder_type = /obj/structure/girder
	hardness = 5

/obj/structure/falsewall/duranium
	icon = 'nsv13/icons/turf/reinforced_wall.dmi'
	name = "Duranium hull"
	desc = "A large hull segment designed to create vessels and structures capable of supporting life in even the most hazardous places."
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	smooth = TRUE
	walltype = /turf/closed/wall/r_wall/ship
	mineral = /obj/item/stack/sheet/duranium

/obj/structure/girder/proc/try_nsv_walls(obj/item/stack/sheet/S, mob/user)
	if(!S.turf_type) //Let the girder code handle it. It's not one of ours.
		return FALSE

	if(state != GIRDER_DISPLACED) //Build regular wall
		if(S.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two sheets of [S] to finish a wall!</span>")
			return FALSE

		to_chat(user, "<span class='notice'>You start plating the wall with [S]...</span>")
		if (do_after(user, 40, target = src))
			if(S.get_amount() < 2)
				to_chat(user, "<span class='warning'>You need two sheets of [S] to create a false wall!</span>")
				return FALSE
			S.use(2)
			to_chat(user, "<span class='notice'>You add the hull plating.</span>")
			var/turf/T = get_turf(src)
			T.PlaceOnTop(S.turf_type)
			transfer_fingerprints_to(T)
			qdel(src)
			return TRUE

	else //Build false wall
		if(S.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two sheets of [S] to create a false wall!</span>")
			return FALSE

		to_chat(user, "<span class='notice'>You start building a false wall with [S]...</span>")
		if(do_after(user, 40, target = src))
			if(S.get_amount() < 2)
				to_chat(user, "<span class='warning'>You need two sheets of [S] to create a false wall!</span>")
				return FALSE
			S.use(2)
			to_chat(user, "<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>")

			var/turf/T = get_turf(src)

			if(S.sheettype && !ispath(S, /obj/item/stack/sheet/mineral))
				var/F = text2path("/obj/structure/falsewall/[S.sheettype]")
				var/obj/structure/falsewall/FW
				FW = new F(T)

				transfer_fingerprints_to(FW)
				qdel(src)
				return TRUE
	return FALSE

/turf/open/floor/carpet/ship
	name = "nanoweave carpet"
	desc = "A padded piece of hull plating which can make a space based installation feel more homely."
	icon = 'nsv13/icons/turf/dark_carpet.dmi'
	icon_state = "dark_carpet"
	floor_tile = /obj/item/stack/tile/carpet/ship
	canSmoothWith = list(/turf/open/floor/carpet/ship)

/obj/item/stack/tile/carpet/ship
	name = "nanoweave carpet tile"
	singular_name = "nanoweave carpet tile"
	desc = "A regular nanoweave carpet tile"
	icon = 'nsv13/icons/turf/dark_carpet.dmi'
	icon_state = "dark_carpet_tile"
	resistance_flags = FLAMMABLE
	turf_type = /turf/open/floor/carpet/ship

/obj/structure/window/reinforced/fulltile/ship
	name = "Nanocarbon reinforced window"
	desc = "A heavyset window reinforced with tiny carbon structures which is designed to take a beating."
	glass_type = /obj/item/stack/sheet/nanocarbon_glass
	canSmoothWith = list(/turf/closed/wall,/obj/machinery/door,/obj/structure/window/fulltile,/obj/structure/window/reinforced/fulltile, /obj/structure/window/plasma/fulltile, /obj/structure/falsewall)
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 25, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 100, "overmap_light" = 65, "overmap_heavy" = 25)

/obj/structure/window/reinforced/fulltile/ship/unanchored
	anchored = FALSE

/obj/structure/window/reinforced/fulltile/ship/interior
	name = "Interior reinforced window"
	desc = "A heavyset window reinforced with tiny carbon structures which is designed to take a beating."
	glass_type = /obj/item/stack/sheet/rglass

/obj/structure/window/reinforced/fulltile/ship/interior/unanchored
	anchored = FALSE

/obj/effect/spawner/structure/window/reinforced
	name = "reinforced window spawner"
	icon_state = "rwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/fulltile/ship/interior, /obj/machinery/door/firedoor/window, /obj/effect/landmark/zebra_interlock_point) //All windows should "batten down" on zebra.

/obj/structure/window/reinforced/ship
	icon = 'nsv13/goonstation/icons/obj/window_pane.dmi'
	icon_state = "rwindow"
	color = "#94bbd1"

/obj/structure/window/ship
	icon = 'nsv13/goonstation/icons/obj/window_pane.dmi'
	icon_state = "window"
	color = "#94bbd1"

/obj/structure/fluff/support_beam
	name = "Support beam"
	desc = "A large metal support which helps hold the ship together."
	icon = 'nsv13/icons/obj/structures/ship_structures.dmi'
	icon_state = "support_beam"
	density = FALSE
	anchored = TRUE

/turf/open/floor/plasteel/ship
	name = "durasteel hull plating"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "durasteel"
	floor_tile = /obj/item/stack/tile/plasteel/ship
	broken_states = list("durasteel_dam1", "durasteel_dam2", "durasteel_dam3", "durasteel_dam4", "durasteel_dam5")

/obj/item/stack/tile/plasteel/ship
	name = "durasteel hull plating tile"
	singular_name = "durasteel hull plating tile"
	desc = "A regular durasteel hull plating tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "durasteel_tile"
	turf_type = /turf/open/floor/plasteel/ship

/turf/open/floor/plasteel/ship/riveted
	name = "riveted steel hull plating"
	icon_state = "riveted"
	floor_tile = /obj/item/stack/tile/plasteel/ship/riveted
	broken_states = list("riveted_dam1", "riveted_dam2", "riveted_dam3", "riveted_dam4", "riveted_dam5")

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
	broken_states = list("padded_dam1", "padded_dam2", "padded_dam3", "padded_dam4", "padded_dam5")

/obj/item/stack/tile/plasteel/padded
	name = "padded steel hull plating tile"
	singular_name = "padded steel hull plating tile"
	desc = "A regular padded steel hull plating tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "padded_tile"
	turf_type = /turf/open/floor/plasteel/ship/padded

/turf/open/floor/plasteel/ship/techfloor //Ported from eris
	name = "embossed hull plating"
	icon_state = "eris_techfloor"
	floor_tile = /obj/item/stack/tile/plasteel/ship/techfloor
	broken_states = list("eris_techfloor_dam1", "eris_techfloor_dam2", "eris_techfloor_dam3", "eris_techfloor_dam4", "eris_techfloor_dam5")

/obj/item/stack/tile/plasteel/ship/techfloor
	name = "embossed hull plating tile"
	singular_name = "embossed hull plating tile"
	desc = "A regular embossed hull plating tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "eris_techfloor_tile"
	turf_type = /turf/open/floor/plasteel/ship/techfloor

/turf/open/floor/plasteel/ship/techfloor/alt
	name = "embossed hull plating"
	icon_state = "eris_techfloor_alt"
	floor_tile = /obj/item/stack/tile/plasteel/ship/techfloor/alt
	broken_states = list("eris_techfloor_alt_dam1", "eris_techfloor_alt_dam2", "eris_techfloor_alt_dam3", "eris_techfloor_alt_dam4", "eris_techfloor_alt_dam5")

/obj/item/stack/tile/plasteel/ship/techfloor/alt
	name = "embossed hull plating tile"
	singular_name = "embossed hull plating tile"
	desc = "A regular embossed hull plating tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "eris_techfloor_alt_tile"
	turf_type = /turf/open/floor/plasteel/ship/techfloor/alt

/turf/open/floor/circuit/orange
	icon_state = "gscircuit"
	icon_normal = "gscircuit"
	color = "#FF8C00"
	light_color = LIGHT_COLOR_ORANGE

/obj/effect/turf_decal/solgov //Credit to baystation for these sprites!
	alpha = 230
	icon = 'nsv13/icons/obj/solgov_floor.dmi'
	icon_state = "center"

/obj/structure/sign/solgov_seal
	name = "Seal of the solarian government"
	desc = "A seal emblazened with a gold trim depicting the star, sol."
	icon = 'nsv13/icons/obj/solgov_logos.dmi'
	icon_state = "solgovseal"
	pixel_y = 27

/obj/structure/sign/solgov_flag
	name = "solgov banner"
	desc = "A large flag displaying the logo of solgov, the local government of the sol system."
	icon = 'nsv13/icons/obj/solgov_logos.dmi'
	icon_state = "solgovflag-left"
	pixel_y = 26

/obj/structure/sign/solgov_flag/right
	icon_state = "solgovflag-right"

/turf/open/floor/monotile/dark/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/monotile/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/monotile/light/airless
	initial_gas_mix = AIRLESS_ATMOS