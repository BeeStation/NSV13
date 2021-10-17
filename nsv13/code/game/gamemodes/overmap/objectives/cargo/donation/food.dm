/datum/overmap_objective/cargo/donation/food 
	name = "Donate food"
	desc = "Donate food"
	crate_name = "Buffet crate"

/datum/overmap_objective/cargo/donation/food/New()
	var/picked = get_random_food()
	var/datum/cargo_item_type/object/C = new /datum/cargo_item_type/object( new picked() )
	C.target = rand( 1, 3 )
	cargo_item_types += C
