/**
 * Common information used by both the hero ship and the fighters/AIs
 */
/datum/ship_weapon
	var/name = "Ship weapon"
	var/default_projectile_type
	var/burst_size
	var/fire_delay
	var/range_modifier
	var/select_alert
	var/failure_alert
	var/list/overmap_firing_sounds
	var/overmap_select_sound

/datum/ship_weapon/railgun
	name = "Electromagnetic railguns"
	default_projectile_type = /obj/item/projectile/bullet/railgun_slug
	burst_size = 1
	fire_delay = 10
	range_modifier = 30
	select_alert = "<span class='notice'>Charging railgun hardpoints...</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Railgun systems are not loaded.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/railgun_fire.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/railgun_ready.ogg'

/datum/ship_weapon/torpedo_launcher
	name = "Torpedo tubes"
	default_projectile_type = /obj/item/projectile/guided_munition/torpedo
	burst_size = 1
	fire_delay = 5
	range_modifier = 30
	select_alert = "<span class='notice'>Torpedo target acquisition systems: online.</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Torpedo tubes are not loaded.</span>"
	overmap_firing_sounds = list(
		'nsv13/sound/effects/ship/torpedo.ogg',
		'nsv13/sound/effects/ship/freespace2/m_shrike.wav',
		'nsv13/sound/effects/ship/freespace2/m_stiletto.wav',
		'nsv13/sound/effects/ship/freespace2/m_tsunami.wav',
		'nsv13/sound/effects/ship/freespace2/m_wasp.wav')
	overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'

/datum/ship_weapon/pdc_mount
	name = "Point defense guns"
	default_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 3
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='notice'>Activating point defense emplacements..</span>"
	failure_alert = "<span class='warning'>DANGER: Point defense emplacements are unable to fire due to lack of ammunition.</span>"

/datum/ship_weapon/missile_launcher
	default_projectile_type = /obj/item/projectile/guided_munition/missile
	burst_size = 1
	fire_delay = 5
	range_modifier = 30
	select_alert = "<span class='notice'>Missile target acquisition systems: online.</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Missile racks are not loaded.</span>"
	overmap_firing_sounds = list(
		'nsv13/sound/effects/ship/torpedo.ogg',
		'nsv13/sound/effects/ship/freespace2/m_shrike.wav',
		'nsv13/sound/effects/ship/freespace2/m_stiletto.wav',
		'nsv13/sound/effects/ship/freespace2/m_tsunami.wav',
		'nsv13/sound/effects/ship/freespace2/m_wasp.wav')
	overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'

/datum/ship_weapon/light_cannon
	default_projectile_type = /obj/item/projectile/bullet/light_cannon_round
	burst_size = 3
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='notice'>Cannon selected. DRADIS assisted targeting: online.</span>"
	failure_alert = "<span class='warning'>DANGER: Cannon ammunition reserves are depleted.</span>"

/datum/ship_weapon/heavy_cannon
	default_projectile_type = /obj/item/projectile/bullet/heavy_cannon_round
	burst_size = 3
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='notice'>Cannon selected. DRADIS assisted targeting: online..</span>"
	failure_alert = "<span class='warning'>DANGER: Cannon ammunition reserves are depleted.</span>"

/datum/ship_weapon/search_rescue_scoop //not currently enabled
	default_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 0
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"
	failure_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"

/datum/ship_weapon/search_rescue_extractor //not currently enabled
	default_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 0
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"
	failure_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"

/datum/ship_weapon/rapid_breach_sealing_welder //not currently enabled
	default_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 0
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"
	failure_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"

/datum/ship_weapon/rapid_breach_sealing_foam //not currently enabled
	default_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 0
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"
	failure_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"

/datum/ship_weapon/refueling_system //not currently enabled
	default_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 0
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"
	failure_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"

//You don't ever actually select this. Crew act as gunners.

/datum/ship_weapon/gauss
	name = "Gauss guns"
	default_projectile_type = /obj/item/projectile/bullet/gauss_slug
	burst_size = 2
	fire_delay = 10
	range_modifier = 20
	select_alert = "<span class='notice'>Activating gauss weapon systems...</span>"
	failure_alert = "<span class='warning'>DANGER: Gauss gun systems not loaded.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/gauss.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/railgun_ready.ogg'

/datum/ship_weapon/flak
	name = "Flak cannon"
	default_projectile_type = /obj/item/projectile/bullet/gauss_slug
	burst_size = 1
	fire_delay = 5 SECONDS
	range_modifier = 30
	overmap_select_sound = 'nsv13/sound/effects/ship/freespace2/computer/escape.wav'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/flak/flakhit1.ogg','nsv13/sound/effects/ship/flak/flakhit2.ogg','nsv13/sound/effects/ship/flak/flakhit3.ogg')
	select_alert = "<span class='notice'>Defensive flak screens: <b>OFFLINE</b>. Activating manual flak control.</span>"
	failure_alert = "<span class='warning'>DANGER: flak guns unable to fire due to lack of ammunition.</span>"