/mob/living/simple_animal/hostile/retaliate/poison/snake
	playable = TRUE
	should_talk = FALSE

/mob/living/simple_animal/hostile/retaliate/poison/snake/Initialize()
	. = ..()
	find_candidates()

/mob/living/simple_animal/hostile/retaliate/poison/snake/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user)
