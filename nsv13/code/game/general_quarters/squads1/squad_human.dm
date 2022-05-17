/mob/living/carbon/human
	var/datum/squad/squad = null

//Show relevent squad info on status panel.
/mob/living/carbon/human/proc/get_stat_tab_squad()
	var/list/tab_data = list()

	if(!squad)
		tab_data["Assigned Squad"] = list(
			text = "None",
			type = STAT_TEXT
		)
		return tab_data

	tab_data["Assigned Squad"] = list(
			text = "[squad.name || "Unassigned"]",
			type = STAT_TEXT
		)
	tab_data["Squad Leader"] = list(
			text = "[squad.leader || "None"]",
			type = STAT_TEXT
		)
	tab_data["Squad Type"] = list(
			text = "[squad.squad_type || "Standard"]",
			type = STAT_TEXT
		)
	tab_data["Standing Orders"] = list(
			text = "[squad.orders || "None"]",
			type = STAT_TEXT
		)

	return tab_data
