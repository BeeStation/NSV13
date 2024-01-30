// additional info for map votes

/datum/controller/subsystem/vote/ui_static_data(mob/user)
	var/static/list/base64_cache = list()

	/* From the feedback table made by SSblackbox, for any entry with the key 'engine_stats', get the round ID and extract
		the number of starts and failures from the JSON data. Call this result "feedback" for short.
		(SELECT round_id, JSON_VALUE(JSON, '$.data.started') AS started, JSON_VALUE(JSON, '$.data.failed') AS failed FROM ss13_feedback WHERE key_name='engine_stats') as feedback

		Take that round ID, and compare it with the data from the round table to also get the map name. Call this results "stats". (It didn't work without the AS, idk why)
		(SELECT ss13_round.id, ss13_round.map_name, feedback.started, feedback.failed FROM ss13_round INNER JOIN [feedback] ON feedback.round_id=ss13_round.id) as stats

		Then add up total starts and failures for each map.
		SELECT map_name, SUM(started) AS started, SUM(failed) AS failed FROM [stats]
	 */
	var/datum/DBQuery/stability_query = SSdbcore.NewQuery("SELECT map_name, SUM(started) AS started, SUM(failed) AS failed FROM " + \
		"(SELECT [format_table_name("round")].id, [format_table_name("round")].map_name, feedback.started, feedback.failed FROM [format_table_name("round")] " + \
		"INNER JOIN (SELECT round_id, JSON_VALUE(JSON, '$.data.started') AS started, JSON_VALUE(JSON, '$.data.failed') AS failed " + \
		"FROM [format_table_name("feedback")] WHERE key_name='engine_stats') AS feedback ON feedback.round_id=[format_table_name("round")].id) AS stats GROUP BY map_name")

	/* This SHOULD get me one row per ship with totals for each ending type but the quotation marks in the results are messing things up...
		From the feedback table, for any entry with the key 'nsv_endings', get the round ID and extract the type of ending from the JSON data.
		This is a text string. Current values (2023/02/17) are "succeeded", "evacuated", and "failed". Call this result "feedback".
		(SELECT round_id, CAST(JSON_EXTRACT(JSON, '$.data') AS CHAR) AS ending FROM ss13_feedback WHERE key_name='nsv_endings') AS feedback

		Take the round ID and compare it with the data from the round table to also get the map name. Add up how many "succeeded", "evacuated", and "destroyed"s
		we have for each map name.
		SUM(CASE WHEN feedback.ending LIKE 'succeeded' THEN 1 ELSE 0 END) as succeeded,
		SUM(CASE WHEN feedback.ending LIKE 'evacuated' THEN 1 ELSE 0 END) as evacuated,
		SUM(CASE WHEN feedback.ending LIKE 'destroyed' THEN 1 ELSE 0 END) as destroyed
		FROM ss13_round INNER JOIN [feedback] ON ss13_round.id=feedback.round_id GROUP BY ss13_round.map_name
	*/

	/* From the feedback table, for any entry with the key 'nsv_endings', get the round ID and extract the type of ending from the JSON data.
		This is a text string. Current values (2023/02/17) are "succeeded", "evacuated", and "failed". Call this result "feedback".
		(SELECT round_id, CAST(JSON_EXTRACT(JSON, '$.data[0]') AS CHAR) AS ending FROM ss13_feedback WHERE key_name='nsv_endings') AS feedback

		Take the round ID and compare it with the data from the round table to get the map name. This gives us one row per round where we
		recorded the ending with the map name and the ending type. The ending type string includes quotation marks.
		SELECT map_name, feedback.ending FROM ss13_round INNER JOIN [feedback] ON ss13_round.id=feedback.round_id
	*/
	var/datum/DBQuery/endings_query = SSdbcore.NewQuery("SELECT map_name, feedback.ending FROM [format_table_name("round")] INNER JOIN (" + \
		"SELECT round_id, CAST(JSON_EXTRACT(JSON, '$.data\[0\]') AS CHAR) AS ending FROM [format_table_name("feedback")] WHERE key_name='nsv_endings') AS feedback " + \
		" ON [format_table_name("round")].id=feedback.round_id")

	SSdbcore.QuerySelect(stability_query)
	SSdbcore.QuerySelect(endings_query)

	var/list/all_map_info = list()

	for(var/key in config.maplist)
		var/datum/map_config/map_data = config.maplist[key]

		var/obj/structure/overmap/typedef = map_data.ship_type

		var/stability = "No data"
		while(stability_query.NextRow())
			if((stability_query.item[1] == map_data.map_name) && (stability_query.item[2]))
				// (starts - failures) * 100 / starts
				stability = "[(stability_query.item[2] - stability_query.item[3]) * 100 / stability_query.item[2]] %"
		stability_query.next_row_to_take = 1

		var/successes = 0
		var/evacs = 0
		var/losses = 0
		var/successes_text = "No data"
		var/evacs_text = "No data"
		var/losses_text = "No data"
		while(endings_query.NextRow())
			if(endings_query.item[1] == map_data.map_name)
				if(endings_query.item[2] == "\"succeeded\"")
					successes += 1
				else if(endings_query.item[2] == "\"evacuated\"")
					evacs += 1
				else if(endings_query.item[2] == "\"destroyed\"")
					losses += 1
		var/total_results = successes + evacs + losses
		if(total_results > 0)
			successes_text = "[successes] ([successes*100/total_results] %)"
			evacs_text = "[evacs] ([evacs*100/total_results] %)"
			losses_text = "[losses] ([losses*100/total_results] %)"
		endings_query.next_row_to_take = 1

		var/mass = "Maneuvering data not found"
		var/mass_number = initial(typedef.mass)
		switch(mass_number)
			if(MASS_TINY)
				mass = "Tiny and maneuverable"
			if(MASS_SMALL)
				mass = "Small and agile"
			if(MASS_MEDIUM)
				mass = "Average armour and manueverability"
			if(MASS_MEDIUM_LARGE)
				mass = "Medium-sized, clunky"
			if(MASS_LARGE)
				mass = "Larger, clunky"
			if(MASS_TITAN)
				mass = "Heavily armored, slow"
			if(MASS_IMMOBILE)
				mass = "An immobile fortess"
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
			"mapper" = map_data.mapper,
			"patternDate" = map_data.commission_date,
			"strengths" = map_data.strengths + mass,
			"weaknesses" = map_data.weaknesses,
			"equipment" = map_data.equipment,
			"durability" = initial(typedef.max_integrity),
			"engineStability" = stability,
			"successRate" = successes_text,
			"evacRate" = evacs_text,
			"lossRate" = losses_text
		)

		all_map_info[key] = map_info

	var/list/data = list("mapInfo" = all_map_info)
	return data
