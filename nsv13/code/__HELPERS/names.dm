/proc/new_station_name()
	var/name = ""
	var/new_station_name = ""
	if(!name)
		name = pick(GLOB.station_names)
	new_station_name = "NSV [name]"

	return new_station_name

/proc/new_prebuilt_fighter_name()
	var/numbers = rand(1,2)
	var/name = ""
	var/new_prebuilt_fighter_name = ""
	if(!name)
		name = pick(GLOB.station_names) //pulling from this list for now
		switch(numbers)
			if(1)
				new_prebuilt_fighter_name = "[name] [rand(1,99)]"
			if(2)
				new_prebuilt_fighter_name = "[name] \Roman[rand(1,99)]"

	return new_prebuilt_fighter_name
