// When validationg freight types, these common items will be ignored
// This list is also used in ignoring common items for making paperwork
GLOBAL_LIST_INIT( blacklisted_paperwork_itemtypes, typecacheof( list(
	/obj/item/ship_weapon/ammunition/torpedo/freight,
	/obj/structure/closet
	// /obj/item/storage
) ) )

// List of specifically defined freight types so the objective knows how to handle a specific item
// If you're planning to deliver multiple different items to the same location, create one freight_type for each item and add these to the same objective

/datum/freight_type/single
	// You'll want to use the /datum/freight_type/object type for defining a specific item
	// This should be an initialized object so prepacked delivery objectives can verify the object is identical and untampered
	// Some cargo types below will default to reagent/amount/credits validation in check contents proc if an item is not provided
	var/atom/item_type = null
	var/item_name = ""

	// target is an arbitrary number to track how many units have been delivered.
	// target can be an amount of objects, a count of minerals, or a unit of reagents
	var/target = 1

	// tally is an arbitrary number that represents a percent of target
	var/tally = 0

	// If prepackaged mission critical items are tampered or destroyed, allow the crew to transfer these items in generic crates or replace them
	// Alternatively if the objective requires the crew to source and donate an item, allow_replacements TRUE permits submitting sourced items
	// This should be set when a cargo objective creates and self assigns freight_types on initialize.
	// Setting allow_replacements TRUE to a new freight_type and send_prepackaged_item FALSE means the players will never be able to complete it!
	// TODO Update objective failure checks to attach to the prepackaged item destruction somehow, instead of failing on large wooden crate opening
	var/allow_replacements = TRUE

	// Get the parent objective for this item type
	var/datum/overmap_objective/cargo/overmap_objective = null

	// Stores a list of initialized atoms
	// If mission critical items are prepackaged, includes additional supplies in case the crate is "accidentally" opened
	// This packaging is not required for objective completion, and _cargo.dm will filter these items from completion checks.
	// Attempting to replace prepackaging will flag the incoming freight torpedo as trash, and will not complete the objective.
	var/list/additional_prepackaging = list()

	var/last_get_amount = null // vv debug

	// Set to TRUE if we want whatever this item and whatever random items it contains
	// freight_contents_index will pass the item contents in as valid freight
	var/approve_inner_contents = FALSE

	// Set a target of objects that MUST appear inside an approved item_type. See social_supplies.dm wrapped crates for an example of this
	// For when you want something to be submitted but don't care what the wildcard is. If you do care what the wildcard is you should write a new freight_type to track this
	// TODO refactor wildcard inner contents to instead be an object freight_type that checks its loc as part of the check_contents approval process
	var/require_inner_contents = 0

	// Admin debug var, signals if the last shipment returned TRUE on check_contents
	var/last_check_contents_success = FALSE

/datum/freight_type/single/proc/set_item_name( var/custom_name )
	if ( item_name ) // Don't overwrite it
		return TRUE

	if ( custom_name )
		item_name = custom_name
		return TRUE

	if ( item_type )
		// Still don't know how else to get an object's name from a typepath without initializing it
		// Someone please tell me how to not bodge this
		var/obj/structure/closet/C = new
		var/atom/newitem = new item_type( C )
		item_name = newitem.name
		qdel( C )
		return TRUE

	// Can't leave blank fields on the comms console or crew will have no idea how to complete this objective
	item_name = item_type
	return TRUE

// Takes in a list of objects itemTargets, adds inner contents of each object to the input list itemTargets, and returns itemTargets
/datum/freight_type/single/proc/add_inner_contents_as_approved( var/list/itemTargets )
	// Add wildcard contents from inner object contents found in the loop above.
	// Otherwise check_cargo in the parent cargo objective thinks these inner wildcard contents are trash
	var/list/innerContents = list()
	if ( approve_inner_contents )
		for ( var/atom/i in itemTargets )
			for ( var/atom/a in i.GetAllContents() )
				innerContents += a

	if ( require_inner_contents )
		if ( innerContents < length( require_inner_contents ) )
			// We found inner contents that would have been approved, but we want more!
			// Marks freight_type as rejected
			return FALSE

	itemTargets += innerContents

	// Remove additional packaging from trash check
	if ( additional_prepackaging )
		for ( var/atom/a in additional_prepackaging )
			itemTargets += a

	last_get_amount = itemTargets
	return itemTargets


// Stations call this proc, the freight_type datum handles the rest
// PLEASE do NOT put areas inside freight torps this WILL cause problems!
/datum/freight_type/single/check_contents( var/datum/freight_type_check )
	// This datum is the top parent, it is too obtuse to handle any checks
	return FALSE

/datum/freight_type/single/get_item_name()
	return item_name

/datum/freight_type/single/get_target()
	return target

/datum/freight_type/single/proc/get_prepackaged_targets( var/obj/container )
	if ( send_prepackaged_item )
		return check_prepackaged_contents( container )
	return FALSE

// TODO add handling for stations begrudgingly accepting tampered cargo transfers
// Due to the nature of objectives rewarding nothing but patrol completion there is no incentive for "bonus points" by leaving cargo untampered, unfortunately
/datum/freight_type/single/proc/check_prepackaged_contents( var/obj/container )
	if ( !item_type ) // Something or someone forgot to define what the crew is delivering
		return FALSE

	if ( !container )
		return FALSE

	var/datum/freight_contents_index/index = new /datum/freight_contents_index()

	for ( var/atom/a in container.GetAllContents() )
		if( !is_type_in_typecache( a, GLOB.blacklisted_paperwork_itemtypes ) || ( is_type_in_typecache( item_type, GLOB.blacklisted_paperwork_itemtypes ) && is_type_in_typecache( a, GLOB.blacklisted_paperwork_itemtypes ) ) )
			if ( LAZYFIND( prepackaged_items, a ) ) // Is this the item we're looking for?
				// Add to contents index for more checks
				index.add_amount( a, 1 )

	var/list/itemTargets = index.get_amount( item_type, target, TRUE )
	add_inner_contents_as_approved( itemTargets )
	return itemTargets

/datum/freight_type/single/get_brief_segment()
	return "nothing"

/datum/freight_type/single/deliver_package()
	if ( !send_prepackaged_item )
		// This proc is a formality, even if we don't have anything to deliver
		return TRUE

	var/obj/structure/overmap/MO = SSstar_system.find_main_overmap()
	if(MO)
		var/obj/structure/closet/crate/large/freight_objective/C = new /obj/structure/closet/crate/large/freight_objective( src )
		for ( var/i = 0; i < target; i++ )
			// For transfer objectives expecting multiple items of the same type, clones the referenced item
			var/atom/added_item = add_item_to_crate( C )
			if ( added_item )
				prepackaged_items += added_item
		for ( var/atom/packaging in additional_prepackaging )
			C.contents += packaging
		C.overmap_objective = overmap_objective
		C.freight_type = src
		MO.send_supplypod( C, null, TRUE )
		return TRUE

/datum/freight_type/single/proc/add_item_to_crate( var/obj/C )
	var/atom/newitem = new item_type( C )
	if ( item_name )
		newitem.name = item_name

	return newitem
