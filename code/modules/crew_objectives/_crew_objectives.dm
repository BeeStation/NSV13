/datum/controller/subsystem/job/proc/give_crew_objective(datum/mind/crewMind, mob/M)
	if(CONFIG_GET(flag/allow_crew_objectives) && ((M?.client?.prefs.toggles2 & PREFTOGGLE_2_CREW_OBJECTIVES) || (crewMind?.current?.client?.prefs.toggles2 & PREFTOGGLE_2_CREW_OBJECTIVES)))
		generate_individual_objectives(crewMind)
	return

/datum/controller/subsystem/job/proc/generate_individual_objectives(datum/mind/crewMind)
	if(!(CONFIG_GET(flag/allow_crew_objectives)))
		return
	if(!crewMind)
		return
	if(!crewMind.current || crewMind.special_role)
		return
	if(!crewMind.assigned_role)
		return
	var/list/valid_objs = crew_obj_jobs["[ckey(crewMind.assigned_role)]"]
	if(!valid_objs || !valid_objs.len)
		return
	var/selectedObj = pick(valid_objs)
	var/datum/objective/crew/newObjective = new selectedObj
	if(!newObjective)
		return
	newObjective.owner = crewMind
	crewMind.crew_objectives += newObjective
	to_chat(crewMind, "<B>W ramach nanotrasenowskiego systemu przeciwfalowego, zostało ci przydzielone dodatkowe zadanie. Wykonanie zostanie sprawdzone pod koniec zmiany. <span class='warning'>Dopuszczenie się aktów zdrady w celu wykonania zadania może skutkować zerwaniem kontraktu.</span></B>")
	to_chat(crewMind, "<B>Your objective:</B> [newObjective.explanation_text]")

/datum/objective/crew
	var/jobs = ""
	explanation_text = "Jeśli to widzisz, krzycz na forum. Coś się zjebało."
