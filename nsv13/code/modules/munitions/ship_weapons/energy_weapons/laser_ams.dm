/datum/ship_weapon/laser_ams
	name = "Laser Anti Missile System"
	default_projectile_type = /obj/item/projectile/beam/laser/heavylaser/phaser
	burst_size = 1
	fire_delay = 0.35 SECONDS
	range_modifier = 30
	select_alert = "<span class='notice'>Laser target acquisition systems: online.</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure!</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/burst_phaser.ogg', 'nsv13/sound/effects/ship/burst_phaser2.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'
	selectable = FALSE
	autonomous = TRUE 
	autonomous_priority = 8
	permitted_ams_modes = list( "Anti-missile countermeasures" = 1 )

/obj/machinery/ship_weapon/energy/ams
	name = "Laser Anti Missile System"
	desc = "A coaxial laser system, capable of firing controlled laser bursts at a target."
	icon ='nsv13/icons/obj/energy_weapons.dmi'
	icon_state = "phase_cannon"
	fire_mode = FIRE_MODE_AMS_LASER //Shot automatically 
	ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo
	bound_width = 64
	pixel_x = -32
	pixel_y = -32
	maintainable = TRUE //AMS will require some form of maintenance to operate 
	safety = FALSE //Ready to go right from the start.
	idle_power_usage =  2500
	active = FALSE
	charge = 0
	charge_rate = 400000 
	charge_per_shot = 4000000
	max_charge = 8000000 // Takes about 10 seconds to gain 1 charge, store 2 charges 
	power_modifier = 0 //Power youre inputting into this thing.
	power_modifier_cap = 1 //Which means that your guns are spitting bursts that do 60 damage.
	energy_weapon_type = /datum/ship_weapon/laser_ams
