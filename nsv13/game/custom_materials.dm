//Metals

GLOBAL_LIST_INIT(duranium_recipes, list (\
	new/datum/stack_recipe("railgun rail", /obj/item/ship_weapon/parts/railgun_rail, 1, time = 20, one_per_turf = FALSE, on_floor = TRUE) \
	))

/obj/item/stack/sheet/duranium
	name = "duranium sheet"
	desc = "This sheet is an extra durable alloy of durasteel and plasteel."
	icon = 'nsv13/icons/obj/custom_stack_objects.dmi'
	icon_state = "sheet-duranium"
	item_state = "sheet-duranium"
	sheettype = "duranium"
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
	))

/obj/item/stack/sheet/durasteel
	name = "durasteel sheet"
	desc = "This sheet is a durable alloy of iron and silver."
	icon = 'nsv13/icons/obj/custom_stack_objects.dmi'
	icon_state = "sheet-durasteel"
	item_state = "sheet-durasteel"
	sheettype = "durasteel"
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
	new/datum/stack_recipe("nanocarbon reinforced fulltile window", /obj/structure/window/reinforced/fulltile/ship, 2, time = 60, one_per_turf = TRUE, on_floor = TRUE) \
	))

/obj/item/stack/sheet/nanocarbon_glass
	name = "nanocarbon glass"
	desc = "This glass sheet is reinforced with a nanocarbon weave."
	icon = 'nsv13/icons/obj/custom_stack_objects.dmi'
	icon_state = "sheet-nanocarbon-glass"
	item_state = "sheet-nanocarbon-glass"
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