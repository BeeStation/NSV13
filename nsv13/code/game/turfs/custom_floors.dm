/turf/open/floor/carpet/ship
	name = "nanoweave carpet"
	desc = "A padded piece of hull plating which can make a space based installation feel more homely."
	icon = 'nsv13/icons/turf/dark_carpet.dmi'
	icon_state = "dark_carpet"
	floor_tile = /obj/item/stack/tile/carpet/ship
	canSmoothWith = null

/turf/open/floor/black/airless
	name = "black floor"
	icon_state = "black"
	initial_gas_mix = AIRLESS_ATMOS

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
	color = "#FF8C00"
	light_color = LIGHT_COLOR_ORANGE

/turf/open/floor/monotile/dark/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/monotile/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/monotile/steel/airless
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
