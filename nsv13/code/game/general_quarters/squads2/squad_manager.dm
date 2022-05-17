GLOBAL_DATUM_INIT(squad_manager, /datum/squad_manager, new)

/datum/squad_manager
	var/name = "Squad Manager"
	var/list/squads = list()
	var/list/specialisations = ALL_SQUAD_ROLES

/datum/squad_manager/proc/get_joinable_squad(datum/job/J)
	var/list/joinable = list()
	for(var/datum/squad/squad in squads)
		if(!squad.hidden)
			if(squad.disallowed_jobs)
				if(LAZYFIND(squad.disallowed_jobs, J.type))
					continue
			if(squad.allowed_jobs)
				if(!(LAZYFIND(squad.allowed_jobs, J.type)))
					continue
			joinable += squad
	return (joinable?.len) ? pick(joinable) : null

/datum/squad_manager/New()
	. = ..()
	for(var/_type in subtypesof(/datum/squad))
		squads += new _type()
