/**
 * Common information used by both the hero ship and the fighters/AIs
 */

//The big mac. Coaxial railguns fired by the pilot.

/datum/ship_weapon/mac
	name = "Naval Artillery"
	default_projectile_type = /obj/item/projectile/bullet/mac_round
	burst_size = 1
	fire_delay = 3.5 SECONDS
	range_modifier = 50
	select_alert = "<span class='notice'>Naval artillery primed.</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Naval artillery systems are not loaded.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/battleship_gun2.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_ready.ogg'
	screen_shake = 2
	ai_fire_delay = 2 SECONDS

/datum/ship_weapon/mac/valid_target(obj/structure/overmap/source, obj/structure/overmap/target, override_mass_check = FALSE)
	if(!istype(source) || !istype(target))
		return FALSE
	if(!override_mass_check && target.mass <= MASS_TINY) //Alright fighter mains. I'm not THAT much of a bastard. Generally AIs will prefer to not use their MAC for flyswatting.
		return FALSE
	return TRUE

//A different MAC.. This one's a warcrime.

/datum/ship_weapon/mac/dirty
	name = "Dirty Naval Artillery"
	default_projectile_type = /obj/item/projectile/bullet/mac_round/dirty

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
	lateral = FALSE
	firing_arc = 45 //Broad side of a barn...
	ai_fire_delay = 5 SECONDS
	allowed_roles = OVERMAP_USER_ROLE_PILOT

/datum/ship_weapon/railgun/valid_target(obj/structure/overmap/source, obj/structure/overmap/target, override_mass_check = FALSE)
	if(!istype(source) || !istype(target))
		return FALSE
	if(!override_mass_check && target.mass <= MASS_TINY) //Alright fighter mains. I'm not THAT much of a bastard. Generally AIs will prefer to not use their MAC for flyswatting.
		return FALSE
	return TRUE

/datum/ship_weapon/hybrid_railgun //Railgun+
	name = "Coaxial Railguns"
	default_projectile_type = /obj/item/projectile/bullet/ //This is ultra dodgy
	burst_size = 1
	fire_delay = 1 SECONDS
	range_modifier = 50
	select_alert = "<span class='notice'>Charging railgun hardpoints...</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Railgun systems are not loaded or charged.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/mac_fire.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_charge.ogg'

//Deprecated by AMS. Still kept around for AI ships
/datum/ship_weapon/torpedo_launcher
	name = "Torpedo tubes"
	default_projectile_type = /obj/item/projectile/guided_munition/torpedo
	burst_size = 1
	fire_delay = 0.5 SECONDS
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
	special_fire_proc = /obj/structure/overmap/proc/fire_torpedo
	lateral = FALSE
	ai_fire_delay = 2 SECONDS

/datum/ship_weapon/torpedo_launcher/burst_disruptor
	name = "Burst Disruption Torpedo tubes"
	default_projectile_type = /obj/item/projectile/guided_munition/torpedo/disruptor
	burst_size = 3
	fire_delay = 4 SECONDS
	range_modifier = 35

/datum/ship_weapon/torpedo_launcher/valid_target(obj/structure/overmap/source, obj/structure/overmap/target, override_mass_check = FALSE)
	if(!istype(source) || !istype(target))
		return FALSE
	if(!override_mass_check && target.mass < MASS_SMALL)	//The Atlas wants fun too :)
		return FALSE
	if(!source.torpedoes)
		return FALSE
	return TRUE

/datum/ship_weapon/aa_guns
	name = "Anti air guns"
	default_projectile_type = /obj/item/projectile/bullet/aa_round
	burst_size = 4
	fire_delay = 0.6 SECONDS
	range_modifier = 10
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/weapons/pdc_single.ogg')
	select_alert = "<span class='notice'>Activating anti-air guns..</span>"
	failure_alert = "<span class='warning'>DANGER: Anti-air guns are unable to fire due to lack of ammunition.</span>"
	weapon_class = WEAPON_CLASS_LIGHT //AIs can fire light weaponry like this for free.
	miss_chance = 33
	max_miss_distance = 6
	ai_fire_delay = 1 SECONDS

/datum/ship_weapon/aa_guns/heavy
	name = "Point defense batteries"
	default_projectile_type = /obj/item/projectile/bullet/aa_round/heavy
	burst_size = 2
	fire_delay = 0.25 SECONDS
	range_modifier = 5
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/autocannon.ogg')

//Energy Weapons

/datum/ship_weapon/burst_phaser // Little red laser
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
	miss_chance = 33
	max_miss_distance = 6
	ai_fire_delay = 0.5 SECONDS

/datum/ship_weapon/phaser // Big blue laser
	name = "Phaser Banks"
	default_projectile_type = /obj/item/projectile/beam/laser/heavylaser/phaser
	burst_size = 1
	fire_delay = 1.5 SECONDS
	range_modifier = 60
	weapon_class = WEAPON_CLASS_HEAVY
	select_alert = "<span class='notice'>Phaser banks standing by...</span>"
	failure_alert = "<span class='warning'>Unable to comply. Phaser banks recharging.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/phaser.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/phaser_select.ogg' //Sound effect provided by: "All Sounds" https://www.youtube.com/watch?v=EpaCJ75T3fo under creative commons. Trimmed by Kmc2000
	screen_shake = 1
	ai_fire_delay = 3 SECONDS

/datum/ship_weapon/phaser/valid_target(obj/structure/overmap/source, obj/structure/overmap/target, override_mass_check = FALSE)
	if(!istype(source) || !istype(target))
		return FALSE
	if(!override_mass_check && target.mass <= MASS_TINY) //Alright fighter mains. I'm not THAT much of a bastard. Generally AIs will prefer to not use their MAC for flyswatting.
		return FALSE
	return TRUE

/datum/ship_weapon/phaser_pd // Gauss laser
	name = "Point-Defense Phasers"
	default_projectile_type = /obj/item/projectile/beam/laser/phaser/pd
	burst_size = 4
	burst_fire_delay = 0.25 SECONDS
	fire_delay = 1.5 SECONDS
	range_modifier = 20
	weapon_class = WEAPON_CLASS_LIGHT
	select_alert = "<span class='notice'>Light phaser banks standing by...</span>"
	failure_alert = "<span class='warning'>Unable to comply. Capacitor banks recharging.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/burst_phaser.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/phaser_select.ogg'
	miss_chance = 20
	ai_fire_delay = 3 SECONDS
	allowed_roles = OVERMAP_USER_ROLE_SECONDARY_GUNNER

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
	lateral = FALSE
	firing_arc = 45 //Yeah have fun turning the galactica to shoot this thing :)
	allowed_roles = OVERMAP_USER_ROLE_PILOT

/datum/ship_weapon/bsa/valid_target(obj/structure/overmap/source, obj/structure/overmap/target, override_mass_check = FALSE)
	if(!istype(source) || !istype(target))
		return FALSE
	if(!override_mass_check && target.mass <= MASS_TINY) //Alright fighter mains. I'm not THAT much of a bastard. Generally AIs will prefer to not use their MAC for flyswatting.
		return FALSE
	return TRUE
//End Energy Weapons

/datum/ship_weapon/missile_launcher
	name = "Missile Launchers"
	default_projectile_type = /obj/item/projectile/guided_munition/missile
	burst_size = 1
	fire_delay = 0.5 SECONDS
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
	special_fire_proc = /obj/structure/overmap/proc/fire_missile
	lateral = FALSE
	ai_fire_delay = 1 SECONDS

/datum/ship_weapon/missile_launcher/valid_target(obj/structure/overmap/source, obj/structure/overmap/target, override_mass_check = FALSE)
	if(!istype(source) || !istype(target))
		return FALSE
	if(!override_mass_check && target.mass > MASS_SMALL)
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

/datum/ship_weapon/light_cannon/integrated	//Weapon for ships big enough that autocannon ammo concerns shouldn't matter this much anymore. Changes their class from HEAVY to LIGHT
	name = "integrated light autocannon"
	weapon_class = WEAPON_CLASS_LIGHT

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
	fire_delay = 0.5 SECONDS
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
	ai_fire_delay = 1 SECONDS

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
	weapon_class = WEAPON_CLASS_LIGHT //AIs can fire light weaponry like this for free.
	miss_chance = 20
	ai_fire_delay = 2 SECONDS
	allowed_roles = OVERMAP_USER_ROLE_SECONDARY_GUNNER

/datum/ship_weapon/pdc_mount // .50 cal flavored PDC bullets, which were previously just PDC flavored .50 cal turrets
	name = "PDC"
	default_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 3
	fire_delay = 0.25 SECONDS
	range_modifier = 10
	select_alert = "<span class='notice'>Activating point defense system...</span>"
	failure_alert = "<span class='warning'>DANGER: point defense system not loaded.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg','nsv13/sound/effects/ship/pdc2.ogg','nsv13/sound/effects/ship/pdc3.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_hold.ogg'
	weapon_class = WEAPON_CLASS_LIGHT //AIs can fire light weaponry like this for free.
	miss_chance = 33
	max_miss_distance = 6
	ai_fire_delay = 0.5 SECONDS
	allowed_roles = OVERMAP_USER_ROLE_PILOT | OVERMAP_USER_ROLE_GUNNER
	var/sound/lastsound // Special PDC sound handling

/datum/ship_weapon/pdc_mount/New()
	..()
	lastsound = pick(overmap_firing_sounds)

// only change our firing sound if we haven't been firing for our fire delay + one second
/datum/ship_weapon/pdc_mount/weapon_sound()
	set waitfor = FALSE
	if(world.time > next_firetime + fire_delay + 10)
		lastsound = pick(overmap_firing_sounds)
	holder.relay(lastsound)

/datum/ship_weapon/flak
	name = "Flak cannon"
	default_projectile_type = /obj/item/projectile/bullet/flak
	burst_size = 1
	fire_delay = 0.5 SECONDS
	range_modifier = 1
	overmap_select_sound = 'nsv13/sound/effects/ship/freespace2/computer/escape.wav'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/flak/flakhit1.ogg','nsv13/sound/effects/ship/flak/flakhit2.ogg','nsv13/sound/effects/ship/flak/flakhit3.ogg')
	select_alert = "<span class='notice'>Defensive flak screens: <b>OFFLINE</b>. Activating manual flak control.</span>"
	failure_alert = "<span class='warning'>DANGER: flak guns unable to fire due to lack of ammunition.</span>"
//	special_fire_proc = /obj/structure/overmap/proc/fire_flak
	lateral = TRUE
	miss_chance = 33
	max_miss_distance = 8
	ai_fire_delay = 0.5 SECONDS
	allowed_roles = OVERMAP_USER_ROLE_PILOT


//AI exclusive weaponry

/datum/ship_weapon/twinmac
	name = "Twin MAC" //Currently only used by the Fist of Sol
	default_projectile_type = /obj/item/projectile/bullet/mac_round
	burst_size = 2
	fire_delay = 3 SECONDS
	range_modifier = 65
	overmap_firing_sounds = list('nsv13/sound/effects/ship/battleship_gun2.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_ready.ogg'
	ai_fire_delay = 3 SECONDS

/datum/ship_weapon/quadgauss
	name = "Quad Gauss"
	default_projectile_type = /obj/item/projectile/bullet/gauss_slug
	burst_size = 4
	fire_delay = 0.5 SECONDS
	range_modifier = 25
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg','nsv13/sound/effects/ship/pdc2.ogg','nsv13/sound/effects/ship/pdc3.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_hold.ogg'
	weapon_class = WEAPON_CLASS_LIGHT //AIs can fire light weaponry like this for free.
	miss_chance = 15
	ai_fire_delay = 0.5 SECONDS

/datum/ship_weapon/hailstorm
	name = "Hailstorm System"
	default_projectile_type = /obj/item/projectile/bullet/hailstorm_bullet
	burst_size = 80
	fire_delay = 20 SECONDS
	range_modifier = 40
	overmap_firing_sounds = list('nsv13/sound/weapons/bsa_fire.ogg')
	overmap_select_sound = 'nsv13/sound/weapons/bsa_select.ogg'
	weapon_class = WEAPON_CLASS_LIGHT
	ai_fire_delay = 20 SECONDS

/datum/ship_weapon/prototype_bsa
	name = "Prototype Bluespace Artillery"
	default_projectile_type = /obj/item/projectile/bullet/prototype_bsa
	burst_size = 1
	fire_delay = 22 SECONDS
	range_modifier = 200
	overmap_firing_sounds = list('nsv13/sound/weapons/bsa_fire.ogg')
	overmap_select_sound = 'nsv13/sound/weapons/bsa_select.ogg'
	ai_fire_delay = 32 SECONDS


