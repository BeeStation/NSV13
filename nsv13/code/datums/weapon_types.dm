/**
 * Common information used by both the hero ship and the fighters/AIs
 */
/datum/ship_weapon
	var/default_projectile_type
	var/burst_size
	var/fire_delay
	var/range_modifier
	var/select_alert
	var/failure_alert
	var/list/overmap_firing_sounds
	var/overmap_select_sound

/datum/ship_weapon/railgun
	default_projectile_type = /obj/item/projectile/bullet/railgun_slug
	burst_size = 1
	fire_delay = 10
	range_modifier = 30
	select_alert = "<span class='notice'>Charging railgun hardpoints...</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Railgun systems are not loaded.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/railgun_fire.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/railgun_ready.ogg'

/datum/ship_weapon/torpedo_launcher
	default_projectile_type = /obj/item/projectile/bullet/torpedo
	burst_size = 1
	fire_delay = 5
	range_modifier = 30
	select_alert = "<span class='notice'>Long range target acquisition systems: online.</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Torpedo tubes are not loaded.</span>"
	overmap_firing_sounds = list(
		'nsv13/sound/effects/ship/torpedo.ogg',
		'nsv13/sound/effects/ship/freespace2/m_shrike.wav',
		'nsv13/sound/effects/ship/freespace2/m_stiletto.wav',
		'nsv13/sound/effects/ship/freespace2/m_tsunami.wav',
		'nsv13/sound/effects/ship/freespace2/m_wasp.wav')
	overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'

/datum/ship_weapon/pdc_mount
	default_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 3
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='notice'>Defensive flak screens: <b>OFFLINE</b>. Activating manual point defense cannon control.</span>"
	failure_alert = "<span class='warning'>DANGER: Point defense emplacements are unable to fire due to lack of ammunition.</span>"
