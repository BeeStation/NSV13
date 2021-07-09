/datum/round_event_control/radioactive_sludge
	name = "Random Sludge Event"
	typepath = /datum/round_event/radioactive_sludge
	weight = 0
	max_occurrences = 1000

/datum/round_event/radioactive_sludge
	var/min_spawners = 2
	var/max_spawners = 10

/datum/round_event/radioactive_sludge/setup()
	startWhen = 2
	endWhen = startWhen + 1
	announceWhen = 1

/datum/round_event/radioactive_sludge/start()
	var/list/possible_spawners = list()
	for(var/obj/effect/landmark/nuclear_waste_spawner/spawner in GLOB.landmarks_list)
		possible_spawners += spawner

	var/num_spawners = min(rand(min_spawners, max_spawners), possible_spawners.len)
	for(var/i = 0; i < num_spawners; i++)
		var/obj/effect/landmark/nuclear_waste_spawner/S = pick(possible_spawners)
		possible_spawners -= S
		S.fire()

/datum/round_event/radioactive_sludge/announce(fake)
	priority_announce("Abnormal levels of radioactive material detected on board.", "Anomaly Alert")
