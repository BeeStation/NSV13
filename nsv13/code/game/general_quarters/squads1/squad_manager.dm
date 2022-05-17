GLOBAL_DATUM_INIT(squad_manager, /datum/squad_manager, new)
//"Enum" that lets you define squads. Format: Name, colour theming.
/datum/squad_manager
	var/name = "Squad Manager"
	var/list/squads = list()

/datum/squad_manager/New()
	. = ..()
	for(var/I = 1; I <= GLOB.squad_styling.len; I++){
		var/datum/squad/S = new /datum/squad()
		S.name = "[GLOB.squad_styling[I][1]]"
		S.colour = GLOB.squad_styling[I][2]
		S.max_members = GLOB.squad_styling[I][3]
		squads += S
		S.generate_channel()
	}
	addtimer(CALLBACK(src, .proc/check_squad_assignments), 5 MINUTES) //Kick off a timer to check if we're on nightmare world lowpop and need to finagle some people into jobs. Ensure people have a chance to join.

///Method which runs just slightly after roundstart, and ensures that the ship has at least its BASIC roles filled
/datum/squad_manager/proc/check_squad_assignments()
	for(var/rank in list("Bridge Staff", "Munitions Technician"))
		var/datum/job/job = SSjob.GetJob(rank)
		if(!job)
			message_admins("No [rank] in SSjob]")
			continue
		if(!job.current_positions) //Unstaffed crucial job! I count MT and BS as ESSENTIAL for ship operation, so if you have none, the game needs to step in and fix your problem for you. This is so that the ship can always keep moving, even if all the crew try and go meme roles like clown (fight me)
			var/list/possible = list()
			for(var/datum/squad/S in squads)
				if(S.members.len && S.squad_type == DC_SQUAD) //Unassigned DC squads with members are preferred. Otherwise, set up any random squad for when people join it.
					possible += S
			if(!possible.len) //Second run: If no squads are populated, we'll want to set up a squad for later.
				for(var/datum/squad/S in squads)
					if(S.squad_type == DC_SQUAD) //If we just re-assigned a squad, don't re-re-assign it because that would be stupid.
						possible += S
			var/datum/squad/victim = pick(possible)
			var/required = DC_SQUAD //Foo.
			required = (rank == "Bridge Staff") ? CIC_OPS : MUNITIONS_SUPPORT
			victim.retask(required)
			minor_announce("[victim] has been retasked as a [required] due to staffing issues", "WhiteRapids Bureaucratic Corps")

/datum/squad_manager/proc/get_squad(name)
	for(var/datum/squad/S in squads){
		if(S.name == name){
			return S
		}
	}

/datum/squad_manager/proc/get_joinable_squad()
	for(var/datum/squad/S in squads){
		if(S.members.len && S.members.len >= S.max_members){
			continue
		}
		else{
			return S
		}
	}
