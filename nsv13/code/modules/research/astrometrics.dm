/**

How this works:
Pick a system to scan that's in range
Scan it (takes scan_goal minutes)
Once you have performed an initial scan, you gain information about what anomalies are in that system, and can collect a few research points from them by doing yet another scan, but to get the full whack, you need to probe them with a science probe that
you build.

*/

/obj/machinery/computer/ship/navigation/astrometrics
	name = "Astrometrics computer"
	desc = "A computer which is capable of interfacing with subspace sensor arrays to gather intel on starsystems. It is capable of performing rudimentary, long range analysis on anomalies, however a probe torpedo will need to be constructed and fired at the anomaly to fully collect its available research."
	req_access = list(ACCESS_RESEARCH)
	circuit = /obj/item/circuitboard/computer/astrometrics
	var/max_range = 40 //In light years, the range at which we can scan systems for data. This is quite short.
	var/scan_progress = 0
	var/scan_goal = 2 MINUTES
	var/datum/star_system/scan_target = null
	var/list/scanned = list()
	var/datum/techweb/linked_techweb = null
	var/obj/item/radio/radio //For engineering alerts.
	var/radio_key = /obj/item/encryptionkey/headset_sci
	var/channel = "Science"

/obj/machinery/computer/ship/navigation/astrometrics/Initialize()
	. = ..()
	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = 0
	radio.recalculateChannels()
	linked_techweb = SSresearch.science_tech

/obj/machinery/computer/ship/navigation/astrometrics/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/starmap)
		assets.send(user)
		ui = new(user, src, "Astrometrics")
		ui.open()
		ui.set_autoupdate(TRUE)

/**
Clean override of the navigation computer to provide scan functionality.
*/

/obj/machinery/computer/ship/navigation/astrometrics/ui_data(mob/user)
	var/list/data = ..()
	var/list/info = SSstar_system.ships[linked]
	var/datum/star_system/current_system = info["current_system"]
	if(scan_target)
		data["scan_target"] = scan_target.name
	else
		data["scan_target"] = null
	if(screen == 2) // Here's where the magic happens.
		data["star_id"] = "\ref[selected_system]"
		var/list/syst = selected_system.system_type
		// data["star_name"] = syst[ "tag" ]
		data["alignment"] = capitalize(selected_system.alignment)
		data["scanned"] = FALSE
		if(info["current_system"])
			var/datum/star_system/curr = info["current_system"]
			data["star_dist"] = curr.dist(selected_system)
		data["anomalies"] = selected_system.get_info()
		if(LAZYFIND(scanned, selected_system.name)) //If we've scanned this one before, get me the list of its anomalies.
			data["scanned"] = TRUE
		if ( data["scanned"] )
			data["system_type"] = syst ? syst[ "label" ] : "ERROR"	//the list /should/ always be initialized when players get to press the button, but alas never trust it.
		else
			data["system_type"] = "Unknown (not scanned)"

	data["can_scan"] = is_in_range(current_system, selected_system)
	data["can_cancel"] = (scan_target) ? TRUE : FALSE
	data["scan_progress"] = scan_progress
	data["scan_goal"] = scan_goal
	var/list/resourcing
	var/list/value_zone = list()
	var/list/system_resources = selected_system?.gas_resources
	/*
		system_resources["/datum/gas/oxygen"]
		system_resources["/datum/gas/nitrogen"]
		system_resources["/datum/gas/plasma"]
		system_resources["/datum/gas/carbon_dioxide"]
		system_resources["/datum/gas/nitrous_oxide"]

	*/
	if(!system_resources)
		resourcing = list(
			"Oxygen" = 0,
			"Nitrogen" = 0,
			"Plasma" = 0,
			"Carbon_Dioxide" = 0,
			"Nitrous_Oxide" = 0,
		)
	else
		resourcing = list()
		resourcing["Oxygen"] = system_resources["/datum/gas/oxygen"]
		resourcing["Nitrogen"] = system_resources["/datum/gas/nitrogen"]
		resourcing["Plasma"] = system_resources["/datum/gas/plasma"]
		resourcing["Carbon_Dioxide"] = system_resources["/datum/gas/carbon_dioxide"]
		resourcing["Nitrous_Oxide"] = system_resources["/datum/gas/nitrous_oxide"]
	
	for(var/gastype in resourcing)
		var/count = resourcing["[gastype]"]
		var/list/gas_viability = list()
		var/min_bound
		var/max_bound
		var/color
		var/class
		switch(count)
			if(150000 to INFINITY)
				min_bound = 100000
				max_bound = 1000000
				color = "blue"
				class = "V"
			if(15000 to 100000)
				min_bound = 10000
				max_bound = 100000
				color = "green"
				class = "IV"
			if(1500 to 10000)
				min_bound = 1000
				max_bound = 10000
				color = "yellow"
				class = "III"
			if(150 to 1000)
				min_bound = 100
				max_bound = 1000
				color = "orange"
				 class = "II"
			else
				min_bound = 0
				max_bound = 100
				color = "red"
				class = "I"
		gas_viability["min_bound"] = min_bound
		gas_viability["max_bound"] = max_bound
		gas_viability["color"] = color
		gas_viability["class"] = class
		value_zone["[gastype]"] = gas_viability

	data["gas_resources"] = resourcing
	data["gas_viability"] = value_zone

	
	return data

/obj/machinery/computer/ship/navigation/astrometrics/is_in_range(datum/star_system/current_system, datum/star_system/system)
	return current_system && system && current_system.dist(system) <= max_range

/obj/machinery/computer/ship/navigation/astrometrics/is_visited(datum/star_system/system)
	return LAZYFIND(scanned, system.name)

/obj/machinery/computer/ship/navigation/astrometrics/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!has_overmap())
		return
	var/list/info = SSstar_system.ships[linked]
	var/datum/star_system/current_system = info["current_system"]
	switch(action)
		if("scan")
			if(!is_in_range(current_system, selected_system))
				return
			scan_progress = 0 //Jus' in case.
			scan_goal = initial(scan_goal)
			scan_target = selected_system
			say("Initiating scan of: [scan_target]")
			playsound(src, 'nsv13/sound/voice/scan_start.wav', 100, FALSE)
			radio.talk_into(src, "Initiating scan of: [scan_target]", channel)
		if("scan_anomaly")
			var/obj/effect/overmap_anomaly/target = locate(params["anomaly_id"])
			if(!istype(target))
				return
			scan_progress = 0 //Jus' in case.
			scan_goal = initial(scan_goal) / 2
			scan_target = target
			say("Initiating scan of: [scan_target]")
			radio.talk_into(src, "Initiating scan of: [scan_target]", channel)
		if("cancel_scan")
			if(!scan_target)
				return
			say("Scan of [scan_target] cancelled!")
			playsound(src, 'nsv13/sound/voice/scanning_cancelled.wav', 100, FALSE)
			radio.talk_into(src, "Scan of [scan_target] cancelled!", channel)
			scan_progress = 0
			scan_target = null
		if("info")
			var/obj/effect/overmap_anomaly/target = locate(params["anomaly_id"])
			if(!istype(target))
				return
			to_chat(usr, "<span class='notice'>[icon2html(target)]: [target.desc]</span>")

/obj/machinery/computer/ship/navigation/astrometrics/process()
	if(scan_target)
		scan_progress += 1 SECONDS
		if(scan_progress >= scan_goal)
			say("Scan of [scan_target] complete!")
			playsound(src, 'nsv13/sound/voice/scanning_complete.wav', 100, FALSE)
			radio.talk_into(src, "Scan of [scan_target] complete!", channel)
			scanned += scan_target.name
			if(istype(scan_target, /obj/effect/overmap_anomaly))
				var/obj/effect/overmap_anomaly/OA = scan_target
				if(OA.research_points > 0 && !OA.scanned) //In case someone else did a scan on it already.
					var/reward = OA.research_points/2
					OA.research_points -= reward
					linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, reward)
				OA.scanned = TRUE
			scan_target = null
			scan_progress = 0

/obj/machinery/computer/ship/navigation/astrometrics/Destroy()
	QDEL_NULL(radio)
	return ..()
