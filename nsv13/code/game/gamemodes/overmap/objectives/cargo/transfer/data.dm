/datum/overmap_objective/cargo/transfer/data 
	name = "Deliver data chip"
	desc = "Deliver a disk with arbitrary data under the table"

/datum/overmap_objective/cargo/transfer/data/New() 
	var/datum/cargo_item_type/object/C = new /datum/cargo_item_type/object( new /obj/item/disk/tech_disk() )
	C.prepackage_item = TRUE
	C.overmap_objective = src
	cargo_item_types += C
