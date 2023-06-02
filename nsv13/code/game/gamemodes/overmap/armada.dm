//Side Objectives still need to be generated
/datum/overmap_gamemode/armada
	name = "Armada"
	config_tag = "armada"
	desc = "Complete objectives to gain reinforcements, defend allocated system when the Syndicate Armada arrives."
	brief = "White Rapids Fleet Intelligence indicates that the Syndicate are preparing an invasion fleet to capture selected_system, rally defences to repel the Armada by freeing up fleet assets and prepare to defend the system."
	starting_system = "Argo"
	starting_faction = "nanotrasen"

	objective_reminder_setting = 0				//We have strict timelines on this
	objective_reminder_interval = 3 MINUTES	//60 Minutes Until Vanguard Arrives
	reminder_one = ""							//Countdown 1
	reminder_two = ""							//Countdown 2
	reminder_three = ""							//Countdown 3
	reminder_four = ""							//Vanguard Arrives
	reminder_five = ""							//Mainfleet Arrives

	var/selected_system							//The target of the Syndicate Attack
	var/reinforcements = 0						//How many reinforcement fleets NT has at hand

	selection_weight = 0
	required_players = 15
	fixed_objectives = list(/datum/overmap_objective/system_defence_armada)

/datum/overmap_gamemode/armada/New()
	//Select a system to be targeted

	var/list/candidate = list()
	for(var/datum/star_system/S in SSstar_system.systems)
		if(S.alignment == "nanotrasen")
			candidate += S.name

	candidate -= "Outpost 45"
	selected_system = pick(candidate)

	brief = "Fleet Intelligence indicates that the Syndicate are preparing an invasion fleet to capture [selected_system], rally defences to repel the Armada by freeing up fleet assets and prepare to defend the system."

	reminder_one = "White Rapids predicts the Syndicate Armada will launch their assault on [selected_system] in [(objective_reminder_interval * 3) / 600] Minutes"
	reminder_two = "White Rapids predicts the Syndicate Armada will launch their assault on [selected_system] in [(objective_reminder_interval * 2) / 600] Minutes"
	reminder_three = "White Rapids predicts the Syndicate Armada will launch their assault on [selected_system] in [(objective_reminder_interval * 1) / 600] Minutes"
	reminder_four = "Bluespace Signatures detected on the fringes of [selected_system], prepare to defend the system!"
	reminder_five = "Additional Bluespace Signatures detected, brace for Syndicate reinforcements!"

/datum/overmap_gamemode/armada/consequence_one() //Purely a reminder
	return

/datum/overmap_gamemode/armada/consequence_two() //Purely a reminder
	return

/datum/overmap_gamemode/armada/consequence_three() //Purely a reminder
	return

/datum/overmap_gamemode/armada/consequence_four() //Syndicate Vanguard + Nanotrasen Reinforcements Arrive
	objective_reminder_interval = 5 MINUTES //Armada Soon, Fellow Spaceman

	for(var/datum/overmap_objective/O in objectives)
		O.check_completion()
		if(O.status == 1) //STATUS_COMPLETED
			reinforcements ++ //For each side objective completed, add an NT fleet

	addtimer(CALLBACK(src, PROC_REF(vanguard)), 1 MINUTES)
	if(reinforcements >= 1)
		addtimer(CALLBACK(src, PROC_REF(reinforce)), 2 MINUTES)


/datum/overmap_gamemode/armada/consequence_five() //Syndicate Armada Arrives
	for(var/datum/overmap_objective/system_defence_armada/O in objectives)
		O.armada_arrived = TRUE

	var/datum/star_system/target = SSstar_system.system_by_id(selected_system)
	var/datum/fleet/F = new /datum/fleet/earthbuster()
	target.fleets += F
	F.current_system = target
	F.assemble(target)

/datum/overmap_gamemode/armada/proc/reinforce()
	reinforcements-- //Deduct one from the pool
	var/datum/star_system/target = SSstar_system.system_by_id(selected_system)
	var/datum/fleet/F = new /datum/fleet/nanotrasen/light() //You expected more?
	target.fleets += F
	F.current_system = target
	F.assemble(target)

	if(reinforcements >= 1)
		addtimer(CALLBACK(src, PROC_REF(reinforce)), 2 MINUTES) //Keep Calling Them In

/datum/overmap_gamemode/armada/proc/vanguard()
	var/datum/star_system/target = SSstar_system.system_by_id(selected_system)
	var/datum/fleet/F = new /datum/fleet/interdiction/stealth()
	target.fleets += F
	F.current_system = target
	F.assemble(target)
