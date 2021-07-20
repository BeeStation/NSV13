/datum/ship_weapon/laser_ams
	name = "Laser Anti Missile System"
	default_projectile_type = /obj/item/projectile/beam/laser/heavylaser/bsa
	burst_size = 1
	fire_delay = 0.35 SECONDS
	range_modifier = 30
	select_alert = "<span class='notice'>Missile target acquisition systems: online.</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Missile tubes are not loaded.</span>"
	overmap_firing_sounds = list(
		'nsv13/sound/effects/ship/torpedo.ogg',
		'nsv13/sound/effects/ship/freespace2/m_shrike.wav',
		'nsv13/sound/effects/ship/freespace2/m_stiletto.wav',
		'nsv13/sound/effects/ship/freespace2/m_tsunami.wav',
		'nsv13/sound/effects/ship/freespace2/m_wasp.wav')
	overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'
	selectable = FALSE

// /obj/machinery/ship_weapon/vls/laser
// 	name = "Laser Anti Missile System"
// 	desc = "A highly advanced launch platform for missiles inspired by recently discovered old-earth technology. The VLS allows for launching cruise missiles from any angle, and directly interfaces with the AMS for lethal precision."
// 	icon = 'nsv13/icons/obj/munitions/vls.dmi'
// 	icon_state = "loader"
// 	firing_sound = 'nsv13/sound/effects/ship/plasma.ogg'
// 	load_sound = 'nsv13/sound/effects/ship/freespace2/m_load.wav'
// 	fire_mode = FIRE_MODE_AMS_LASER
// 	ammo_type = list()
// 	CanAtmosPass = FALSE
// 	CanAtmosPassVertical = FALSE
// 	semi_auto = TRUE
// 	max_ammo = 5
// 	density = FALSE
// 	circuit = /obj/item/circuitboard/machine/vls
// 	auto_load = TRUE

/obj/machinery/ship_weapon/energy/ams
	name = "Laser Anti Missile System"
	desc = "A coaxial laser system, capable of firing controlled laser bursts at a target."
	icon ='nsv13/icons/obj/energy_weapons.dmi'
	icon_state = "phase_cannon"
	fire_mode = FIRE_MODE_AMS_LASER //Shot by the pilot.
	ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo
	bound_width = 64
	pixel_x = -32
	pixel_y = -32
	maintainable = FALSE //Laser do shoot good and reliably.
	safety = FALSE //Ready to go right from the start.
	idle_power_usage =  2500
	active = FALSE
	charge = 0
	charge_rate = 25000 //How quickly do we charge?
	charge_per_shot = 50000 //How much power per shot do we have to use?
	max_charge = 250000 //5 shots before it has to recharge.
	power_modifier = 0 //Power youre inputting into this thing.
	power_modifier_cap = 3 //Which means that your guns are spitting bursts that do 60 damage.
	energy_weapon_type = /datum/ship_weapon/laser_ams
