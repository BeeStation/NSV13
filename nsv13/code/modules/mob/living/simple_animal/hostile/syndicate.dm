
/obj/effect/light_emitter/red_energy_sword //used to make interior shotgunners more visable
	set_luminosity = 1
	set_cap = 1.5
	light_color = LIGHT_COLOR_RED



//// Base mob ////

/mob/living/simple_animal/hostile/nsv
	name = "Assistant"
	desc = "Get another greyshirt into the fight!"
	icon = 'nsv13/icons/mob/simple_human.dmi'
	icon_state = "generic"
	icon_living = "generic"
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
	maxHealth = 80
	health = 80
	melee_damage = 8
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	loot = list(/obj/effect/gibspawner/human)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 10
	faction = list("Syndicate")
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = TRUE
	dodging = FALSE
	rapid_melee = 1
	do_footstep = TRUE

///// Interior Mobs ////
/mob/living/simple_animal/hostile/nsv/syndicate
	name = "Syndicate crew"
	desc = "A generic member of the Syndicate Navy."
	icon = 'nsv13/icons/mob/simple_human.dmi'
	icon_state = "nsvsyndie"
	icon_living = "nsvsyndie"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	turns_per_move = 5
	speed = 1
	maxHealth = 100
	health = 100
	melee_damage = 8
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 3, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 10
	faction = list("Syndicate")
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = TRUE
	dodging = TRUE
	mobchatspan = "syndmob"

/mob/living/simple_animal/hostile/nsv/syndicate/ranged
	name = "Syndicate crew"
	desc = "Looks like this one has taken up arms."
	icon_state = "nsvsyndie_gun"
	icon_living = "nsvsyndie_gun"
	melee_damage = 6
	attacktext = "pistol whips"
	attack_sound = 'sound/weapons/punchmiss.ogg'
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 3, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	faction = list("Syndicate")
	dodging = FALSE
	ranged = 1
	retreat_distance = 4
	minimum_distance = 4
	casingtype = /obj/item/ammo_casing/c10mm
	projectilesound = 'sound/weapons/gunshot.ogg'
	rapid_melee = 0

/mob/living/simple_animal/hostile/nsv/syndicate/ranged/smg
	rapid = 2
	name = "Syndicate marine"
	desc = "Stop looking, start shooting!"
	health = 130
	maxHealth = 130
	melee_damage = 10
	attacktext = "bludgeons"
	attack_sound = 'sound/weapons/genhit1.ogg'
	icon_state = "nsvsyndie_smg"
	icon_living = "nsvsyndie_smg"
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/weapons/gunshot_smg.ogg'

/mob/living/simple_animal/hostile/nsv/syndicate/ranged/shotgun
	name = "Syndicate breacher"
	desc = "If you're reading this, it's probably too late."
	health = 155
	maxHealth = 155
	melee_damage = 14
	attacktext = "bludgeons"
	attack_sound = 'sound/weapons/genhit1.ogg'
	rapid_fire_delay = 6
	minimum_distance = 3
	icon_state = "nsvsyndie_shotgun"
	icon_living = "nsvsyndie_shotgun"
	speed = 2
	projectilesound = 'sound/weapons/shotgunshot.ogg'
	casingtype = /obj/item/ammo_casing/shotgun/buckshot
	dodging = TRUE
	var/obj/effect/light_emitter/red_energy_sword/HuDLight

/mob/living/simple_animal/hostile/nsv/syndicate/ranged/shotgun/Initialize(mapload)
	. = ..()
	HuDLight = new(src)
	set_light(1)

/mob/living/simple_animal/hostile/nsv/syndicate/ranged/shotgun/Destroy()
	QDEL_NULL(HuDLight)
	return ..()


//// Space Mobs ////

/mob/living/simple_animal/hostile/nsv/syndicate/space
	icon_state = "nsvsyndie_space"
	icon_living = "nsvsyndie_space"
	desc = "A generic member of the Syndicate Navy, now in a spacesuit."
	maxHealth = 100
	health = 100
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 1
	spacewalk = TRUE

/mob/living/simple_animal/hostile/nsv/syndicate/space/ranged
	icon_state = "nsvsyndie_gun_space"
	icon_living = "nsvsyndie_gun_space"
	desc = "A generic member of the Syndicate Navy, now in a spacesuit. This one also has a gun!"
	maxHealth = 120
	health = 120
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 1
	spacewalk = TRUE
	ranged = 1
	retreat_distance = 4
	minimum_distance = 4

/mob/living/simple_animal/hostile/nsv/syndicate/space/ranged/smg
	rapid = 2
	name = "Syndicate stormtrooper"
	desc = "Stop looking, start shooting!"
	health = 175
	maxHealth = 175
	melee_damage = 10
	attacktext = "bludgeons"
	attack_sound = 'sound/weapons/genhit1.ogg'
	icon_state = "nsvsyndie_smg_space"
	icon_living = "nsvsyndie_smg_space"
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/weapons/gunshot_smg.ogg'

/mob/living/simple_animal/hostile/nsv/syndicate/space/sword
	name = "Syndicate stormtrooper"
	icon_state = "nsvsyndie_melee_space"
	icon_living = "nsvsyndie_melee_space"
	desc = "Relentless... Fearless... and rapidly approaching."
	attack_sound = 'sound/weapons/blade1.ogg'
	attacktext = "slashes"
	melee_damage = 32
	maxHealth = 250
	health = 250
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 3
	spacewalk = TRUE
	dodging = TRUE
	rapid_melee = 0
	var/projectile_deflect_chance = 40
	armour_penetration = 30
	var/obj/effect/light_emitter/red_energy_sword/HuDLight
	hardattacks = TRUE

/mob/living/simple_animal/hostile/nsv/syndicate/space/sword/Initialize(mapload)
	. = ..()
	HuDLight = new(src)
	set_light(2)

/mob/living/simple_animal/hostile/nsv/syndicate/space/sword/Destroy()
	QDEL_NULL(HuDLight)
	return ..()

/mob/living/simple_animal/hostile/nsv/syndicate/space/ranged/shotgun
	name = "Syndicate stormtrooper"
	desc = "Feet first into hell."
	health = 200
	maxHealth = 200
	melee_damage = 10
	attacktext = "bludgeons"
	attack_sound = 'sound/weapons/genhit1.ogg'
	rapid_fire_delay = 6
	minimum_distance = 3
	icon_state = "nsvsyndie_shotgun_space"
	icon_living = "nsvsyndie_shotgun_space"
	speed = 1
	casingtype = /obj/item/ammo_casing/shotgun/buckshot
	dodging = TRUE
	rapid_fire_delay = 6
	minimum_distance = 3
	projectilesound = 'sound/weapons/shotgunshot.ogg'
