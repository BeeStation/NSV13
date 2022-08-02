//Metals

GLOBAL_LIST_INIT(duranium_recipes, list ( \
	new/datum/stack_recipe("railgun rail", /obj/item/ship_weapon/parts/railgun_rail, 1, time = 20, one_per_turf = FALSE, on_floor = TRUE), \
	new/datum/stack_recipe("mac barrel", /obj/item/ship_weapon/parts/mac_barrel, 1, time = 20, one_per_turf = FALSE, on_floor = TRUE), \
	))

/obj/item/stack/sheet/duranium
	name = "duranium"
	singular_name = "duranium sheet"
	desc = "This sheet is an extra durable alloy of durasteel and plasteel."
	icon = 'nsv13/icons/obj/custom_stack_objects.dmi'
	icon_state = "sheet-duranium"
	item_state = "sheet-duranium"
	sheettype = "duranium"
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT, /datum/material/plasma = MINERAL_MATERIAL_AMOUNT/2, /datum/material/silver = MINERAL_MATERIAL_AMOUNT/2)
	throwforce = 10
	flags_1 = CONDUCT_1
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/duranium
	turf_type = /turf/closed/wall/r_wall/ship

/obj/item/stack/sheet/duranium/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.duranium_recipes
	return ..()

/obj/item/stack/sheet/duranium/twenty
	amount = 20

/obj/item/stack/sheet/duranium/fifty
	amount = 50

GLOBAL_LIST_INIT(durasteel_recipes, list ( \
	new/datum/stack_recipe("nanoweave plating", /obj/item/stack/tile/carpet/ship, 1, 4, 20), \
	new/datum/stack_recipe("durasteel hull plating", /obj/item/stack/tile/durasteel, 1, 4, 20), \
	new/datum/stack_recipe("durasteel hull plating - alt", /obj/item/stack/tile/durasteel/alt, 1, 4, 20), \
	new/datum/stack_recipe("riveted hull plating", /obj/item/stack/tile/durasteel/riveted, 1, 4, 20), \
	new/datum/stack_recipe("padded steel hull plating", /obj/item/stack/tile/durasteel/padded, 1, 4, 20), \
	new/datum/stack_recipe("embossed hull plating", /obj/item/stack/tile/durasteel/eris_techfloor, 1, 4, 20), \
	new/datum/stack_recipe("embossed hull plating - alt", /obj/item/stack/tile/durasteel/eris_techfloor_alt, 1, 4, 20), \
	new/datum/stack_recipe("techfloor", /obj/item/stack/tile/durasteel/mono_steel, 1, 4, 20), \
	new/datum/stack_recipe("tech plating", /obj/item/stack/tile/durasteel/mono_steel, 1, 4, 20), \
	new/datum/stack_recipe("steel monotile", /obj/item/stack/tile/durasteel/mono_steel, 1, 4, 20), \
	new/datum/stack_recipe("dark monotile", /obj/item/stack/tile/durasteel/mono_dark, 1, 4, 20), \
	new/datum/stack_recipe("light monotile", /obj/item/stack/tile/durasteel/mono_light, 1, 4, 20), \
	new/datum/stack_recipe("monofloor", /obj/item/stack/tile/durasteel/monofloor, 1, 4, 20) \
	))

/obj/item/stack/sheet/durasteel
	name = "durasteel"
	singular_name = "durasteel sheet"
	desc = "This sheet is a durable alloy of iron and silver."
	icon = 'nsv13/icons/obj/custom_stack_objects.dmi'
	icon_state = "sheet-durasteel"
	item_state = "sheet-durasteel"
	sheettype = "durasteel"
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT, /datum/material/silver = MINERAL_MATERIAL_AMOUNT)
	throwforce = 10
	flags_1 = CONDUCT_1
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/durasteel
	turf_type = /turf/closed/wall/ship

/obj/item/stack/sheet/durasteel/twenty
	amount = 20

/obj/item/stack/sheet/durasteel/fifty
	amount = 50

/obj/item/stack/sheet/durasteel/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.durasteel_recipes
	return ..()

GLOBAL_LIST_INIT(nanocarbon_glass_recipes, list (\
	new/datum/stack_recipe("nanocarbon reinforced fulltile window", /obj/structure/window/reinforced/fulltile/ship/unanchored, 2, time = 0, on_floor = TRUE, window_checks = TRUE) \
	))

/obj/item/stack/sheet/nanocarbon_glass
	name = "nanocarbon glass"
	singular_name = "nanocarbon glass sheet"
	desc = "This glass sheet is reinforced with a nanocarbon weave."
	icon = 'nsv13/icons/obj/custom_stack_objects.dmi'
	icon_state = "sheet-nanocarbon-glass"
	item_state = "sheet-nanocarbon-glass"
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT, /datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	throwforce = 10
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/nanocarbon_glass

/obj/item/stack/sheet/nanocarbon_glass/twenty
	amount = 20

/obj/item/stack/sheet/nanocarbon_glass/fifty
	amount = 50

/obj/item/stack/sheet/nanocarbon_glass/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.nanocarbon_glass_recipes
	return ..()

//NSV floor tiles

/obj/item/stack/tile/durasteel
	name = "durasteel floor tile"
	singular_name = "durasteel floor tile"
	desc = "A durasteel tile. Those could work as a pretty decent throwing weapon."
	icon = 'nsv13/icons/obj/custom_tiles.dmi'
	icon_state = "durasteel_tile"
	force = 6
	materials = list(/datum/material/iron=500, /datum/material/silver=500)
	throwforce = 10
	flags_1 = CONDUCT_1
	turf_type = /turf/open/floor/durasteel
	mineralType = "durasteel"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70, "stamina" = 0)
	resistance_flags = FIRE_PROOF
	var/list/tilelist = list( \
	"durasteel tile", \
	"durasteel tile - alt", \
	"riveted durasteel tile", \
	"padded durasteel tile", \
	"embossed durasteel tile", \
	"embossed durasteel tile - alt", \
	"linoleum", \
	"techfloor tile", \
	"tech plating tile", \
	"monotile", \
	"dark monotile", \
	"light monotile", \
	"monofloor" \
	)

/obj/item/stack/tile/durasteel/Initialize(mapload, amount)
	. = ..()
	var/static/list/options = list()
	for(var/option in tilelist) //Just hardcoded for now!
		options[option] = image(icon = 'nsv13/icons/turf/floors.dmi', icon_state = option)

/obj/item/stack/tile/durasteel/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Ctrl-click to change the tile type.</span>"

/obj/item/stack/tile/durasteel/CtrlClick(mob/user)
	. = ..()
	if(loc == user.contents && (!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user))) && !is_cyborg)
		show_radial_menu(user, user, options)

/obj/item/stack/tile/durasteel/alt
	icon_state = "durasteel_tile_alt"
	turf_type = /turf/open/floor/durasteel/alt

/obj/item/stack/tile/durasteel/riveted
	icon_state = "riveted_tile"
	turf_type = /turf/open/floor/durasteel/riveted

/obj/item/stack/tile/durasteel/padded
	icon_state = "padded_tile"
	turf_type = /turf/open/floor/durasteel/padded

/obj/item/stack/tile/durasteel/eris_techfloor
	icon_state = "eris_techfloor_tile"
	turf_type = /turf/open/floor/durasteel/eris_techfloor

/obj/item/stack/tile/durasteel/eris_techfloor_alt
	icon_state = "eris_techfloor_alt_tile"
	turf_type = /turf/open/floor/durasteel/eris_techfloor_alt

/obj/item/stack/tile/durasteel/lino
	icon_state = "lino_tile"
	turf_type = /turf/open/floor/durasteel/lino

/obj/item/stack/tile/durasteel/techfloor
	icon_state = "techfloor_tile"
	turf_type = /turf/open/floor/durasteel/techfloor

/obj/item/stack/tile/durasteel/techfloor_grid
	icon_state = "techfloor_grid_tile"
	turf_type = /turf/open/floor/durasteel/techfloor_grid

/obj/item/stack/tile/durasteel/mono_steel
	icon_state = "monotile_steel"
	turf_type = /turf/open/floor/monotile/steel

/obj/item/stack/tile/durasteel/mono_dark
	icon_state = "monotile_dark"
	turf_type = /turf/open/floor/monotile/dark

/obj/item/stack/tile/durasteel/mono_light
	icon_state = "monotile_light"
	turf_type = /turf/open/floor/monotile/light

/obj/item/stack/tile/durasteel/monofloor
	icon_state = "monofloor_tile"
	turf_type = /turf/open/floor/monofloor
//carpet

/obj/item/stack/tile/carpet/ship
	name = "nanoweave carpet tile"
	singular_name = "nanoweave carpet tile"
	desc = "A regular nanoweave carpet tile"
	icon = 'nsv13/icons/turf/dark_carpet.dmi'
	icon_state = "dark_carpet_tile"
	resistance_flags = FLAMMABLE
	turf_type = /turf/open/floor/carpet/ship

/obj/item/stack/tile/carpet/ship/blue
	name = "nanoweave carpet tile (blue)"
	icon = 'nsv13/icons/turf/blue_carpet.dmi'
	icon_state = "blue_carpet_tile"
	turf_type = /turf/open/floor/carpet/ship/blue

/obj/item/stack/tile/carpet/ship/orange_carpet
	name = "nanoweave carpet tile (orange)"
	icon = 'nsv13/icons/turf/orange_carpet.dmi'
	icon_state = "orange_carpet_tile"
	turf_type = /turf/open/floor/carpet/ship/orange_carpet

/obj/item/stack/tile/carpet/ship/purple_carpet
	name = "nanoweave carpet tile (purple)"
	icon = 'nsv13/icons/turf/purple_carpet.dmi'
	icon_state = "purple_carpet_tile"
	turf_type = /turf/open/floor/carpet/ship/purple_carpet

/obj/item/stack/tile/carpet/ship/beige_carpet
	name = "nanoweave carpet tile (beige)"
	icon = 'nsv13/icons/turf/beige_carpet.dmi'
	icon_state = "beige_carpet_tile"
	turf_type = /turf/open/floor/carpet/ship/beige_carpet

/obj/item/stack/tile/carpet/ship/red_carpet
	name = "nanoweave carpet tile (red)"
	icon = 'nsv13/icons/turf/beige_carpet.dmi'
	icon_state = "red_carpet_tile"
	turf_type = /turf/open/floor/carpet/ship/red_carpet
