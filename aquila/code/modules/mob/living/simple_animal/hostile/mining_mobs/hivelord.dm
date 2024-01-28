/mob/living/simple_animal/hostile/asteroid/hivelord
	playable = TRUE
	should_talk = FALSE

/mob/living/simple_animal/hostile/asteroid/hivelord/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user, TRUE)
