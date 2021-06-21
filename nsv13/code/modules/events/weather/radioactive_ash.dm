/datum/round_event_control/radioactive_ash
	name = "Radioactive Ash Storm"
	typepath = /datum/round_event/radioactive_ash
	max_occurrences = 1

/datum/round_event/radioactive_ash


/datum/round_event/radioactive_ash/setup()
	startWhen = 3
	endWhen = startWhen + 1
	announceWhen	= 1

/datum/round_event/radioactive_ash/announce(fake)
	priority_announce("Concentrated radioactive particles approaching the ship.", "Anomaly Alert")

/datum/round_event/radioactive_ash/start()
	SSweather.run_weather(/datum/weather/nuclear_fallout)
