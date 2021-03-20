//used for holding information about unique properties of maps
//feed it json files that match the datum layout
//defaults to box
//  -Cyberboss

/datum/map_config //NSV EDITED START
	// Metadata
	var/config_filename = "_maps/gladius.json"
	var/defaulted = TRUE  // set to FALSE by LoadConfig() succeeding
	// Config from maps.txt
	var/config_max_users = 0
	var/config_min_users = 0
	var/voteweight = 1
	var/votable = FALSE

	// Config actually from the JSON - should default to Hammerhead //NSV EDITS
	var/map_name = "NSV Gladius - DEFAULTED"
	var/map_link = null //This is intentionally wrong, this will make it not link to webmap.
	var/map_path = "map_files/Gladius"
	var/map_file = list("Gladius2.dmm", "Gladius1.dmm")
	var/ship_type = /obj/structure/overmap/nanotrasen/battlecruiser/starter
	var/mining_ship_type = /obj/structure/overmap/nanotrasen/mining_cruiser/rocinante
	var/mine_disable = FALSE //NSV13 - Allow disabling of mineship loading.
	var/mine_file = "Rocinante.dmm" //Nsv13. Heavy changes to this file
	var/mine_path = "map_files/Mining/nsv13"
	var/faction = "nanotrasen" //Nsv13 - To what faction does the NSV belong?
	var/patrol_type = "standard" //Nsv13 - Lets you set the patrol type per map. Sometimes we just wanna space cruise y'dig?
	var/mine_traits = null

	var/traits = list(
		list(
			"Up" = 1,
			"Linkage" = "Cross",
			"Station" = 1,
			"Boardable Ship" = 1),
		list(
			"Down" = -1,
			"Linkage" = "Cross",
			"Station" = 1,
			"Boardable Ship" = 1)
		)
	var/space_ruin_levels = -1
	var/space_empty_levels = 1

	var/allow_custom_shuttles = TRUE
	var/shuttles = list(
		"cargo" = "cargo_gladius",
		"ferry" = "ferry_kilo",
		"emergency" = "emergency_donut")

//NSV EDITED END

/proc/load_map_config(filename = "data/next_map.json", default_to_box, delete_after, error_if_missing = TRUE)
	var/datum/map_config/config = new
	if (default_to_box)
		return config
	if (!config.LoadConfig(filename, error_if_missing))
		qdel(config)
		config = new /datum/map_config  // Fall back to Box
		//config.LoadConfig(config.config_filename)
	if (delete_after)
		fdel(filename)
	return config

#define CHECK_EXISTS(X) if(!istext(json[X])) { log_world("[##X] missing from json!"); return; }
/datum/map_config/proc/LoadConfig(filename, error_if_missing)
	if(!fexists(filename))
		if(error_if_missing)
			log_world("map_config not found: [filename]")
		return

	var/json = file(filename)
	if(!json)
		log_world("Could not open map_config: [filename]")
		return

	json = rustg_file_read(json)
	if(!json)
		log_world("map_config is not text: [filename]")
		return

	json = json_decode(json)
	if(!json)
		log_world("map_config is not json: [filename]")
		return

	config_filename = filename

	CHECK_EXISTS("map_name")
	map_name = json["map_name"]
	CHECK_EXISTS("map_path")
	map_path = json["map_path"]

	map_file = json["map_file"]
	// "map_file": "BoxStation.dmm"
	if (istext(map_file))
		if (!fexists("_maps/[map_path]/[map_file]"))
			log_world("Map file ([map_path]/[map_file]) does not exist!")
			return
	// "map_file": ["Lower.dmm", "Upper.dmm"]
	else if (islist(map_file))
		for (var/file in map_file)
			if (!fexists("_maps/[map_path]/[file]"))
				log_world("Map file ([map_path]/[file]) does not exist!")
				return
	else
		log_world("map_file missing from json!")
		return

	if (islist(json["shuttles"]))
		var/list/L = json["shuttles"]
		for(var/key in L)
			var/value = L[key]
			shuttles[key] = value
	else if ("shuttles" in json)
		log_world("map_config shuttles is not a list!")
		return

	traits = json["traits"]
	// "traits": [{"Linkage": "Cross"}, {"Space Ruins": true}]
	if (islist(traits))
		// "Station" is set by default, but it's assumed if you're setting
		// traits you want to customize which level is cross-linked
		for (var/level in traits)
			if (!(ZTRAITS_STATION in level))
				level += ZTRAITS_STATION
	// "traits": null or absent -> default
	else if (!isnull(traits))
		log_world("map_config traits is not a list!")
		return

	var/temp = json["space_ruin_levels"]
	if (isnum_safe(temp))
		space_ruin_levels = temp
	else if (!isnull(temp))
		log_world("map_config space_ruin_levels is not a number!")
		return

	temp = json["space_empty_levels"]
	if (isnum_safe(temp))
		space_empty_levels = temp
	else if (!isnull(temp))
		log_world("map_config space_empty_levels is not a number!")
		return

	if(!("mine_disable" in json)) //Bypass mineload so we don't load any mining vessels period.
		mine_file = json["mine_file"]
		mine_path = json["mine_path"]
		// "map_file": "BoxStation.dmm"
		if (istext(mine_file))
			if (!fexists("_maps/[mine_path]/[mine_file]"))
				log_world("Map file ([mine_path]/[mine_file]) does not exist!")
				return
		// "map_file": ["Lower.dmm", "Upper.dmm"]
		else if (islist(mine_file))
			for (var/file in mine_file)
				if (!fexists("_maps/[mine_path]/[file]"))
					log_world("Map file ([mine_path]/[file]) does not exist!")
					return
		else
			log_world("mine_file missing from json!")
			return

		CHECK_EXISTS("mining_ship_type")
		if("mining_ship_type" in json)
			mining_ship_type = text2path(json["mining_ship_type"])
		else
			log_world("mining_ship_type missing from json!")
			return

	else
		mine_disable = TRUE
	//Nsv13 stuff. No CHECK_EXISTS because we don't want to yell at mappers if they don't override these two.
	if("faction" in json) //We don't always want to bother overriding faction, so the default will do for now
		faction = json["faction"]
	if("patrol_type" in json) //Lets us set our patrol type per map.
		patrol_type = json["patrol_type"]

	CHECK_EXISTS("ship_type")
	if("ship_type" in json)
		ship_type = text2path(json["ship_type"])
	else
		log_world("ship_type missing from json!")
		return

	mine_traits = json["mine_traits"]
	// "traits": [{"Linkage": "Cross"}, {"Space Ruins": true}]
	if (islist(mine_traits))
		// "Station" is set by default, but it's assumed if you're setting
		// traits you want to customize which level is cross-linked
		for (var/level in mine_traits)
			if (!(ZTRAITS_BOARDABLE_SHIP in level))
				level += ZTRAITS_BOARDABLE_SHIP
	// "traits": null or absent -> default
	else if (!isnull(mine_traits))
		log_world("mine_traits is not a list!")
		return

	allow_custom_shuttles = json["allow_custom_shuttles"] != FALSE

	if("map_link" in json)						// NSV Changes begin
		map_link = json["map_link"]
	else
		log_world("map_link missing from json!")	// NSV Changes end

	defaulted = FALSE
	return TRUE
#undef CHECK_EXISTS

/datum/map_config/proc/GetFullMapPaths()
	if (istext(map_file))
		return list("_maps/[map_path]/[map_file]")
	. = list()
	for (var/file in map_file)
		. += "_maps/[map_path]/[file]"

/datum/map_config/proc/is_votable()
	var/below_max = !(config_max_users) || GLOB.clients.len <= config_max_users
	var/above_min = !(config_min_users) || GLOB.clients.len >= config_min_users
	return votable && below_max && above_min

/datum/map_config/proc/MakeNextMap()
	return config_filename == "data/next_map.json" || fcopy(config_filename, "data/next_map.json")
