GLOBAL_DATUM_INIT(squad_manager, /datum/squad_manager, new)

/datum/squad_manager
	var/name = "Squad Manager"
	var/static/list/squads = list()
	var/static/list/role_squad_map = list()
	//Think "what do they need that squad vendors can't give them?"
	var/static/list/role_access_map = list(
		DC_SQUAD = list(),
		MEDICAL_SQUAD = list(),
		SECURITY_SQUAD = list(ACCESS_BRIG),
		MUNITIONS_SUPPORT = list(ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE),
		COMBAT_AIR_PATROL = list(ACCESS_COMBAT_PILOT, ACCESS_MUNITIONS), //Hangar is typically through munitions
		CIC_OPS = list(ACCESS_HEADS, ACCESS_RC_ANNOUNCE),
	)
	var/static/list/role_verb_map = list(
		DC_SQUAD = "<span class='warning'><br/>During <b>General Quarters</b> you must find a squad vendor, gear up, then report to your squad leader for orders.<br/> \
			As a <i>damage control party member</i> you are responsible for repairing the ship and ensuring that breaches are sealed, debris is cleared from the halls, and injured people are taken to the medical bay.<br/>\
			Although your assigned duty is damage control, you must listen to your squad leader, as they may receive orders to redirect your squad to another essential duty <br/>\
			<i>Squad vendors</i> open up during General Quarters, and allow you to acquire a kit containing tarpaulins for closing breaches, basic tools, metal foam and a distinctive uniform to tell your squad members apart.</span>",
		MEDICAL_SQUAD = "<span class='warning'><br/>During <b>General Quarters</b> you must find a squad vendor, gear up, then report to your squad leader for orders.<br/> \
			As a <i>medical team member</i> you are responsible for providing basic field first-aid to injured crewmen. Once the patient is out of critical condition, bring them to the medical bay.<br/>\
			Although your assigned duty is medical aid, you must listen to your squad leader, as they may receive orders to redirect your squad to another essential duty <br/>\
			<i>Squad vendors</i> open up during General Quarters, and allow you to acquire a kit containing tarpaulins for closing breaches, basic tools, metal foam and a distinctive uniform to tell your squad members apart.</span>",
		SECURITY_SQUAD = "<span class='warning'><br/>During <b>General Quarters</b> you must find a squad vendor, gear up, then report to your squad leader for orders.<br/> \
			As a <i>security fireteam member</i> you are responsible for assisting security in repelling boarders, or by partaking in boarding action.<br/>\
			You must listen to your squad leader, as they may receive orders to redirect your squad to another essential duty. <br/>\
			<i>Squad vendors</i> open up during General Quarters, and allow you to acquire a kit containing tarpaulins for closing breaches, basic tools, metal foam and a distinctive uniform to tell your squad members apart.</span>",
		COMBAT_AIR_PATROL = "<span class='warning'><br/>During <b>General Quarters</b> you must find a squad vendor, gear up, then report to your squad leader for orders.<br/> \
			As a member of the<i>auxiliary combat air patrol</i> you are responsible for manning any available fighters. If all the fighters are manned by pilots, report to the XO for re-assignment.<br/>\
			You must listen to your squad leader, as they may receive orders to redirect your squad to another essential duty. <br/>\
			<i>Squad vendors</i> open up during General Quarters.</span>",
		MUNITIONS_SUPPORT = "<span class='warning'><br/>During <b>General Quarters</b> you must find a squad vendor, gear up, then report to your squad leader for orders.<br/> \
			As a member of the<i>munitions support crew</i> you are responsible aiding the munitions technicians with firing the guns. If there are no munitions techs, then your squad must assume command of the weapons bay and ensure the guns are firing.<br/>\
			You must listen to your squad leader, as they may receive orders to redirect your squad to another essential duty. <br/>\
			<i>Squad vendors</i> open up during General Quarters.</span>",
		CIC_OPS = "<span class='warning'><br/>During <b>General Quarters</b> you must find a squad vendor, gear up, then report to your squad leader for orders.<br/> \
			As a <i>CIC operations specialist</i> you are responsible for manning the ship control consoles and ensuring that the ship is able to fight back against any threats. If all the bridge stations are manned by bridge crew, report to the XO for re-assignment.<br/>\
			You must listen to your squad leader, as they may receive orders to redirect your squad to another essential duty. <br/>\
			<i>Squad vendors</i> open up during General Quarters..</span>",
	)

/datum/squad_manager/New()
	. = ..()
	for(var/_type in subtypesof(/datum/squad))
		var/datum/squad/squad = new _type()
		squads |= squad
		if(!role_squad_map[squad.id])
			role_squad_map[squad.id] = list()
		role_squad_map[squad.id] |= squad
	addtimer(CALLBACK(src, .proc/check_squad_assignments), 5 MINUTES) //Kick off a timer to check if we need to finagle some people into jobs. Ensure people have a chance to join.

/datum/squad_manager/proc/get_squad(name)
	for(var/datum/squad/S in squads)
		if(S.name == name)
			return S

// Try to find a squad that's not already tasked that can do the job
/datum/squad_manager/proc/assign_squad(role)
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
	minor_announce("[stuckee] has been retasked as a [role] due to staffing issues", "WhiteRapids Bureaucratic Corps")

// Method which runs just slightly after roundstart, and ensures that the ship has at least its BASIC roles filled
/datum/squad_manager/proc/check_squad_assignments()
	var/datum/job/job = SSjob.GetJob("Bridge Staff")
	if(!job.current_positions)
		assign_squad(CIC_OPS)

	job = SSjob.GetJob("Munitions Technician")
	if(!job.current_positions)
		assign_squad(MUNITIONS_SUPPORT)

	var/tally = 0
	job = SSjob.GetJob("Station Engineer")
	tally += job.current_positions
	job = SSjob.GetJob("Atmospheric Technician")
	tally += job.current_positions
	if(!tally)
		assign_squad(DC_SQUAD)

/datum/squad_manager/proc/get_joinable_squad(datum/job/J)
	var/list/joinable = list()
	for(var/datum/squad/squad in squads)
		if(!squad.hidden)
			if(LAZYFIND(squad.allowed_jobs, J.type))
				joinable += squad
			else if(!LAZYFIND(squad.disallowed_jobs, J.type))
				joinable += squad
	return (length(joinable)) ? pick(joinable) : null
