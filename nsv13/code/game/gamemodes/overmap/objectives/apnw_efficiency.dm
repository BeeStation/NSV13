/datum/overmap_objective/apnw_efficiency
	name = "Test APNW"
	desc = "Get APNW to target efficiency level"
	brief = "Test the APNW by raising the repair efficiency to at least target_efficiency %"
	var/obj/machinery/armour_plating_nanorepair_well/APNW = null
	var/target_efficiency = 0.50 // out of 1

/datum/overmap_objective/apnw_efficiency/New()
	. = ..()
	APNW = locate() in GLOB.machines
	if(!APNW)
		message_admins("Overmap gamemode failed to locate APNW! Setting to auto-complete.")
		status = 1
	else
		target_efficiency = rand(60, 90) / 100
		START_PROCESSING(SSprocessing, src)

/datum/overmap_objective/apnw_efficiency/instance()
	. = ..()
	desc = "Get APNW to [target_efficiency * 100]% efficiency level"
	brief = "Test the APNW by raising the repair efficiency to at least [target_efficiency * 100]%"

/datum/overmap_objective/apnw_efficiency/process()
	check_completion()

/datum/overmap_objective/apnw_efficiency/check_completion()
	if(status != 0)
		STOP_PROCESSING(SSprocessing, src)
		return
	if(APNW.repair_efficiency >= target_efficiency)
		SSovermap_mode.update_reminder(objective=TRUE)
		status = 1
		STOP_PROCESSING(SSprocessing, src)
