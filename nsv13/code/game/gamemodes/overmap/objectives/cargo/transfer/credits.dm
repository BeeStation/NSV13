/datum/overmap_objective/cargo/transfer/credits 
	name = "Deliver credits"
	desc = "Deliver credits under the table"

/datum/overmap_objective/cargo/transfer/credits/New() 
	var/datum/cargo_item_type/object/credits/C = new /datum/cargo_item_type/object/credits( new /obj/item/holochip() )
	C.target = rand( 3, 15 ) * 1000
	C.prepackage_item = TRUE
	C.overmap_objective = src
	cargo_item_types += C
