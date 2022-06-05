/datum/antagonist/pirate/boarder
	name = "Space Pirate"
	var/datum/team/pirate/boarder/boarding_crew

/datum/team/pirate/boarder
	name = "Space Pirate Boarding Crew"

/datum/antagonist/pirate/boarder/greet()
	to_chat(owner, "<span class='boldannounce'>You are a Space Pirate!</span>")
	to_chat(owner, "<B>You've managed to dock within proximity of a Nanotrasen war vessel. You're outnumbered, outgunned, and under prepared in every conceivable way, but if you can manage to successfully pull off a heist on this vessel, it'd be enough to put your pirate crew on the map.</B>")
	owner.announce_objectives()

/datum/antagonist/pirate/boarder/get_team()
	return boarding_crew

/datum/antagonist/pirate/boarder/on_gain()
	if(boarding_crew)
		objectives |= boarding_crew.objectives
	return ..()

/datum/antagonist/pirate/boarder/create_team(datum/team/pirate/boarder/new_team)
	if(!new_team)
		for(var/datum/antagonist/pirate/boarder/P in GLOB.antagonists)
			if(!P.owner)
				continue
			if(P.boarding_crew)
				boarding_crew = P.boarding_crew
				return
		if(!new_team)
			boarding_crew = new /datum/team/pirate/boarder
			boarding_crew.forge_objectives()
			return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	boarding_crew = new_team

/datum/team/pirate/boarder/forge_objectives()
	var/datum/objective/loot/plunder/P = new()
	P.team = src
	for(var/obj/machinery/computer/piratepad_control/PPC in GLOB.machines)
		var/area/A = get_area(PPC)
		if(istype(A,/area/shuttle/pirate))
			P.cargo_hold = PPC
			break
	objectives += P
	for(var/datum/mind/M in members)
		var/datum/antagonist/pirate/boarder/B = M.has_antag_datum(/datum/antagonist/pirate/boarder)
		if(B)
			B.objectives |= objectives

/datum/objective/loot/plunder
	explanation_text = "Loot and pillage the ship, transport 50000 credits worth of loot." //replace me
