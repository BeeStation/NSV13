/datum/overmap_objective/system_defence_armada
	name = "Defend"
	desc = "Defend selected_system against a Syndicate invasion fleet"

	var/armada_arrived = FALSE		//Has the armada arrived yet?
	var/selected_system				//Which system is the target?

/datum/overmap_objective/system_defence_armada/instance()
	.=..()
	var/datum/overmap_gamemode/M = SSovermap_mode.mode
	if(istype(M, /datum/overmap_gamemode/armada))
		var/datum/overmap_gamemode/armada/A = M
		selected_system = A.selected_system

	desc = "Defend [selected_system] against a Syndicate invasion fleet"
	brief = "Defend [selected_system] against a Syndicate invasion fleet"

/datum/overmap_objective/system_defence_armada/check_completion()
	if(!armada_arrived)
		return

	var/datum/star_system/target = SSstar_system.system_by_id(selected_system)
	if(target.alignment != "nanotrasen")
		priority_announce("Attention [station_name()]. Our presence in this sector has been severely diminished due to your incompetence. Return to base immediately for disciplinary action.", "Naval Command")
		SSovermap_mode.mode.defeat()
