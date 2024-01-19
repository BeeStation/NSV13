/mob/living/simple_animal/cockroach
	playable = TRUE
	should_talk = FALSE

/mob/living/simple_animal/cockroach/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user)
