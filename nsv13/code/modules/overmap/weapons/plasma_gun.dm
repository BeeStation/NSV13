/obj/machinery/ship_weapon/plasma_gun
	name = "\improper Magnetic Plasma Accelerator Cannon"
	icon = 'nsv13/icons/obj/railgun.dmi' //Temp Sprite
	icon_state = "OBC" //Temp Sprite
	desc = "Retrieve the lamp, Torch, for the Dominion, and the Light!"
	anchored = TRUE

	density = TRUE
	safety = TRUE

	bound_width = 128
	bound_height = 32
	ammo_type = /obj/item/stack/sheet/mineral/plasma
	circuit = /obj/item/circuitboard/machine/plasma_gun

	fire_mode = FIRE_MODE_PHORON

	auto_load = TRUE
	semi_auto = TRUE
	maintainable = TRUE
	max_ammo = 30
	feeding_sound = 'nsv13/sound/effects/ship/freespace2/m_load.wav' //TEMP, CHANGE
	fed_sound = null //TEMP, CHANGE
	chamber_sound = null //TEMP, CHANGE

	load_delay = 20
	unload_delay = 20
	fire_animation_length = 10 SECONDS //Maybe? We'll see how I feel about a long firing animations.

	feed_delay = 0
	chamber_delay_rapid = 0
	chamber_delay = 0
	bang = FALSE

/obj/item/circuitboard/machine/plasma_gun
	name = "circuit board (plasma gun)"
	desc = "My faithful...stand firm!"
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 50,
		/obj/item/stack/sheet/iron = 100,
		/obj/item/stack/sheet/mineral/uranium = 20,
		/obj/item/stock_parts/manipulator = 10,
		/obj/item/stock_parts/capacitor = 10,
		/obj/item/stock_parts/matter_bin = 10,
		/obj/item/assembly/igniter = 1,
		/obj/item/ship_weapon/parts/firing_electronics = 1
	)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	build_path = /obj/machinery/ship_weapon/broadside

/datum/ship_weapon/plasma_gun
	name = "MPAC"
	burst_size = 1
	fire_delay = 180 SECONDS
	range_modifier = 10 //Check what this changes
	default_projectile_type = /obj/item/projectile/bullet/broadside
	select_alert = "<span class='notice'>Charging magnetic accelerator...</span>"
	failure_alert = "<span class='warning'>Magnetic Accelerator not ready!</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/broadside.ogg') //Make custom sound, thgwop
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_load_unjam.ogg' //Make custom sound, charging maybe?
	weapon_class = WEAPON_CLASS_HEAVY
	ai_fire_delay = 180 SECONDS
	allowed_roles = OVERMAP_USER_ROLE_GUNNER

/obj/item/projectile/bullet/plasma_gun
	name = "broadside shell"
	icon = 'nsv13/icons/obj/projectiles_nsv.dmi'
	icon_state = "plasma_ball" //Really bad test sprite, animate and globular later
	damage = 150
	obj_integrity = 500
	flag = "overmap_heavy"
	speed = 0.25
	projectile_piercing = ALL
