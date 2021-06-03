//FULL CREDIT FOR THE DROPSHIP INTERIORS GOES TO CM.

/turf/closed/wall/indestructible/dropship
	name = "dropship"
	desc = "A piece of a mighty spaceship."
	icon = 'nsv13/icons/turf/dropship.dmi'
	icon_state = "brown_fr"

/turf/open/indestructible/dropship
	name = "dropship floor"
	desc = "A piece of a mighty spaceship."
	icon = 'nsv13/icons/turf/dropship_floor.dmi'
	icon_state = "rasputin1"

/obj/effect/landmark/dropship_entry
	name = "dropship entry point"
	var/linked = FALSE

/turf/closed/wall/indestructible/dropship/entry
	name = "Hangar Bay Doors"
	desc = "Heavyset doors that lock mid-flight."
	icon_state = "79"

/turf/closed/wall/indestructible/dropship/entry/Bumped(atom/movable/AM)
	. = ..()
	var/obj/structure/overmap/fighter/dropship/OM = get_overmap()
	if(OM && istype(OM) && !(SSmapping.level_trait(OM.z, ZTRAIT_OVERMAP)))
		OM.exit(AM)

/obj/structure/chair/comfy/dropship
	name = "acceleration chair"
	desc = "A seat which clamps down onto its occupant to keep them safe during flight."
	icon = 'nsv13/icons/obj/chairs.dmi'
	icon_state = "shuttle_chair"

/obj/structure/chair/comfy/dropship/Initialize()
	. = ..()
	update_armrest()

/obj/structure/chair/comfy/dropship/GetArmrest()
	return mutable_appearance('nsv13/icons/obj/chairs.dmi', "[initial(icon_state)]_[has_buckled_mobs() ? "closed" : "open"]")

/obj/structure/chair/comfy/dropship/update_armrest()
	cut_overlay(armrest)
	QDEL_NULL(armrest)
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER
	add_overlay(armrest)

/area/dropship
	name = "NSV Sephora"
	icon_state = "shuttle"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	has_gravity = STANDARD_GRAVITY
	always_unpowered = FALSE
	valid_territory = FALSE
	//unique = FALSE
	lighting_colour_tube = "#e6af68"
	lighting_colour_bulb = "#e6af68"
	teleport_restriction = TELEPORT_ALLOW_NONE
	//ambient_buzz = 'nsv13/sound/effects/fighters/cockpit.ogg'

//If we ever want to let them build these things..
/area/dropship/generic
	name = "dropship"
	unique = FALSE //So this var lets you instance new areas...wish I'd known about this 4 years ago haha

/area/dropship/generic/syndicate
	name = "dropship"
	unique = FALSE //So this var lets you instance new areas...wish I'd known about this 4 years ago haha
	lighting_colour_tube = "#d34330"
	lighting_colour_bulb = "#d34330"
/obj/item/fighter_component/fuel_tank/tier2/dropship
	name = "Dropship Fuel Tank"
	desc = "A fuel tank large enough for troop transports."
	icon_state = "fueltank_tier2"
	fuel_capacity = 3000
	tier = 2
	weight = 2

/area
	var/obj/structure/overmap/overmap_fallback = null //Used for dropships. Allows you to define an overmap to "fallback" to if get_overmap() fails to find a space level with a linked overmap.

/obj/structure/overmap/fighter/dropship/enter(mob/user)
	if(!interior_entry_points?.len)
		message_admins("[src] has no interior or entry points and [user] tried to board it.")
		return FALSE
	var/turf/T = get_turf(pick(interior_entry_points))
	var/atom/movable/AM
	if(user.pulling)
		AM = user.pulling
		playsound(src, 'nsv13/sound/effects/footstep/ladder2.ogg')
		AM.forceMove(T)
		user.forceMove(T)
		user.start_pulling(AM)
		if(ismob(AM))
			mobs_in_ship += AM
	else
		playsound(src, 'nsv13/sound/effects/footstep/ladder2.ogg')
		user.forceMove(T)
	mobs_in_ship += user

/obj/structure/overmap/fighter/dropship/proc/exit(mob/user)
	var/turf/T = get_turf(src)
	var/atom/movable/AM
	if(user.pulling)
		AM = user.pulling
		playsound(src, 'nsv13/sound/effects/footstep/ladder2.ogg')
		AM.forceMove(T)
		user.forceMove(T)
		user.start_pulling(AM)
		if(ismob(AM))
			mobs_in_ship -= AM
	else
		playsound(src, 'nsv13/sound/effects/footstep/ladder2.ogg')
		user.forceMove(T)
	mobs_in_ship -= user

/obj/structure/overmap/fighter/dropship/attack_hand(mob/user)
	if(allowed(user))
		if(do_after(user, 2 SECONDS, target=src))
			enter(user)
			to_chat(user, "<span class='notice'>You climb into [src]'s passenger compartment.</span>")
			return TRUE

/obj/structure/overmap/fighter/dropship/MouseDrop_T(atom/movable/target, mob/user)
	if(!isliving(user))
		return FALSE
	for(var/slot in loadout.equippable_slots)
		var/obj/item/fighter_component/FC = loadout.get_slot(slot)
		if(FC?.load(src, target))
			return FALSE
	if(allowed(user))
		if(ismecha(user.loc))
			enter(user.loc)
			return
		else
			to_chat(target, "[(user == target) ? "You start to climb into [src]'s passenger compartment" : "[user] starts to lift you into [src]'s passenger compartment"]")
		if(do_after(user, 2 SECONDS, target=src))
			enter(user)
	else
		to_chat(user, "<span class='warning'>Access denied.</span>")

/**
	Override, as we're using the turf reservation system instead of the maploader (this was done for lag reasons, turf reservation REALLY lags with big maps!)
*/

/atom/get_overmap() //Here I go again on my own, walkin' down the only road I've ever known
	RETURN_TYPE(/obj/structure/overmap)
	if(..())
		return ..()
	var/area/AR = get_area(src)
	return AR?.overmap_fallback

//Bit jank but w/e

/obj/structure/overmap/fighter/dropship/force_parallax_update(ftl_start)
	for(var/area/AR in linked_areas)
		AR.parallax_movedir = (ftl_start ? EAST : null)
	for(var/mob/M in mobs_in_ship)
		if(M && M.client && M.hud_used && length(M.client.parallax_layers))
			M.hud_used.update_parallax(force=TRUE)

//Jank ass override, because this is actually necessary... but eughhhh

/obj/structure/overmap/fighter/dropship/stop_piloting(mob/living/M, force=FALSE)
	LAZYREMOVE(operators,M)
	M.overmap_ship = null
	if(M.click_intercept == src)
		M.click_intercept = null
	if(pilot && M == pilot)
		LAZYREMOVE(M.mousemove_intercept_objects, src)
		pilot = null
		if(helm)
			playsound(helm, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
	if(gunner && M == gunner)
		if(tactical)
			playsound(tactical, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
		gunner = null
		target_lock = null
	if(LAZYFIND(gauss_gunners, M))
		var/datum/component/overmap_gunning/C = M.GetComponent(/datum/component/overmap_gunning)
		C.end_gunning()
	if(M.client)
		M.client.view_size.resetToDefault()
		M.client.overmap_zoomout = 0
	var/mob/camera/ai_eye/remote/overmap_observer/eyeobj = M.remote_control
	M.cancel_camera()
	if(M.client) //Reset px, y
		M.client.pixel_x = 0
		M.client.pixel_y = 0

	if(istype(M, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/hal = M
		hal.view_core()
		hal.remote_control = null
		qdel(eyeobj)
		qdel(eyeobj?.off_action)
		qdel(M.remote_control)
		return

	qdel(eyeobj)
	qdel(eyeobj?.off_action)
	qdel(M.remote_control)
	M.remote_control = null
	M.set_focus(M)
	M.cancel_camera()
	M.remove_verb(fighter_verbs)
	return TRUE

/obj/machinery/computer/ship/helm/console/dropship
	name = "Dropship Flight Station"
	desc = "A modified console that allows you to interface with a fighter's systems remotely."
	circuit = /obj/item/circuitboard/computer/ship/helm/dropship

/obj/item/circuitboard/computer/ship/helm/dropship
	name = "circuit board (dropship helm computer)"
	build_path = /obj/machinery/computer/ship/helm/console/dropship

/obj/machinery/computer/ship/helm/console/dropship/attack_hand(mob/living/user)
	. = ..()
	var/obj/structure/overmap/OM = get_overmap()
	OM?.start_piloting(user, position)
	ui_interact(user)

/obj/machinery/computer/ship/helm/console/dropship/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FighterControls")
		ui.open()

/obj/machinery/computer/ship/helm/console/dropship/ui_data(mob/user)
	var/obj/structure/overmap/OM = get_overmap()
	var/list/data = OM.ui_data(user)
	return data

/obj/machinery/computer/ship/helm/console/dropship/ui_act(action, params, datum/tgui/ui)
	var/obj/structure/overmap/fighter/dropship/OM = get_overmap()
	if(..() || !OM)
		return
	var/atom/movable/target = locate(params["id"])
	switch(action)
		if("examine")
			if(!target)
				return
			to_chat(usr, "<span class='notice'>[target.desc]</span>")
		if("eject_hardpoint")
			if(!target)
				return
			var/obj/item/fighter_component/FC = target
			if(!istype(FC))
				return
			to_chat(usr, "<span class='notice'>You start uninstalling [target.name] from [src].</span>")
			if(!do_after(usr, 5 SECONDS, target=src))
				return
			to_chat(usr, "<span class='notice>You uninstall [target.name] from [src].</span>")
			OM.loadout.remove_hardpoint(FC, FALSE)
		if("dump_hardpoint")
			if(!target)
				return
			var/obj/item/fighter_component/FC = target
			if(!istype(FC) || !FC.contents?.len)
				return
			to_chat(usr, "<span class='notice'>You start to unload [target.name]'s stored contents...</span>")
			if(!do_after(usr, 5 SECONDS, target=src))
				return
			to_chat(usr, "<span class='notice>You dump [target.name]'s contents.</span>")
			OM.loadout.dump_contents(FC)
		if("fuel_pump")
			var/obj/item/fighter_component/apu/APU = OM.loadout.get_slot(HARDPOINT_SLOT_APU)
			if(!APU)
				to_chat(usr, "<span class='warning'>You can't send fuel to an APU that isn't installed.</span>")
				return
			var/obj/item/fighter_component/engine/engine = OM.loadout.get_slot(HARDPOINT_SLOT_ENGINE)
			if(!engine)
				to_chat(usr, "<span class='warning'>You can't send fuel to an APU that isn't installed.</span>")
			APU.toggle_fuel_line()
			OM.relay('nsv13/sound/effects/fighters/warmup.ogg')
		if("battery")
			var/obj/item/fighter_component/battery/battery = OM.loadout.get_slot(HARDPOINT_SLOT_BATTERY)
			if(!battery)
				to_chat(usr, "<span class='warning'>[src] does not have a battery installed!</span>")
				return
			battery.toggle()
			to_chat(usr, "You flip the battery switch.</span>")
		if("apu")
			var/obj/item/fighter_component/apu/APU = OM.loadout.get_slot(HARDPOINT_SLOT_APU)
			if(!APU)
				to_chat(usr, "<span class='warning'>[src] does not have an APU installed!</span>")
				return
			APU.toggle()
			OM.relay('nsv13/sound/effects/fighters/warmup.ogg')
		if("ignition")
			var/obj/item/fighter_component/engine/engine = OM.loadout.get_slot(HARDPOINT_SLOT_ENGINE)
			if(!engine)
				to_chat(usr, "<span class='warning'>[src] does not have an engine installed!</span>")
				return
			engine.try_start()
		if("docking_mode")
			var/obj/item/fighter_component/docking_computer/DC = OM.loadout.get_slot(HARDPOINT_SLOT_DOCKING)
			if(!DC || !istype(DC))
				to_chat(usr, "<span class='warning'>[src] does not have a docking computer installed!</span>")
				return
			to_chat(usr, "<span class='notice'>You [DC.docking_mode ? "disengage" : "engage"] [src]'s docking computer.</span>")
			DC.docking_mode = !DC.docking_mode
			OM.relay('nsv13/sound/effects/fighters/switch.ogg')
			return
		if("brakes")
			OM.toggle_brakes()
			OM.relay('nsv13/sound/effects/fighters/switch.ogg')
			return
		if("inertial_dampeners")
			OM.toggle_inertia()
			OM.relay('nsv13/sound/effects/fighters/switch.ogg')
			return
		if("weapon_safety")
			OM.toggle_safety()
			OM.relay('nsv13/sound/effects/fighters/switch.ogg')
			return
		if("target_lock")
			OM.relay('nsv13/sound/effects/fighters/switch.ogg')
			return
		if("mag_release")
			if(!OM.mag_lock)
				return
			OM.mag_lock.abort_launch()
		if("master_caution")
			OM.set_master_caution(FALSE)
			return
		if("show_dradis")
			OM.dradis.ui_interact(usr)
			return
		if("toggle_ftl")
			var/obj/item/fighter_component/ftl/ftl = OM.loadout.get_slot(HARDPOINT_SLOT_FTL)
			if(!ftl)
				return
			ftl.active = !ftl.active
			OM.relay('nsv13/sound/effects/fighters/switch.ogg')


	OM.relay('nsv13/sound/effects/fighters/switch.ogg')
