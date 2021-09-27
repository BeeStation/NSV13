
// List of specifically defined cargo_objective types so the objective knows how to handle a specific item  
// If you're planning to deliver multiple different items to the same location, create one cargo_item_type for each item and add these to the same objective 

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

/datum/cargo_item_type/proc/get_brief_segment()
	return "nothing"

// Handheld item type objectives 

/datum/cargo_item_type/object 
	var/obj/item = null // This should be an initialized object 
	target = 1

/datum/cargo_item_type/object/New( var/obj/object, var/number )
	// Object should be initialized 
	if ( object ) 
		item = object 

	if ( number )
		target = number

/datum/cargo_item_type/object/check_contents( var/obj/container )
	message_admins( "generic check_contents" )
	var/obj/object = recursive_locate( item, container )
	message_admins( object )
	return object

/datum/cargo_item_type/object/get_brief_segment() 
	return "[item.name] ([target])"

/datum/cargo_item_type/object/mineral 
	target = 50

/datum/cargo_item_type/object/mineral/check_contents( var/obj/container )
	message_admins( "generic check_contents" )
	var/obj/item/stack/sheet/mineral/object = recursive_locate( item, container )
	message_admins( object )
	var/success = ( object.amount > target )
	return success

/datum/cargo_item_type/object/get_brief_segment() 
	return "[item] ([target] sheets)"

// Reagent type cargo objectives 

/datum/cargo_item_type/reagent 
	var/datum/reagent/reagent = null
	var/list/containers = list( // We're not accepting chemicals in food 
		/obj/item/reagent_containers/spray,
		/obj/item/reagent_containers/glass,
		/obj/item/reagent_containers/chemtank
	)
	target = 30 // Standard volume of a bottle 

/datum/cargo_item_type/reagent/New( var/datum/reagent/medicine, var/amount ) 
	if ( medicine )
		reagent = medicine 

	if ( amount ) 
		target = amount 

/datum/cargo_item_type/reagent/check_contents( var/obj/container )
	message_admins( "reagent check_contents" )
	var/obj/item/reagent_containers/object = locate( /obj/item/reagent_containers/glass ) in container
	message_admins( object )
	var/datum/reagents/R = object.reagents 
	var/success = R.has_reagent( reagent, target )
	message_admins( success )
	return success

/datum/cargo_item_type/reagent/get_brief_segment() 
	return "[reagent] ([target] units)"

/datum/cargo_item_type/reagent/blood 
	reagent = /datum/reagent/blood
	var/blood_type = null
	containers = list(
		/obj/item/reagent_containers/blood
	)
	target = 200 // Standard volume of a blood pack 

/datum/cargo_item_type/reagent/blood/New( var/type ) 
	if ( type )
		blood_type = type 

/datum/cargo_item_type/reagent/blood/check_contents( var/obj/container )
	message_admins( "reagent check_contents" )
	var/obj/item/reagent_containers/C = locate( /obj/item/reagent_containers/blood ) in container
	message_admins( C )
	// get_safe_blood( C.reagents )

/datum/cargo_item_type/reagent/blood/get_brief_segment() 
	return "blood type [blood_type] or a donor compatible equivalent ([target] units)"
