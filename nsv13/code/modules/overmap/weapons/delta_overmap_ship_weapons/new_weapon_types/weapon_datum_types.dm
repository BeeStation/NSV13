//A new home for weaon datum types that were migrated.

//The big MAC. Fired by the gunner.
/datum/overmap_ship_weapon/mac
	name = "Naval Artillery"
	standard_projectile_type = /obj/item/projectile/bullet/mac_round
	burst_size = 1
	fire_delay = 3.5 SECONDS
	optimal_range = 50
	select_alert = "<span class='notice'>Naval artillery primed.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/battleship_gun2.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_ready.ogg'
	screen_shake = 2
	ai_fire_delay = 2 SECONDS
	weapon_aim_flags = OSW_AIMING_BEAM
	sort_priority = 12

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
	optimal_range = 20
	select_alert = "<span class='notice'>Charging railgun hardpoints...</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/railgun_fire.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_hold.ogg'
	screen_shake = 1
	ai_fire_delay = 5 SECONDS
	firing_arc = 45 //Broad side of a barn...
	weapon_facing_flags = OSW_FACING_FRONT
	weapon_firing_flags = OSW_ALWAYS_FIRES_FORWARD
	weapon_control_flags = OSW_CONTROL_PILOT|OSW_CONTROL_AI
	sort_priority = 8

/datum/overmap_ship_weapon/railgun/is_target_size_valid(obj/structure/overmap/target)
	if(target.mass <= MASS_TINY) //Alright fighter mains. I'm not THAT much of a bastard. Generally AIs will prefer to not use their MAC for flyswatting.
		return FALSE
	return TRUE

/datum/overmap_ship_weapon/hybrid_railgun //Railgun+
	name = "Hybrid Railguns"
	standard_projectile_type = /obj/item/projectile/bullet //This is ultra dodgy
	burst_size = 1
	fire_delay = 1 SECONDS
	optimal_range = 50
	select_alert = "<span class='notice'>Charging hybrid railgun hardpoints...</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/mac_fire.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_charge.ogg'
	weapon_aim_flags = OSW_AIMING_BEAM
	sort_priority = 8

//Deprecated by AMS. Still kept around for AI ships
/datum/overmap_ship_weapon/torpedo_launcher
	name = "Torpedo tubes"
	standard_projectile_type = /obj/item/projectile/guided_munition/torpedo
	burst_size = 1
	fire_delay = 0.5 SECONDS
	select_alert = "<span class='notice'>Torpedo target acquisition systems: online.</span>"
	overmap_firing_sounds = list(
		'nsv13/sound/effects/ship/torpedo.ogg',
		'nsv13/sound/effects/ship/freespace2/m_shrike.wav',
		'nsv13/sound/effects/ship/freespace2/m_stiletto.wav',
		'nsv13/sound/effects/ship/freespace2/m_tsunami.wav',
		'nsv13/sound/effects/ship/freespace2/m_wasp.wav')
	overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'
	used_nonphysical_ammo = OSW_AMMO_TORPEDO
	ai_fire_delay = 2 SECONDS
	weapon_firing_flags = OSW_ALWAYS_FIRES_FORWARD
	has_special_action = TRUE
	sort_priority = 10
	nonphysical_firing_sounds_local = FALSE

/datum/overmap_ship_weapon/torpedo_launcher/special_action(mob/user)
	if(!needs_real_weapons())
		return
	cycle_ammo_filter(user)

/datum/overmap_ship_weapon/torpedo_launcher/get_nonphysical_projectile_type()
	if(!linked_overmap.torpedo_type)
		return ..()
	return linked_overmap.torpedo_type

/datum/overmap_ship_weapon/torpedo_launcher/is_target_size_valid(obj/structure/overmap/target)
	if(target.mass < MASS_SMALL)
		return FALSE
	return TRUE

/datum/overmap_ship_weapon/torpedo_launcher/burst_disruptor
	name = "Burst Disruption Torpedo tubes"
	standard_projectile_type = /obj/item/projectile/guided_munition/torpedo/disruptor
	burst_size = 3
	fire_delay = 4 SECONDS


/datum/overmap_ship_weapon/aa_guns
	name = "Anti air guns"
	standard_projectile_type = /obj/item/projectile/bullet/aa_round
	burst_size = 4
	fire_delay = 0.6 SECONDS
	optimal_range = 15
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/weapons/pdc_single.ogg')
	select_alert = "<span class='notice'>Activating anti-air guns..</span>"
	miss_chance = 33
	max_miss_distance = 6
	ai_fire_delay = 1 SECONDS
	used_nonphysical_ammo = OSW_AMMO_LIGHT

/datum/overmap_ship_weapon/aa_guns/heavy
	name = "Point defense batteries"
	standard_projectile_type = /obj/item/projectile/bullet/aa_round/heavy
	burst_size = 2
	fire_delay = 0.25 SECONDS
	optimal_range = 12
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/autocannon.ogg')

//Energy Weapons

/datum/overmap_ship_weapon/burst_phaser // Little red laser
	name = "Burst Phasers"
	standard_projectile_type = /obj/item/projectile/beam/laser/phaser
	burst_size = 1
	fire_delay = 0.5 SECONDS
	optimal_range = 20
	overmap_select_sound = 'nsv13/sound/effects/ship/phaser_adjust.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/burst_phaser.ogg', 'nsv13/sound/effects/ship/burst_phaser2.ogg')
	select_alert = "<span class='notice'>Activating frontal phasers..</span>"
	miss_chance = 33
	max_miss_distance = 6
	ai_fire_delay = 0.5 SECONDS
	used_nonphysical_ammo = OSW_AMMO_LIGHT
	weapon_control_flags = OSW_CONTROL_PILOT|OSW_CONTROL_AI
	weapon_firing_flags = OSW_ALWAYS_FIRES_FORWARD
	sort_priority = 8

/datum/overmap_ship_weapon/phaser // Big blue laser
	name = "Phaser Banks"
	standard_projectile_type = /obj/item/projectile/beam/laser/heavylaser/phaser
	burst_size = 1
	fire_delay = 1.5 SECONDS
	optimal_range = 60
	select_alert = "<span class='notice'>Phaser banks standing by...</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/phaser.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/phaser_select.ogg' //Sound effect provided by: "All Sounds" https://www.youtube.com/watch?v=EpaCJ75T3fo under creative commons. Trimmed by Kmc2000
	screen_shake = 1
	ai_fire_delay = 3 SECONDS
	weapon_aim_flags = OSW_AIMING_BEAM
	sort_priority = 12

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
	optimal_range = 16
	select_alert = "<span class='notice'>Light phaser banks standing by...</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/burst_phaser.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/phaser_select.ogg'
	miss_chance = 20
	ai_fire_delay = 3 SECONDS
	weapon_control_flags = OSW_CONTROL_MANUAL|OSW_CONTROL_AI
	used_nonphysical_ammo = OSW_AMMO_LIGHT
	sort_priority = 6

/datum/overmap_ship_weapon/bsa
	name = "Bluespace Artillery"
	standard_projectile_type = /obj/item/projectile/beam/laser/heavylaser/bsa
	burst_size = 1
	fire_delay = 20 SECONDS
	select_alert = "<span class='notice'>Bluespace artillery ready.</span>"
	overmap_firing_sounds = list('nsv13/sound/weapons/bsa_fire.ogg')
	overmap_select_sound = 'nsv13/sound/weapons/bsa_select.ogg'
	screen_shake = 5
	firing_arc = 45 //Yeah have fun turning the galactica to shoot this thing :)
	weapon_facing_flags = OSW_FACING_FRONT
	weapon_firing_flags = OSW_ALWAYS_FIRES_FORWARD
	weapon_control_flags = OSW_CONTROL_PILOT|OSW_CONTROL_AI
	used_nonphysical_ammo = OSW_AMMO_FREE
	sort_priority = 100
	nonphysical_firing_sounds_local = FALSE

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
	optimal_range = 30
	select_alert = "<span class='notice'>Missile target acquisition systems: online.</span>"
	overmap_firing_sounds = list(
		'nsv13/sound/effects/ship/torpedo.ogg',
		'nsv13/sound/effects/ship/freespace2/m_shrike.wav',
		'nsv13/sound/effects/ship/freespace2/m_stiletto.wav',
		'nsv13/sound/effects/ship/freespace2/m_tsunami.wav',
		'nsv13/sound/effects/ship/freespace2/m_wasp.wav')
	overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'
	firing_arc = 45 //Broad side of a barn...
	ai_fire_delay = 1 SECONDS
	weapon_facing_flags = OSW_FACING_FRONT
	weapon_firing_flags = OSW_ALWAYS_FIRES_FORWARD
	used_nonphysical_ammo = OSW_AMMO_MISSILE
	has_special_action = TRUE
	sort_priority = 9
	nonphysical_firing_sounds_local = FALSE

/datum/overmap_ship_weapon/missile_launcher/special_action(mob/user)
	if(!needs_real_weapons())
		return
	cycle_ammo_filter(user)

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
	optimal_range = 18
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/autocannon.ogg')
	select_alert = "<span class='notice'>Cannon selected. DRADIS assisted targeting: online.</span>"
	firing_arc = 20
	weapon_facing_flags = OSW_FACING_FRONT
	weapon_firing_flags = OSW_ALWAYS_FIRES_FORWARD
	sort_priority = 4

/datum/overmap_ship_weapon/light_cannon/integrated	//Weapon for ships big enough that autocannon ammo concerns shouldn't matter this much anymore. Changes their class from HEAVY to LIGHT
	name = "integrated light autocannon"
	used_nonphysical_ammo = OSW_AMMO_LIGHT

/datum/overmap_ship_weapon/heavy_cannon
	name = ".30 cal heavy cannon"
	standard_projectile_type = /obj/item/projectile/bullet/heavy_cannon_round
	burst_size = 2
	fire_delay = 0.5 SECONDS
	optimal_range = 18
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/BRRTTTTTT.ogg')
	select_alert = "<span class='notice'>Cannon selected. DRADIS assisted targeting: online..</span>"
	firing_arc = 20
	weapon_facing_flags = OSW_FACING_FRONT
	weapon_firing_flags = OSW_ALWAYS_FIRES_FORWARD
	sort_priority = 6

//Fighters

/datum/overmap_ship_weapon/fighter
	name = "Uh oh, this is a basetype, you shouldn't be seeing this!"
	requires_physical_guns = FALSE
	///Which weapon datum this uses. Fighters should only ever have two (Primary first, Secondary second)
	var/weapon_slot = 0
	nonphysical_firing_sounds_local = FALSE //Brrr

/datum/overmap_ship_weapon/fighter/fire_nonphysical(atom/target, mob/living/firer, ai_aim)
	var/active_burst_size = min(burst_size, get_ammo())
	var/list/hardpoint_response = linked_overmap.hardpoint_fire(target, src, weapon_slot, active_burst_size)
	. = length(hardpoint_response)
	if(.)
		async_nonphysical_fire(target, firer, ai_aim, ., hardpoint_response)

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
	optimal_range = 18
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/autocannon.ogg')
	select_alert = "<span class='notice'>Primary mount selected.</span>"
	weapon_control_flags = OSW_CONTROL_PILOT|OSW_CONTROL_GUNNER
	weapon_firing_flags = OSW_ALWAYS_FIRES_FORWARD
	weapon_slot = OSW_FIGHTER_MAIN_WEAPON
	sort_priority = 999 //Cursed code - These MUST always be the first two (and in the right order)
	can_modify_priority = FALSE

/datum/overmap_ship_weapon/fighter/secondary
	name = "Secondary Equipment Mount"
	standard_projectile_type = /obj/item/projectile/guided_munition/missile //This is overridden anyway
	burst_size = 1
	fire_delay = 0.5 SECONDS
	optimal_range = 30
	select_alert = "<span class='notice'>Secondary mount selected.</span>"
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
	can_modify_priority = FALSE

//You don't ever actually select this. Crew act as gunners.
/datum/overmap_ship_weapon/gauss
	name = "Gauss guns"
	standard_projectile_type = /obj/item/projectile/bullet/gauss_slug
	burst_size = 2
	fire_delay = 3 SECONDS
	optimal_range = 18
	select_alert = "<span class='notice'>Activating gauss weapon systems...</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/gauss.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_hold.ogg'
	miss_chance = 20
	ai_fire_delay = 2 SECONDS
	weapon_control_flags = OSW_CONTROL_MANUAL|OSW_CONTROL_AI
	used_nonphysical_ammo = OSW_AMMO_LIGHT
	sort_priority = 6

/datum/overmap_ship_weapon/pdc_mount //! .50 cal flavored PDC bullets, which were previously just PDC flavored .50 cal turrets
	name = "PDC"
	standard_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 3
	fire_delay = 0.25 SECONDS
	optimal_range = 10
	select_alert = "<span class='notice'>Activating point defense system...</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg','nsv13/sound/effects/ship/pdc2.ogg','nsv13/sound/effects/ship/pdc3.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_hold.ogg'
	miss_chance = 33
	max_miss_distance = 6
	ai_fire_delay = 0.5 SECONDS
	weapon_control_flags = OSW_CONTROL_PILOT|OSW_CONTROL_GUNNER|OSW_CONTROL_AI|OSW_CONTROL_AUTONOMOUS|OSW_CONTROL_AI_FULL_AUTONOMY
	used_nonphysical_ammo = OSW_AMMO_LIGHT
	var/sound/lastsound // Special PDC sound handling
	sort_priority = 4

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
	optimal_range = 8
	overmap_select_sound = 'nsv13/sound/effects/ship/freespace2/computer/escape.wav'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/flak/flakhit1.ogg','nsv13/sound/effects/ship/flak/flakhit2.ogg','nsv13/sound/effects/ship/flak/flakhit3.ogg')
	select_alert = "<span class='notice'>Defensive flak screens: <b>OFFLINE</b>. Activating manual flak control.</span>"
	miss_chance = 33
	max_miss_distance = 8
	ai_fire_delay = 0.5 SECONDS
	weapon_control_flags = OSW_CONTROL_PILOT|OSW_CONTROL_AI|OSW_CONTROL_AUTONOMOUS|OSW_CONTROL_FULL_AUTONOMY
	used_nonphysical_ammo = OSW_AMMO_LIGHT
	///flak aims at one consistent target until it is out of range.
	var/obj/structure/overmap/last_auto_target
	max_ai_range = 30
	sort_priority = 2

/datum/overmap_ship_weapon/flak/New(obj/structure/overmap/link_to, update_role_weapon_lists = TRUE, flak_battery_count, ...)
	. = ..()
	burst_size = flak_battery_count //Instead of the old flak battery var determining burst size, this does it better.

/datum/overmap_ship_weapon/flak/Destroy(force, ...)
	last_auto_target = null
	return ..()

//Broadside

/datum/overmap_ship_weapon/broadside
	name = "SNBC"
	burst_size = 5
	minimum_ammo_per_physical_gun = 5 //Physical version only fires full bursts.
	fire_delay = 0.5 SECONDS
	optimal_range = 12
	standard_projectile_type = /obj/item/projectile/bullet/broadside
	select_alert = "<span class='notice'>Locking Broadside Cannons...</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/broadside.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_load_unjam.ogg'
	miss_chance = 10
	max_miss_distance = 6
	ai_fire_delay = 10 SECONDS
	screen_shake = 10
	used_nonphysical_ammo = OSW_AMMO_HEAVY
	weapon_facing_flags = OSW_FACING_SIDES
	firing_arc = 30 //Twice that of spread, probably update this is you update that.
	weapon_firing_flags = OSW_ALWAYS_FIRES_BROADSIDES
	weapon_aim_flags = OSW_SIDE_AIMING_BEAM
	sort_priority = 12
	nonphysical_fire_single_sound = TRUE //This will blow up ghost ship player ears otherwise.
	nonphysical_fire_single_ammo_use = TRUE //Easier to balance with other AI weapons.

/datum/overmap_ship_weapon/vls
	name = "STS Missile System"
	standard_projectile_type = /obj/item/projectile/guided_munition/missile
	burst_size = 1
	fire_delay = 0.35 SECONDS
	optimal_range = 30
	select_alert = "<span class='notice'>STS missile target acquisition systems: online.</span>" //Tiny message difference for ghost ships with both.
	overmap_firing_sounds = list(
		'nsv13/sound/effects/ship/torpedo.ogg',
		'nsv13/sound/effects/ship/freespace2/m_shrike.wav',
		'nsv13/sound/effects/ship/freespace2/m_stiletto.wav',
		'nsv13/sound/effects/ship/freespace2/m_tsunami.wav',
		'nsv13/sound/effects/ship/freespace2/m_wasp.wav')
	overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'
	weapon_control_flags = OSW_CONTROL_AUTONOMOUS|OSW_CONTROL_GUNNER|OSW_CONTROL_AI
	has_special_action = TRUE
	used_nonphysical_ammo = OSW_AMMO_MISSILE
	sort_priority = 9
	nonphysical_firing_sounds_local = FALSE

/datum/overmap_ship_weapon/vls/get_nonphysical_projectile_type()
	if(!linked_overmap.missile_type)
		return ..()
	return linked_overmap.missile_type

/datum/overmap_ship_weapon/vls/special_action(mob/user)
	if(!needs_real_weapons())
		return
	cycle_ammo_filter(user)

/datum/overmap_ship_weapon/laser_ams
	name = "Laser Anti Missile System"
	standard_projectile_type = /obj/item/projectile/beam/laser/point_defense
	burst_size = 1
	fire_delay = 0.35 SECONDS
	optimal_range = 30
	select_alert = "<span class='notice'>Laser target acquisition systems: online.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/burst_phaser.ogg', 'nsv13/sound/effects/ship/burst_phaser2.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'
	permitted_ams_modes = list( "Anti-missile countermeasures" = 1 )
	weapon_control_flags = OSW_CONTROL_AUTONOMOUS
	used_nonphysical_ammo = OSW_AMMO_LIGHT
	sort_priority = 2

/datum/overmap_ship_weapon/plasma_caster
	name = "MPAC"
	burst_size = 1
	fire_delay = 5 SECONDS //Everyone's right, weapon code is jank...
	max_ai_range = 25000 //It will continue to
	standard_projectile_type = /obj/item/projectile/bullet/plasma_caster
	select_alert = "<span class='notice'>Charging magnetic accelerator...</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/plasma_gun_fire.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/phaser_select.ogg'
	ai_fire_delay = 180 SECONDS
	weapon_control_flags = OSW_CONTROL_GUNNER|OSW_CONTROL_AI
	weapon_firing_flags = OSW_ALWAYS_FIRES_FORWARD
	sort_priority = 12

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
	optimal_range = 65
	overmap_firing_sounds = list('nsv13/sound/effects/ship/battleship_gun2.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_ready.ogg'
	ai_fire_delay = 3 SECONDS
	sort_priority = 12

/datum/overmap_ship_weapon/quadgauss
	name = "Quad Gauss"
	standard_projectile_type = /obj/item/projectile/bullet/gauss_slug
	burst_size = 4
	fire_delay = 0.5 SECONDS
	optimal_range = 25
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg','nsv13/sound/effects/ship/pdc2.ogg','nsv13/sound/effects/ship/pdc3.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_hold.ogg'
	miss_chance = 15
	ai_fire_delay = 0.5 SECONDS
	used_nonphysical_ammo = OSW_AMMO_LIGHT
	sort_priority = 6

/datum/overmap_ship_weapon/hailstorm
	name = "Hailstorm System"
	standard_projectile_type = /obj/item/projectile/bullet/hailstorm_bullet
	burst_size = 80
	fire_delay = 20 SECONDS
	optimal_range = 20
	overmap_firing_sounds = list('nsv13/sound/weapons/bsa_fire.ogg')
	overmap_select_sound = 'nsv13/sound/weapons/bsa_select.ogg'
	ai_fire_delay = 20 SECONDS
	used_nonphysical_ammo = OSW_AMMO_LIGHT
	sort_priority = 4

/datum/overmap_ship_weapon/prototype_bsa
	name = "Prototype Bluespace Artillery"
	standard_projectile_type = /obj/item/projectile/bullet/prototype_bsa
	burst_size = 1
	fire_delay = 22 SECONDS
	overmap_firing_sounds = list('nsv13/sound/weapons/bsa_fire.ogg')
	overmap_select_sound = 'nsv13/sound/weapons/bsa_select.ogg'
	ai_fire_delay = 32 SECONDS
	sort_priority = 100
	used_nonphysical_ammo = OSW_AMMO_FREE
	nonphysical_firing_sounds_local = FALSE


