/mob/living/simple_animal/mouse
	playable = TRUE
	should_talk = FALSE

/mob/living/simple_animal/mouse/Initialize()
	. = ..()
	find_candidates()

/mob/living/simple_animal/mouse/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user)

/mob/living/simple_animal/mouse/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced)
	. = ..()
