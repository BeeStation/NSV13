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
	var/obj/structure/overmap/small_craft/transport/OM = get_overmap()
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
	lighting_colour_tube = "#e6af68"
	lighting_colour_bulb = "#e6af68"
	area_flags = 0 // Not a unique area and spawns are not allowed
	teleport_restriction = TELEPORT_ALLOW_NONE

//If we ever want to let them build these things..
/area/dropship/generic
	name = "dropship"

/area/dropship/generic/syndicate
	name = "dropship"
	lighting_colour_tube = "#d34330"
	lighting_colour_bulb = "#d34330"

/obj/item/fighter_component/fuel_tank/tier2/dropship
	name = "Dropship Fuel Tank"
	desc = "A fuel tank large enough for troop transports."
	icon_state = "fueltank_tier2"
	fuel_capacity = 3000
	tier = 2
	weight = 2

/obj/structure/overmap/small_craft/transport/enter(mob/user)
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

/obj/structure/overmap/small_craft/transport/proc/exit(mob/user)
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

/obj/structure/overmap/small_craft/transport/attack_hand(mob/user)
	if(allowed(user))
		if(do_after(user, 2 SECONDS, target=src))
			enter(user)
			to_chat(user, "<span class='notice'>You climb into [src]'s passenger compartment.</span>")
			return TRUE

/obj/structure/overmap/small_craft/transport/MouseDrop_T(atom/movable/target, mob/user)
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

//Bit jank but w/e

/obj/structure/overmap/small_craft/transport/force_parallax_update(ftl_start)
	for(var/area/AR in linked_areas)
		AR.parallax_movedir = (ftl_start ? EAST : null)
	for(var/mob/M in mobs_in_ship)
		if(M && M.client && M.hud_used && length(M.client.parallax_layers))
			M.hud_used.update_parallax(force=TRUE)

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
	to_chat(user, "<span class='notice'>Small craft use directional keys (WASD in hotkey mode) to accelerate/decelerate in a given direction and the mouse to change the direction of craft.\
			Mouse 1 will fire the selected weapon (if applicable).</span>")
	to_chat(user, "<span class='warning'>=Hotkeys=</span>")
	to_chat(user, "<span class='notice'>Use <b>tab</b> to activate hotkey mode, then:</span>")
	to_chat(user, "<span class='notice'>Use the <b> Ctrl + Scroll Wheel</b> to zoom in / out. \
			Press <b>Space</b> to cycle fire modes. \
			Press <b>X</b> to cycle inertial dampners. \
			Press <b>Alt<b> to cycle the handbrake. \
			Press <b>C<b> to cycle mouse free movement.</span>")

/obj/machinery/computer/ship/helm/console/dropship/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FighterControls")
		ui.open()
		ui.set_autoupdate(TRUE) // Fuel gauge, ammo, etc

/obj/machinery/computer/ship/helm/console/dropship/ui_data(mob/user)
	var/obj/structure/overmap/OM = get_overmap()
	var/list/data = OM.ui_data(user)
	return data

/obj/machinery/computer/ship/helm/console/dropship/ui_act(action, params, datum/tgui/ui)
	var/obj/structure/overmap/small_craft/transport/OM = get_overmap()
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
			OM.dradis?.ui_interact(usr)
			return
		if("toggle_ftl")
			var/obj/item/fighter_component/ftl/ftl = OM.loadout.get_slot(HARDPOINT_SLOT_FTL)
			if(!ftl)
				return
			ftl.active = !ftl.active
			OM.relay('nsv13/sound/effects/fighters/switch.ogg')
		if("return_jump")
			var/obj/item/fighter_component/ftl/ftl = OM.loadout.get_slot(HARDPOINT_SLOT_FTL)
			if(!ftl)
				return
			if(ftl.ftl_state != 3)
				to_chat(usr, "<span class='warning'>Unable to comply. FTL vector calculation still in progress.</span>")
				return
			var/obj/structure/overmap/mothership = SSstar_system.find_main_overmap()
			if(!mothership)
				to_chat(usr, "<span class='warning'>Unable to comply. FTL tether lost.</span>")
				return
			var/datum/star_system/dest = SSstar_system.ships[mothership]["current_system"]
			if(!dest)
				to_chat(usr, "<span class='warning'>Unable to comply. Target beacon is currently in FTL transit.</span>")
				return
			ftl.jump(dest)
			return


	OM.relay('nsv13/sound/effects/fighters/switch.ogg')

/obj/structure/overmap/small_craft/transport/stop_piloting(mob/living/M, eject_mob=FALSE, force=FALSE) // Just changes eject default to false
	return ..()
