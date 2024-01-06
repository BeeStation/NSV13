/datum/round_event_control/anomaly/anomaly_bluespace
	name = "Anomaly: Bluespace"
	typepath = /datum/round_event/anomaly/anomaly_bluespace

	max_occurrences = 1
	weight = 10

/datum/round_event/anomaly/anomaly_bluespace
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/bluespace

/datum/round_event/anomaly/anomaly_bluespace/announce(fake)
	priority_announce("Niestabilna anomalia bluespace zlokalizowana na skanerach dalekiego zasięgu. Spodziewana lokalizacja: [impact_area.name].", "Alarm: Anomalia", SSstation.announcer.get_rand_alert_sound())
