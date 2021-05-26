/**
 * Common information used by both the hero ship and the fighters/AIs
 */

//The big mac. Coaxial railguns fired by the pilot.

/datum/ship_weapon
	var/firing_arc = null //If this weapon only fires in an arc (for ai ships)
	var/weapon_class = WEAPON_CLASS_HEAVY //Do AIs need to resupply with ammo to use this weapon?

/datum/ship_weapon/proc/valid_target(obj/structure/overmap/source, obj/structure/overmap/target)
	if(!istype(source) || !istype(target))
		return FALSE
	return TRUE

/datum/ship_weapon/mac
	name = "Naval Artillery"
	default_projectile_type = /obj/item/projectile/bullet/mac_round
	burst_size = 1
	fire_delay = 3.5 SECONDS
	range_modifier = 50
	select_alert = "<span class='notice'>Naval artillery primed.</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Naval artillery systems are not loaded.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/battleship_gun.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_ready.ogg'
	screen_shake = 2

/datum/ship_weapon/mac/valid_target(obj/structure/overmap/source, obj/structure/overmap/target)
	if(!istype(source) || !istype(target))
		return FALSE
	if(target.mass <= MASS_TINY) //Alright fighter mains. I'm not THAT much of a bastard. Generally AIs will prefer to not use their MAC for flyswatting.
		return FALSE
	return TRUE

//Coaxial railguns

/datum/ship_weapon/railgun
	name = "Coaxial railguns"
	default_projectile_type = /obj/item/projectile/bullet/railgun_slug
	burst_size = 1
	fire_delay = 1.5 SECONDS
	range_modifier = 20
	select_alert = "<span class='notice'>Charging railgun hardpoints...</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Railgun systems are not loaded.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/railgun_fire.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_hold.ogg'
	screen_shake = 1
	selectable = FALSE
	lateral = FALSE
	firing_arc = 45 //Broad side of a barn...

//Deprecated by AMS. Still kept around for AI ships
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

/datum/ship_weapon/torpedo_launcher/valid_target(obj/structure/overmap/source, obj/structure/overmap/target)
	if(!istype(source) || !istype(target))
		return FALSE
	if(target.mass <= MASS_SMALL)
		return FALSE
	if(!source.torpedoes)
		return FALSE
	return TRUE

/datum/ship_weapon/pdc_mount
	name = "Point defense batteries"
	default_projectile_type = /obj/item/projectile/bullet/pdc_round/heavy
	burst_size = 2
	fire_delay = 0.25 SECONDS
	range_modifier = 5
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/autocannon.ogg')
	select_alert = "<span class='notice'>Activating point defense emplacements..</span>"
	failure_alert = "<span class='warning'>DANGER: Point defense emplacements are unable to fire due to lack of ammunition.</span>"
	weapon_class = WEAPON_CLASS_LIGHT //AIs can fire light weaponry like this for free.

/datum/ship_weapon/pdc_mount/aa_guns
	name = "Anti air guns"
	default_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 4
	fire_delay = 10 SECONDS
	range_modifier = 10
	overmap_firing_sounds = list('nsv13/sound/weapons/pdc_single.ogg')
	select_alert = "<span class='notice'>Activating anti-air guns..</span>"
	failure_alert = "<span class='warning'>DANGER: Anti-air guns are unable to fire due to lack of ammunition.</span>"

//Energy Weapons

/datum/ship_weapon/pdc_mount/burst_phaser
	name = "Burst Phasers"
	default_projectile_type = /obj/item/projectile/beam/laser/phaser
	burst_size = 1
	fire_delay = 0.5 SECONDS
	range_modifier = 10
	overmap_select_sound = 'nsv13/sound/effects/ship/phaser_adjust.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/burst_phaser.ogg', 'nsv13/sound/effects/ship/burst_phaser2.ogg')
	select_alert = "<span class='notice'>Activating frontal phasers..</span>"
	failure_alert = "<span class='warning'>DANGER: Point defense emplacements are unable to fire due to lack of ammunition.</span>"
	weapon_class = WEAPON_CLASS_LIGHT //AIs can fire light weaponry like this for free.
	lateral = FALSE
	firing_arc = 60 //Relatively generous, but coax.

/datum/ship_weapon/phaser
	name = "Phaser Banks"
	default_projectile_type = /obj/item/projectile/beam/laser/heavylaser/phaser
	burst_size = 1
	fire_delay = 1.5 SECONDS
	range_modifier = 60
	select_alert = "<span class='notice'>Phaser banks standing by...</span>"
	failure_alert = "<span class='warning'>Unable to comply. Phaser banks recharging.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/phaser.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/phaser_select.ogg' //Sound effect provided by: "All Sounds" https://www.youtube.com/watch?v=EpaCJ75T3fo under creative commons. Trimmed by Kmc2000
	screen_shake = 1

/datum/ship_weapon/bsa
	name = "Bluespace Artillery"
	default_projectile_type = /obj/item/projectile/beam/laser/heavylaser/bsa
	burst_size = 1
	fire_delay = 20 SECONDS
	range_modifier = 255
	select_alert = "<span class='notice'>Bluespace artillery ready.</span>"
	failure_alert = "<span class='warning'>Unable to comply. Bluespace artillery recharging...</span>"
	overmap_firing_sounds = list('nsv13/sound/weapons/bsa_fire.ogg')
	overmap_select_sound = 'nsv13/sound/weapons/bsa_select.ogg'
	screen_shake = 5
	//Pilot operated :))
	selectable = FALSE
	lateral = FALSE
	firing_arc = 45 //Yeah have fun turning the galactica to shoot this thing :)

//End Energy Weapons

/datum/ship_weapon/missile_launcher
	name = "Missile Launchers"
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
	firing_arc = 45 //Broad side of a barn...

/datum/ship_weapon/missile_launcher/valid_target(obj/structure/overmap/source, obj/structure/overmap/target)
	if(!istype(source) || !istype(target))
		return FALSE
	if(target.mass > MASS_SMALL)
		return FALSE
	if(!source.missiles)
		return FALSE
	return TRUE

/datum/ship_weapon/light_cannon
	name = "light autocannon"
	default_projectile_type = /obj/item/projectile/bullet/light_cannon_round
	burst_size = 2
	fire_delay = 0.25 SECONDS
	range_modifier = 10
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/autocannon.ogg')
	select_alert = "<span class='notice'>Cannon selected. DRADIS assisted targeting: online.</span>"
	failure_alert = "<span class='warning'>DANGER: Cannon ammunition reserves are depleted.</span>"
	lateral = FALSE

/datum/ship_weapon/heavy_cannon
	name = ".30 cal heavy cannon"
	default_projectile_type = /obj/item/projectile/bullet/heavy_cannon_round
	burst_size = 2
	fire_delay = 0.5 SECONDS
	range_modifier = 10
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/BRRTTTTTT.ogg')
	select_alert = "<span class='notice'>Cannon selected. DRADIS assisted targeting: online..</span>"
	failure_alert = "<span class='warning'>DANGER: Cannon ammunition reserves are depleted.</span>"
	lateral = FALSE

/datum/ship_weapon/fighter_primary
	name = "Primary Equipment Mount"
	default_projectile_type = /obj/item/projectile/bullet/light_cannon_round //This is overridden anyway
	burst_size = 1
	fire_delay = 0.25 SECONDS
	range_modifier = 10
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/autocannon.ogg')
	select_alert = "<span class='notice'>Primary mount selected.</span>"
	failure_alert = "<span class='warning'>DANGER: Primary mount not responding to fire command.</span>"
	lateral = FALSE
	special_fire_proc = /obj/structure/overmap/proc/primary_fire

/datum/ship_weapon/fighter_secondary
	name = "Secondary Equipment Mount"
	default_projectile_type = /obj/item/projectile/guided_munition/missile //This is overridden anyway
	burst_size = 1
	fire_delay = 5
	range_modifier = 30
	select_alert = "<span class='notice'>Secondary mount selected.</span>"
	failure_alert = "<span class='warning'>DANGER: Secondary mount not responding to fire command.</span>"
	overmap_firing_sounds = list(
		'nsv13/sound/effects/ship/torpedo.ogg',
		'nsv13/sound/effects/ship/freespace2/m_shrike.wav',
		'nsv13/sound/effects/ship/freespace2/m_stiletto.wav',
		'nsv13/sound/effects/ship/freespace2/m_tsunami.wav',
		'nsv13/sound/effects/ship/freespace2/m_wasp.wav')
	overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'
	firing_arc = 45 //Broad side of a barn...
	special_fire_proc = /obj/structure/overmap/proc/secondary_fire

//You don't ever actually select this. Crew act as gunners.

/datum/ship_weapon/gauss
	name = "Gauss guns"
	default_projectile_type = /obj/item/projectile/bullet/gauss_slug
	burst_size = 2
	fire_delay = 3 SECONDS
	range_modifier = 10
	select_alert = "<span class='notice'>Activating gauss weapon systems...</span>"
	failure_alert = "<span class='warning'>DANGER: Gauss gun systems not loaded.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/gauss.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_hold.ogg'
	selectable = FALSE
	weapon_class = WEAPON_CLASS_LIGHT //AIs can fire light weaponry like this for free.

/datum/ship_weapon/fiftycal
	name = ".50 cals"
	default_projectile_type = /obj/item/projectile/bullet/fiftycal
	burst_size = 1
	fire_delay = 0.35 SECONDS
	range_modifier = 10
	select_alert = "<span class='notice'>Activating .50 cals...</span>"
	failure_alert = "<span class='warning'>DANGER: 50 cal gun systems not loaded.</span>"
	overmap_firing_sounds = list('nsv13/sound/weapons/pdc_single.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_hold.ogg'
	selectable = FALSE
	weapon_class = WEAPON_CLASS_LIGHT //AIs can fire light weaponry like this for free.

/datum/ship_weapon/flak
	name = "Flak cannon"
	default_projectile_type = /obj/item/projectile/bullet/flak
	burst_size = 1
	fire_delay = 0
	range_modifier = 1
	overmap_select_sound = 'nsv13/sound/effects/ship/freespace2/computer/escape.wav'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/flak/flakhit1.ogg','nsv13/sound/effects/ship/flak/flakhit2.ogg','nsv13/sound/effects/ship/flak/flakhit3.ogg')
	select_alert = "<span class='notice'>Defensive flak screens: <b>OFFLINE</b>. Activating manual flak control.</span>"
	failure_alert = "<span class='warning'>DANGER: flak guns unable to fire due to lack of ammunition.</span>"
//	special_fire_proc = /obj/structure/overmap/proc/fire_flak
	selectable = FALSE
	lateral = TRUE
