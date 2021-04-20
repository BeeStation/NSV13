/obj/item/ship_weapon/ammunition/missile/cruise
	name = "MS-1 'Sparrowhawk' standard cruise missile"
	desc = "Lethally precise, terrifyingly destructive. Can only be fired from the VLS."
	icon = 'nsv13/icons/obj/munitions/missile.dmi'
	icon_state = "standard"
	bound_width = 128
	anchored = TRUE
	density = TRUE

/datum/ship_weapon/vls
	name = "STS Missile System"
	default_projectile_type = /obj/item/projectile/guided_munition/missile
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
	selectable = TRUE

/datum/ship_weapon/vls/valid_target(obj/structure/overmap/source, obj/structure/overmap/target)
	if(!istype(source) || !istype(target))
		return FALSE
	if(!source.missiles)
		return FALSE
	return TRUE

/obj/machinery/ship_weapon/vls
	name = "M14 VLS Loader"
	desc = "A highly advanced launch platform for missiles inspired by recently discovered old-earth technology. The VLS allows for launching cruise missiles from any angle, and directly interfaces with the AMS for lethal precision."
	icon = 'nsv13/icons/obj/munitions/vls.dmi'
	icon_state = "loader"
	firing_sound = 'nsv13/sound/effects/ship/plasma.ogg'
	load_sound = 'nsv13/sound/effects/ship/freespace2/m_load.wav'
	fire_mode = FIRE_MODE_AMS
	ammo_type = list(/obj/item/ship_weapon/ammunition/missile, /obj/item/ship_weapon/ammunition/torpedo)
	CanAtmosPass = FALSE
	CanAtmosPassVertical = FALSE
	semi_auto = TRUE
	max_ammo = 2
	density = FALSE
	circuit = /obj/item/circuitboard/machine/vls
	var/obj/structure/fluff/vls_hatch/hatch = null

/obj/machinery/ship_weapon/vls/Crossed(atom/movable/AM, oldloc)
	. = ..()
	var/can_shoot_this = FALSE
	for(var/_ammo_type in ammo_type)
		if(istype(AM, _ammo_type))
			can_shoot_this = TRUE
			break

	if(can_shoot_this)
		if(ammo?.len >= max_ammo)
			return FALSE
		if(loading)
			return FALSE
		if(state >= 2)
			return FALSE
		ammo += AM
		AM.forceMove(src)
		if(load_sound)
			playsound(src, load_sound, 100, 1)
		state = 2

/obj/machinery/ship_weapon/vls/PostInitialize()
	..()
	if(maintainable)
		maint_req = rand(80, 120) //They don't break down often, but keep an eye on them.

/obj/machinery/ship_weapon/vls/animate_projectile(atom/target, lateral=TRUE)
	// We have different sprites and behaviors for each torpedo
	var/obj/item/ship_weapon/ammunition/torpedo/T = chambered
	if(T)
		var/obj/item/projectile/P = linked.fire_projectile(T.projectile_type, target, homing = TRUE, lateral = weapon_type.lateral)
		if(T.contents.len)
			for(var/atom/movable/AM in T.contents)
				to_chat(AM, "<span class='warning'>You feel slightly nauseous as you're shot out into space...</span>")
				AM.forceMove(P)

/obj/machinery/ship_weapon/vls/Initialize()
	. = ..()
	var/turf/T = SSmapping.get_turf_above(src)
	if(!T)
		return
	hatch = locate(/obj/structure/fluff/vls_hatch) in T
	var/matrix/ntransform = new()
	if(dir & NORTH)
		ntransform.Turn(90)
		ntransform.Translate(-16,-16)
		hatch.transform = ntransform
		return
	if(dir & SOUTH)
		ntransform.Turn(-90)
		ntransform.Translate(-16,16)
		hatch.transform = ntransform
		return
	if(dir & EAST)
		return
	if(dir & WEST)
		ntransform.Turn(-180)
		ntransform.Translate(-32,1)
		hatch.transform = ntransform
		return
#define HT_OPEN TRUE
#define HT_CLOSED FALSE

/obj/machinery/ship_weapon/vls/feed()
	. = ..()
	if(!hatch)
		return
	hatch.toggle(HT_OPEN)

/obj/machinery/ship_weapon/vls/local_fire()
	. = ..()
	if(!hatch)
		return
	hatch.toggle(HT_CLOSED)

/obj/machinery/ship_weapon/vls/unload_magazine()
	. = ..()
	if(!hatch)
		return
	hatch.toggle(HT_CLOSED)


/obj/structure/fluff/vls_hatch
	name = "VLS Launch Hatch"
	desc = "A hatch designed to let cruise missiles out, and keep air in for the deck below."
	icon = 'nsv13/icons/obj/munitions/vls.dmi'
	icon_state = "vls_closed"
	CanAtmosPass = FALSE
	CanAtmosPassVertical = FALSE
	obj_flags = CAN_BE_HIT | BLOCK_Z_FALL
	anchored = TRUE
	obj_integrity = 1000
	max_integrity = 1000

/obj/structure/fluff/vls_hatch/proc/toggle(state)
	if(state == HT_OPEN)
		obj_flags &= ~BLOCK_Z_FALL
		icon_state = "vls"
		density = FALSE
		return
	obj_flags |= BLOCK_Z_FALL
	icon_state = "vls_closed"
	density = TRUE

/obj/structure/overmap
	var/list/target_painted = list()
	var/list/ams_modes = list()

/datum/ams_mode
	var/name = "Example"
	var/desc = "Nothing"
	var/enabled = FALSE
	var/max_range = 255
	var/max_targets = 10 //To save resources.

///What sort of targets are we searching for? @return a list of valid targets
/datum/ams_mode/proc/acquire_targets(obj/structure/overmap/OM)
	var/list/targets = list()
	for(var/obj/structure/overmap/ship in OM.target_painted)
		if(!ship || !istype(ship))
			continue
		if(ship == OM || ship.faction == OM.faction || ship.z != OM.z)
			continue
		var/target_range = get_dist(ship,OM)
		if(target_range > max_range || target_range <= 0) //Random pulled from the aether
			continue
		if(targets.len >= max_targets) //This syntax lol
			break
		targets += ship
	return targets

///Fires at a selected target, you shouldn't need to override this.
/datum/ams_mode/proc/handle_autonomy(obj/structure/overmap/OM, /datum/ship_weapon/AMS)
	if(!OM || !enabled)
		return FALSE
	var/list/potential_targets = acquire_targets(OM)
	if(!potential_targets.len)
		return FALSE
	var/atom/movable/target = pick(potential_targets)
	OM.Beam(target,icon_state="sat_beam",time=OM.ams_targeting_cooldown,maxdistance=max_range)
	if(world.time < OM.next_ams_shot)
		return FALSE
	if(QDELETED(target))
		return FALSE
	OM.fire_weapon(target, mode=FIRE_MODE_AMS, lateral=TRUE)
	OM.next_ams_shot = world.time + OM.ams_targeting_cooldown

//Subtypes.

/datum/ams_mode/sts
	name = "Anti-ship"
	desc = "Allows the AMS to automatically acquire and fire at any and all painted targets. Imprecise, but effective."
	max_range = 85
	enabled = TRUE //By default, so that AIs can use it.

/datum/ams_mode/countermeasures
	name = "Anti-missile countermeasures"
	desc = "This mode will target oncoming missiles and attempt to counter them with the ship's own missile complement. Recommended for usage exclusively with ECM missiles."
	max_range = 10

/obj/machinery/computer/ams
	name = "AMS control console"
	icon_screen = "ams"
	circuit = /obj/item/circuitboard/computer/ams
/obj/structure/overmap
	var/next_ams_shot = 0
	var/ams_targeting_cooldown = 1.5 SECONDS

/obj/machinery/computer/ams/ui_act(action, params)
	. = ..()
	var/datum/ams_mode/target = locate(params["target"])
	if(!target)
		return FALSE
	target.enabled = !target.enabled

/obj/machinery/computer/ams/ui_data(mob/user)
	..()
	var/list/data = list()
	. = data
	var/obj/structure/overmap/OM = get_overmap()
	if(!OM)
		return
	var/list/categories = list()
	for(var/datum/ams_mode/AMS in OM.ams_modes)
		var/list/category = list()
		category["name"] = AMS.name
		category["desc"] = AMS.desc
		category["enabled"] = AMS.enabled
		category["id"] = "\ref[AMS]"
		categories[++categories.len] = category
	data["categories"] = categories
	return data

/obj/machinery/computer/ams/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AMS")
		ui.open()

/datum/ams_mode/countermeasures/acquire_targets(obj/structure/overmap/OM)
	var/list/targets = list()
	for(var/obj/item/projectile/guided_munition/P in SSprojectiles.processing)
		if(!P || !istype(P))
			continue
		if(P.faction == OM.faction || P.overmap_firer == OM)
			continue
		var/target_range = get_dist(P,OM)
		//Now, let's work out if the missile is actually "oncoming"
		var/incidence_dir = get_dir(P, OM)
		if(angle2dir(P.Angle)!= incidence_dir)
			//message_admins("[angle2dir(P.Angle)] vs [incidence_dir]")
			continue
		if(target_range > max_range || target_range <= 0) //Random pulled from the aether
			continue
		if(targets.len >= max_targets)
			break
		targets += P
	return targets


/obj/structure/overmap/proc/handle_flak()
	if(fire_mode == FIRE_MODE_FLAK) //If theyre aiming the flak manually.
		return
	if(!weapon_types[FIRE_MODE_FLAK] || flak_battery_amount <= 0)
		return FALSE
	var/datum/ship_weapon/SW = weapon_types[FIRE_MODE_FLAK]
	var/flak_left = flak_battery_amount //Multi-flak batteries!
	if(!ai_controlled)
		if(!last_target || !istype(last_target, /obj/structure/overmap) || QDELETED(last_target) || !isovermap(last_target) || last_target == src || get_dist(last_target,src) >= SW.range_modifier) //Stop hitting yourself enterprise
			last_target = null
		else
			fire_weapon(last_target, mode=FIRE_MODE_FLAK, lateral=TRUE)
			flak_left --
			if(flak_left <= 0)
				return
	for(var/obj/structure/overmap/ship in GLOB.overmap_objects)
		if(!ship || !istype(ship))
			continue
		if(ship == src || ship == last_target || ship.faction == faction || wrecked || ship.wrecked || ship.z != z) //No friendly fire, don't blow up wrecks that the crew may wish to loot. For AIs, do not target our active target, and risk blowing up our precious torpedoes / missiles.
			continue
		var/target_range = get_dist(ship,src)
		if(target_range > 30 || target_range <= 0) //Random pulled from the aether
			continue
		if(!QDELETED(ship) && isovermap(ship) && ship.is_sensor_visible(src) >= SENSOR_VISIBILITY_TARGETABLE)
			last_target = ship
			fire_weapon(ship, mode=FIRE_MODE_FLAK, lateral=TRUE)
			flak_left --
			if(flak_left <= 0)
				break

/**
 * Handles the AMS system
 */
/obj/structure/overmap/proc/handle_autonomous_targeting()
	if(flak_battery_amount >= 1)
		handle_flak()
	if(!weapon_types[FIRE_MODE_AMS])
		return FALSE
	var/datum/ship_weapon/AMS = weapon_types[FIRE_MODE_AMS]
	for(var/datum/ams_mode/AMM in ams_modes)
		if(AMM.enabled)
			AMM.handle_autonomy(src, AMS)

	//Not currently used, but may as well keep it for reference...
	if(flak_battery_amount > 0)
		var/datum/ship_weapon/SW = weapon_types[FIRE_MODE_FLAK]
		var/flak_left = flak_battery_amount //Multi-flak batteries!
		if(!ai_controlled)
			if(!last_target || !istype(last_target, /obj/structure/overmap) || QDELETED(last_target) || !isovermap(last_target) || last_target == src || get_dist(last_target,src) >= SW.range_modifier) //Stop hitting yourself enterprise
				last_target = null
			else
				fire_weapon(last_target, mode=FIRE_MODE_FLAK, lateral=TRUE)
				flak_left --
				if(flak_left <= 0)
					return
		for(var/obj/structure/overmap/ship in GLOB.overmap_objects)
			if(!ship || !istype(ship))
				continue
			if(ship == src || ship == last_target || ship.faction == faction || wrecked || ship.wrecked || ship.z != z) //No friendly fire, don't blow up wrecks that the crew may wish to loot. For AIs, do not target our active target, and risk blowing up our precious torpedoes / missiles.
				continue
			var/target_range = get_dist(ship,src)
			if(target_range > 30 || target_range <= 0) //Random pulled from the aether
				continue
			if(!QDELETED(ship) && isovermap(ship) && ship.is_sensor_visible(src) >= SENSOR_VISIBILITY_TARGETABLE)
				last_target = ship
				fire_weapon(ship, mode=FIRE_MODE_FLAK, lateral=TRUE)
				flak_left --
				if(flak_left <= 0)
					break
