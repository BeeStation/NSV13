/datum/controller/subsystem/ticker/proc/overmap_report()
	var/list/parts = list()
	parts += "<b>[SSovermap_mode.mode.name]</b>"
	parts += "" //Line Break
	parts += "Objectives:"
	for(var/datum/overmap_objective/O in SSovermap_mode.mode.objectives)
		switch(O.status)
			if(OBJECTIVE_STATUS_INPROGRESS,OBJECTIVE_STATUS_FAILED)
				parts += "[O.brief]: <font color=red><b>FAILED</b></font>"
			if(OBJECTIVE_STATUS_COMPLETED,OBJECTIVE_STATUS_OVERRIDE)
				parts += "[O.brief]: <font color=green><b>COMPLETED</b></font>"

	parts += "" //Line Break
	var/did_you_win_son = FALSE
	var/objective_check = 0
	for(var/datum/overmap_objective/O in SSovermap_mode.mode.objectives)
		if(O.status == OBJECTIVE_STATUS_OVERRIDE) //Victory override check
			did_you_win_son = TRUE
			break

		else if(O.status == OBJECTIVE_STATUS_COMPLETED)
			objective_check ++

	if(objective_check >= SSovermap_mode.mode.objectives.len)
		did_you_win_son = TRUE

	if(did_you_win_son)
		parts += "The crew of the [GLOB.station_name] <font color=green><b>COMPLETED</b></font> their mission for [capitalize(SSovermap_mode.mode.starting_faction)]<b>"
		return "<div class='panel greenborder'>[parts.Join("<br>")]</div>"

	else
		parts += "The crew of the [GLOB.station_name] <font color=red><b>FAILED</b></font> their mission for [capitalize(SSovermap_mode.mode.starting_faction)]<b>"
		return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
