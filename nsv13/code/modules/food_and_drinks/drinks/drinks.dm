/obj/item/reagent_containers/food/drinks/ftliver
	name = "Faster-Than-Liver"
	desc = "They've gone into plaid!"
	icon_state = "ftliver"
	list_reagents = list(/datum/reagent/consumable/ethanol/ftliver = 30)
	foodtype = ALCOHOL

//Duplicate item for map compatibility
/obj/item/reagent_containers/food/drinks/mug/coco
	name = "Dutch hot cocoa"
	desc = "Made in Space South America."
	list_reagents = list(/datum/reagent/consumable/cocoa/hot_cocoa = 15, /datum/reagent/consumable/sugar = 5)
	foodtype = SUGAR
	resistance_flags = FREEZE_PROOF
	custom_price = 42