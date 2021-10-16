
// List of specifically defined cargo_objective types so the objective knows how to handle a specific item  
// If you're planning to deliver multiple different items to the same location, create one cargo_item_type for each item and add these to the same objective 

/datum/cargo_item_type
	// You'll want to use the /datum/cargo_item_type/object type for defining a specific item 
	// This should be an initialized object so prepacked delivery objectives can verify the object is identical and untampered 
	// Some cargo types below will default to reagent/amount/credits validation in check_contents if an item is not provided 
	var/atom/item = null

	// target is an arbitrary number to track how many units have been delivered. 
	// target can be an amount of objects, a count of minerals, or a unit of reagents 
	var/target = 1 

	// tally is an arbitrary number that represents a percent of target 
	var/tally = 0 

	// Set to TRUE to automatically place this item in the ship's warehouse, for simpler transfer objectives 
	// If an item is provided in a prepackaged large wooden crate but the players open it, the players can either repackage or source a replacement to deliver 
	// item is a required field if prepackaged_item is true. 
	// overmap_objective is a required field if prepackaged_item is true. 
	var/prepackage_item = FALSE 

	// Get the parent objective for this item type 
	var/datum/overmap_objective/cargo/overmap_objective = null

/datum/cargo_item_type/proc/check_contents( var/obj/container ) 
	// Stations call this proc, the cargo_item_type datum handles the rest 
	// PLEASE do NOT put areas inside freight torps this WILL cause problems! 
	if ( prepackage_item )
		return check_prepackaged_contents( container )
	return FALSE

/datum/cargo_item_type/proc/check_prepackaged_contents( var/obj/container )
	var/list/prepackagedTargets = list()

	for ( var/atom/a in container.GetAllContents() )
		if( istype( a, item ) ) // Is this the item we're looking for? 
			if ( istype( a.loc, /obj/structure/closet/crate/large/cargo_objective ) ) // Is it still in its original container? Ensures the unique item was untouched 
				if ( !prepackagedTargets[ a.type ] ) 
					prepackagedTargets[ a.type ] = 0
				prepackagedTargets[ a.type ]++
				
	if ( prepackagedTargets[ item.type ] && prepackagedTargets[ item.type ] >= target ) 
		// TODO add handling for stations begrudgingly accepting tampered cargo transfers 
		// Due to the nature of objectives rewarding nothing but patrol completion there is no incentive for "bonus points" by leaving cargo untampered, unfortunately 
		return TRUE 

/datum/cargo_item_type/proc/get_brief_segment()
	return "nothing"

/datum/cargo_item_type/proc/deliver_package() 
	if ( prepackage_item )
		var/obj/structure/overmap/MO = SSstar_system.find_main_overmap()
		if(MO)
			var/obj/structure/closet/crate/large/cargo_objective/C = new /obj/structure/closet/crate/large/cargo_objective( src )
			for ( var/i = 0; i < target; i++ )
				C.contents += DuplicateObject( item )
			C.overmap_objective = overmap_objective
			C.cargo_item_type = src
			MO.send_supplypod( C, null, TRUE )
			return TRUE 

// Handheld item type objectives 

/datum/cargo_item_type/object 
	target = 1

/datum/cargo_item_type/object/New( var/obj/object, var/number )
	// Object should be initialized
	if ( object ) 
		item = object 

	if ( number )
		target = number

/datum/cargo_item_type/object/check_contents( var/obj/container )
	if ( ..() ) 
		return TRUE 

	var/list/itemTargets = list()

	for ( var/atom/a in container.GetAllContents() )
		if( istype( a, item ) )
			if ( !itemTargets[ a.type ] ) 
				itemTargets[ a.type ] = 0
			itemTargets[ a.type ]++
				
	if ( itemTargets[ item.type ] && itemTargets[ item.type ] >= target ) 
		return TRUE 

/datum/cargo_item_type/object/get_brief_segment() 
	return "[item.name] ([target])"

/datum/cargo_item_type/object/credits
	target = 10000

/datum/cargo_item_type/object/credits/New( var/number )
	if ( number )
		target = number
	
	var/obj/item/holochip/H = new /obj/item/holochip()
	H.credits = target // Preset value for possible prepackage transfer objectives 
	item = H

/datum/cargo_item_type/object/credits/check_contents( var/obj/container )
	if ( ..() ) 
		return TRUE 

	var/list/itemTargets = list()

	for ( var/obj/item/holochip/a in container.GetAllContents() )
		if( istype( a, item ) )
			if ( !itemTargets[ a.type ] ) 
				itemTargets[ a.type ] = 0
			itemTargets[ a.type ] += a.credits
	
	if ( itemTargets[ item.type ] && itemTargets[ item.type ] >= target ) 
		return TRUE 

/datum/cargo_item_type/object/credits/get_brief_segment() 
	return "[target] credits"

/datum/cargo_item_type/object/mineral 
	target = 50

/datum/cargo_item_type/object/mineral/check_contents( var/obj/container )
	if ( ..() ) 
		return TRUE 

	var/list/itemTargets = list()

	for ( var/obj/item/stack/a in container.GetAllContents() )
		if( istype( a, item ) )
			if ( !itemTargets[ a.type ] ) 
				itemTargets[ a.type ] = 0
			itemTargets[ a.type ] += a.amount
	
	if ( itemTargets[ item.type ] && itemTargets[ item.type ] >= target ) 
		return TRUE 

/datum/cargo_item_type/object/get_brief_segment() 
	return "[item.name] ([target] sheets)"

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
	if ( ..() ) 
		return TRUE 

	var/list/reagentTargets = list() // Capable of summing reagents across multiple containers, useful for massive chemical deliveries! 
	
	for ( var/obj/item/reagent_containers/a in container.GetAllContents() )
		if ( is_type_in_list( a, containers ) )
			var/datum/reagents/reagents = a.reagents
			for ( var/datum/reagent/R in reagents.reagent_list )
				if ( !reagentTargets[ R.type ] ) 
					reagentTargets[ R.type ] = 0
				reagentTargets[ R.type ] += R.volume
	
	if ( reagentTargets[ reagent ] && reagentTargets[ reagent ] >= target ) 
		return TRUE 

/datum/cargo_item_type/reagent/get_brief_segment() 
	return "[reagent.name] ([target] units)"

/datum/cargo_item_type/reagent/blood 
	reagent = /datum/reagent/blood
	var/blood_type = null
	containers = list(
		/obj/item/reagent_containers/blood
	)
	target = 200 // Standard volume of a blood pack 

/datum/cargo_item_type/reagent/blood/New( var/type ) 
	message_admins( "/datum/cargo_item_type/reagent/blood/New" )
	if ( type )
		blood_type = type 

/datum/cargo_item_type/reagent/blood/check_contents( var/obj/container )
	if ( ..() ) 
		return TRUE 

	var/list/bloodTypeTargets = list() // Capable of summing reagents across multiple containers, useful for massive blood bag deliveries! 

	for ( var/obj/item/reagent_containers/a in container.GetAllContents() )
		if ( is_type_in_list( a, containers ) )
			var/datum/reagents/reagents = a.reagents
			for ( var/datum/reagent/blood/R in reagents.reagent_list )
				if ( !bloodTypeTargets[ R.data[ "blood_type" ] ] ) 
					bloodTypeTargets[ R.data[ "blood_type" ] ] = 0
				bloodTypeTargets[ R.data[ "blood_type" ] ] += R.volume

	if ( bloodTypeTargets[ reagent ] && bloodTypeTargets[ reagent ] >= target ) 
		return TRUE 

/datum/cargo_item_type/reagent/blood/get_brief_segment() 
	message_admins( "/datum/cargo_item_type/reagent/blood/get_brief_segment" )
	return "blood type [blood_type] ([target] units)"
