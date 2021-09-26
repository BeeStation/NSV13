/datum/overmap_objective/cargo
	name = "cargo objective"
	// crate_name appears as a crate name when stations return requisition forms to players. 
	// crate_name should be named similarly to cargo supply console crate names 
	var/crate_name = "Approved Shipment"
	binary = FALSE
	extension_supported = FALSE // Players won't enjoy being handed a cargo job after beating up fleets. Review this if we decide to refactor missions later 

	// Variables target and tally are automatically handled by the cargo_item_type datum
	// Please set your target and tally amounts when setting up the cargo_item_type datum 
	target = 0 
	tally = 0 
	
	var/destination = null // For knowing who wants what by looking at this objective datum 
	var/datum/cargo_item_type/cargo_item_type = null // Cargo objectives handle the station's requisitioned item in a special datum so we can control how to check contents  

/datum/overmap_objective/cargo/instance() 
	get_target()
	pick_station()

/datum/overmap_objective/cargo/proc/get_target()
	if ( cargo_item_type )
		target = cargo_item_type.target 

/datum/overmap_objective/cargo/proc/pick_station()
	message_admins( "generic pick_station" )
	// Pick a random existing station to give this objective to 
	var/list/ntstations = list()
	for ( var/trader in SSstar_system.traders )
		var/datum/trader/T = trader
		if ( T.faction_type == FACTION_ID_NT )
			ntstations += T 

	var/obj/structure/overmap/trader/S = pick( ntstations )

	// Assign this objective directly to the station, so the station can track it 
	destination = S 
	S.add_objective( src )

/datum/overmap_objective/cargo/proc/check_cargo( var/obj/shipment ) 
	if ( cargo_item_type ) 
		var/all_accounted_for = cargo_item_type.check_contents( shipment )
		if ( all_accounted_for )
			tally = target // Target is set when the cargo_item_type is assigned 
			status = 1
