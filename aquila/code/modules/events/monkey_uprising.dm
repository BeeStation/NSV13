/datum/round_event_control/monkey_uprising
	name = "Monkey Uprising"
	typepath = /datum/round_event/monkey_uprising
	weight = 10
	max_occurrences = 1
	min_players = 15

/datum/round_event/monkey_uprising

/datum/round_event/monkey_uprising/start()
	var/list/candidates = list()
	for(var/mob/living/M in shuffle(GLOB.alive_mob_list))
		if(ismonkey(M))
			if(M.client && M.mind)
				if(!is_monkey(M.mind))
					candidates[M] = 100
			else
				candidates[M] = 1

	if(candidates.len)
		var/mob/living/winner = pickweight(candidates)
		winner.ForceContractDisease(new /datum/disease/transformation/jungle_fever, FALSE, TRUE)
		announce_to_ghosts(winner)
