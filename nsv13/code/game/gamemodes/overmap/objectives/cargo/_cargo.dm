
// If you're writing new cargo objectives please perform these test cases: 
// Objective approves when supplying all and only items requested 
// Objective rejects when supplying items requested and any additional trash 
// For objectives with multiple cargo item types or targets greater than 1, rejects when supplying only some of items requested 
// For objectives that send prepackaged items, approves when supplying items that have been removed from its original cargo crate, unless the objective is written to automatically fail on tamper 

/datum/overmap_objective/cargo
	name = "cargo objective"
	// crate_name appears as a crate name when stations return requisition forms to players. 
	// crate_name should be named similarly to cargo supply console crate names 
	var/crate_name = "Approved Shipment"
	binary = TRUE
	extension_supported = FALSE // Players won't enjoy being handed a cargo job after beating up fleets. Review this if we decide to refactor missions later 
	allow_duplicates = TRUE

	// Variables target and tally are automatically handled by the freight_type datum
	// Please set your target and tally amounts when setting up the freight_type datum 
	target = 0 
	tally = 0 
	
	var/destination = null // For knowing who wants what by looking at this objective datum 

	// On proc pick_station, pick_same_destination attempts to find a station that is already expecting cargo. This avoids situations where players are trekking halfway across the universe to deliver two separate items 
	// Set to FALSE if you always want random stations to be picked
	// If you want to ensure your gamemode assigns its destinations correctly with pick_same_destination TRUE and using random_objectives, either choose only objectives with pick_same_destination TRUE, manually set all cargo objectives pick_same_destination to TRUE, or do not use variable random_objectives! When cherrypicking objectives with both pick_same_destination TRUE and FALSE, preorder your cargo missions in list objectives (not random_objectives) by pick_same_destination FALSE first, pick_same_destination TRUE last. This ensures these objectives have applicable stations to pick from. I'm not responsible for destination inconsistency for not following these instructions 
	// TLDR station destinations get funky when a gamemode uses random_objectives to store multiple cargo objectives with pick_same_destination set to TRUE and FALSE, due to how random_objectives randomly selects its objectives 
	var/pick_same_destination = TRUE
	
	// Cargo objectives handle the station's requisitioned item in a special datum so we can control how to check contents  
	// Reminder! Freight torpedoes can only hold 4 slots worth of items! This means cargo objectives should not be requiring more than 4 prepackaged item types 
	var/list/freight_types = list()
	var/last_check_cargo_items_requested = null
	var/last_check_cargo_items_all = null

/datum/overmap_objective/cargo/instance() 
	message_admins(" reset pick_same_destination to FALSE" )
	get_target()
	pick_station()
	update_brief()

/datum/overmap_objective/cargo/proc/get_target()
	if ( length( freight_types ) )
		for( var/datum/freight_type/type in freight_types )
			target += type.target 
	else 
		message_admins( "A cargo objective was assigned with no delivery item types set! Automatically marking as completed" )
		brief = "Succeed"
		status = 1

/datum/overmap_objective/cargo/proc/pick_station()
	// Pick a random existing station to give this objective to 
	var/list/ntstations = list()
	var/list/ntstations_expecting_cargo = list()
	for ( var/trader in SSstar_system.traders )
		var/datum/trader/T = trader
		if ( T.faction_type == FACTION_ID_NT )
			var/obj/structure/overmap/S = T.current_location
			var/obj/structure/overmap/MO = SSstar_system.find_main_overmap()

			if ( S?.current_system.name != MO?.starting_system ) // No transfer objectives to same-system stations on roundstart 
				ntstations += S 
				
				if ( length( S.expecting_cargo ) )
					ntstations_expecting_cargo += S

	var/obj/structure/overmap/S
	if ( pick_same_destination && length( ntstations_expecting_cargo ) )
		S = pick( ntstations_expecting_cargo )
	else 
		S = pick( ntstations )

	// Assign this objective directly to the station, so the station can track it 
	destination = S 
	S.add_objective( src )

/datum/overmap_objective/cargo/proc/deliver_package() 
	for ( var/datum/freight_type/T in freight_types ) 
		if ( !T.deliver_package() )
			message_admins( "A cargo objective failed to deliver a prepackaged item to the ship! Automatically marking the objective as completed." )
			status = 1

/datum/overmap_objective/cargo/proc/update_brief() 
	if ( length( freight_types ) )
		var/list/segments = list()
		for( var/datum/freight_type/type in freight_types )
			segments += type.get_brief_segment() 
		
		var/obj/structure/overmap/S = destination
		brief = "Deliver [segments.Join( ", " )] to station [S] in system [S.current_system]"

/datum/overmap_objective/cargo/donation/update_brief() 
	if ( length( freight_types ) )
		var/list/segments = list()
		for( var/datum/freight_type/type in freight_types )
			segments += type.get_brief_segment() 
		
		var/obj/structure/overmap/S = destination
		brief = "Source and donate [segments.Join( ", " )] to station [S] in system [S.current_system]"

/datum/overmap_objective/cargo/transfer/update_brief() 
	if ( length( freight_types ) )
		var/list/segments = list()
		for( var/datum/freight_type/type in freight_types )
			segments += type.get_brief_segment() 
		
		var/obj/structure/overmap/S = destination
		brief = "Transfer [segments.Join( ", " )] to station [S] in system [S.current_system]"

/datum/overmap_objective/cargo/proc/check_cargo( var/obj/shipment ) 
	message_admins( "check_cargo" )
	if ( length( freight_types ) ) 
		var/all_accounted_for = TRUE 
		
		// Cargo objectives with multiple freight types need to be checked individually, 
		// then the entire container needs checked for non-objective related trash. 
		// Individual freight_type datums cannot check for non-objective trash because they do not have the full context of other freight_types in the same list 
		
		var/list/allContents = shipment.GetAllContents()
		last_check_cargo_items_requested = list()
		last_check_cargo_items_all = allContents
		for( var/datum/freight_type/type in freight_types )
			var/list/item_results = type.check_contents( shipment )
			if ( item_results ) 
				for ( var/atom/i in item_results ) 
					last_check_cargo_items_requested += i
					allContents -= i 
			else 
				// There are missing items in this freight type, we're not going to bother checking the rest  
				all_accounted_for = FALSE 
				break 

		message
		if ( all_accounted_for && !length( allContents ) )
			tally = target // Target is set when the freight_type is assigned 
			status = 1

		message_admins( "[all_accounted_for]" )
		return all_accounted_for
