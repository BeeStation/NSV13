/proc/new_station_name()
	var/name = ""
	var/new_station_name = ""
	if(!name)
		name = pick(GLOB.station_names)
	new_station_name = "NSV [name]"

	return new_station_name

//Dwarf Names
/proc/dwarf_name()
	return "[pick(GLOB.dwarf_first)] [pick(GLOB.dwarf_last)]"