//Stuff related to autonomy / ams targetting

/**
 * What this weapon does if it is told to fire in autonomous mode.
 */
/datum/overmap_ship_weapon/proc/autonomous_fire(atom/target, datum/ams_mode/amm)
	var/obj/structure/overmap/OM = linked_overmap
	if(!linked_overmap)
		return //What?
	OM.Beam(target,icon_state="sat_beam",time=OM.ams_targeting_cooldown,maxdistance=amm.max_range)
	if(world.time < OM.next_ams_shot)
		return FALSE
	if(QDELETED(target))
		return FALSE
	. = fire_proc_chain(target)
	OM.ams_shots_fired += .
	OM.next_ams_shot = world.time + OM.ams_targeting_cooldown

/**
 * Used by ship weapons with `FULL_AUTONOMY` as opposed to AMS controlled ones.
 */
/datum/overmap_ship_weapon/proc/autonomous_handling()
	return

//Flak fires at nearby ships automatically.
/datum/overmap_ship_weapon/flak/autonomous_handling()
	if(last_auto_target)
		if(!QDELETED(last_auto_target) && last_auto_target.faction != linked_overmap.faction && last_auto_target.z == linked_overmap.z && overmap_dist(linked_overmap, last_auto_target) <= max_ai_range)
			fire_proc_chain(last_auto_target)
		else
			last_auto_target = null
	for(var/obj/structure/overmap/ship in linked_overmap.current_system.system_contents)
		if(!ship || !istype(ship))
			continue
		if(linked_overmap.ai_controlled && ship == linked_overmap.last_target)
			continue //Avoid blasting our own shots.
		if(ship == linked_overmap || ship == linked_overmap.last_target || ship.faction == linked_overmap.faction || ship.z != linked_overmap.z) //No friendly fire, don't blow up wrecks that the crew may wish to loot. For AIs, do not target our active target, and risk blowing up our precious torpedoes / missiles.
			continue
		if(linked_overmap.warcrime_blacklist[ship.type]) // Please don't blow up my rocks
			continue
		if(ship.essential)
			continue
		var/target_range = get_dist(ship,linked_overmap)
		if(target_range > max_ai_range)
			continue
		if(QDELETED(ship) || !isovermap(ship) || ship.is_sensor_visible(linked_overmap) < SENSOR_VISIBILITY_TARGETABLE)
			continue
		if(!can_fire(ship)) //Shouldn't be too many checks since the basic canfire checks are already ran before going in here.
			continue
		last_auto_target = ship
		fire_proc_chain(ship)

//AI has autonomous missile defense.
/datum/overmap_ship_weapon/pdc_mount/autonomous_handling()
	if(linked_overmap.disruption)
		return FALSE
	// Target our incoming missiles
	for(var/obj/item/projectile/guided_munition/incoming_missile in linked_overmap.torpedoes_to_target)
		if(QDELETED(incoming_missile))
			continue
		if(incoming_missile.z != linked_overmap.z)
			continue
		var/target_range = overmap_dist(incoming_missile, linked_overmap)
		// Don't engage until it's close
		if(target_range > 15)
			continue
		fire_proc_chain(incoming_missile, ai_aim = TRUE)
		break



///===Section: AMS modes===

/datum/ams_mode
	var/name = "Example"
	var/desc = "Nothing"
	var/enabled = FALSE
	var/max_range = 255
	var/max_targets = 10 //To save resources.

///Returns a list of overmaps from previously painted targets that are valid, at most `max_targets`.
/datum/ams_mode/proc/acquire_targets(obj/structure/overmap/OM)
	var/list/targets = list()
	for(var/obj/structure/overmap/ship in OM.target_painted)
		if(length(targets) >= max_targets)
			break
		if(!ship || !istype(ship))
			continue
		if(ship == OM || ship.faction == OM.faction || ship.z != OM.z)
			continue
		if(ship.essential)
			continue
		var/target_range = get_dist(ship,OM)
		if(target_range > max_range)
			continue
		targets += ship
	return targets

/**
 * Is this mode currently ready to be used? Used by e.g. missile tubes to not overkill.
 */
/datum/ams_mode/proc/able_to_operate(obj/structure/overmap/linked_overmap)
	return TRUE

//Subtypes.

/datum/ams_mode/sts
	name = "Anti-ship"
	desc = "Allows the AMS to automatically acquire and fire at any and all painted targets. Imprecise, but effective."
	max_range = 85
	enabled = TRUE //By default, so that AIs can use it.

/datum/ams_mode/sts/acquire_targets(obj/structure/overmap/OM)
	if(OM.ams_data_source == AMS_LOCKED_TARGETS)
		if(OM.target_lock)
			return list(OM.target_lock)
		return list()
	return ..()

/datum/ams_mode/sts/able_to_operate(obj/structure/overmap/linked_overmap)
	if(linked_overmap.ams_shot_limit <= linked_overmap.ams_shots_fired)
		return FALSE
	return TRUE

/datum/ams_mode/countermeasures
	name = "Anti-missile countermeasures"
	desc = "This mode will target oncoming missiles and attempt to counter them with the ship's own missile complement. Recommended for usage exclusively with ECM missiles."
	max_range = 10

//Only aims at locked targets because the previous code was horrendously processing intensive. Anything dangerous will have you locked anyways.
/datum/ams_mode/countermeasures/acquire_targets(obj/structure/overmap/OM)
	return OM.torpedoes_to_target.Copy(1, min(length(OM.torpedoes_to_target), max_targets))

//===Section: AMS computer===

/obj/machinery/computer/ams
	name = "AMS control console"
	icon_screen = "ams"
	circuit = /obj/item/circuitboard/computer/ams

/obj/machinery/computer/ams/Destroy()
	if(circuit && !ispath(circuit))
		circuit.forceMove(loc)
		circuit = null
	. = ..()

/obj/machinery/computer/ams/ui_act(action, params)
	if(..())
		return
	var/obj/structure/overmap/linked = get_overmap()
	if(action == "data_source")
		if(!linked)
			return
		if(linked.ams_data_source == AMS_LOCKED_TARGETS)
			linked.ams_data_source = AMS_PAINTED_TARGETS
			return
		linked.ams_data_source = AMS_LOCKED_TARGETS
		return
	if(action == "set_shot_limit")
		linked.ams_shot_limit = sanitize_integer(params["shot_limit"], 1, 100, 5)
		return
	if(action == "select")
		var/datum/ams_mode/target = locate(params["target"])
		if(!target)
			return FALSE
		linked.ams_shots_fired = 0
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
	data["data_source"] = OM.ams_data_source
	data["shot_limit"] = OM.ams_shot_limit
	return data

/obj/machinery/computer/ams/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AMS")
		ui.open()
		ui.set_autoupdate(TRUE) // Ammo updates, loading delay


//===Section: Ship procs===

/**
 * Handles the AMS system
 */
/obj/structure/overmap/proc/handle_autonomous_targeting()
	if(!current_system) //Not worth the hassle.
		return
	if(!length(autonomous_weapon_datums))
		return //Short circuit to avoiunneeded processing.

	for(var/datum/overmap_ship_weapon/osw as() in autonomous_weapon_datums)
		if(osw.controller_count > 0)
			continue
		if(!(osw.weapon_control_flags & OSW_CONTROL_FULL_AUTONOMY) && !(ai_controlled && (osw.weapon_control_flags & OSW_CONTROL_AI_FULL_AUTONOMY)))
			continue
		if(!osw.can_fire())
			continue
		osw.autonomous_handling()

	for(var/datum/ams_mode/amm in ams_modes)
		if(!amm.enabled)
			continue
		if(!amm.able_to_operate(src))
			continue
		var/list/amm_targets = amm.acquire_targets(src)
		if(!length(amm_targets))
			continue
		var/atom/amm_target = pick(amm_targets) //One activation always fires on a single target.
		for(var/datum/overmap_ship_weapon/osw as() in autonomous_weapon_datums)
			if(osw.controller_count > 0)
				continue
			if(osw.weapon_control_flags & OSW_CONTROL_FULL_AUTONOMY)
				continue
			if(osw.weapon_control_flags & OSW_CONTROL_AI_FULL_AUTONOMY)
				continue //These weapons are usually only autonomous in AI hands.
			var/list/permitted_ams_modes = osw.permitted_ams_modes
			if(!length(permitted_ams_modes) || !permitted_ams_modes[amm.name])
				continue
			if(!osw.can_fire(amm_target))
				continue
			// Fire the highest-priority working weapon, usable weapons will vary depending on current state.
			if(!osw.autonomous_fire(amm_target, amm))
				continue
			break

// Handles passing incoming missile launches to torpedo targeting and alerting the crew to a launch.
// Paramaters: The launching ship, and the incoming projectile
/obj/structure/overmap/proc/on_missile_lock(obj/structure/overmap/firer, obj/item/projectile/proj)
	add_enemy(firer)
	torpedoes_to_target += proj
	RegisterSignal(proj, COMSIG_PARENT_QDELETING, PROC_REF(remove_torpedo_target))
	if(dradis)
		dradis.relay_sound('nsv13/sound/effects/fighters/launchwarning.ogg')
		if(COOLDOWN_FINISHED(dradis, last_missile_warning))
			var/incoming_angle = round(overmap_angle(src, proj))
			dradis.visible_message("<span class='warning'>[icon2html(src, viewers(src))] WARNING: STS radar lock detected. Bearing: [incoming_angle].</span>")
			COOLDOWN_START(dradis, last_missile_warning, 10 SECONDS)

/obj/structure/overmap/proc/remove_torpedo_target(obj/item/projectile/proj)
	SIGNAL_HANDLER
	torpedoes_to_target -= proj
	UnregisterSignal(proj, COMSIG_PARENT_QDELETING)
