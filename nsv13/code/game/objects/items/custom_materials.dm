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
	new/datum/stack_recipe("durasteel hull plating", /obj/item/stack/tile/plasteel/ship, 1, 4, 20), \
	new/datum/stack_recipe("riveted hull plating", /obj/item/stack/tile/plasteel/ship/riveted, 1, 4, 20), \
	new/datum/stack_recipe("padded steel hull plating", /obj/item/stack/tile/plasteel/padded, 1, 4, 20), \
	new/datum/stack_recipe("embossed hull plating", /obj/item/stack/tile/plasteel/ship/techfloor, 1, 4, 20), \
	new/datum/stack_recipe("embossed hull plating - alt", /obj/item/stack/tile/plasteel/ship/techfloor/alt, 1, 4, 20), \
	new/datum/stack_recipe("steel monotile", /obj/item/stack/tile/mono/steel, 1, 4, 20), \
	new/datum/stack_recipe("dark monotile", /obj/item/stack/tile/mono/dark, 1, 4, 20), \
	new/datum/stack_recipe("light monotile", /obj/item/stack/tile/mono/light, 1, 4, 20), \
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
	desc = "A regular dursasteel tile. Those could work as a pretty decent throwing weapon."
	icon = 'nsv13/icons/turf/floors.dmi'
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
	"riveted durasteel tile", \
	"padded durasteel tile", \
	"embossed durasteel tile", \
	"alt embossed durasteel tile", \

	)

/obj/item/stack/tile/durasteel/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Ctrl-click to change the tile type.</span>"

/obj/item/stack/tile/durasteel/CtrlClick(mob/user)
	. = ..()
	if(loc == user.contents && (!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user))) && !is_cyborg)
		var/tiletype = input(user, "Which type of tile do you want to change to?" as anything in tilelist)
		switch(tiletype)
			if("durasteel tile")


/obj/item/stack/tile/plasteel/ship
	name = "durasteel hull plating tile"
	singular_name = "durasteel hull plating tile"
	desc = "A regular durasteel hull plating tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "durasteel_tile"
	turf_type = /turf/open/floor/plasteel/ship

/obj/item/stack/tile/plasteel/ship/riveted
	name = "riveted steel hull plating tile"
	singular_name = "riveted steel hull plating tile"
	desc = "A regular riveted steel hull plating tile"
	icon_state = "riveted_tile"
	turf_type = /turf/open/floor/plasteel/ship/riveted

/obj/item/stack/tile/plasteel/ship/padded
	name = "padded steel hull plating tile"
	singular_name = "padded steel hull plating tile"
	desc = "A regular padded steel hull plating tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "padded_tile"
	turf_type = /turf/open/floor/plasteel/ship/padded

/obj/item/stack/tile/plasteel/ship/techfloor
	name = "embossed hull plating tile"
	singular_name = "embossed hull plating tile"
	desc = "A regular embossed hull plating tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "eris_techfloor_tile"
	turf_type = /turf/open/floor/plasteel/ship/techfloor

/obj/item/stack/tile/plasteel/ship/techfloor/alt
	name = "embossed hull plating tile"
	singular_name = "embossed hull plating tile"
	desc = "A regular embossed hull plating tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "eris_techfloor_alt_tile"
	turf_type = /turf/open/floor/plasteel/ship/techfloor/alt

/obj/item/stack/tile/plasteel/grid/mono
	name = "steel hull plating tile"
	singular_name = "steel hull plating tile"
	desc = "A regular steel hull plating tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "steel_tile"
	turf_type = /turf/open/floor/plasteel/grid/mono

/obj/item/stack/tile/plasteel/grid/lino
	name = "linoleum hull plating tile"
	singular_name = "linoleum hull plating tile"
	desc = "A regular linoleum hull plating tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "lino_tile"
	turf_type = /turf/open/floor/plasteel/grid/lino

/obj/item/stack/tile/plasteel/grid/techfloor
	name = "techfloor tile"
	singular_name = "techfloor hull plating tile"
	desc = "A regular techfloor hull plating tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "techfloor_tile"
	turf_type = /turf/open/floor/plasteel/grid/lino

/obj/item/stack/tile/plasteel/grid/techfloor/grid
	name = "techfloor tile"
	singular_name = "techfloor hull plating tile"
	desc = "A regular techfloor hull plating tile"
	icon = 'nsv13/icons/turf/floors.dmi'
	icon_state = "techfloor_grid_tile"
	turf_type = /turf/open/floor/plasteel/grid/techfloor/grid

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
