/obj/machinery/computer/ship/ftl_core
	name = "\improper FTL frameshift core"
	desc = "A highly advanced system capable of using exotic energy to bend space around it, exotic energy must be supplied by drive pylons"
	icon = 'nsv13/icons/obj/machinery/FTL_drive.dmi'
	icon_state = "core_idle"
	pixel_x = -80
	pixel_y = -64
//	bound_height = 128
//	bound_width = 160
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	icon_screen = null
	icon_keyboard = null
	req_access = list(ACCESS_ENGINE_EQUIP)
	var/tier = 1 // increased tiers increase jump range
	var/faction = "nanotrasen"
	var/link_id = "default"
	var/list/pylons = list() //connected pylons
	var/active = FALSE // Whether or not we should be charging
	var/progress = 0 // charge progress, 0-req_charge
	var/can_cancel_jump = TRUE //Defaults to true. TODO: Make emagging disable this
	var/req_charge = 100
	var/cooldown = 0 // cooldown in process ticks
	var/charge_rate = 0.5 // how much charge is given per pylon
	var/obj/item/radio/radio //For engineering alerts.
	var/radio_key = /obj/item/encryptionkey/headset_eng
	var/radio_channel = "Engineering"
	var/max_range = 30000
	var/jump_speed_factor = 3.5 //How quickly do we jump? Larger is faster.
	var/list/tracking = list()
	var/ftl_startup_time = 30 SECONDS // How long does it take to iniate the jump
	var/ftl_loop = 'nsv13/sound/effects/ship/FTL_loop.ogg'
	var/ftl_start = 'nsv13/sound/effects/ship/FTL_long.ogg'
	var/ftl_exit = 'nsv13/sound/effects/ship/freespace2/warp_close.wav'
	var/auto_spool = FALSE

	var/ftl_state = FTL_STATE_IDLE

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
		if(pylons.len == 4) // No more than 4 pylons for the sake of the UI
			break
		if(link_id == P.link_id && P.get_overmap() == get_overmap() && P.is_operational())
			pylons += P

/obj/machinery/computer/ship/ftl_core/proc/check_pylons()
	if(!LAZYLEN(pylons) && !get_pylons())
		return FALSE
	return TRUE


/obj/machinery/computer/ship/ftl_core/proc/spoolup()
	if(!is_operational() || !anchored)
		visible_message("<span class='warning'>FTL core damaged or without power, startup procedure cancelled.</span>")
		return
	if(cooldown)
		visible_message("<span class='warning'>FTL core temperature beyond safety limits, please wait for cooldown cycle to complete.</span>")
		return
	if(progress)
		visible_message("<span class='warning'>FTL maifold is already active.</span>")
		return
	if(!check_pylons())
		visible_message("<span class='warning'>Insufficient connected drive pylons.</span>")
		return

	visible_message("<span class='info'>Core fuel cycle starting.</span>")
	active = TRUE
	START_PROCESSING(SSmachines, src)
	playsound(src, 'nsv13/sound/effects/computer/hum3.ogg', 100, 1)
	playsound(src, 'nsv13/sound/voice/ftl_spoolup.wav', 100, FALSE)
	radio.talk_into(src, "FTL spoolup initiated.", radio_channel)
	icon_state = "core_active"
	use_power = 500

/obj/machinery/computer/ship/ftl_core/process()
	if(!active || !is_operational() || !anchored)
		depower()
		return
	if(ftl_state == FTL_STATE_JUMPING)
		return
	var/active_charge = FALSE
	for(var/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/P in pylons)
		if(P.pylon_state == PYLON_STATE_ACTIVE)
			progress = min(progress + charge_rate, req_charge)
			active_charge = TRUE
			if(prob(30))
				P.Beam(src, icon_state = "lightning[rand(1, 12)]", time = 10, maxdistance = 10)
				playsound(P, 'sound/magic/lightningshock.ogg', 50, 1, extrarange = 5)
	if(!active_charge && progress > 0)
		progress--
		if(progress < req_charge && ftl_state == FTL_STATE_READY)
			cancel_ftl()
	if(ftl_state != FTL_STATE_READY && progress >= req_charge)
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
	ui = new(user, src, "FTLComputerModular")
	ui.open()

/obj/machinery/computer/ship/ftl_core/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(. || !has_overmap())
		return
	playsound(src, 'nsv13/sound/effects/computer/scroll_start.ogg', 100, 1)
	var/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/P = locate(params["id"])
	switch(action)
		if("pylon_power")
			if(!P)
				return
			switch(P.pylon_state)
				if(PYLON_STATE_OFFLINE)
					if(P.try_enable()) // enables it if it passes
						visible_message("<span class='notice'>Pylon power cycle starting.</span>")
					else
						visible_message("<span class='warning'>Selected pylon missing power connection!</span>")
				if(PYLON_STATE_SHUTDOWN)
					visible_message("<span class='warning'>Please wait for pylon power cycle to complete before reactivating.</span>")
				else
					P.set_state(PYLON_STATE_SHUTDOWN)
					. = TRUE
		if("find_pylons")
			get_pylons()
			. = TRUE

		if("toggle_power")
			if(active)
				depower()
			else
				spoolup()
			. = TRUE

/obj/machinery/computer/ship/ftl_core/ui_data(mob/user)
	var/list/data = list()
	data["powered"] = ftl_state != FTL_STATE_IDLE
	data["progress"] = progress
	data["goal"] = req_charge
	data["ready"] = ftl_state == FTL_STATE_READY
	data["jumping"] = ftl_state == FTL_STATE_JUMPING
	var/list/pylons_info = list()
	var/count = 0
	for(var/obj/machinery/atmospherics/components/binary/ftl/drive_pylon/P in pylons)
		count++
		var/list/pylon_info = list()
		pylon_info["name"] = "Pylon [count]"
		pylon_info["id"] = "\ref[P]"
		pylon_info["status"] = P.pylon_state
		pylon_info["gyro"] = round(P.gyro_speed / P.req_gyro_speed)
		pylon_info["capacitor"] = round(P.capacitor / P.req_capacitor)
		pylon_info["draw"] = DisplayPower(P.min_power_draw)
		pylons_info[++pylons_info.len] = pylon_info // probably could have a better var name for this one
	data["pylons"] = pylons_info
	return data

/obj/machinery/computer/ship/ftl_core/proc/jump(datum/star_system/target_system)
	ftl_state = FTL_STATE_JUMPING
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
	ftl_state = FTL_STATE_READY

/obj/machinery/computer/ship/ftl_core/proc/cancel_ftl()
	ftl_state = FTL_STATE_SPOOLING
	playsound(src, 'nsv13/sound/voice/ftl_cancelled.wav', 100, FALSE)
	radio.talk_into(src, "FTL translation cancelled.", radio_channel)

/obj/machinery/computer/ship/ftl_core/update_icon()
	return //Override computer updates

/obj/machinery/computer/ship/ftl_core/proc/depower()
	if(progress >= 0)
		var/list/timers = active_timers
		active_timers = null
		for(var/thing in timers)
			var/datum/timedevent/timer = thing
			if(timer.spent)
				continue
			qdel(timer)
		active = FALSE
		ftl_state = FTL_STATE_IDLE
		icon_state = "core_idle"
		progress = 0
		use_power = 50
		if(auto_spool)
			active = TRUE
			spoolup()
			START_PROCESSING(SSmachines, src)
			return TRUE
		STOP_PROCESSING(SSmachines, src)
		return TRUE
	return FALSE
