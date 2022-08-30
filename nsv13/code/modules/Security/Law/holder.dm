/proc/init_crime_list()
	var/list/crime_list = list()

	var/paths = subtypesof(/datum/crime)

	for(var/path in paths)
		var/datum/crime/C = new path()
		crime_list[path] = C

	return crime_list

/proc/find_crime_object_from_type(input)
	if(GLOB.crime_list[input])
		return GLOB.crime_list[input]
	else
		return null
