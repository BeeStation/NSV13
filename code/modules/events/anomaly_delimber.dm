/datum/round_event_control/anomaly/anomaly_delimber
	name = "Anomaly: Delimber"
	typepath = /datum/round_event/anomaly/anomaly_delimber

	min_players = 10
	max_occurrences = 5
	weight = 10

/datum/round_event/anomaly/anomaly_delimber
	startWhen = 10
	announceWhen = 3
	anomaly_path = /obj/effect/anomaly/delimber

/datum/round_event/anomaly/anomaly_delimber/announce(fake)
	priority_announce("Anomalia dekapitacyjna wykryta. Spodziewana lokalizacja: [impact_area.name]. Należy odziać się w skafandry biologiczne w celu uchronienia się przed utratą kończyny.", "Alarm: Anomalia")
