/datum/controller/configuration
	name = "Configuration"

	var/directory = CONFIG_DIRECTORY

	var/warned_deprecated_configs = FALSE
	var/hiding_entries_by_type = TRUE	//Set for readability, admins can set this to FALSE if they want to debug it
	var/list/entries
	var/list/entries_by_type

	var/list/maplist
	var/datum/map_config/defaultmap

	var/list/modes			// allowed modes
	var/list/gamemode_cache
	var/list/votable_modes		// votable modes
	var/list/mode_names
	var/list/mode_reports
	var/list/mode_false_report_weight

	var/list/active_donators //NSV13 - donator code

	var/motd

	var/static/regex/ic_filter_regex
	var/static/regex/ooc_filter_regex

	var/list/fail2topic_whitelisted_ips
	var/list/protected_cids

/datum/controller/configuration/proc/admin_reload()
	if(IsAdminAdvancedProcCall())
		return
	log_admin("[key_name_admin(usr)] has forcefully reloaded the configuration from disk.")
	message_admins("[key_name_admin(usr)] has forcefully reloaded the configuration from disk.")
	full_wipe()
	Load(world.params[OVERRIDE_CONFIG_DIRECTORY_PARAMETER])

/datum/controller/configuration/proc/Load(_directory)
	if(IsAdminAdvancedProcCall())		//If admin proccall is detected down the line it will horribly break everything.
		return
	if(_directory)
		directory = _directory

	if(!fexists("[directory]/config.txt") && fexists("[directory]/example/config.txt"))
		directory = "[directory]/example"

	if(entries)
		CRASH("/datum/controller/configuration/Load() called more than once!")
	InitEntries()
	LoadModes()
	if(fexists("[directory]/config.txt") && LoadEntries("config.txt") <= 1)
		var/list/legacy_configs = list("game_options.txt", "dbconfig.txt", "comms.txt")
		for(var/I in legacy_configs)
			if(fexists("[directory]/[I]"))
				log_config("No $include directives found in config.txt! Loading legacy [legacy_configs.Join("/")] files...")
				for(var/J in legacy_configs)
					LoadEntries(J)
				break
	loadmaplist(CONFIG_MAPS_FILE)
	LoadTopicRateWhitelist()
	LoadProtectedIDs()
	LoadChatFilter()

	if (Master)
		Master.OnConfigLoad()

/datum/controller/configuration/proc/full_wipe()
	if(IsAdminAdvancedProcCall())
		return
	entries_by_type.Cut()
	QDEL_LIST_ASSOC_VAL(entries)
	entries = null
	QDEL_LIST_ASSOC_VAL(maplist)
	maplist = null
	QDEL_NULL(defaultmap)

/datum/controller/configuration/Destroy()
	full_wipe()
	config = null

	return ..()

/datum/controller/configuration/proc/InitEntries()
	var/list/_entries = list()
	entries = _entries
	var/list/_entries_by_type = list()
	entries_by_type = _entries_by_type

	for(var/I in typesof(/datum/config_entry))	//typesof is faster in this case
		var/datum/config_entry/E = I
		if(initial(E.abstract_type) == I)
			continue
		E = new I
		var/esname = E.name
		var/datum/config_entry/test = _entries[esname]
		if(test)
			log_config("Error: [test.type] has the same name as [E.type]: [esname]! Not initializing [E.type]!")
			qdel(E)
			continue
		_entries[esname] = E
		_entries_by_type[I] = E

/datum/controller/configuration/proc/RemoveEntry(datum/config_entry/CE)
	entries -= CE.name
	entries_by_type -= CE.type

/datum/controller/configuration/proc/LoadEntries(filename, list/stack = list())
	if(IsAdminAdvancedProcCall())
		return

	var/filename_to_test = world.system_type == MS_WINDOWS ? lowertext(filename) : filename
	if(filename_to_test in stack)
		log_config("Warning: Config recursion detected ([english_list(stack)]), breaking!")
		return
	stack = stack + filename_to_test

	log_config("Loading config file [filename]...")
	var/list/lines = world.file2list("[directory]/[filename]")
	var/list/_entries = entries
	for(var/L in lines)
		L = trim(L)
		if(!L)
			continue

		var/firstchar = L[1]
		if(firstchar == "#")
			continue

		var/lockthis = firstchar == "@"
		if(lockthis)
			L = copytext(L, length(firstchar) + 1)

		var/pos = findtext(L, " ")
		var/entry = null
		var/value = null

		if(pos)
			entry = lowertext(copytext(L, 1, pos))
			value = copytext(L, pos + length(L[pos]))
		else
			entry = lowertext(L)

		if(!entry)
			continue

		if(entry == "$include")
			if(!value)
				log_config("Warning: Invalid $include directive: [value]")
			else
				LoadEntries(value, stack)
				++.
			continue

		var/datum/config_entry/E = _entries[entry]
		if(!E)
			log_config("Unknown setting in configuration: '[entry]'")
			continue

		if(lockthis)
			E.protection |= CONFIG_ENTRY_LOCKED

		if(E.deprecated_by)
			var/datum/config_entry/new_ver = entries_by_type[E.deprecated_by]
			var/new_value = E.DeprecationUpdate(value)
			var/good_update = istext(new_value)
			log_config("Entry [entry] is deprecated and will be removed soon. Migrate to [new_ver.name]![good_update ? " Suggested new value is: [new_value]" : ""]")
			if(!warned_deprecated_configs)
				addtimer(CALLBACK(GLOBAL_PROC, /proc/message_admins, "This server is using deprecated configuration settings. Please check the logs and update accordingly."), 0)
				warned_deprecated_configs = TRUE
			if(good_update)
				value = new_value
				E = new_ver
			else
				warning("[new_ver.type] is deprecated but gave no proper return for DeprecationUpdate()")

		var/validated = E.ValidateAndSet(value)
		if(!validated)
			log_config("Failed to validate setting \"[value]\" for [entry]")
		else
			if(E.modified && !E.dupes_allowed)
				log_config("Duplicate setting for [entry] ([value], [E.resident_file]) detected! Using latest.")

		E.resident_file = filename

		if(validated)
			E.modified = TRUE

	++.

/datum/controller/configuration/can_vv_get(var_name)
	return (var_name != NAMEOF(src, entries_by_type) || !hiding_entries_by_type) && ..()

/datum/controller/configuration/vv_edit_var(var_name, var_value)
	var/list/banned_edits = list(NAMEOF(src, entries_by_type), NAMEOF(src, entries), NAMEOF(src, directory))
	return !(var_name in banned_edits) && ..()

/datum/controller/configuration/stat_entry()
	var/list/tab_data = list()
	tab_data["[name]"] = list(
		text="Edit",
		action = "statClickDebug",
		params=list(
			"targetRef" = REF(src),
			"class"="config",
		),
		type=STAT_BUTTON,
	)
	return tab_data

/datum/controller/configuration/proc/Get(entry_type)
	var/datum/config_entry/E = entry_type
	var/entry_is_abstract = initial(E.abstract_type) == entry_type
	if(entry_is_abstract)
		CRASH("Tried to retrieve an abstract config_entry: [entry_type]")
	if(!entries_by_type)
		CRASH("Tried to retrieve config value before it was loaded or it was nulled.")
	E = entries_by_type[entry_type]
	if(!E)
		CRASH("Missing config entry for [entry_type]!")
	if((E.protection & CONFIG_ENTRY_HIDDEN) && IsAdminAdvancedProcCall() && GLOB.LastAdminCalledProc == "Get" && GLOB.LastAdminCalledTargetRef == "[REF(src)]")
		log_admin_private("Config access of [entry_type] attempted by [key_name(usr)]")
		return
	return E.config_entry_value

/datum/controller/configuration/proc/Set(entry_type, new_val)
	var/datum/config_entry/E = entry_type
	var/entry_is_abstract = initial(E.abstract_type) == entry_type
	if(entry_is_abstract)
		CRASH("Tried to set an abstract config_entry: [entry_type]")
	E = entries_by_type[entry_type]
	if(!E)
		CRASH("Missing config entry for [entry_type]!")
	if((E.protection & CONFIG_ENTRY_LOCKED) && IsAdminAdvancedProcCall() && GLOB.LastAdminCalledProc == "Set" && GLOB.LastAdminCalledTargetRef == "[REF(src)]")
		log_admin_private("Config rewrite of [entry_type] to [new_val] attempted by [key_name(usr)]")
		return
	return E.ValidateAndSet("[new_val]")

/datum/controller/configuration/proc/LoadModes()
	gamemode_cache = typecacheof(/datum/game_mode, TRUE)
	modes = list()
	mode_names = list()
	mode_reports = list()
	mode_false_report_weight = list()
	votable_modes = list()
	var/list/probabilities = Get(/datum/config_entry/keyed_list/probability)
	for(var/T in gamemode_cache)
		// I wish I didn't have to instance the game modes in order to look up
		// their information, but it is the only way (at least that I know of).
		var/datum/game_mode/M = new T()

		if(M.config_tag)
			if(!(M.config_tag in modes))		// ensure each mode is added only once
				modes += M.config_tag
				mode_names[M.config_tag] = M.name
				probabilities[M.config_tag] = M.probability
				mode_reports[M.report_type] = M.generate_report()
				if(probabilities[M.config_tag]>0)
					mode_false_report_weight[M.report_type] = M.false_report_weight
				else
					//"impossible" modes will still falsly show up occasionally, else they'll stick out like a sore thumb if an admin decides to force a disabled gamemode.
					mode_false_report_weight[M.report_type] = min(1, M.false_report_weight)
				if(M.votable)
					votable_modes += M.config_tag
		qdel(M)
	votable_modes += "secret"

/datum/controller/configuration/proc/LoadMOTD()
	motd = rustg_file_read("[directory]/motd.txt")
	var/tm_info = GLOB.revdata.GetTestMergeInfo()
	if(motd || tm_info)
		motd = motd ? "[motd]<br>[tm_info]" : tm_info

/datum/controller/configuration/proc/loadmaplist(filename)
	log_config("Loading config file [filename]...")
	filename = "[directory]/[filename]"
	var/list/Lines = world.file2list(filename)

	var/datum/map_config/currentmap = null
	for(var/t in Lines)
		if(!t)
			continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(t[1] == "#")
			continue

		var/pos = findtext(t, " ")
		var/command = null
		var/data = null

		if(pos)
			command = lowertext(copytext(t, 1, pos))
			data = copytext(t, pos + length(t[pos]))
		else
			command = lowertext(t)

		if(!command)
			continue

		if (!currentmap && command != "map")
			continue

		switch (command)
			if ("map")
				currentmap = load_map_config("[data]", MAP_DIRECTORY)
				if(currentmap.defaulted)
					log_config("Failed to load map config for [data]!")
					currentmap = null
			if ("minplayers","minplayer")
				currentmap.config_min_users = text2num(data)
			if ("maxplayers","maxplayer")
				currentmap.config_max_users = text2num(data)
			if ("weight","voteweight")
				currentmap.voteweight = text2num(data)
			if ("default","defaultmap")
				defaultmap = currentmap
			if ("votable")
				currentmap.votable = TRUE
			if ("endmap")
				LAZYINITLIST(maplist)
				maplist[currentmap.map_name] = currentmap
				currentmap = null
			if ("disabled")
				currentmap = null
			else
				log_config("Unknown command in map vote config: '[command]'")


/datum/controller/configuration/proc/pick_mode(mode_name)
	// I wish I didn't have to instance the game modes in order to look up
	// their information, but it is the only way (at least that I know of).
	// ^ This guy didn't try hard enough
	for(var/T in gamemode_cache)
		var/datum/game_mode/M = T
		var/ct = initial(M.config_tag)
		if(ct && ct == mode_name)
			return new T
	return new /datum/game_mode/extended()

/datum/controller/configuration/proc/get_runnable_modes()
	var/list/datum/game_mode/runnable_modes = new
	var/list/probabilities = Get(/datum/config_entry/keyed_list/probability)
	var/list/min_pop = Get(/datum/config_entry/keyed_list/min_pop)
	var/list/max_pop = Get(/datum/config_entry/keyed_list/max_pop)
	var/list/repeated_mode_adjust = Get(/datum/config_entry/number_list/repeated_mode_adjust)
	for(var/T in gamemode_cache)
		var/datum/game_mode/M = new T()
		if(!(M.config_tag in modes))
			qdel(M)
			continue
		if(probabilities[M.config_tag]<=0)
			qdel(M)
			continue
		if(min_pop[M.config_tag])
			M.required_players = min_pop[M.config_tag]
		if(max_pop[M.config_tag])
			M.maximum_players = max_pop[M.config_tag]
		if(M.can_start())
			var/final_weight = probabilities[M.config_tag]
			if(SSpersistence.saved_modes.len == 3 && repeated_mode_adjust.len == 3)
				var/recent_round = min(SSpersistence.saved_modes.Find(M.config_tag),3)
				var/adjustment = 0
				while(recent_round)
					adjustment += repeated_mode_adjust[recent_round]
					recent_round = SSpersistence.saved_modes.Find(M.config_tag,recent_round+1,0)
				final_weight *= ((100-adjustment)/100)
			runnable_modes[M] = final_weight
	return runnable_modes

/datum/controller/configuration/proc/get_runnable_midround_modes(crew)
	var/list/datum/game_mode/runnable_modes = new
	var/list/probabilities = Get(/datum/config_entry/keyed_list/probability)
	var/list/min_pop = Get(/datum/config_entry/keyed_list/min_pop)
	var/list/max_pop = Get(/datum/config_entry/keyed_list/max_pop)
	for(var/T in (gamemode_cache - SSticker.mode.type))
		var/datum/game_mode/M = new T()
		if(!(M.config_tag in modes))
			qdel(M)
			continue
		if(probabilities[M.config_tag]<=0)
			qdel(M)
			continue
		if(min_pop[M.config_tag])
			M.required_players = min_pop[M.config_tag]
		if(max_pop[M.config_tag])
			M.maximum_players = max_pop[M.config_tag]
		if(M.required_players <= crew)
			if(M.maximum_players >= 0 && M.maximum_players < crew)
				continue
			runnable_modes[M] = probabilities[M.config_tag]
	return runnable_modes

/datum/controller/configuration/proc/LoadTopicRateWhitelist()
	LAZYINITLIST(fail2topic_whitelisted_ips)
	if(!fexists("[directory]/topic_rate_limit_whitelist.txt"))
		log_config("Error 404: topic_rate_limit_whitelist.txt not found!")
		return

	log_config("Loading config file topic_rate_limit_whitelist.txt...")

	for(var/line in world.file2list("[directory]/topic_rate_limit_whitelist.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue

		fail2topic_whitelisted_ips[line] = 1

/datum/controller/configuration/proc/LoadProtectedIDs()
	var/jsonfile = rustg_file_read("[directory]/protected_cids.json")
	if(!jsonfile)
		log_config("Error 404: protected_cids.json not found!")
		return

	log_config("Loading config file protected_cids.json...")

	protected_cids = json_decode(jsonfile)

/datum/controller/configuration/proc/LoadChatFilter()
	var/list/in_character_filter = list()
	var/list/ooc_filter = list()

	if(!fexists("[directory]/ooc_filter.txt"))
		log_config("Error 404: ooc_filter.txt not found!")
		return

	if(!fexists("[directory]/in_character_filter.txt"))
		log_config("Error 404: in_character_filter.txt not found!")
		return

	log_config("Loading config file ooc_filter.txt...")

	for(var/line in world.file2list("[directory]/ooc_filter.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		in_character_filter += REGEX_QUOTE(line) //Anything banned in OOC is also probably banned in IC
		ooc_filter += REGEX_QUOTE(line)

	ooc_filter_regex = ooc_filter.len ? regex("\\b([jointext(ooc_filter, "|")])\\b", "i") : null


	log_config("Loading config file in_character_filter.txt...")

	for(var/line in world.file2list("[directory]/in_character_filter.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		in_character_filter += REGEX_QUOTE(line)

	ic_filter_regex = in_character_filter.len ? regex("\\b([jointext(in_character_filter, "|")])\\b", "i") : null

//NSV13 - donator code
/datum/controller/configuration/proc/LoadDonators()
	active_donators = list()
	for(var/line in world.file2list("[global.config.directory]/donators.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		active_donators += ckey(line)

	if(!active_donators.len)
		active_donators = null

// DEBUG MAP DETAIL VIEWER
/datum/controller/configuration/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MapDetails")
		ui.open()

/datum/controller/configuration/ui_state(mob/user)
	return GLOB.always_state

/datum/controller/configuration/ui_data(mob/user)
	var/list/data = list("choices" = list())

	for(var/key in maplist)
		data["choices"][key] = 0

	return data

/datum/controller/configuration/ui_static_data(mob/user)
	var/static/list/base64_cache = list()

	// AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA - Corvid
	var/datum/DBQuery/stability_query = SSdbcore.NewQuery("SELECT map_name, SUM(started) AS started, SUM(failed) AS failed FROM " + \
		"(SELECT [format_table_name("round")].id, [format_table_name("round")].map_name, feedback.started, feedback.failed FROM [format_table_name("round")] " + \
		"INNER JOIN (SELECT round_id, JSON_VALUE(JSON, '$.data.started') AS started, JSON_VALUE(JSON, '$.data.failed') AS failed " + \
		"FROM [format_table_name("feedback")] WHERE key_name='engine_stats') AS feedback ON feedback.round_id=[format_table_name("round")].id) AS stats GROUP BY map_name")

	/*
	// This should get me one row per ship with totals for each ending type but doesn't
	var/datum/DBQuery/endings_query = SSdbcore.NewQuery("SUM(CASE WHEN feedback.ending LIKE 'succeeded' THEN 1 ELSE 0 END) as succeeded, " + \
		"SUM(CASE WHEN feedback.ending LIKE 'evacuated' THEN 1 ELSE 0 END) as evacuated, SUM(CASE WHEN feedback.ending LIKE 'destroyed' THEN 1 ELSE 0 END) as destroyed " + \
		"FROM ss13_round INNER JOIN (" + \
		"SELECT round_id, CAST(JSON_EXTRACT(JSON, '$.data') AS CHAR) AS ending FROM ss13_feedback WHERE key_name='nsv_endings') AS feedback " + \
		" ON ss13_round.id=feedback.round_id")
		*/
	var/datum/DBQuery/endings_query = SSdbcore.NewQuery("SELECT map_name, feedback.ending FROM ss13_round INNER JOIN (" + \
		"SELECT round_id, CAST(JSON_EXTRACT(JSON, '$.data') AS CHAR) AS ending FROM ss13_feedback WHERE key_name='nsv_endings') AS feedback " + \
		" ON ss13_round.id=feedback.round_id")

	SSdbcore.QuerySelect(stability_query)
	SSdbcore.QuerySelect(endings_query)

	var/list/all_map_info = list()

	for(var/key in maplist)
		var/datum/map_config/map_data = maplist[key]

		var/obj/structure/overmap/typedef = map_data.ship_type

		var/stability = "No data"
		while(stability_query.NextRow())
			if((stability_query.item[1] == map_data.map_name) && (stability_query.item[2]))
				// (starts - failures) * 100 / starts
				stability = (stability_query.item[2] - stability_query.item[3]) * 100 / stability_query.item[2]
		stability_query.next_row_to_take = 1

		var/successes = 0
		var/evacs = 0
		var/losses = 0
		while(endings_query.NextRow())
			if(endings_query.item[1] == map_data.map_name)
				message_admins(endings_query.item[2])
				if(endings_query.item[2] == "\"succeeded\"")
					successes += 1
				else if(endings_query.item[2] == "\"evacuated\"")
					evacs += 1
				else if(endings_query.item[2] == "\"destroyed\"")
					losses += 1
		var/result_rates = "No data"
		var/total_results = successes + evacs + losses
		if(total_results > 0)
			result_rates = "[successes*100/total_results] / [evacs*100/total_results] / [losses*100/total_results]"
		endings_query.next_row_to_take = 1
		var/base64
		if(!base64)
			if(base64_cache[map_data.ship_type])
				base64 = base64_cache[map_data.ship_type]
			else
				base64 = icon2base64(icon(initial(typedef.icon), initial(typedef.icon_state), frame=1))
				base64_cache[map_data.ship_type] = base64

		var/list/map_info = list(
			"img" = base64,
			"shipClass" = initial(typedef.name),
			"description" = map_data.map_description,
			"manufacturer" = map_data.manufacturer,
			"patternDate" = map_data.pattern_date,
			"strengths" = map_data.strengths,
			"weaknesses" = map_data.weaknesses,
			"weapons" = map_data.weapons,
			"durability" = initial(typedef.max_integrity),
			"engine" = map_data.engine_type,
			"engineStability" = stability,
			"successRate" = result_rates
		)
		message_admins("[map_data.map_name]: [stability], [result_rates]")

		all_map_info[key] = map_info

	var/list/data = list("mapInfo" = all_map_info)
	return data
