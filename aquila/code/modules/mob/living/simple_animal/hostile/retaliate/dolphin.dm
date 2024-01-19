/mob/living/simple_animal/hostile/retaliate/dolphin
	playable = TRUE
	should_talk = FALSE

/mob/living/simple_animal/hostile/retaliate/dolphin/Initialize()
	. = ..()
	find_candidates()

/mob/living/simple_animal/hostile/retaliate/dolphin/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user)
