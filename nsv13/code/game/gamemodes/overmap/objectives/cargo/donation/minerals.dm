/datum/overmap_objective/cargo/donation/minerals
	name = "Donate minerals"
	desc = "Donate 1 or more minerals"

/datum/overmap_objective/cargo/donation/minerals/instance() 
	// Pick a random existing station to give this objective to 
	var/list/ntstations = list()
	for ( var/trader in SSstar_system.traders )
		var/datum/trader/T = trader
		if ( T.faction_type == FACTION_ID_NT )
			// Don't pick mineral type traders to deliver minerals 
			if ( !istype( T.type, /datum/trader/shallowstone ) )
				ntstations += T 

	var/obj/structure/overmap/trader/S = pick( ntstations )
	
	// Assign this objective directly to the station, so the station can track it 
	destination = S 
	S.add_objective( src )
