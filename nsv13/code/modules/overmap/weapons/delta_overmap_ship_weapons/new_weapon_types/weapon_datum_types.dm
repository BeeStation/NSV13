//A new home for weaon datum types that were migrated.

//OSW WIP: Consider range modified var.
//OSW WIP: Implement base priority settings.

//The big MAC. Fired by the gunner.
/datum/overmap_ship_weapon/mac
	name = "Naval Artillery"
	standard_projectile_type = /obj/item/projectile/bullet/mac_round
	burst_size = 1
	fire_delay = 3.5 SECONDS
	range_modifier = 50
	select_alert = "<span class='notice'>Naval artillery primed.</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Naval artillery systems are not loaded.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/battleship_gun2.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_ready.ogg'
	screen_shake = 2
	ai_fire_delay = 2 SECONDS
	weapon_control_flags = OSW_CONTROL_GUNNER|OSW_CONTROL_AI|OSW_CONTROL_AIMING_BEAM

/datum/overmap_ship_weapon/mac/is_target_size_valid(obj/structure/overmap/target)
	if(target.mass <= MASS_TINY) //Alright fighter mains. I'm not THAT much of a bastard. Generally AIs will prefer to not use their MAC for flyswatting.
		return FALSE
	return TRUE

//A different MAC.. This one's a warcrime.

/datum/overmap_ship_weapon/mac/dirty
	name = "Dirty Naval Artillery"
	standard_projectile_type = /obj/item/projectile/bullet/mac_round/dirty


//Coaxial railguns

/datum/overmap_ship_weapon/railgun
	name = "Coaxial railguns"
	standard_projectile_type = /obj/item/projectile/bullet/railgun_slug
	burst_size = 1
	fire_delay = 1.5 SECONDS
	range_modifier = 20
	select_alert = "<span class='notice'>Charging railgun hardpoints...</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Railgun systems are not loaded.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/railgun_fire.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_hold.ogg'
	screen_shake = 1
	ai_fire_delay = 5 SECONDS
	firing_arc = 45 //Broad side of a barn...
	weapon_facing_flags = OSW_FACING_FRONT|OSW_ALWAYS_FIRES_FORWARD
	weapon_control_flags = OSW_CONTROL_PILOT|OSW_CONTROL_AI

/datum/overmap_ship_weapon/railgun/is_target_size_valid(obj/structure/overmap/target)
	if(target.mass <= MASS_TINY) //Alright fighter mains. I'm not THAT much of a bastard. Generally AIs will prefer to not use their MAC for flyswatting.
		return FALSE
	return TRUE

/datum/overmap_ship_weapon/hybrid_railgun //Railgun+
	name = "Coaxial Railguns"
	standard_projectile_type = /obj/item/projectile/bullet //This is ultra dodgy
	burst_size = 1
	fire_delay = 1 SECONDS
	range_modifier = 50
	select_alert = "<span class='notice'>Charging railgun hardpoints...</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Railgun systems are not loaded or charged.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/mac_fire.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_charge.ogg'
	weapon_control_flags = OSW_CONTROL_GUNNER|OSW_CONTROL_AI|OSW_CONTROL_AIMING_BEAM

//Deprecated by AMS. Still kept around for AI ships
/datum/overmap_ship_weapon/torpedo_launcher
	name = "Torpedo tubes"
	standard_projectile_type = /obj/item/projectile/guided_munition/torpedo
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
	used_nonphysical_ammo = OSW_AMMO_TORPEDO
	ai_fire_delay = 2 SECONDS
	weapon_facing_flags = OSW_FACING_OMNI|OSW_ALWAYS_FIRES_FORWARD

/datum/overmap_ship_weapon/torpedo_launcher/get_nonphysical_projectile_type()
	if(!linked_overmap.torpedo_type)
		return ..()
	return linked_overmap.torpedo_type

/datum/overmap_ship_weapon/torpedo_launcher/is_target_size_valid(obj/structure/overmap/target)
	if(!target.mass < MASS_SMALL)
		return FALSE
	return TRUE

/datum/overmap_ship_weapon/torpedo_launcher/burst_disruptor
	name = "Burst Disruption Torpedo tubes"
	standard_projectile_type = /obj/item/projectile/guided_munition/torpedo/disruptor
	burst_size = 3
	fire_delay = 4 SECONDS
	range_modifier = 35


/datum/overmap_ship_weapon/aa_guns
	name = "Anti air guns"
	standard_projectile_type = /obj/item/projectile/bullet/aa_round
	burst_size = 4
	fire_delay = 0.6 SECONDS
	range_modifier = 10
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/weapons/pdc_single.ogg')
	select_alert = "<span class='notice'>Activating anti-air guns..</span>"
	failure_alert = "<span class='warning'>DANGER: Anti-air guns are unable to fire due to lack of ammunition.</span>"
	miss_chance = 33
	max_miss_distance = 6
	ai_fire_delay = 1 SECONDS
	used_nonphysical_ammo = OSW_AMMO_LIGHT

/datum/overmap_ship_weapon/aa_guns/heavy
	name = "Point defense batteries"
	standard_projectile_type = /obj/item/projectile/bullet/aa_round/heavy
	burst_size = 2
	fire_delay = 0.25 SECONDS
	range_modifier = 5
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/autocannon.ogg')

//Energy Weapons

/datum/overmap_ship_weapon/burst_phaser // Little red laser
	name = "Burst Phasers"
	standard_projectile_type = /obj/item/projectile/beam/laser/phaser
	burst_size = 1
	fire_delay = 0.5 SECONDS
	range_modifier = 10
	overmap_select_sound = 'nsv13/sound/effects/ship/phaser_adjust.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/burst_phaser.ogg', 'nsv13/sound/effects/ship/burst_phaser2.ogg')
	select_alert = "<span class='notice'>Activating frontal phasers..</span>"
	failure_alert = "<span class='warning'>DANGER: Point defense emplacements are unable to fire due to lack of ammunition.</span>"
	miss_chance = 33
	max_miss_distance = 6
	ai_fire_delay = 0.5 SECONDS
	used_nonphysical_ammo = OSW_AMMO_LIGHT
	weapon_control_flags = OSW_CONTROL_PILOT|OSW_CONTROL_AI
	weapon_facing_flags = OSW_FACING_OMNI|OSW_ALWAYS_FIRES_FORWARD

/datum/overmap_ship_weapon/phaser // Big blue laser
	name = "Phaser Banks"
	standard_projectile_type = /obj/item/projectile/beam/laser/heavylaser/phaser
	burst_size = 1
	fire_delay = 1.5 SECONDS
	range_modifier = 60
	select_alert = "<span class='notice'>Phaser banks standing by...</span>"
	failure_alert = "<span class='warning'>Unable to comply. Phaser banks recharging.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/phaser.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/phaser_select.ogg' //Sound effect provided by: "All Sounds" https://www.youtube.com/watch?v=EpaCJ75T3fo under creative commons. Trimmed by Kmc2000
	screen_shake = 1
	ai_fire_delay = 3 SECONDS
	weapon_control_flags = OSW_CONTROL_GUNNER|OSW_CONTROL_AI|OSW_CONTROL_AIMING_BEAM

/datum/overmap_ship_weapon/phaser/is_target_size_valid(obj/structure/overmap/target)
	if(target.mass <= MASS_TINY) //Alright fighter mains. I'm not THAT much of a bastard. Generally AIs will prefer to not use their MAC for flyswatting.
		return FALSE
	return TRUE

/datum/overmap_ship_weapon/phaser_pd // Gauss laser
	name = "Point-Defense Phasers"
	standard_projectile_type = /obj/item/projectile/beam/laser/phaser/pd
	burst_size = 4
	burst_fire_delay = 0.25 SECONDS
	fire_delay = 1.5 SECONDS
	range_modifier = 20
	select_alert = "<span class='notice'>Light phaser banks standing by...</span>"
	failure_alert = "<span class='warning'>Unable to comply. Capacitor banks recharging.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/burst_phaser.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/phaser_select.ogg'
	miss_chance = 20
	ai_fire_delay = 3 SECONDS
	//allowed_roles = OVERMAP_USER_ROLE_SECONDARY_GUNNER //OSW WIP: ???? Adjust this. Probably manual here for now? Have to hook later.
	weapon_control_flags = OSW_CONTROL_MANUAL|OSW_CONTROL_AI
	used_nonphysical_ammo = OSW_AMMO_LIGHT

/datum/overmap_ship_weapon/bsa
	name = "Bluespace Artillery"
	standard_projectile_type = /obj/item/projectile/beam/laser/heavylaser/bsa
	burst_size = 1
	fire_delay = 20 SECONDS
	range_modifier = 255
	select_alert = "<span class='notice'>Bluespace artillery ready.</span>"
	failure_alert = "<span class='warning'>Unable to comply. Bluespace artillery recharging...</span>"
	overmap_firing_sounds = list('nsv13/sound/weapons/bsa_fire.ogg')
	overmap_select_sound = 'nsv13/sound/weapons/bsa_select.ogg'
	screen_shake = 5
	firing_arc = 45 //Yeah have fun turning the galactica to shoot this thing :)
	weapon_facing_flags = OSW_FACING_FRONT|OSW_ALWAYS_FIRES_FORWARD
	weapon_control_flags = OSW_CONTROL_PILOT|OSW_CONTROL_AI

/datum/overmap_ship_weapon/bsa/is_target_size_valid(obj/structure/overmap/target)
	if(target.mass <= MASS_TINY) //Fighters do not get turned into dust (intentionally at least).
		return FALSE
	return TRUE
//End Energy Weapons

/datum/overmap_ship_weapon/missile_launcher
	name = "Missile Launchers"
	standard_projectile_type = /obj/item/projectile/guided_munition/missile
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
	ai_fire_delay = 1 SECONDS
	weapon_facing_flags = OSW_FACING_FRONT|OSW_ALWAYS_FIRES_FORWARD

/datum/overmap_ship_weapon/missile_launcher/get_nonphysical_projectile_type()
	if(!linked_overmap.missile_type)
		return ..()
	return linked_overmap.missile_type


/datum/overmap_ship_weapon/missile_launcher/is_target_size_valid(obj/structure/overmap/target)
	if(target.mass > MASS_SMALL)
		return FALSE
	return TRUE

/datum/overmap_ship_weapon/light_cannon
	name = "light autocannon"
	standard_projectile_type = /obj/item/projectile/bullet/light_cannon_round
	burst_size = 2
	fire_delay = 0.25 SECONDS
	range_modifier = 10
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/autocannon.ogg')
	select_alert = "<span class='notice'>Cannon selected. DRADIS assisted targeting: online.</span>"
	failure_alert = "<span class='warning'>DANGER: Cannon ammunition reserves are depleted.</span>"
	weapon_facing_flags = OSW_FACING_OMNI|OSW_ALWAYS_FIRES_FORWARD

/datum/overmap_ship_weapon/light_cannon/integrated	//Weapon for ships big enough that autocannon ammo concerns shouldn't matter this much anymore. Changes their class from HEAVY to LIGHT
	name = "integrated light autocannon"
	used_nonphysical_ammo = OSW_AMMO_LIGHT

/datum/overmap_ship_weapon/heavy_cannon
	name = ".30 cal heavy cannon"
	standard_projectile_type = /obj/item/projectile/bullet/heavy_cannon_round
	burst_size = 2
	fire_delay = 0.5 SECONDS
	range_modifier = 10
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/BRRTTTTTT.ogg')
	select_alert = "<span class='notice'>Cannon selected. DRADIS assisted targeting: online..</span>"
	failure_alert = "<span class='warning'>DANGER: Cannon ammunition reserves are depleted.</span>"
	weapon_facing_flags = OSW_FACING_OMNI|OSW_ALWAYS_FIRES_FORWARD

//Fighters

/datum/overmap_ship_weapon/fighter
	requires_physical_guns = FALSE
	///Which weapon datum this uses. Fighters should only ever have two (Primary first, Secondary second)
	var/weapon_slot = 0

/datum/overmap_ship_weapon/fighter/fire_nonphysical(atom/target, mob/living/firer, ai_aim)
	var/hardpoint_response = linked_overmap.hardpoint_fire(target, src, weapon_slot)
	if(hardpoint_response)
		. = async_nonphysical_fire(target, firer, ai_aim, burst_size)

/datum/overmap_ship_weapon/fighter/get_ammo()
	. = linked_overmap.hardpoint_get_ammo(weapon_slot)

/datum/overmap_ship_weapon/fighter/get_max_ammo()
	. = linked_overmap.hardpoint_get_max_ammo(weapon_slot)

//Fighter already handles ammo use (technically unneeded since `fire_nonphysical()`, the calling proc, is already overridden)
/datum/overmap_ship_weapon/fighter/use_nonphysical_ammo(amount)
	return TRUE

/datum/overmap_ship_weapon/fighter/primary
	name = "Primary Equipment Mount"
	standard_projectile_type = /obj/item/projectile/bullet/light_cannon_round //This is overridden anyway
	burst_size = 1
	fire_delay = 0.25 SECONDS
	range_modifier = 10
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/autocannon.ogg')
	select_alert = "<span class='notice'>Primary mount selected.</span>"
	failure_alert = "<span class='warning'>DANGER: Primary mount not responding to fire command.</span>"
	weapon_control_flags = OSW_CONTROL_PILOT|OSW_CONTROL_GUNNER
	weapon_facing_flags = OSW_FACING_OMNI|OSW_ALWAYS_FIRES_FORWARD
	weapon_slot = OSW_FIGHTER_MAIN_WEAPON
	sort_priority = 999 //Cursed code - These MUST always be the first two (and in the right order)

//L-OSW WIP: Block Fighter weapons (/ Fighters) from using sort.

/datum/overmap_ship_weapon/fighter/secondary
	name = "Secondary Equipment Mount"
	standard_projectile_type = /obj/item/projectile/guided_munition/missile //This is overridden anyway
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
	ai_fire_delay = 1 SECONDS
	weapon_control_flags = OSW_CONTROL_PILOT|OSW_CONTROL_GUNNER
	weapon_facing_flags = OSW_FACING_FRONT
	weapon_slot = OSW_FIGHTER_SECONDARY_WEAPON
	sort_priority = 998

//You don't ever actually select this. Crew act as gunners.
/datum/overmap_ship_weapon/gauss
	name = "Gauss guns"
	standard_projectile_type = /obj/item/projectile/bullet/gauss_slug
	burst_size = 2
	fire_delay = 3 SECONDS
	range_modifier = 10
	select_alert = "<span class='notice'>Activating gauss weapon systems...</span>"
	failure_alert = "<span class='warning'>DANGER: Gauss gun systems not loaded.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/gauss.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_hold.ogg'
	miss_chance = 20
	ai_fire_delay = 2 SECONDS
	weapon_control_flags = OSW_CONTROL_MANUAL|OSW_CONTROL_AI
	used_nonphysical_ammo = OSW_AMMO_LIGHT

/datum/overmap_ship_weapon/pdc_mount //! .50 cal flavored PDC bullets, which were previously just PDC flavored .50 cal turrets
	name = "PDC"
	standard_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 3
	fire_delay = 0.25 SECONDS
	range_modifier = 10
	select_alert = "<span class='notice'>Activating point defense system...</span>"
	failure_alert = "<span class='warning'>DANGER: point defense system not loaded.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg','nsv13/sound/effects/ship/pdc2.ogg','nsv13/sound/effects/ship/pdc3.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_hold.ogg'
	miss_chance = 33
	max_miss_distance = 6
	ai_fire_delay = 0.5 SECONDS
	weapon_control_flags = OSW_CONTROL_PILOT|OSW_CONTROL_GUNNER|OSW_CONTROL_AI|OSW_CONTROL_AUTONOMOUS|OSW_CONTROL_AI_FULL_AUTONOMY
	var/sound/lastsound // Special PDC sound handling

/datum/overmap_ship_weapon/pdc_mount/New()
	. = ..()
	lastsound = pick(overmap_firing_sounds)

// only change our firing sound if we haven't been firing for our fire delay + one second
/datum/overmap_ship_weapon/pdc_mount/play_weapon_sound()
	if(world.time > next_firetime + fire_delay + (1 SECONDS))
		lastsound = pick(overmap_firing_sounds)
	linked_overmap.relay(lastsound)

/datum/overmap_ship_weapon/flak
	name = "Flak cannon"
	standard_projectile_type = /obj/item/projectile/bullet/flak
	burst_size = 1
	fire_delay = 0.5 SECONDS
	range_modifier = 1
	overmap_select_sound = 'nsv13/sound/effects/ship/freespace2/computer/escape.wav'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/flak/flakhit1.ogg','nsv13/sound/effects/ship/flak/flakhit2.ogg','nsv13/sound/effects/ship/flak/flakhit3.ogg')
	select_alert = "<span class='notice'>Defensive flak screens: <b>OFFLINE</b>. Activating manual flak control.</span>"
	failure_alert = "<span class='warning'>DANGER: flak guns unable to fire due to lack of ammunition.</span>"
	miss_chance = 33
	max_miss_distance = 8
	ai_fire_delay = 0.5 SECONDS
	weapon_control_flags = OSW_CONTROL_PILOT|OSW_CONTROL_AI|OSW_CONTROL_FULL_AUTONOMY
	///flak aims at one consistent target until it is out of range.
	var/obj/structure/overmap/last_auto_target

/datum/overmap_ship_weapon/flak/New(obj/structure/overmap/link_to, update_role_weapon_lists = TRUE, flak_battery_count,...)
	. = ..()
	burst_size = flak_battery_count //Instead of the old flak battery var determining burst size, this does it better.

/datum/overmap_ship_weapon/flak/Destroy(force, ...)
	last_auto_target = null
	return ..()

//Broadside

/datum/overmap_ship_weapon/broadside
	name = "SNBC"
	burst_size = 5
	fire_delay = 0.5 SECONDS
	range_modifier = 10
	standard_projectile_type = /obj/item/projectile/bullet/broadside
	select_alert = "<span class='notice'>Locking Broadside Cannons...</span>"
	failure_alert = "<span class='warning'>DANGER: No Shells Loaded In Broadside Cannons!</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/broadside.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_load_unjam.ogg'
	miss_chance = 10
	max_miss_distance = 6
	ai_fire_delay = 10 SECONDS
	screen_shake = 10
	used_nonphysical_ammo = OSW_AMMO_HEAVY
	weapon_control_flags = OSW_CONTROL_GUNNER|OSW_CONTROL_AI

/datum/overmap_ship_weapon/vls
	name = "STS Missile System"
	standard_projectile_type = /obj/item/projectile/guided_munition/missile
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
	weapon_control_flags = OSW_CONTROL_AUTONOMOUS|OSW_CONTROL_GUNNER|OSW_CONTROL_AI

/datum/overmap_ship_weapon/laser_ams
	name = "Laser Anti Missile System"
	standard_projectile_type = /obj/item/projectile/beam/laser/point_defense
	burst_size = 1
	fire_delay = 0.35 SECONDS
	range_modifier = 30
	select_alert = "<span class='notice'>Laser target acquisition systems: online.</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure!</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/burst_phaser.ogg', 'nsv13/sound/effects/ship/burst_phaser2.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'
	permitted_ams_modes = list( "Anti-missile countermeasures" = 1 )
	weapon_control_flags = OSW_CONTROL_AUTONOMOUS
	used_nonphysical_ammo = OSW_AMMO_LIGHT

/datum/overmap_ship_weapon/plasma_caster
	name = "MPAC"
	burst_size = 1
	fire_delay = 5 SECONDS //Everyone's right, weapon code is jank...
	range = 25000 //It will continue to
	standard_projectile_type = /obj/item/projectile/bullet/plasma_caster
	select_alert = "<span class='notice'>Charging magnetic accelerator...</span>"
	failure_alert = "<span class='warning'>Magnetic Accelerator not ready!</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/plasma_gun_fire.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/phaser_select.ogg'
	ai_fire_delay = 180 SECONDS
	weapon_control_flags = OSW_CONTROL_GUNNER|OSW_CONTROL_AI
	weapon_facing_flags = OSW_FACING_OMNI|OSW_ALWAYS_FIRES_FORWARD

/*
=======================================
============AI ONLY WEAPONS============
=======================================
*/

/datum/overmap_ship_weapon/twinmac
	name = "Twin MAC" //Currently only used by the Fist of Sol
	standard_projectile_type = /obj/item/projectile/bullet/mac_round
	burst_size = 2
	fire_delay = 3 SECONDS
	range_modifier = 65
	overmap_firing_sounds = list('nsv13/sound/effects/ship/battleship_gun2.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_ready.ogg'
	ai_fire_delay = 3 SECONDS

/datum/overmap_ship_weapon/quadgauss
	name = "Quad Gauss"
	standard_projectile_type = /obj/item/projectile/bullet/gauss_slug
	burst_size = 4
	fire_delay = 0.5 SECONDS
	range_modifier = 25
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg','nsv13/sound/effects/ship/pdc2.ogg','nsv13/sound/effects/ship/pdc3.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_hold.ogg'
	miss_chance = 15
	ai_fire_delay = 0.5 SECONDS
	used_nonphysical_ammo = OSW_AMMO_LIGHT

/datum/overmap_ship_weapon/hailstorm
	name = "Hailstorm System"
	standard_projectile_type = /obj/item/projectile/bullet/hailstorm_bullet
	burst_size = 80
	fire_delay = 20 SECONDS
	range_modifier = 40
	overmap_firing_sounds = list('nsv13/sound/weapons/bsa_fire.ogg')
	overmap_select_sound = 'nsv13/sound/weapons/bsa_select.ogg'
	ai_fire_delay = 20 SECONDS
	used_nonphysical_ammo = OSW_AMMO_LIGHT

/datum/overmap_ship_weapon/prototype_bsa
	name = "Prototype Bluespace Artillery"
	standard_projectile_type = /obj/item/projectile/bullet/prototype_bsa
	burst_size = 1
	fire_delay = 22 SECONDS
	range_modifier = 200
	overmap_firing_sounds = list('nsv13/sound/weapons/bsa_fire.ogg')
	overmap_select_sound = 'nsv13/sound/weapons/bsa_select.ogg'
	ai_fire_delay = 32 SECONDS


