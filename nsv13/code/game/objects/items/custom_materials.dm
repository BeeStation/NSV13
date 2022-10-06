//Metals

GLOBAL_LIST_INIT(duranium_recipes, list (\
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
