/datum/round_event_control/anomaly/anomaly_flux
	name = "Anomaly: Hyper-Energetic Flux"
	typepath = /datum/round_event/anomaly/anomaly_flux

	min_players = 40
	max_occurrences = 5
	weight = 5

/datum/round_event/anomaly/anomaly_flux
	startWhen = 10
	announceWhen = 3
	anomaly_path = /obj/effect/anomaly/flux

/datum/round_event/anomaly/anomaly_flux/announce(fake)
	priority_announce("Fala strumieni hiperenergetycznych zlokalizowana na skanerach dalekiego zasięgu. Spodziewany punkt uderzenia: [impact_area.name].", "Alarm: Anomalia", SSstation.announcer.get_rand_alert_sound())
