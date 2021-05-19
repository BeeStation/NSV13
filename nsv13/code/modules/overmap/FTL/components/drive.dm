/obj/machinery/computer/ship/ftl_core
	name = "\improper FTL framewarp core"
	desc = "A highly advanced system capable of using exotic energy to bend space around it, exotic energy must be supplied by drive pylons"
	icon = 'nsv13/icons/obj/machinery/FTL_drive.dmi'
	icon_state = "core_idle"
	bound_height = 64
	bound_width = 64
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	icon_screen = null
	icon_keyboard = null
	req_access = list(ACCESS_ENGINE_EQUIP)
	var/jumping = FALSE // are we already jumping?
	var/tier = 1 // increased tiers increase jump range
	var/link_id = "default"
	var/list/pylons = list() //connected pylons
	var/enabled = FALSE // Whether or not we should be charging
	var/charge = 0 // charge progress, 0-req_charge
	var/req_charge = 100
	var/cooldown = 0 // cooldown in process ticks
	var/charge_rate = 0.5 // how much charge is given per pylon
	var/obj/item/radio/radio //For engineering alerts.
	var/radio_key = /obj/item/encryptionkey/headset_eng
	var/radio_channel = "Engineering"
	var/max_range = 30000
	var/engaged = FALSE //Are we fully ready?

/obj/machinery/computer/ship/ftl_core/Initialize()
	. = ..()
	add_overlay("screen")
	get_pylons()
	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = 0
	radio.recalculateChannels()

/obj/machinery/computer/ship/ftl_core/proc/get_pylons()
	pylons.len = 0
	for(var/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/P in GLOB.machines)
		if(pylons.len >= 4)
			break
		if(link_id == P.link_id && P.get_overmap() == get_overmap() && P.is_operational())
			pylons += P

/obj/machinery/computer/ship/ftl_core/proc/check_pylons()
	if(!LAZYLEN(pylons) && !get_pylons())
		return FALSE
	return TRUE


/obj/machinery/computer/ship/ftl_core/proc/begin_charge()
	if(!is_operational() || !anchored)
		visible_message("<span class='warning'>FTL core damaged or without power, startup procedure cancelled.</span>")
		return
	if(cooldown)
		visible_message("<span class='warning'>FTL core temperature beyond safety limits, please wait for cooldown cycle to complete.</span>")
		return
	if(charge)
		visible_message("<span class='warning'>FTL maifold is already active.</span>")
		return
	if(!check_pylons())
		visible_message("<span class='warning'>Insufficient connected drive pylons.</span>")
		return

	visible_message("<span class='info'>Core fuel cycle starting.</span>")
	enabled = TRUE
	playsound(src, 'nsv13/sound/effects/computer/hum3.ogg', 100, 1)
	playsound(src, 'nsv13/sound/voice/ftl_spoolup.wav', 100, FALSE)
	radio.talk_into(src, "FTL spoolup initiated.", radio_channel)
	icon_state = "core_active"
	use_power = 500

/obj/machinery/computer/ship/ftl_core/process()
	if(!enabled || !is_operational() || !anchored)
		depower()
		return
	if(jumping)
		return
	var/active_charge = FALSE
	for(var/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/P in pylons)
		if(P.pylon_state == PYLON_STATE_ACTIVE)
			charge = min(charge + charge_rate, req_charge)
			active_charge = TRUE
	if(!active_charge && charge > 0)
		charge--
		if(charge < req_charge && engaged)
			cancel_ftl()
	if(!engaged && charge >= req_charge)
		ready_ftl()

//No please do not delete the FTL's radio and especially do not cause it to get stuck in limbo due to runtimes from said radio being gone.
/obj/machinery/computer/ship/ftl_core/prevent_content_explosion()
	return TRUE

/obj/machinery/computer/ship/ftl_core/attackby(obj/item/I, mob/user) //Allows you to upgrade dradis consoles to show asteroids, as well as revealing more valuable ones.
	. = ..()
	if(istype(I, /obj/item/ftl_slipstream_chip))
		var/obj/item/ftl_slipstream_chip/FI = I
		if(FI.tier > tier)
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
			to_chat(user, "<span class='notice'>You slot [I] into [src], updating its vector calculation systems.</span>")
			tier = FI.tier
			qdel(FI)
			upgrade()
		else
			to_chat(user, "<span class='notice'>[src] has already been upgraded to a higher tier than [FI] can offer.</span>")

/obj/machinery/computer/ship/ftl_core/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == "tier")
		upgrade()

/obj/machinery/computer/ship/ftl_core/proc/upgrade()
	switch(tier)
		if(1)
			return
		if(2)
			name = "upgraded [initial(name)]"
			max_range = initial(max_range) * 2
			jump_speed_factor = 2

		if(3) //Admin only, for now
			name = "advanced [initial(name)]"
			auto_spool = TRUE
			jump_speed_factor = 5
			max_range = initial(max_range) * 3

/*
Preset classes of FTL drive with pre-programmed behaviours
*/

/obj/machinery/computer/ship/ftl_core/preset/Initialize()
	. = ..()
	upgrade()

/obj/machinery/computer/ship/ftl_core/preset/upgraded
	tier = 2

/obj/machinery/computer/ship/ftl_core/preset/super
	tier = 3

/obj/machinery/computer/ship/ftl_core/syndicate
	name = "syndicate FTL core"
	radio_key = /obj/item/encryptionkey/syndicate
	radio_channel = "Syndicate"
	faction = "syndicate"
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/ship/ftl_core/mining
	name = "mining FTL core"
	radio_key = /obj/item/encryptionkey/headset_mining
	radio_channel = "Supply"
	req_access = null
	req_one_access_txt = "31;48"

/obj/machinery/computer/ship/ftl_core/Initialize()
	. = ..()
	start_monitoring(get_overmap()) //I'm a lazy hack that can't actually be assed to deal with an if statement in react right now.

/obj/machinery/computer/ship/ftl_core/syndicate/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/ship/ftl_core/syndicate/LateInitialize()
	. = ..()
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.role > NORMAL_OVERMAP && OM.faction != faction)
			start_monitoring(OM)

//Tell the FTL computer to start tracking a ship, regardless of how far apart you both are.
/obj/machinery/computer/ship/ftl_core/proc/start_monitoring(obj/structure/overmap/OM)
	tracking[OM] = list("ship" = OM, "name" = OM.name, "current_system" = OM.starting_system, "target_system" = null)
	RegisterSignal(OM, COMSIG_FTL_STATE_CHANGE, .proc/announce_jump)

/*
A way for syndies to track where the player ship is going in advance, so they can get ahead of them and hunt them down.
*/

/obj/machinery/computer/ship/ftl_core/proc/announce_jump()
	radio.talk_into(src, "TRACKING: FTL signature detected. Tracking information updated.", radio_channel)
	for(var/list/L in tracking)
		var/obj/structure/overmap/target = L["ship"]
		var/datum/star_system/target_system = SSstar_system.ships[target]["target_system"]
		var/datum/star_system/current_system = SSstar_system.ships[target]["current_system"]
		tracking[target] = list("name" = target.name, "current_system" = current_system.name, "target_system" = target_system.name)

/obj/machinery/computer/ship/ftl_core/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/has_overmap), 5 SECONDS)
	STOP_PROCESSING(SSmachines, src)

/obj/machinery/computer/ship/ftl_core/has_overmap()
	. = ..()
	linked?.ftl_drive = src

/obj/machinery/computer/ship/ftl_core/attack_hand(mob/user)
	if(!has_overmap())
		return
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	ui_interact(user)

/obj/machinery/computer/ship/ftl_core/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	ui = new(user, src, "FTLComputer_M")
	ui.open()

/obj/machinery/computer/ship/ftl_core/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(. || !has_overmap())
		return
	playsound(src, 'nsv13/sound/effects/computer/scroll_start.ogg', 100, 1)

	var/atom/movable/target = locate(params["id"])
	switch(action)
		if("pylon_power")
			var/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/P = target
			switch(P.pylon_state)
				if(PYLON_STATE_OFFLINE)
					if(P.try_enable()) // enables it if it passes
						visible_message("<span class='notice'>Pylon power cycle starting.</span>")
					else
						visible_message("<span class='warning'>Pylon missing power connection.</span>")

				if(PYLON_STATE_SHUTDOWN)
					visible_message("<span class='warning'>Please wait for pylon power cycle to complete before re-activating.</span>")
				else
					P.set_state(PYLON_STATE_SHUTDOWN)
		if("find_pylons")
			get_pylons()

		if("toggle_power")
			if(enabled)
				depower()
			else
				begin_charge()
		if("show_tracking")
			screen = 2
		if("go_back")
			screen = 1
		if("jump")
			if(!engaged)
				visible_message("<span class='warning'>Unable to comply. Insufficient fuel. 'Blind' FTL jumps are prohibited by the system administrative policy.</span>")
				return
			for(var/datum/star_system/S in SSstar_system.systems)
				if(S.visitable && S.name == params["target"])
					jump(S)
					break

/obj/machinery/computer/ship/ftl_core/ui_data(mob/user)
	var/list/data = list()
	data["powered"] = enabled
	data["progress"] = charge
	data["goal"] = req_charge
	data["ready"] = engaged
	data["mode"] = screen
	data["jumping"] = jumping
	data["systems"] = list()

	var/list/pylons_info = list()
	var/count = 0
	for(var/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/P in pylons)
		count++
		var/list/pylon_info = list()
		pylon_info["number"] = count
		pylon_info["id"] = "\ref[P]"
		pylon_info["enabled"] = P.pylon_state != PYLON_STATE_OFFLINE
		pylon_info["shutdown"] = P.pylon_state == PYLON_STATE_SHUTDOWN
		pylons_info += pylon_info // there's a plural I promise
	data["pylons"] = pylons_info

	var/list/ships = list()
	for(var/X in tracking)
		var/list/ship_info = list()
		ship_info["name"] = tracking[X]["name"]
		ship_info["current_system"] = tracking[X]["current_system"]
		ship_info["target_system"] = tracking[X]["target_system"]
		ships += ship_info
	data["tracking"] = ships
	for(var/datum/star_system/S in SSstar_system.systems)
		if(S.visitable && S != linked.current_system)
			data["systems"] += list(list("name" = S.name, "distance" = "2 minutes"))
	return data

/obj/machinery/computer/ship/ftl_core/proc/jump(datum/star_system/target_system)
	jumping = TRUE
	if(!target_system)
		radio.talk_into(src, "ERROR. Specified star_system no longer exists.", radio_channel)
		return
	linked?.begin_jump(target_system)
	playsound(src, 'nsv13/sound/voice/ftl_start.wav', 100, FALSE)
	radio.talk_into(src, "Initiating FTL translation.", radio_channel)
	playsound(src, 'nsv13/sound/effects/ship/freespace2/computer/escape.wav', 100, 1)
	visible_message("<span class='notice'>Initiating FTL jump.</span>")
	addtimer(CALLBACK(src, .proc/depower), ftl_startup_time)

/obj/machinery/computer/ship/ftl_core/proc/ready_ftl()
	playsound(src, 'nsv13/sound/voice/ftl_ready.wav', 100, FALSE)
	radio.talk_into(src, "FTL fuel cycle complete. Ready to commence FTL translation.", radio_channel)
	playsound(src, 'nsv13/sound/effects/ship/freespace2/computer/escape.wav', 100, 1)
	engaged = TRUE

/obj/machinery/computer/ship/ftl_core/proc/cancel_ftl()
	engaged = FALSE
	playsound(src, 'nsv13/sound/voice/ftl_cancelled.wav', 100, FALSE)
	radio.talk_into(src, "FTL translation cancelled.", radio_channel)

/obj/machinery/computer/ship/ftl_core/update_icon()
	return //Override computer updates

/obj/machinery/computer/ship/ftl_core/proc/depower()
	if(charge >= 0)
		jumping = FALSE
		var/list/timers = active_timers
		active_timers = null
		for(var/thing in timers)
			var/datum/timedevent/timer = thing
			if(timer.spent)
				continue
			qdel(timer)
		enabled = FALSE
		engaged = FALSE
		icon_state = "core_idle"
		charge = 0
		use_power = 50
		if(auto_spool)
			active = TRUE
			spoolup()
			START_PROCESSING(SSmachines, src)
		return TRUE
	return FALSE
