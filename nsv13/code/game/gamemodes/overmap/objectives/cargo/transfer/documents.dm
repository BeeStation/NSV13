/datum/overmap_objective/cargo/transfer/documents
	name = "Deliver secure documents"
	desc = "Deliver secure documents"

/datum/overmap_objective/cargo/transfer/documents/New() 
	var/datum/cargo_item_type/object/C = new /datum/cargo_item_type/object( new /obj/item/documents() )
	C.prepackage_item = TRUE
	C.overmap_objective = src
	cargo_item_types += C
