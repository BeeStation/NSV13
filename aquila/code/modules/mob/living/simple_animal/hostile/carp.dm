/mob/living/simple_animal/hostile/carp
	playable = TRUE
	should_talk = FALSE

/mob/living/simple_animal/hostile/carp/Initialize()
	. = ..()
	find_candidates()

/mob/living/simple_animal/hostile/carp/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user)
