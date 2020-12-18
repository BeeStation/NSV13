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
	canSmoothWith = null

/turf/open/floor/carpet/ship/Initialize()
	. = ..()
	canSmoothWith = typecacheof(/turf/open/floor/carpet/ship)

/obj/item/stack/tile/carpet/ship
	name = "nanoweave carpet tile"
	singular_name = "nanoweave carpet tile"
	desc = "A regular nanoweave carpet tile"
	icon = 'nsv13/icons/turf/dark_carpet.dmi'
	icon_state = "dark_carpet_tile"
	resistance_flags = FLAMMABLE
	turf_type = /turf/open/floor/carpet/ship

/turf/open/floor/carpet/ship/blue
	name = "nanoweave carpet (blue)"
	desc = "A padded piece of hull plating which can make a space based installation feel more homely."
	icon = 'nsv13/icons/turf/blue_carpet.dmi'
	icon_state = "blue_carpet"
	floor_tile = /obj/item/stack/tile/carpet/ship/blue

/obj/item/stack/tile/carpet/ship/blue
	name = "nanoweave carpet tile (blue)"
	singular_name = "nanoweave carpet tile"
	desc = "A regular nanoweave carpet tile"
	icon = 'nsv13/icons/turf/blue_carpet.dmi'
	icon_state = "blue_carpet_tile"
	resistance_flags = FLAMMABLE
	turf_type = /turf/open/floor/carpet/ship/blue

/turf/open/floor/carpet/ship/orange_carpet
	name = "nanoweave carpet (orange)"
	desc = "A padded piece of hull plating which can make a space based installation feel more homely."
	icon = 'nsv13/icons/turf/orange_carpet.dmi'
	icon_state = "orange_carpet"
	floor_tile = /obj/item/stack/tile/carpet/ship/orange_carpet

/obj/item/stack/tile/carpet/ship/orange_carpet
	name = "nanoweave carpet tile (orange)"
	singular_name = "nanoweave carpet tile"
	desc = "A regular nanoweave carpet tile"
	icon = 'nsv13/icons/turf/orange_carpet.dmi'
	icon_state = "orange_carpet_tile"
	resistance_flags = FLAMMABLE
	turf_type = /turf/open/floor/carpet/ship/orange_carpet

/turf/open/floor/carpet/ship/purple_carpet
	name = "nanoweave carpet (purple)"
	desc = "A padded piece of hull plating which can make a space based installation feel more homely."
	icon = 'nsv13/icons/turf/purple_carpet.dmi'
	icon_state = "purple_carpet"
	floor_tile = /obj/item/stack/tile/carpet/ship/purple_carpet

/obj/item/stack/tile/carpet/ship/purple_carpet
	name = "nanoweave carpet tile (purple)"
	singular_name = "nanoweave carpet tile"
	desc = "A regular nanoweave carpet tile"
	icon = 'nsv13/icons/turf/purple_carpet.dmi'
	icon_state = "purple_carpet_tile"
	resistance_flags = FLAMMABLE
	turf_type = /turf/open/floor/carpet/ship/purple_carpet

/turf/open/floor/carpet/ship/beige_carpet
	name = "nanoweave carpet (beige)"
	desc = "A padded piece of hull plating which can make a space based installation feel more homely."
	icon = 'nsv13/icons/turf/beige_carpet.dmi'
	icon_state = "beige_carpet"
	floor_tile = /obj/item/stack/tile/carpet/ship/beige_carpet

/obj/item/stack/tile/carpet/ship/beige_carpet
	name = "nanoweave carpet tile (beige)"
	singular_name = "nanoweave carpet tile"
	desc = "A regular nanoweave carpet tile"
	icon = 'nsv13/icons/turf/beige_carpet.dmi'
	icon_state = "beige_carpet_tile"
	resistance_flags = FLAMMABLE
	turf_type = /turf/open/floor/carpet/ship/beige_carpet

/turf/open/floor/carpet/ship/red_carpet
	name = "nanoweave carpet (red)"
	desc = "A padded piece of hull plating which can make a space based installation feel more homely."
	icon = 'nsv13/icons/turf/red_carpet.dmi'
	icon_state = "red_carpet"
	floor_tile = /obj/item/stack/tile/carpet/ship/red_carpet

/obj/item/stack/tile/carpet/ship/red_carpet
	name = "nanoweave carpet tile (red)"
	singular_name = "nanoweave carpet tile"
	desc = "A regular nanoweave carpet tile"
	icon = 'nsv13/icons/turf/beige_carpet.dmi'
	icon_state = "red_carpet_tile"
	resistance_flags = FLAMMABLE
	turf_type = /turf/open/floor/carpet/ship/red_carpet

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

/turf/open/floor/plasteel/ship
	name = "durasteel hull plating"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "durasteel"
	floor_tile = /obj/item/stack/tile/plasteel/ship
	broken_states = list("durasteel_dam1", "durasteel_dam2", "durasteel_dam3", "durasteel_dam4", "durasteel_dam5")
	burnt_states = list("floorscorched1", "floorscorched2", "floorscorched3", "floorscorched4")

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
	burnt_states = list("riveted_scorched1", "riveted_scorched2", "riveted_scorched3")

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
	burnt_states = list("padded_scorched1", "padded_scorched2", "padded_scorched3", "padded_scorched4")

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
	burnt_states = list("eris_techfloor_scorched1", "eris_techfloor_scorched2")

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
	burnt_states = list("eris_techfloor_alt_scorched1", "eris_techfloor_alt_scorched2", "eris_techfloor_alt_scorched3")

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

/turf/open/floor/monotile/dark/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/monotile/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/monotile/light/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/plasteel/grid/mono
	name = "steel hull plate"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "steel"
	floor_tile = /obj/item/stack/tile/plasteel/grid/mono
	broken_states = list("steel_dam1", "steel_dam2", "steel_dam3", "steel_dam4", "steel_dam5")
	burnt_states = list("steel_scorched1", "steel_schorched2", "steel_scorched3", "steel_scorched4")

/obj/item/stack/tile/plasteel/grid/mono
	name = "steel hull plating tile"
	singular_name = "steel hull plating tile"
	desc = "A regular steel hull plating tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "steel_tile"
	turf_type = /turf/open/floor/plasteel/grid/mono

/turf/open/floor/plasteel/grid/lino
	name = "linoleum hull plate"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "lino"
	floor_tile = /obj/item/stack/tile/plasteel/grid/lino
	broken_states = list("lino_dam1", "lino_dam2")
	burnt_states = list("lino_scorched1")

/obj/item/stack/tile/plasteel/grid/lino
	name = "linoleum hull plating tile"
	singular_name = "linoleum hull plating tile"
	desc = "A regular linoleum hull plating tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "lino_tile"
	turf_type = /turf/open/floor/plasteel/grid/lino

/turf/open/floor/plasteel/grid/techfloor
	name = "techfloor tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "techfloor"
	floor_tile = /obj/item/stack/tile/plasteel/grid/techfloor
	broken_states = list("techfloor_dam1", "techfloor_dam2")
	burnt_states = list("techfloor_scorched1", "techfloor_scorched2")

/obj/item/stack/tile/plasteel/grid/techfloor
	name = "techfloor tile"
	singular_name = "techfloor hull plating tile"
	desc = "A regular techfloor hull plating tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "techfloor_tile"
	turf_type = /turf/open/floor/plasteel/grid/lino

/turf/open/floor/plasteel/grid/techfloor/grid
	name = "techfloor grid"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "techfloor_grid"
	floor_tile = /obj/item/stack/tile/plasteel/grid/techfloor
	broken_states = list("techfloor_grid_dam1")
	burnt_states = list("techfloor_grid_scorched1", "techfloor_grid_scorched2")

/obj/item/stack/tile/plasteel/grid/techfloor/grid
	name = "techfloor tile"
	singular_name = "techfloor hull plating tile"
	desc = "A regular techfloor hull plating tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "techfloor_grid_tile"
	turf_type = /turf/open/floor/plasteel/grid/techfloor/grid

/turf/open/floor/plasteel/grid/techfloor/grid/airless
	initial_gas_mix = AIRLESS_ATMOS

/obj/effect/turf_decal/tile/ship
	name = "tile decal"
	icon = 'nsv13/icons/turf/decals.dmi'
	icon_state = "bordercorner"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/tile/ship/blue
	name = "blue corner"
	color = "#52B4E9"

/obj/effect/turf_decal/tile/ship/green
	name = "green corner"
	color = "#9FED58"

/obj/effect/turf_decal/tile/ship/yellow
	name = "yellow corner"
	color = "#EFB341"

/obj/effect/turf_decal/tile/ship/red
	name = "red corner"
	color = "#DE3A3A"

/obj/effect/turf_decal/tile/ship/bar
	name = "bar corner"
	color = "#791500"

/obj/effect/turf_decal/tile/ship/purple
	name = "purple corner"
	color = "#D381C9"

/obj/effect/turf_decal/tile/ship/brown
	name = "brown corner"
	color = "#A46106"

/obj/effect/turf_decal/tile/ship/neutral
	name = "neutral corner"
	color = "#D4D4D4"

/obj/effect/turf_decal/tile/ship/half
	name = "tile decal"
	icon = 'nsv13/icons/turf/decals.dmi'
	icon_state = "borderhalf"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/tile/ship/half/blue
	name = "blue corner"
	color = "#52B4E9"

/obj/effect/turf_decal/tile/ship/half/green
	name = "green corner"
	color = "#9FED58"

/obj/effect/turf_decal/tile/ship/half/yellow
	name = "yellow corner"
	color = "#EFB341"

/obj/effect/turf_decal/tile/ship/half/red
	name = "red corner"
	color = "#DE3A3A"

/obj/effect/turf_decal/tile/ship/half/bar
	name = "bar corner"
	color = "#791500"

/obj/effect/turf_decal/tile/ship/half/purple
	name = "purple corner"
	color = "#D381C9"

/obj/effect/turf_decal/tile/ship/half/brown
	name = "brown corner"
	color = "#A46106"

/obj/effect/turf_decal/tile/ship/half/neutral
	name = "neutral corner"
	color = "#D4D4D4"

/obj/effect/turf_decal/tile/ship/full
	name = "tile decal"
	icon = 'nsv13/icons/turf/decals.dmi'
	icon_state = "borderfull"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/tile/ship/full/blue
	name = "blue corner"
	color = "#52B4E9"

/obj/effect/turf_decal/tile/ship/full/green
	name = "green corner"
	color = "#9FED58"

/obj/effect/turf_decal/tile/ship/full/yellow
	name = "yellow corner"
	color = "#EFB341"

/obj/effect/turf_decal/tile/ship/full/red
	name = "red corner"
	color = "#DE3A3A"

/obj/effect/turf_decal/tile/ship/full/bar
	name = "bar corner"
	color = "#791500"

/obj/effect/turf_decal/tile/ship/full/purple
	name = "purple corner"
	color = "#D381C9"

/obj/effect/turf_decal/tile/ship/full/brown
	name = "brown corner"
	color = "#A46106"

/obj/effect/turf_decal/tile/ship/full/neutral
	name = "neutral corner"
	color = "#D4D4D4"

/obj/effect/turf_decal/ship
	name = "turf decal"
	icon = 'nsv13/icons/turf/decals.dmi'
	icon_state = "borderfloor"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/ship/outline
	icon_state = "outline"

/obj/effect/turf_decal/ship/borderfloor/gunmetal
	name = "border decal"
	icon = 'nsv13/icons/turf/decals.dmi'
	icon_state = "borderfloor_white"
	color = "#61666A" //Curse you baystation

/obj/effect/turf_decal/ship/borderfloor/gunmetal/corner
	icon_state = "borderfloorcorner_white"

/obj/effect/turf_decal/ship/borderfloor
	name = "border decal"
	icon = 'nsv13/icons/turf/decals.dmi'
	icon_state = "borderfloor"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/ship/borderfloor/corner
	name = "border decal"
	icon_state = "borderfloorcorner"

/obj/effect/turf_decal/ship/borderfloor/corner/alt
	name = "border decal"
	icon_state = "borderfloorcorner2"

/obj/effect/turf_decal/ship/oldtile
	name = "border decal"
	icon_state = "oldtile"

/obj/effect/turf_decal/ship/rust
	name = "rust"
	icon_state = "rust"

/obj/effect/turf_decal/ship/shutoff
	name = "power shutoff"
	icon_state = "shutoff"

/obj/effect/turf_decal/ship/techfloor
	name = "border decal"
	icon_state = "techfloor_edges"

/obj/effect/turf_decal/ship/techfloor/grid
	name = "border decal"
	icon_state = "techfloor_grid"

/obj/effect/turf_decal/ship/techfloor/grey
	name = "border decal"
	icon_state = "techfloor_grey"

/obj/effect/turf_decal/ship/techfloor/corner
	name = "border decal"
	icon_state = "techfloor_corners"

/obj/effect/turf_decal/ship/delivery
	name = "delivery"
	icon_state = "delivery"

/obj/effect/turf_decal/ship/delivery/yellow
	name = "delivery"
	icon_state = "delivery"
	color = "#DCDC4B"


//3/4 signs stolen from bay
/obj/structure/sign/ship
	icon = 'nsv13/icons/obj/decals.dmi'

/obj/structure/sign/ship/space
	name = "WARNING: HARD VACUUM AHEAD"
	icon_state = "space"

/obj/structure/sign/ship/fire
	name = "Fire hazard"
	icon_state = "fire"

/obj/structure/sign/ship/nosmoking
	name = "No smoking"
	icon_state = "nosmoking"

/obj/structure/sign/ship/smoking
	name = "Smoking area"
	icon_state = "smoking"

/obj/structure/sign/ship/securearea
	name = "CAUTION: SECURE AREA"
	icon_state = "securearea"

/obj/structure/sign/ship/securearea/alt
	name = "CAUTION: SECURE AREA"
	icon_state = "securearea2"

/obj/structure/sign/ship/armoury
	name = "Weapons locker"
	icon_state = "armory"

/obj/structure/sign/ship/server
	name = "Server room"
	icon_state = "server"

/obj/structure/sign/ship/shock
	name = "CAUTION: HIGH VOLTAGE"
	icon_state = "shock"

/obj/structure/sign/ship/hikpa
	name = "CAUTION: HIGH PRESSURE"
	icon_state = "hikpa"

/obj/structure/sign/ship/mail
	name = "Mail"
	icon_state = "mail"

/obj/structure/sign/ship/radiation
	name = "CAUTION: RADIATION"
	icon_state = "radiation"

/obj/structure/sign/ship/examroom
	name = "Examination room"
	icon_state = "examroom"

/obj/structure/sign/ship/science
	name = "Research and development"
	icon_state = "science"

/obj/structure/sign/ship/chemistry
	name = "Chemistry"
	icon_state = "chemistry"

/obj/structure/sign/ship/medical
	name = "Medbay"
	icon_state = "bluecross2"

/obj/structure/sign/ship/plaque
	name = "Dedication plaque"
	desc = "A plaque with several things written on it."
	icon_state = "lightplaque"

/obj/structure/sign/ship/plaque/dark
	icon_state = "darkplaque"

/obj/structure/sign/ship/plaque/light
	icon_state = "lightplaquealt"

/obj/structure/sign/ship/plaque/examine(mob/user)
	. = ..()
	var/obj/structure/overmap/scream = get_overmap()
	to_chat(user, "<span class='notice'>This plaque records those who attended the launching ceremony of the ship you're on. <br> This plaque names the ship as: <b>[scream?.name]</b> </span>")

/obj/structure/sign/ship/pods
	name = "Escape pods"
	icon_state = "podsnorth"

/obj/structure/sign/ship/pods/north
	icon_state = "podssouth"

/obj/structure/sign/ship/pods/east
	icon_state = "podseast"

/obj/structure/sign/ship/pods/west
	icon_state = "podswest"

/obj/structure/sign/ship/deck
	name = "Deck 1"
	icon_state = "deck-1"

/obj/structure/sign/ship/deck/two
	name = "Deck 2"
	icon_state = "deck-2"

/obj/structure/sign/ship/deck/three
	name = "Deck 3"
	icon_state = "deck-3"

/obj/structure/sign/ship/deck/four
	name = "Deck 4"
	icon_state = "deck-4"

/obj/structure/sign/ship/deck/five
	name = "Deck 5"
	icon_state = "deck-5"
