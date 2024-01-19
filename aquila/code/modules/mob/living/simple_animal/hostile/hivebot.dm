/mob/living/simple_animal/hostile/hivebot
	playable = TRUE
	should_talk = FALSE

/mob/living/simple_animal/hostile/hivebot/Initialize()
	. = ..()
	find_candidates()

/mob/living/simple_animal/hostile/hivebot/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user)
