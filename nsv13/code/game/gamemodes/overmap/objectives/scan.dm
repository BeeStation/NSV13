/datum/overmap_objective/scan
	name = "Scan anomalies"
	desc = "Scan target anomalies of anomaly_type"
	brief = "Locate and scan target anomaly_type\s"
	var/obj/effect/overmap_anomaly/anomaly_type
	var/list/anomaly_whitelist = list(/
		/obj/effect/overmap_anomaly/safe/sun, /
		/obj/effect/overmap_anomaly/safe/sun/red_giant, /
		/obj/effect/overmap_anomaly/wormhole
		)
	var/minimum_anomalies = 1
	var/maximum_anomalies = 5

/datum/overmap_objective/scan/New()
	. = ..()
	anomaly_type = pick(anomaly_whitelist)
	target = rand(minimum_anomalies, maximum_anomalies) //doing this to check if there are enough of this type
	if(?[anomaly_type])
		message_admins("Overmap gamemode failed to locate anomalies! Setting to auto-complete.")
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
