// WALLS

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
	sheet_amount = 1
	hardness = 5

/obj/structure/falsewall/duranium
	icon = 'nsv13/icons/turf/reinforced_wall.dmi'
	icon_state = "solid"
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
		if(istype(S, /obj/item/stack/sheet/duranium)) //Duranium wall building
			if(state == GIRDER_REINF)
				if(S.get_amount() < 1)
					return FALSE
				to_chat(user, "<span class='notice'>You start finalizing the duranium wall...</span>")
				if(do_after(user, 50, target = src))
					if(S.get_amount() < 1)
						return FALSE
					S.use(1)
					to_chat(user, "<span class='notice'>You finish constructing the wall.</span>")
					var/turf/T = get_turf(src)
					T.PlaceOnTop(/turf/closed/wall/r_wall/ship)
					transfer_fingerprints_to(T)
					qdel(src)
				return TRUE
			else
				to_chat(user, "<span class='warning'>The girder is too weak to support the Duranium plating!")
				return TRUE
		if(S.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two sheets of [S] to finish a wall!</span>")
			return FALSE
		to_chat(user, "<span class='notice'>You start plating the wall with [S]...</span>")
		if (do_after(user, 40, target = src))
			if(S.get_amount() < 2)
				to_chat(user, "<span class='warning'>You need two sheets of [S] to finish a wall!</span>")
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

// WINDOWS

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
	glass_amount = 2

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

/turf/open/openspace/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/closed/indestructible/boarding_cordon
	name = "ship interior cordon"
	icon_state = "cordon"

/turf/closed/indestructible/boarding_cordon/Initialize(mapload)
	. = ..()
	alpha = 0
	mouse_opacity = FALSE

/turf/closed/indestructible/boarding_cordon/Bumped(atom/movable/AM)
	if(isobserver(AM))
		return
	if(istype(AM, /obj/structure/overmap/small_craft))
		var/obj/structure/overmap/small_craft/OM = AM
		return OM.check_overmap_elegibility(ignore_position = TRUE)
	return ..()

/turf/open/floor/engine/nucleium
	name = "Nucleium Floor"
	initial_gas_mix = ATMOS_TANK_NUCLEIUM
