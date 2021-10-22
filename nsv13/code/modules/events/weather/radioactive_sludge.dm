/datum/round_event_control/radioactive_sludge
	name = "Random Sludge Event"
	typepath = /datum/round_event/radioactive_sludge
	weight = 0
	max_occurrences = 1000

/datum/round_event/radioactive_sludge
	var/min_tiles = 6
	var/max_tiles = 16
	var/area/selected_area

/datum/round_event/radioactive_sludge/setup()
	startWhen = 15
	endWhen = startWhen + 1
	announceWhen = 1
	selected_area = pick(GLOB.the_station_areas)

/datum/round_event/radioactive_sludge/start()
	var/list/selected_turfs = get_area_turfs(selected_area)
	shuffle_inplace(selected_turfs)
	var/num_tiles = rand(min_tiles, max_tiles)
	for(var/turf/T as anything in selected_turfs)
		if(num_tiles <= 0)
			break
		if(isclosedturf(T) || is_blocked_turf(T, TRUE))
			continue
		if(locate(/obj/effect/decal/nuclear_waste) in T)
			continue
		new /obj/effect/decal/nuclear_waste(T)
		num_tiles--

/datum/round_event/radioactive_sludge/announce(fake)
	if(fake)
		selected_area = pick(GLOB.the_station_areas)
	priority_announce("Hazardous material leak detected in [initial(selected_area.name)]. Vacating the area is recommended.", "Structural Alert")
