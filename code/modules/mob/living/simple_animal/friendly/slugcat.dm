
/mob/living/simple_animal/pet/slugcat
	name = "the concept of a slugcat"
	desc = "If you see this, someone has done something wrong and placed the WRONG slugcat."
	icon = 'icons/mob/pets.dmi'
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "splats"
	speak_emote = list("yawns")
	emote_hear = list("yawns.")
	emote_see = list("wiggles.", "jiggles.","shivers.")
	faction = list("neutral")
	attacktext = "bites"
	melee_damage = 5
	health = 35
	maxHealth = 35
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 10
	chat_color = "#7a87ff"
	ventcrawler = VENTCRAWLER_ALWAYS
	do_footstep = TRUE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2, /obj/item/organ/ears/cat = 1)

/mob/living/simple_animal/pet/slugcat/default
	name = "slugcat"
	desc = "A weird slithery cat-thing. Hailing from a distant, rainy world."
	icon_state = "catslug"
	icon_living = "catslug"
	icon_dead = "catslug_dead"
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/simple_animal/pet/slugcat/syndicate
	name = "hardsuited slugcat"
	health = 50
	maxHealth = 50
	melee_damage = 10
	desc = "It's a slugcat... in a red hardsuit. Oh no!"
	icon_state = "syndislug"
	icon_living = "syndislug"
	icon_dead = "syndislug_dead"
	attack_sound = 'sound/weapons/blade1.ogg'
	attacktext = "stabs"

/mob/living/simple_animal/pet/slugcat/deathsquad
	name = "deathsquad slugcat"
	health = 150
	maxHealth = 150
	melee_damage = 25
	desc = "It's a slugcat in a deathsquad hardsuit, What more needs to be said?"
	icon_state = "deathslug"
	icon_living = "deathslug"
	icon_dead = "deathslug_dead"
	attack_sound = 'sound/weapons/pulse.ogg'
	attacktext = "obliterates"
