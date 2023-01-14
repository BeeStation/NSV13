
/// Gets an item of the specified type from the list
/proc/get_by_type(list/L, type)
	RETURN_TYPE(/datum)
	for(var/datum/T in L)
		if(istype(T, type))
			return T
		else continue
