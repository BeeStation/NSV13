/datum/overmap_objective/cargo/transfer/documents
	name = "Deliver secure documents"
	desc = "Deliver secure documents"
	crate_name = "Secure Documents Transfer"
	send_to_station_pickup_point = TRUE

/datum/overmap_objective/cargo/transfer/documents/New()
	..()
	var/datum/freight_type/single/object/C = new /datum/freight_type/single/object( /obj/item/documents )
	C.send_prepackaged_item = TRUE
	C.allow_replacements = FALSE // This is secure data, replacement is not an option
	C.overmap_objective = src
	freight_type_group = new( list( C ) )
