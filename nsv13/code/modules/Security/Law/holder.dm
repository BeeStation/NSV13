/proc/init_crimes()
	var/list/crime_list = list()
	GLOB.crime_blacklist = list(/datum/crime/minor, /datum/crime)

	var/paths = subtypesof(/datum/crime)

	for(var/path in paths)
		if(path in GLOB.crime_blacklist)
			continue
		var/datum/crime/C = new path()
		crime_list[path] = C

	return crime_list

/proc/build_crime_list()
	var/paths = subtypesof(/datum/crime)
	GLOB.crime_list = list() //typepath to crime list
	GLOB.crime_list_results_lookup_list = list() //UI glob

	for(var/path in paths)
		if(path in GLOB.crime_blacklist)
			continue
		var/datum/crime/C = new path()

		GLOB.crime_list[path] = C

		GLOB.crime_list_results_lookup_list += list(list("name" = C.name, "level" = C.level))

/proc/find_crime_object_from_type(input)
	if(GLOB.crimes[input])
		return GLOB.crimes[input]
	else
		return null

/proc/get_crime_type_from_product_string(string)
	var/input_crime = replacetext(lowertext(string), " ", "_")
	if(isnull(input_crime))
		return

	input_crime = find_crime(input_crime)
	return input_crime

/proc/find_crime(input)
	. = FALSE
	if(GLOB.crimes[input])
		return input
	else
		return get_crime_id(input)

/proc/get_crime_id(crime_name)
	for(var/X in GLOB.crimes)
		var/datum/crime/C = GLOB.crimes[X]
		if(ckey(crime_name) == ckey(lowertext(C.name)))
			return X
