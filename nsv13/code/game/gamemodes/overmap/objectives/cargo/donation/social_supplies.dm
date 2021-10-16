/datum/overmap_objective/cargo/donation/social_supplies
	name = "Donate social supplies"
	desc = "Donate 1 or more social supplies"

/datum/overmap_objective/cargo/donation/social_supplies/New() 
	var/list/picked = pick( list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain,
		/obj/item/reagent_containers/food/snacks/store/cake/carrot,
		/obj/item/reagent_containers/food/snacks/store/cake/birthday,
		/obj/item/reagent_containers/food/snacks/store/cake/cheese,
		/obj/item/reagent_containers/food/snacks/store/cake/chocolate,
		/obj/item/reagent_containers/food/snacks/store/cake/holy_cake,
		/obj/item/reagent_containers/food/snacks/store/cake/pound_cake,
	) )
	var/datum/cargo_item_type/object/cake = new /datum/cargo_item_type/object( new picked() )
	var/datum/cargo_item_type/reagent/drinks = new /datum/cargo_item_type/reagent( subtypesof( /datum/reagent/consumable/ethanol ) )
	drinks.target = 200
	var/datum/cargo_item_type/reagent/presents = new /datum/cargo_item_type/object( new /obj/item/smallDelivery() )
	presents.target = 3

	cargo_item_types += cake
	cargo_item_types += drinks
	cargo_item_types += presents
