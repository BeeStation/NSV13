/obj/machinery/ship_weapon/energy/ams
	name = "Laser Anti Missile System"
	desc = "A coaxial laser system, capable of firing controlled laser bursts at a target."
	icon ='nsv13/icons/obj/energy_weapons.dmi'
	icon_state = "missile_cannon"
	fire_mode = FIRE_MODE_AMS_LASER //Shot automatically 
	ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo
	bound_width = 64
	pixel_x = -32
	pixel_y = -32
	// maintainable = TRUE //AMS will require some form of maintenance to operate 
	safety = FALSE //Ready to go right from the start.
	idle_power_usage = 2500
	active = FALSE
	charge = 0
	// charge_rate = 600000 // At power level 5, requires 3MW per tick to charge 
	// charge_per_shot = 6000000 // At power level 5, requires 30MW to fire, takes about 10 seconds to gain 1 charge
	// max_charge = 12000000 // Store 2 charges 
	// Testing vars for solgov AI ships 
	charge_rate = 100
	charge_per_shot = 100
	max_charge = 1000
	power_modifier = 0 //Power you're inputting into this thing.
	power_modifier_cap = 5
	energy_weapon_type = /datum/ship_weapon/laser_ams

/datum/ship_weapon/laser_ams
	name = "Laser Anti Missile System"
	default_projectile_type = /obj/item/projectile/beam/laser/point_defense
	// default_projectile_type = /obj/item/projectile/bullet/fiftycal
	burst_size = 1
	fire_delay = 0.35 SECONDS
	range_modifier = 30
	select_alert = "<span class='notice'>Laser target acquisition systems: online.</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure!</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/burst_phaser.ogg', 'nsv13/sound/effects/ship/burst_phaser2.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'
	weapon_class = WEAPON_CLASS_LIGHT
	selectable = FALSE
	autonomous = TRUE 
	permitted_ams_modes = list( "Anti-missile countermeasures" = 1 )
