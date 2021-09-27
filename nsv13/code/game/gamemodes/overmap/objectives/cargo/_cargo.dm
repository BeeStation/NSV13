/datum/overmap_objective/cargo
	name = "cargo objective"
	// crate_name appears as a crate name when stations return requisition forms to players. 
	// crate_name should be named similarly to cargo supply console crate names 
	var/crate_name = "Approved Shipment"
	binary = FALSE
	extension_supported = FALSE // Players won't enjoy being handed a cargo job after beating up fleets. Review this if we decide to refactor missions later 
	allow_duplicates = TRUE

	// Variables target and tally are automatically handled by the cargo_item_type datum
	// Please set your target and tally amounts when setting up the cargo_item_type datum 
	target = 0 
	tally = 0 
	
	var/destination = null // For knowing who wants what by looking at this objective datum 

	// On proc pick_station, pick_same_destination attempts to find a station that is already expecting cargo. This avoids situations where players are trekking halfway across the universe to deliver two separate items 
	// Set to FALSE if you always want random stations to be picked
	// If you want to ensure your gamemode assigns its destinations correctly with pick_same_destination TRUE and using possible_objectives, either choose only objectives with pick_same_destination TRUE, manually set all cargo objectives pick_same_destination to TRUE, or do not use variable possible_objectives! When cherrypicking objectives with both pick_same_destination TRUE and FALSE, preorder your cargo missions in list objectives (not possible_objectives) by pick_same_destination FALSE first, pick_same_destination TRUE last. This ensures these objectives have applicable stations to pick from. I'm not responsible for destination inconsistency for not following these instructions 
	// TLDR station destinations get funky when a gamemode uses possible_objectives to store multiple cargo objectives with pick_same_destination set to TRUE and FALSE, due to how possible_objectives randomly selects its objectives 
	var/pick_same_destination = TRUE
	
	// Cargo objectives handle the station's requisitioned item in a special datum so we can control how to check contents  
	// var/datum/cargo_item_type/cargo_item_type = null
	var/list/cargo_item_types = list()

/datum/overmap_objective/cargo/instance() 
	get_target()
	pick_station()
	update_brief()

/datum/overmap_objective/cargo/proc/get_target()
	if ( length( cargo_item_types ) )
		for( var/datum/cargo_item_type/type in cargo_item_types )
			target += type.target 
	else 
		// This is an objective with no deliveries set! 
		brief = "Succeed"
		status = 1

/datum/overmap_objective/cargo/proc/pick_station()
	message_admins( "generic pick_station" )
	// Pick a random existing station to give this objective to 
	var/list/ntstations = list()
	var/list/ntstations_expecting_cargo = list()
	for ( var/trader in SSstar_system.traders )
		var/datum/trader/T = trader
		if ( T.faction_type == FACTION_ID_NT )
			var/obj/structure/overmap/trader/S = T.current_location
			ntstations += S 
			
			if ( length( S.expecting_cargo ) )
				ntstations_expecting_cargo += S

	var/obj/structure/overmap/trader/S
	if ( pick_same_destination && length( ntstations_expecting_cargo ) )
		S = pick( ntstations_expecting_cargo )
	else 
		S = pick( ntstations )

	// Assign this objective directly to the station, so the station can track it 
	destination = S 
	S.add_objective( src )

/datum/overmap_objective/cargo/proc/update_brief() 
	if ( length( cargo_item_types ) )
		var/list/segments = list()
		for( var/datum/cargo_item_type/type in cargo_item_types )
			segments += type.get_brief_segment() 
		
		var/obj/structure/overmap/S = destination
		brief = "Deliver [segments.Join( ", " )] to station [S] in system [S.current_system]"

/datum/overmap_objective/cargo/donation/update_brief() 
	if ( length( cargo_item_types ) )
		var/list/segments = list()
		for( var/datum/cargo_item_type/type in cargo_item_types )
			segments += type.get_brief_segment() 
		
		var/obj/structure/overmap/S = destination
		brief = "Source and donate [segments.Join( ", " )] to station [S] in system [S.current_system]"

/datum/overmap_objective/cargo/transfer/update_brief() 
	if ( length( cargo_item_types ) )
		var/list/segments = list()
		for( var/datum/cargo_item_type/type in cargo_item_types )
			segments += type.get_brief_segment() 
		
		var/obj/structure/overmap/S = destination
		brief = "Transfer [segments.Join( ", " )] to station [S] in system [S.current_system]"

/datum/overmap_objective/cargo/proc/check_cargo( var/obj/shipment ) 
	if ( length( cargo_item_types ) ) 
		var/all_accounted_for = TRUE 
		
		for( var/datum/cargo_item_type/type in cargo_item_types )
			if ( !( type.check_contents( shipment ) ) ) 
				all_accounted_for = FALSE 

		if ( all_accounted_for )
			tally = target // Target is set when the cargo_item_type is assigned 
			status = 1
