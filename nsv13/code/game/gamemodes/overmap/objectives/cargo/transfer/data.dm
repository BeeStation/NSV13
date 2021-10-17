/datum/overmap_objective/cargo/transfer/data 
	name = "Deliver data chip"
	desc = "Deliver a disk with arbitrary data under the table"
	crate_name = "Secure Data Transfer"

/datum/overmap_objective/cargo/transfer/data/New() 
	var/datum/freight_type/object/C = new /datum/freight_type/object( new /obj/item/disk/tech_disk() )
	C.prepackage_item = TRUE
	C.overmap_objective = src
	freight_types += C
