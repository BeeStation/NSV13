/datum/round_event_control/overmap_test_one
	name = "Overmap Test One"
	typepath = /datum/round_event/overmap_test_one
	weight = 0
	max_occurrences = 1
	min_players = 5

/datum/round_event/overmap_test_one


/datum/round_event/overmap_test_one/start()
	var/current_sys = SSstarsystem.find_system()
	var/opponent = /obj/structure/overmap/syndicate/ai
	SSstarsystem.modular_spawn_enemies(opponent, current_sys)
	SSstarsystem.modifier = 0