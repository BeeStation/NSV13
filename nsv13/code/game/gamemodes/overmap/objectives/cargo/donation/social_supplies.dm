/datum/overmap_objective/cargo/donation/social_supplies
	name = "Donate social supplies"
	desc = "Donate 1 or more social supplies"

/datum/overmap_objective/cargo/donation/social_supplies/New() 
	var/datum/cargo_item_type/object/cake = new /datum/cargo_item_type/object( new /obj/item/reagent_containers/food/snacks/store/cake )
	var/datum/cargo_item_type/reagent/drinks = new /datum/cargo_item_type/reagent( subtypesof( /datum/reagent/consumable/ethanol ) )
	drinks.target = 200
	var/datum/cargo_item_type/reagent/presents = new /datum/cargo_item_type/object( /obj/item/smallDelivery )
	presents.target = 3

	cargo_item_types += cake
	cargo_item_types += drinks
	cargo_item_types += presents
