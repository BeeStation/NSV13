/datum/round_event_control/radiation_storm
	name = "Radiation Storm"
	typepath = /datum/round_event/radiation_storm
	max_occurrences = 1
	weight = 10
	can_malf_fake_alert = TRUE

/datum/round_event/radiation_storm


/datum/round_event/radiation_storm/setup()
	startWhen = 3
	endWhen = startWhen + 1
	announceWhen	= 1

/datum/round_event/radiation_storm/announce(fake)
	priority_announce("Wysokie poziomy radiacji wykryte w pobliżu stacji. Prosimy udać się do tuneli serwisowych.", "Alarm: Anomalia", ANNOUNCER_RADIATION)
	//sound not longer matches the text, but an audible warning is probably good

/datum/round_event/radiation_storm/start()
	SSweather.run_weather(/datum/weather/rad_storm)
