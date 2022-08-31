/proc/init_crimes()
	var/list/crime_list = list()

	var/paths = subtypesof(/datum/crime)

	for(var/path in paths)
		var/datum/crime/C = new path()
		crime_list[path] = C

	return crime_list

/proc/build_crime_list()
	var/paths = subtypesof(/datum/crime)
	GLOB.crime_list = list() //typepath to crime list
	GLOB.crime_list_results_lookup_list = list() //UI glob

	for(var/path in paths)
		var/datum/crime/C = new path()

		GLOB.crime_list[path] = C

		GLOB.crime_list_results_lookup_list += list(list("name" = C.name, "desc" = C.description))

/proc/find_crime_object_from_type(input)
	if(GLOB.crimes[input])
		return GLOB.crimes[input]
	else
		return null
