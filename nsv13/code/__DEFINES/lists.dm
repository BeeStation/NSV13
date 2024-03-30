
/// Gets a datum of the specified type from the list, get_by_type(L) will return the first datum
/proc/get_by_type(list/L, type)
	RETURN_TYPE(/datum)
	for(var/datum/T in L)
		if(istype(T, type))
			return T
		else if(!type && isdatum(T))
			return T
		else continue

/// Gets a specified atom type from the list, get_atom_by_type(L) will return the first atom
/proc/get_atom_by_type(list/L, type)
	RETURN_TYPE(/atom)
	for(var/atom/A in L)
		if(istype(A, type))
			return A
		else if(!type && isatom(A))
			return A
		else continue
