GLOBAL_DATUM_INIT(squad_manager, /datum/squad_manager, new)

/datum/squad_manager
	var/name = "Squad Manager"
	var/static/list/squads = list()
	var/static/list/role_squad_map = list()
	//Think "what do they need that squad vendors can't give them?"
	//These aren't granted by default, someone has to enable access
	var/static/list/role_access_map = list(
		DC_SQUAD = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_ATMOSPHERICS), //Low staffing? Guess you better get the engine running
		MEDICAL_SQUAD = list(ACCESS_MEDICAL, ACCESS_SURGERY),
		SECURITY_SQUAD = list(ACCESS_BRIG, ACCESS_SEC_DOORS, ACCESS_TRANSPORT_PILOT, ACCESS_HANGAR),
		MUNITIONS_SUPPORT = list(ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE),
		COMBAT_AIR_PATROL = list(ACCESS_COMBAT_PILOT, ACCESS_MUNITIONS), //Hangar is typically through munitions
		CIC_OPS = list(ACCESS_HEADS, ACCESS_RC_ANNOUNCE),
	)//
	var/static/list/role_objective_map = list(
		DC_SQUAD = "<span class='warning'><br/>During <b>General Quarters</b> report to the <i>squad vendors</i> to obtain your equipment.<br/>\
			Your primary duties are to repair the ship, seal breaches, and bring injured to medbay.<br/>\
			Listen to your squad leader, who may issue further orders.</span>",
		MEDICAL_SQUAD = "<span class='warning'><br/>During <b>General Quarters</b> report to the <i>squad vendors</i> to obtain your equipment.<br/>\
			Your primary duties are to provide first-aid to injured crewmen and bring stabilized patients to medbay.<br/>\
			Listen to your squad leader, who may issue further orders.</span>",
		SECURITY_SQUAD = "<span class='warning'><br/>During <b>General Quarters</b> report to the <i>squad vendors</i> to obtain your equipment.<br/>\
			Your primary duties are to assist security in repelling boarders and participate in boarding actions.<br/>\
			Listen to your squad leader, who may issue further orders.</span>",
		COMBAT_AIR_PATROL = "<span class='warning'><br/>During <b>General Quarters</b> report to the <i>squad vendors</i> to obtain your equipment.<br/>\
			Your primary duty is to man any available fighters. If all fighters are manned by pilots, report to the XO for re-assignment.<br/>\
			Listen to your squad leader, who may issue further orders.</span>",
		MUNITIONS_SUPPORT = "<span class='warning'><br/>During <b>General Quarters</b> report to the <i>squad vendors</i> to obtain your equipment.<br/>\
			Your primary duty is to assist munitions with loading and firing the guns. If there are no munitions techs, you are acting munitions techs.<br/>\
			Listen to your squad leader, who may issue further orders.</span>",
		CIC_OPS = "<span class='warning'><br/>During <b>General Quarters</b> report to the <i>squad vendors</i> to obtain your equipment.<br/>\
			Your primary duty is to ensure the navigation and tactical consoles are manned. If all stations are manned by bridge crew, report to the XO for re-assignment.<br/>\
			Listen to your squad leader, who may issue further orders.</span>",
	)

/datum/squad_manager/New()
	. = ..()
	for(var/_type in subtypesof(/datum/squad))
		var/datum/squad/squad = new _type()
		squads |= squad
		LAZYADDASSOCLIST(role_squad_map, squad.role, squad)
		squad.retask(squad.role)
	addtimer(CALLBACK(src, PROC_REF(check_squad_assignments)), 5 MINUTES) //Kick off a timer to check if we need to finagle some people into jobs. Ensure people have a chance to join.

/datum/squad_manager/proc/get_squad(name)
	for(var/datum/squad/S in squads)
		if(S.name == name)
			return S

// Try to find a squad that's not already tasked that can do the job
/datum/squad_manager/proc/assign_squad(role)
	var/list/assigned_list = role_squad_map[role]
	if(length(assigned_list))
		for(var/datum/squad/assigned in assigned_list)
			if(!istype(assigned) || !length(assigned.members))
				continue
			assigned.lowpop_retasked = TRUE
			assigned.access_enabled = TRUE // They won't be much help without this
			return
	//Prefer DC squads by default. Make sure there are people in them and we haven't tasked them already
	var/list/possible = role_squad_map[DC_SQUAD]
	for(var/datum/squad/S in possible)
		if(S.lowpop_retasked || !length(S.members))
			possible -= S
	//Okay, is anyone left?
	if(!length(possible))
		for(var/datum/squad/S in squads)
			if(!S.lowpop_retasked && length(S.members))
				possible |= S
	if(!length(possible))
		//Well, we did our best
		return

	var/datum/squad/stuckee = pick(possible)
	stuckee.retask(role)
	stuckee.lowpop_retasked = TRUE
	stuckee.access_enabled = TRUE // They won't be much help without this
	minor_announce("[stuckee] has been retasked as a [role] due to staffing issues", "WhiteRapids Bureaucratic Corps")

// Method which runs just slightly after roundstart, and ensures that the ship has at least its BASIC roles filled
/datum/squad_manager/proc/check_squad_assignments()
	var/datum/job/job = SSjob.GetJob("Bridge Staff")
	if(!istype(job))
		message_admins("Could not get Bridge Staff job datum")
	else if(!job.current_positions)
		assign_squad(CIC_OPS)

	job = SSjob.GetJob("Munitions Technician")
	if(!istype(job))
		message_admins("Could not get Munitions Technician job datum")
	else if(!job.current_positions)
		assign_squad(MUNITIONS_SUPPORT)

	var/tally = 0
	job = SSjob.GetJob("Station Engineer")
	if(!istype(job))
		message_admins("Could not get Station Engineer job datum")
	else
		tally += job.current_positions
	job = SSjob.GetJob("Atmospheric Technician")
	if(!istype(job))
		message_admins("Could not get Atmospheric Technician job datum")
	else
		tally += job.current_positions
	if(!tally)
		assign_squad(DC_SQUAD)

/datum/squad_manager/proc/get_joinable_squad(datum/job/J)
	var/list/joinable = list()
	var/datum/squad/smallest_squad = null
	var/datum/squad/least_members = 99
	for(var/datum/squad/squad in squads)
		if(!squad.hidden)
			if(LAZYFIND(squad.disallowed_jobs, J.type) && !LAZYFIND(squad.allowed_jobs, J.type))
				continue
			joinable += squad
			var/squad_size = length(squad.members)
			if(least_members > squad_size)
				smallest_squad = squad
				least_members = squad_size
	if(!length(joinable))
		return null
	var/datum/squad/chosen = pick(joinable)
	if(length(chosen.members) >= chosen.max_members)
		return smallest_squad
	return chosen
