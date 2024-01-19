/mob/living/simple_animal/hostile/construct
	playable = TRUE
	should_talk = FALSE

/mob/living/simple_animal/hostile/construct/Initialize()
	. = ..()
	find_candidates()

/mob/living/simple_animal/hostile/construct/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user)
