/datum/overmap_objective/scan
	name = "Scan anomalies"
	desc = "Scan a target anomaly_type"
	brief = "Locate and scan target anomaly_type"
	var/anomaly_type
	var/anomaly_name = "anomaly"
	var/list/anomaly_whitelist = list(
		/obj/effect/overmap_anomaly/safe/sun,
		/obj/effect/overmap_anomaly/safe/sun/red_giant,
		/obj/effect/overmap_anomaly/wormhole,
		/obj/effect/overmap_anomaly/singularity)
	var/minimum_anomalies = 1
	var/maximum_anomalies = 5

/datum/overmap_objective/scan/New()
	. = ..()
	var/list/valid_anomalies = anomaly_whitelist
	target = rand(minimum_anomalies, maximum_anomalies)
	while(length(valid_anomalies) && !anomaly_type) //doing this to check if there are enough of this type
		anomaly_type = pick(valid_anomalies)
		anomaly_name = get_by_type(GLOB.overmap_anomalies, anomaly_type)?.name
		if(count_by_type(GLOB.overmap_anomalies, anomaly_type) < target)
			valid_anomalies -= anomaly_type
			anomaly_type = null
			anomaly_name = "ERROR"
	if(!anomaly_type)
		message_admins("Overmap gamemode failed to locate enough anomalies! Setting to auto-complete.")
		status = 1

/datum/overmap_objective/scan/instance()
	. = ..()
	desc = "Scan [target] [anomaly_type]\s"
	brief = "Locate and scan [target] [anomaly_type]\s"

/datum/overmap_objective/scan/check_completion()
	if(tally <= target)
		return
	if(tally >= target)
		SSovermap_mode.update_reminder(objective=TRUE)
		status = 1
