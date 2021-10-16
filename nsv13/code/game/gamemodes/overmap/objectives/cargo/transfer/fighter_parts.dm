/datum/overmap_objective/cargo/transfer/fighter_parts
	name = "Deliver fighter parts"
	desc = "Deliver fighter parts"

/datum/overmap_objective/cargo/transfer/fighter_parts/New() 
	var/list/possible_components = list()

	for( var/C in subtypesof( /obj/item/fighter_component ) )
		possible_components += C

	for ( var/i = 0; i < rand( 2, 4 ); i++ ) 
		var/picked = pick( possible_components )
		var/datum/cargo_item_type/object/C = new /datum/cargo_item_type/object( new picked() )
		C.prepackage_item = TRUE
		C.overmap_objective = src
		cargo_item_types += C
