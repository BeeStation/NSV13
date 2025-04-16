//// Base mob ////
///// Interior Mobs ////
/mob/living/simple_animal/hostile/nsv/nanotrasen
	name = "Nanotrasen marine"
	desc = "About time they sent some backup!"
	icon = 'nsv13/icons/mob/simple_human.dmi'
	icon_state = "nsvnt_melee"
	icon_living = "nsvnt_melee"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	maxHealth = 120
	health = 120
	melee_damage = 14
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	a_intent = INTENT_HARM
	loot = list(/obj/effect/gibspawner/human)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 10
	faction = list("neutral")
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = TRUE
	dodging = TRUE
	rapid_melee = 1
	do_footstep = TRUE


/mob/living/simple_animal/hostile/nsv/nanotrasen/ranged
	name = "Nanotrasen marine"
	desc = "Rocking the finest glock this side of Sol."
	icon = 'nsv13/icons/mob/simple_human.dmi'
	icon_state = "nsvnt_ranged"
	icon_living = "nsvnt_ranged"
	maxHealth = 120
	health = 120
	melee_damage = 6
	attacktext = "pistol whips"
	attack_sound = 'sound/weapons/punchmiss.ogg'
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 10
	faction = list("neutral")
	check_friendly_fire = 1
	ranged = 1
	retreat_distance = 5
	minimum_distance = 4
	casingtype = /obj/item/ammo_casing/c9mm
	projectilesound = 'nsv13/sound/weapons/glock.ogg'

//// Space mobs ////
/mob/living/simple_animal/hostile/nsv/nanotrasen/space
	name = "Nanotrasen marine"
	icon_state = "nsvnt_melee_space"
	icon_living = "nsvnt_melee_space"
	desc = "Whilst not a cutting edge spacesuit, squadsuits work just as well."
	maxHealth = 135
	health = 135
	melee_damage = 13
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 1
	spacewalk = TRUE

/mob/living/simple_animal/hostile/nsv/nanotrasen/space/ranged
	icon_state = "nsvnt_ranged_space"
	icon_living = "nsvnt_ranged_space"
	desc = "Bringing down the Syndicate, one 9mm round at a time!"
	maxHealth = 135
	health = 135
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 1
	spacewalk = TRUE
	ranged = 1
	retreat_distance = 4
	minimum_distance = 4
	casingtype = /obj/item/ammo_casing/c9mm
	projectilesound = 'nsv13/sound/weapons/glock.ogg'

/mob/living/simple_animal/hostile/nsv/nanotrasen/space/ranged/elite
	rapid = 2
	name = "Nanotrasen elite marine"
	desc = "Good grief, is that Mjolnir armour?"
	health = 175
	maxHealth = 175
	melee_damage = 10
	attacktext = "bludgeons"
	attack_sound = 'sound/weapons/genhit1.ogg'
	icon_state = "nsvnt_ranged_space_elite"
	icon_living = "nsvnt_ranged_space_elite"
	casingtype = /obj/item/ammo_casing/peacekeeper/lethal
	projectilesound = 'nsv13/sound/weapons/m4_fire.wav'
	dodging = TRUE
	spacewalk = TRUE
	retreat_distance = 4
	minimum_distance = 3
	speed = 2
	ranged = 1

