/datum/overmap_objective/cargo
	name = "cargo objective"
	binary = FALSE
	extension_supported = FALSE

	// target and tally are an arbitrary numbers used in displaying objectives on communications console.
	target = 0 // Set your target to the number of units required, or the total number of items required, or the number of shipped item types 
	tally = 0 // Set your tally to reflect the percentage of target completion 
	
	var/destination = null // For knowing who wants what by looking at this objective datum 

/datum/overmap_objective/cargo/instance() 
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
