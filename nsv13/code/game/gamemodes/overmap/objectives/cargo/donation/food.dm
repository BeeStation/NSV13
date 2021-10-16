/datum/overmap_objective/cargo/donation/food 
	name = "Donate food"
	desc = "Donate food"

/datum/overmap_objective/cargo/donation/food/New()
	var/picked = get_random_food()
	cargo_item_types += new /datum/cargo_item_type/object( new picked() )
