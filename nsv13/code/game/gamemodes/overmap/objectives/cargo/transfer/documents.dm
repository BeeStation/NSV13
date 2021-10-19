/datum/overmap_objective/cargo/transfer/documents
	name = "Deliver secure documents"
	desc = "Deliver secure documents"
	crate_name = "Secure Documents Transfer"

/datum/overmap_objective/cargo/transfer/documents/New() 
	var/datum/freight_type/object/C = new /datum/freight_type/object( new /obj/item/documents() )
	C.send_prepackaged_item = TRUE
	C.overmap_objective = src
	freight_types += C
