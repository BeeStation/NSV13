/turf/open/floor/carpet/ship
	name = "nanoweave carpet"
	desc = "A padded piece of hull plating which can make a space based installation feel more homely."
	icon = 'nsv13/icons/turf/dark_carpet.dmi'
	icon_state = "dark_carpet"
	base_icon_state = "dark_carpet"
	floor_tile = /obj/item/stack/tile/carpet/ship
	canSmoothWith = null

/turf/open/floor/black/airless
	name = "black floor"
	icon_state = "black"
	base_icon_state = "black"
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/ship/Initialize(mapload)
	. = ..()
	canSmoothWith = typecacheof(/turf/open/floor/carpet/ship)

/turf/open/floor/carpet/ship/blue
	name = "nanoweave carpet (blue)"
	desc = "A padded piece of hull plating which can make a space based installation feel more homely."
	icon = 'nsv13/icons/turf/blue_carpet.dmi'
	icon_state = "blue_carpet"
	base_icon_state = "blue_carpet"
	floor_tile = /obj/item/stack/tile/carpet/ship/blue

/turf/open/floor/carpet/ship/orange_carpet
	name = "nanoweave carpet (orange)"
	desc = "A padded piece of hull plating which can make a space based installation feel more homely."
	icon = 'nsv13/icons/turf/orange_carpet.dmi'
	icon_state = "orange_carpet"
	base_icon_state = "orange_carpet"
	floor_tile = /obj/item/stack/tile/carpet/ship/orange_carpet

/turf/open/floor/carpet/ship/purple_carpet
	name = "nanoweave carpet (purple)"
	desc = "A padded piece of hull plating which can make a space based installation feel more homely."
	icon = 'nsv13/icons/turf/purple_carpet.dmi'
	icon_state = "purple_carpet"
	base_icon_state = "purple_carpet"
	floor_tile = /obj/item/stack/tile/carpet/ship/purple_carpet

/turf/open/floor/carpet/ship/beige_carpet
	name = "nanoweave carpet (beige)"
	desc = "A padded piece of hull plating which can make a space based installation feel more homely."
	icon = 'nsv13/icons/turf/beige_carpet.dmi'
	icon_state = "beige_carpet"
	base_icon_state = "beige_carpet"
	floor_tile = /obj/item/stack/tile/carpet/ship/beige_carpet

/turf/open/floor/carpet/ship/red_carpet
	name = "nanoweave carpet (red)"
	desc = "A padded piece of hull plating which can make a space based installation feel more homely."
	icon = 'nsv13/icons/turf/red_carpet.dmi'
	icon_state = "red_carpet"
	base_icon_state = "red_carpet"
	floor_tile = /obj/item/stack/tile/carpet/ship/red_carpet

/turf/open/floor/durasteel
	name = "durasteel floor"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "durasteel"
	floor_tile = /obj/item/stack/tile/durasteel
	broken_states = list("durasteel_dam1", "durasteel_dam2", "durasteel_dam3", "durasteel_dam4", "durasteel_dam5")
	burnt_states = list("floorscorched1", "floorscorched2", "floorscorched3", "floorscorched4")

/turf/open/floor/durasteel/alt
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "steel"
	floor_tile = /obj/item/stack/tile/durasteel/alt
	broken_states = list("steel_dam1", "steel_dam2", "steel_dam3", "steel_dam4", "steel_dam5")
	burnt_states = list("steel_scorched1", "steel_schorched2", "steel_scorched3", "steel_scorched4")

/turf/open/floor/durasteel/riveted
	name = "riveted durasteel floor"
	icon_state = "riveted"
	floor_tile = /obj/item/stack/tile/durasteel/riveted
	broken_states = list("riveted_dam1", "riveted_dam2", "riveted_dam3", "riveted_dam4", "riveted_dam5")
	burnt_states = list("riveted_scorched1", "riveted_scorched2", "riveted_scorched3")

/turf/open/floor/durasteel/padded
	name = "padded durasteel floor"
	icon_state = "padded"
	floor_tile = /obj/item/stack/tile/durasteel/padded
	broken_states = list("padded_dam1", "padded_dam2", "padded_dam3", "padded_dam4", "padded_dam5")
	burnt_states = list("padded_scorched1", "padded_scorched2", "padded_scorched3", "padded_scorched4")

/turf/open/floor/durasteel/eris_techfloor //Ported from eris
	name = "embossed durasteel floor"
	icon_state = "eris_techfloor"
	floor_tile = /obj/item/stack/tile/durasteel/techfloor
	broken_states = list("eris_techfloor_dam1", "eris_techfloor_dam2", "eris_techfloor_dam3", "eris_techfloor_dam4", "eris_techfloor_dam5")
	burnt_states = list("eris_techfloor_scorched1", "eris_techfloor_scorched2")

/turf/open/floor/durasteel/eris_techfloor_alt
	name = "durasteel floor"
	icon_state = "eris_techfloor_alt"
	floor_tile = /obj/item/stack/tile/durasteel/eris_techfloor_alt
	broken_states = list("eris_techfloor_alt_dam1", "eris_techfloor_alt_dam2", "eris_techfloor_alt_dam3", "eris_techfloor_alt_dam4", "eris_techfloor_alt_dam5")
	burnt_states = list("eris_techfloor_alt_scorched1", "eris_techfloor_alt_scorched2", "eris_techfloor_alt_scorched3")

/turf/open/floor/durasteel/lino
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "lino"
	floor_tile = /obj/item/stack/tile/durasteel/lino
	broken_states = list("lino_dam1", "lino_dam2")
	burnt_states = list("lino_scorched1")

/turf/open/floor/durasteel/techfloor
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "techfloor"
	floor_tile = /obj/item/stack/tile/durasteel/techfloor
	broken_states = list("techfloor_dam1", "techfloor_dam2")
	burnt_states = list("techfloor_scorched1", "techfloor_scorched2")

/turf/open/floor/durasteel/techfloor_grid
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "techfloor_grid"
	floor_tile = /obj/item/stack/tile/durasteel/techfloor_grid
	broken_states = list("techfloor_grid_dam1")
	burnt_states = list("techfloor_grid_scorched1", "techfloor_grid_scorched2")

/turf/open/floor/durasteel/techfloor_grid/airless
	initial_gas_mix = AIRLESS_ATMOS

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

/turf/open/floor/plasteel/grid/techfloor/grid/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/monofloor/corner
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "steel_monofloor_corner"
	base_icon_state = "steel_monofloor_corner"

/turf/open/floor/plating/rusty_techgrid
	name = "rusted grid plating"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "techfloor_rusted"
	base_icon_state = "techfloor_rusted"
	broken_states = list("techfloor_rusted_dam1", "techfloor_rusted_dam2")
	burnt_states = list("techfloor_rusted_scorched1", "techfloor_rusted_scorched2")

/turf/open/floor/stairs
	name = "stairs"
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairs"
	base_icon_state = "stairs"
