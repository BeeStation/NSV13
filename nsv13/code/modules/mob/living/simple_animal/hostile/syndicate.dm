/*
	CONTENTS
	LINE   - Syndicate Space Ranged and Melee
	LINE   - Syndicate Standard Ranged and Melee
*/

/obj/effect/light_emitter/helmet_light_simple//used so there's a combination of both their head light and light coming off the energy sword
	set_luminosity = 3
	set_cap = 3.5
	light_color = LIGHT_COLOR_WHITE


//basic bitch//
/mob/living/simple_animal/hostile/syndicate/nsv
	name = "Syndicate crewman"
	desc = "A shell away from going postal."
	icon = 'nsv13/icons/mob/simple_human.dmi'
	icon_state = "nsvsyndie"
	icon_living = "nsvsyndie"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 1
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	maxHealth = 125
	health = 125
	melee_damage = 13
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 12
	faction = list(ROLE_SYNDICATE)
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = TRUE
	dodging = TRUE
	rapid_melee = 1
	do_footstep = TRUE
	loot = list(/obj/effect/gibspawner/human)

//guns, non-space//
/mob/living/simple_animal/hostile/syndicate/nsv/gun
	ranged = 1
	retreat_distance = 4
	minimum_distance = 4
	icon_state = "nsvsyndie_gun"
	icon_living = "nsvsyndie_gun"
	casingtype = /obj/item/ammo_casing/c10mm
	projectilesound = 'sound/weapons/gunshot.ogg'
	dodging = FALSE
	rapid_melee = 1

/mob/living/simple_animal/hostile/syndicate/nsv/gun/smg
	rapid = 2
	icon_state = "nsvsyndie_smg"
	icon_living = "nsvsyndie_smg"
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/weapons/gunshot_smg.ogg'

/mob/living/simple_animal/hostile/syndicate/nsv/gun/shotgun
	rapid = 2
	rapid_fire_delay = 6
	minimum_distance = 3
	icon_state = "nsvsyndie_shotgun"
	icon_living = "nsvsyndie_shotgun"
	casingtype = /obj/item/ammo_casing/shotgun/buckshot
	projectilesound = 'sound/weapons/shotgunshot.ogg'

//space//
/mob/living/simple_animal/hostile/syndicate/nsv/space
	name = "Syndicate brawler"
	desc = "Going to introduce your face to the deck."
	icon = 'nsv13/icons/mob/simple_human.dmi'
	icon_state = "nsvsyndie_space"
	icon_living = "nsvsyndie_space"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	loot = list(/obj/effect/gibspawner/human)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	spacewalk = TRUE
	maxHealth = 150
	health = 150
	melee_damage = 15

/mob/living/simple_animal/hostile/syndicate/nsv/space/gun
	name = "Syndicate marine"
	desc = "Fluent in over 400 forms of kicking your ass."
	icon = 'nsv13/icons/mob/simple_human.dmi'
	icon_state = "nsvsyndie_gun_space"
	icon_living = "nsvsyndie_gun_space"
	loot = list(/obj/effect/gibspawner/human)
	spacewalk = TRUE
	ranged = 1
	retreat_distance = 3
	minimum_distance = 3
	casingtype = /obj/item/ammo_casing/c10mm
	projectilesound = 'sound/weapons/gunshot.ogg'
	dodging = FALSE
	rapid_melee = 1
	minimum_distance = 4

/mob/living/simple_animal/hostile/syndicate/nsv/space/smg
	name = "Syndicate rifleman"
	desc = "Itching to commit some atrocities."
	icon = 'nsv13/icons/mob/simple_human.dmi'
	icon_state = "nsvsyndie_smg_space"
	icon_living = "nsvsyndie_smg_space"
	spacewalk = TRUE
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/weapons/gunshot_smg.ogg'
	rapid = 2
	retreat_distance = 4
	minimum_distance = 4
	maxHealth = 170
	health = 170
	rapid_fire_delay = 4
	minimum_distance = 5

/mob/living/simple_animal/hostile/syndicate/nsv/space/shotgun
	name = "Syndicate CQC"
	desc = "Has 99 problems, and you aren't one of them."
	icon = 'nsv13/icons/mob/simple_human.dmi'
	icon_state = "nsvsyndie_smg_space"
	icon_living = "nsvsyndie_smg_space"
	spacewalk = TRUE
	retreat_distance = 2
	minimum_distance = 2
	maxHealth = 180
	health = 180
	rapid_fire_delay = 6
	minimum_distance = 3
	
