/proc/init_punishment()
	var/list/punish_list = list()
	//GLOB.punishment_blacklist = list(/datum/punishment)

	var/paths = subtypesof(/datum/punishment)

	for(var/path in paths)
		//if(path in GLOB.punishment_blacklist)
		//	continue
		var/datum/punishment/C = new path()
		punish_list[path] = C

	return punish_list

/proc/find_punishment_object_from_type(input)
	if(GLOB.punishment[input])
		return GLOB.punishment[input]
	else
		return null
