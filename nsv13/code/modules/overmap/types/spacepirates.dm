
//Space Pirate ships go here

/obj/structure/overmap/spacepirate/HomeOne
	name = "HomeOne Class Pirate Raider"
	desc = "A heavily modified hauler that was rebuilt using outdated armaments for maximum firepower and speed, these self-sufficient raiding vessels are not known for their durability."
	icon = 'nsv13/icons/overmap/new/nanotrasen/frigate.dmi'
	icon_state = "spacepirate_hauler"
	mass = MASS_SMALL
	sprite_size = 48
	damage_states = FALSE
	obj_integrity = 1200
	max_integrity = 1200
	starting_system = "Staging"
	armor = list("overmap_light" = 80, "overmap_medium" = 45, "overmap_heavy" = 10)
	bound_height = 32
	bound_width = 32
	role = INSTANCED_MIDROUND_SHIP

/obj/structure/overmap/spacepirate/HomeOne/apply_weapons()
	new /datum/overmap_ship_weapon/gauss(src, FALSE)
	new /datum/overmap_ship_weapon/pdc_mount(src, FALSE)
	new /datum/overmap_ship_weapon/hybrid_railgun(src, FALSE)
	new /datum/overmap_ship_weapon/vls(src)
//AI versions

/obj/structure/overmap/spacepirate/ai
	name = "Space Pirate"
	desc = "A Space Pirate Vessel"
	icon = 'nsv13/icons/overmap/new/nanotrasen/frigate.dmi'
	icon_state = "spacepirate_hauler"
	faction = "pirate"
	mass = MASS_SMALL
	max_integrity = 400
	armor = list("overmap_light" = 80, "overmap_medium" = 45, "overmap_heavy" = 10)
	torpedo_type = /obj/item/projectile/guided_munition/torpedo/ai
	missile_type = /obj/item/projectile/guided_munition/missile/ai
	bound_height = 64
	bound_width = 64
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	ai_flags = AI_FLAG_ANTI_FIGHTER //You didn't expect identical tactics, did you?
	combat_dice_type = /datum/combat_dice/frigate

/obj/structure/overmap/spacepirate/ai/Initialize(mapload)
	. = ..()
	name = "[name] ([rand(0,999)])" //pirate names go here

/obj/structure/overmap/spacepirate/ai/apply_weapons()
	var/random_weapons = pick(1, 2, 3, 4, 5)
	switch(random_weapons) //Dakkagang
		if(1)
			new /datum/overmap_ship_weapon/aa_guns(src, FALSE)
			new /datum/overmap_ship_weapon/torpedo_launcher(src, FALSE)
			new /datum/overmap_ship_weapon/pdc_mount(src)
			torpedoes = 10 //I am not actually adjusting the max ammo for the pirate versions because they probably bolted on a launcher.
		if(2)
			new /datum/overmap_ship_weapon/aa_guns(src, FALSE)
			new /datum/overmap_ship_weapon/railgun(src, FALSE)
			new /datum/overmap_ship_weapon/pdc_mount(src)
			shots_left = 10
			max_shots_left = 10 //Lower than base so I am adjusting here.
		if(3)
			new /datum/overmap_ship_weapon/aa_guns(src, FALSE)
			new /datum/overmap_ship_weapon/gauss(src, FALSE)
			new /datum/overmap_ship_weapon/pdc_mount(src)
		if(4)
			new /datum/overmap_ship_weapon/aa_guns(src, FALSE)
			new /datum/overmap_ship_weapon/missile_launcher(src, FALSE)
			new /datum/overmap_ship_weapon/pdc_mount(src)
			missiles = 10
		if(5)
			new /datum/overmap_ship_weapon/aa_guns(src, FALSE)
			new /datum/overmap_ship_weapon/flak(src, FALSE)
			new /datum/overmap_ship_weapon/pdc_mount(src)

/obj/structure/overmap/spacepirate/ai/boarding //our boarding capable variant (we want to control how many of these there are)
	ai_flags = AI_FLAG_BOARDER

/obj/structure/overmap/spacepirate/ai/nt_missile
	name = "Space Pirate Missile Boat"
	desc = "This vessel appears to have been commandeered by the space pirates"
	icon = 'nsv13/icons/overmap/new/nanotrasen/frigate.dmi'
	icon_state = "spacepirate_frigate"
	mass = MASS_SMALL
	sprite_size = 48
	damage_states = FALSE
	bound_height = 96
	bound_width = 96
	obj_integrity = 525
	max_integrity = 525
	armor = list("overmap_light" = 80, "overmap_medium" = 45, "overmap_heavy" = 10)
	ai_flags = AI_FLAG_DESTROYER
	torpedoes = 30
	missiles = 30

/obj/structure/overmap/spacepirate/ai/nt_missile/apply_weapons()
	var/random_weapons = pick(1, 2, 3, 4, 5)
	switch(random_weapons) //Dakkagang
		if(1)
			new /datum/overmap_ship_weapon/aa_guns(src, FALSE)
			new /datum/overmap_ship_weapon/torpedo_launcher(src, FALSE)
			new /datum/overmap_ship_weapon/pdc_mount(src)
		if(2)
			new /datum/overmap_ship_weapon/aa_guns(src, FALSE)
			new /datum/overmap_ship_weapon/railgun(src, FALSE)
			new /datum/overmap_ship_weapon/pdc_mount(src)
			shots_left = 10
			max_shots_left = 10
		if(3)
			new /datum/overmap_ship_weapon/aa_guns(src, FALSE)
			new /datum/overmap_ship_weapon/pdc_mount(src)
		if(4)
			new /datum/overmap_ship_weapon/aa_guns(src, FALSE)
			new /datum/overmap_ship_weapon/missile_launcher(src, FALSE)
			new /datum/overmap_ship_weapon/pdc_mount(src)
		if(5)
			new /datum/overmap_ship_weapon/aa_guns(src, FALSE)
			new /datum/overmap_ship_weapon/flak(src, FALSE)
			new /datum/overmap_ship_weapon/pdc_mount(src)

/obj/structure/overmap/spacepirate/ai/syndie_gunboat
	name = "Space Pirate Gunboat"
	desc = "This vessel appears to have been commandeered by the space pirates"
	icon = 'nsv13/icons/overmap/syndicate/syn_light_cruiser.dmi'
	icon_state = "spacepirate_cruiser"
	mass = MASS_MEDIUM
	sprite_size = 96
	damage_states = FALSE
	bound_height = 128
	bound_width = 128
	max_integrity = 350
	shots_left = 20
	armor = list("overmap_light" = 80, "overmap_medium" = 45, "overmap_heavy" = 10)
	ai_flags = AI_FLAG_BATTLESHIP | AI_FLAG_ELITE //Needs to be shooting all its guns
	combat_dice_type = /datum/combat_dice/destroyer

/obj/structure/overmap/spacepirate/ai/syndie_gunboat/apply_weapons() //Dakka+
	new /datum/overmap_ship_weapon/aa_guns(src, FALSE)
	new /datum/overmap_ship_weapon/mac/dirty(src, FALSE)
	new /datum/overmap_ship_weapon/gauss(src, FALSE)
	new /datum/overmap_ship_weapon/pdc_mount(src)

/obj/structure/overmap/spacepirate/ai/dreadnought //And you thought the pirates only had small ships
	name = "Space Pirate Dreadnought"
	desc = "Hoist the colours high"
	icon = 'nsv13/icons/overmap/syndicate/gunboat.dmi' //who knows which one should be which??? vOv
	icon_state = "spacepirate_gunboat"
	mass = MASS_LARGE
	sprite_size = 128
	damage_states = FALSE
	bound_width = 160
	bound_height = 160
	obj_integrity = 5000
	max_integrity = 5000
	shots_left = 35
	torpedoes = 35
	armor = list("overmap_light" = 95, "overmap_medium" = 80, "overmap_heavy" = 45)
	can_resupply = TRUE
	ai_flags = AI_FLAG_SUPPLY | AI_FLAG_ELITE
	combat_dice_type = /datum/combat_dice/flagship

/obj/structure/overmap/spacepirate/ai/dreadnought/apply_weapons()
	new /datum/overmap_ship_weapon/aa_guns(src, FALSE)
	new /datum/overmap_ship_weapon/torpedo_launcher(src, FALSE)
	new /datum/overmap_ship_weapon/railgun(src, FALSE)
	new /datum/overmap_ship_weapon/flak(src, FALSE, 2)
	new /datum/overmap_ship_weapon/gauss(src, FALSE)
	new /datum/overmap_ship_weapon/pdc_mount(src)

