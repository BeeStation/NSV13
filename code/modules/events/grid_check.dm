/datum/round_event_control/grid_check
	name = "Grid Check"
	typepath = /datum/round_event/grid_check
	weight = 10
	max_occurrences = 3

/datum/round_event/grid_check
	announceWhen	= 1
	startWhen = 1

/datum/round_event/grid_check/announce(fake)
	priority_announce("Wykryto nieprawidłowe działanie w sieci zasilania [station_name()]' Jako środek ostrożności, zasilanie stacji zostanie odcięte na nieokreślony czas", "Krytyczny błąd zasilania", ANNOUNCER_POWEROFF)

/datum/round_event/grid_check/start()
	power_fail(30, 120)
