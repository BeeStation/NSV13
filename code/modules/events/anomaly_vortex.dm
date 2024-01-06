/datum/round_event_control/anomaly/anomaly_vortex
	name = "Anomaly: Vortex"
	typepath = /datum/round_event/anomaly/anomaly_vortex

	min_players = 15
	max_occurrences = 2
	weight = 10

/datum/round_event/anomaly/anomaly_vortex
	startWhen = 10
	announceWhen = 3
	anomaly_path = /obj/effect/anomaly/bhole

/datum/round_event/anomaly/anomaly_vortex/announce(fake)
	priority_announce("Anomalia wirowa o dużej intensywności wykryta na skanerach długiego zasięgu. Spodziewany punkt uderzenia: [impact_area.name]", "Alarm: Anomalia", SSstation.announcer.get_rand_alert_sound())
