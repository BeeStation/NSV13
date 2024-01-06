/datum/round_event_control/anomaly/anomaly_pyro
	name = "Anomaly: Pyroclastic"
	typepath = /datum/round_event/anomaly/anomaly_pyro

	max_occurrences = 5
	weight = 10

/datum/round_event/anomaly/anomaly_pyro
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/pyro

/datum/round_event/anomaly/anomaly_pyro/announce(fake)
	priority_announce("Anomalia piroklastyczna wykryta na skanerach długiego zasięgu. Spodziewany punkt uderzenia: [impact_area.name].", "Alarm: Anomalia", SSstation.announcer.get_rand_alert_sound())
