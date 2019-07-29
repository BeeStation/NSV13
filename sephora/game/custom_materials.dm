//Metals

/obj/item/stack/sheet/duranium
	name = "duranium sheet"
	desc = "This sheet is an extra durable alloy of durasteel and plasteel."
	icon = 'sephora/icons/obj/custom_stack_objects.dmi'
	icon_state = "sheet-duranium"
	item_state = "sheet-duranium"
	throwforce = 10
	flags_1 = CONDUCT_1
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/duranium
	turf_type = /turf/closed/wall/ship

/obj/item/stack/sheet/duranium/twenty
	amount = 20

/obj/item/stack/sheet/duranium/fifty
	amount = 50

GLOBAL_LIST_INIT(durasteel_recipes, list ( \
	new/datum/stack_recipe("nanoweave plating", /obj/item/stack/tile/carpet/ship, 1, 4, 20),
	new/datum/stack_recipe("durasteel hull plating", /obj/item/stack/tile/plasteel/ship, 1, 4, 20), \
	new/datum/stack_recipe("riveted hull plating", /obj/item/stack/tile/plasteel/ship/riveted, 1, 4, 20), \
	new/datum/stack_recipe("padded steel hull plating", /obj/item/stack/tile/plasteel/padded, 1, 4, 20), \
	new/datum/stack_recipe("embossed hull plating", /obj/item/stack/tile/plasteel/ship/techfloor, 1, 4, 20), \
	new/datum/stack_recipe("embossed hull plating - alt", /obj/item/stack/tile/plasteel/ship/techfloor/alt, 1, 4, 20), \
	))

/obj/item/stack/sheet/durasteel
	name = "durasteel sheet"
	desc = "This sheet is a durable alloy of iron and silver."
	icon = 'sephora/icons/obj/custom_stack_objects.dmi'
	icon_state = "sheet-durasteel"
	item_state = "sheet-durasteel"
	throwforce = 10
	flags_1 = CONDUCT_1
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/durasteel
	turf_type = /turf/closed/wall/r_wall/ship

/obj/item/stack/sheet/durasteel/twenty
	amount = 20

/obj/item/stack/sheet/durasteel/fifty
	amount = 50

/obj/item/stack/sheet/durasteel/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.durasteel_recipes
	return ..()