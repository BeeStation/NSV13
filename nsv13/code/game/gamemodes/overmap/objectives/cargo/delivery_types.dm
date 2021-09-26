
// List of specifically defined cargo_objective types so the objective knows how to handle a specific item  
// If you're planning to deliver multiple different items to the same location, create one objective for each item and manually assign all objectives to the same location

/datum/cargo_item_type
	// target is an arbitrary number to track how many units have been delivered. 
	// target can be an amount of objects, a count of minerals, or a unit of reagents 
	var/target = 0 
	// tally is an arbitrary number that represents a percent of target 
	var/tally = 0 

/datum/cargo_item_type/proc/check_contents( var/obj/container ) 
	// This is a default item type, it has no item information to compare! 
	// Stations call this proc, the cargo_item_type datum handles the rest 
	// PLEASE do not put areas inside freight torps this WILL cause problems! 
	return FALSE 

// Handheld item type objectives 

/datum/cargo_item_type/object 
	var/obj/item = null 
	target = 1

/datum/cargo_item_type/object/check_contents( var/obj/container )
	message_admins( "generic check_contents" )
	var/obj/object = recursive_locate( item, container )
	message_admins( object )
	return object

/datum/cargo_item_type/object/mineral 
	target = 50

/datum/cargo_item_type/object/mineral/check_contents( var/obj/container )
	message_admins( "generic check_contents" )
	var/obj/item/stack/sheet/mineral/object = recursive_locate( item, container )
	message_admins( object )
	var/success = ( object.amount > target )
	return success

// Reagent type cargo objectives 

/datum/cargo_item_type/reagent 
	var/reagent = null
	var/list/containers = list( // We're not accepting chemicals in food 
		/obj/item/reagent_containers/spray,
		/obj/item/reagent_containers/glass,
		/obj/item/reagent_containers/chemtank
	)
	target = 30 // Standard volume of a bottle 

/datum/cargo_item_type/reagent/check_contents( var/obj/container )
	message_admins( "reagent check_contents" )
	var/obj/item/reagent_containers/object = locate( /obj/item/reagent_containers/glass ) in container
	message_admins( object )
	var/datum/reagents/R = object.reagents 
	var/success = R.has_reagent( reagent, target )
	message_admins( success )
	return success

/datum/cargo_item_type/reagent/blood 
	reagent = /datum/reagent/blood
	var/blood_type = null
	containers = list(
		/obj/item/reagent_containers/blood
	)
	target = 200 // Standard volume of a blood pack 

/datum/cargo_item_type/reagent/blood/check_contents( var/obj/container )
	message_admins( "reagent check_contents" )
	var/object = locate( /obj/item/reagent_containers/blood ) in container
	message_admins( object )
