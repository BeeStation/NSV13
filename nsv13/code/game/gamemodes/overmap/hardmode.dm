//Specific objectives and changes for hardmode

/datum/overmap_gamemode/hardmode
	name = "Dolos Assault"
	config_tag = "hardmode"
	desc = "Harder gamemode - Defeat the Syndicate in Rubicon and Dolos (intended to be used with the hardmode setting)"
	brief = "The Syndicate have prepared a strong naval force, fly to Dolos through Rubicon, and put them back in their place! Then clean up the rest of them or return home victorious."
	starting_system = "Medea" //Start closer to the frontline for immediate action
	starting_faction = "nanotrasen"
	objective_reminder_setting = 1
	whitelist_only = TRUE //Needs to be specifically enabled in the map config to roll (outside of the specific hardmode toggle)
	selection_weight = 5
	required_players = 25 //You'll need a decent sized crew
	fixed_objectives = list(/datum/overmap_objective/clear_system/rubicon, /datum/overmap_objective/clear_system/dolos)
	reminder_origin = "Whiterapids QRF Command"

/datum/controller/subsystem/overmap_mode/proc/toggle_hardmode()
	if(!initialized) //Not yet
		message_admins("Hardmode failed to activate! Turn it on when the overmap gamemode subsystem is done loading in the control panel!")
		return FALSE
	hard_mode_enabled = !hard_mode_enabled
	log_game("Hard mode has been [hard_mode_enabled ? "enabled" : "disabled"]!")
	if(hard_mode_enabled) //Go on, clear the map out
		force_mode(/datum/overmap_gamemode/hardmode)
		SSresearch.hardmode_tech_enable()
		var/datum/star_system/R = SSstar_system.system_by_id("Rubicon")
		R.spawn_fleet(/datum/fleet/interdiction/light) //They're going to assault you immediately, should be replaced with a more general aggressive Syndicate expansion behaviour
		if(mode_initialised) //Not really needed when they're not in game yet
			priority_announce("Increased hostile activity detected. Mission objectives for [station_name()] updated. Please consult the communications console for a new mission statement. Mobilize your forces at once.")
		if(!SSticker.HasRoundStarted()) //No antagonists, you've got enough on your plate
			GLOB.master_mode = "secret_extended"
	else //Undo all of that
		SSresearch.hardmode_tech_disable()
		force_mode(/datum/overmap_gamemode/patrol) //Just set it to patrol instead
		var/datum/star_system/D = SSstar_system.system_by_id("Dolos Remnants")
		for(var/datum/fleet/F in D.fleets)
			if(istype(F, /datum/fleet/remnant))
				F.move(SSstar_system.system_by_id("Oasis Fidei"), TRUE) //Retreat
		if(!SSticker.HasRoundStarted()) //Back to normal
			GLOB.master_mode = "secret"
	return TRUE
