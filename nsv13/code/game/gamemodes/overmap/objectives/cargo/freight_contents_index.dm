
// Stores freight torpedo contents and its prepackaged status data 

/datum/freight_contents_index 
	// Keep a total count of the actual type we're checking 
	var/list/atoms_amount = list()
	// Return these items that contain the amount in the list above 
	var/list/atoms_list = list()

/datum/freight_contents_index/proc/add_amount( var/atom/a, var/amount, var/type )
	if ( !type ) 
		if ( a?.type )
			type = a.type 

	if ( !atoms_amount[ type ] ) 
		atoms_amount[ type ] = 0
		atoms_list[ type ] = list()
	atoms_amount[ type ] += amount 
	atoms_list[ type ] += a 

/datum/freight_contents_index/proc/get_amount( var/type, var/amount ) 
	if ( atoms_amount[ type ] && atoms_amount[ type ] >= amount )
		return atoms_list[ type ]
