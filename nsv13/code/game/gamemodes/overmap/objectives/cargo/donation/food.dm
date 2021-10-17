/datum/overmap_objective/cargo/donation/food 
	name = "Donate food"
	desc = "Donate food"
	crate_name = "Buffet crate"

/datum/overmap_objective/cargo/donation/food/New()
	var/picked = get_random_food()
	var/datum/freight_type/object/C = new /datum/freight_type/object( new picked() )
	C.target = rand( 1, 3 )
	freight_types += C
