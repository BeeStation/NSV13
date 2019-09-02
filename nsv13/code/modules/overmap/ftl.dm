/obj/structure/overmap/proc/begin_jump()
	relay_to_nearby('nsv13/sound/effects/ship/FTL.ogg', null, ignore_self=TRUE)//Ships just hear a small "crack" when another one jumps
	relay('nsv13/sound/effects/ship/FTL_long.ogg')
	addtimer(CALLBACK(src, .proc/jump, TRUE), 30 SECONDS)

/obj/structure/overmap/proc/jump(ftl_start) //FTL start IE, are we beginning a jump? Or ending one?
	if(main_overmap)
		var/list/areas = list()
		areas = GLOB.teleportlocs.Copy()
		for(var/A in areas)
			var/area/AR = areas[A]
			if(istype(AR, /area/space))
				continue
			if(ftl_start)
				AR.parallax_movedir = EAST
			else
				AR.parallax_movedir = null
	else
		if(ftl_start)
			linked_area.parallax_movedir = EAST
		else
			linked_area.parallax_movedir = null
	for(var/mob/M in mobs_in_ship)
		if(M && M.client && M.hud_used && length(M.client.parallax_layers))
			M.hud_used.update_parallax(forced = TRUE)
		if(iscarbon(M))
			var/mob/living/carbon/L = M
			if(HAS_TRAIT(L, TRAIT_SEASICK))
				if(prob(40)) //Take a roll! First option makes you puke and feel terrible. Second one makes you feel iffy.
					L.adjust_disgust(60)
				else
					L.adjust_disgust(40)
		shake_camera(M, 4, 1)
	if(ftl_start)
		relay('nsv13/sound/effects/ship/FTL_loop.ogg', "<span class='warning'>You feel the ship lurch forward</span>", loop=TRUE, channel = CHANNEL_SHIP_ALERT)
		addtimer(CALLBACK(src, .proc/jump, FALSE), 2 MINUTES)
	else
		relay('nsv13/sound/effects/ship/freespace2/warp_close.wav', "<span class='warning'>You feel the ship lurch to a halt</span>", loop=FALSE, channel = CHANNEL_SHIP_ALERT)

#define FTL_STATE_IDLE 1
#define FTL_STATE_SPOOLING 2
#define FTL_STATE_READY 3

/obj/machinery/computer/ship/ftl_computer
	name = "Seegson FTL navigation computer"
	desc = "A supercomputer which is capable of calculating exhorbitantly complex vectors which are interpreted into a simplified 4-dimensional course through which ships are able to travel. It takes some time to spool up between uses"
	icon = 'nsv13/goonstation/icons/ftlcomp.dmi'
	icon_state = "ftl_off"
	bound_height = 96
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	icon_screen = null
	icon_keyboard = null
	req_access = list(ACCESS_ENGINE_EQUIP)
	var/state = FTL_STATE_IDLE //Mr Gaeta, spool up the FTLs.
	var/obj/item/radio/radio //For engineering alerts.
	var/radio_key = /obj/item/encryptionkey/headset_eng
	var/engineering_channel = "Engineering"
	var/spoolup_time = 2 MINUTES

/obj/machinery/computer/ship/ftl_computer/attack_hand(mob/user)
	if(!is_operational())
		depower()
		return
	var/dat = ""
	dat += "<h2> Status: </h2>"
	switch(state)
		if(FTL_STATE_IDLE)
			dat += "<A href='?src=\ref[src];blank=1'>FTL Drive status: IDLE</A><BR>"
		if(FTL_STATE_SPOOLING)
			dat += "<A href='?src=\ref[src];blank=1'>FTL Drive status: SPOOLING</A><BR>"
		if(FTL_STATE_READY)
			dat += "<A href='?src=\ref[src];blank=1'>FTL Drive status: READY</A><BR>"
	dat += "<h2> Actions: </h2>"
	switch(state)
		if(FTL_STATE_IDLE)
			dat += "<A href='?src=\ref[src];spoolup=1'>Begin FTL drive spoolup sequence</A><BR>"
		if(FTL_STATE_READY)
			dat += "<A href='?src=\ref[src];jumpmenu=1'>View discovered FTL vectors</A><BR>"
	dat += "<A href='?src=\ref[src];depower=1'>Halt FTL vector calculation (power saving mode)</A><BR>"
	playsound(src, 'nsv13/sound/effects/computer/scroll_start.ogg', 100, 1)
	var/datum/browser/popup = new(user, "FTL drive console", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/ship/ftl_computer/proc/show_destinations(mob/user)
	if(state != FTL_STATE_READY)
		return
	var/dat = ""
	dat += "<h2> Calculated FTL vectors: </h2><br>"
	dat += "-----------------------------------<br>"
	dat += "<A href='?src=\ref[src];jump=1'>'Corvi' - Vector #[rand(0, 9999)] carom [rand(0, 20)].</A><BR>" //Placeholder. There isnt actually anywhere you can jump just yet.
	var/datum/browser/popup = new(user, "Available bluespace vectors", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/ship/ftl_computer/proc/jump()
	linked?.begin_jump()
	radio.talk_into(src, "Initiating FTL jump.", engineering_channel)
	playsound(src, 'nsv13/sound/effects/ship/freespace2/computer/escape.wav', 100, 1)
	visible_message("<span class='notice'>Initiating FTL jump.</span>")
	depower()

/obj/machinery/computer/ship/ftl_computer/proc/ready_ftl()
	state = FTL_STATE_READY
	radio.talk_into(src, "FTL vectors calculated. Drive status: READY.", engineering_channel)
	playsound(src, 'nsv13/sound/effects/ship/freespace2/computer/escape.wav', 100, 1)

/obj/machinery/computer/ship/ftl_computer/Topic(href, href_list)
	if(!in_range(src, usr) || !is_operational())
		return
	if(!has_overmap())
		return
	if(href_list["spoolup"])
		spoolup()
	if(href_list["jumpmenu"])
		show_destinations(usr)
	if(href_list["jump"])
		jump()
	if(href_list["depower"])
		depower()
	playsound(src, 'nsv13/sound/effects/computer/scroll1.ogg', 100, 1)
	attack_hand(usr)

/obj/machinery/computer/ship/ftl_computer/proc/spoolup()
	if(state == FTL_STATE_IDLE)
		playsound(src, 'nsv13/sound/effects/computer/hum3.ogg', 100, 1)
		radio.talk_into(src, "Calculating bluespace vectors. FTL spoolup initiated.", engineering_channel)
		icon_state = "ftl_charging"
		state = FTL_STATE_SPOOLING
		addtimer(CALLBACK(src, .proc/ready_ftl), spoolup_time)

/obj/machinery/computer/ship/ftl_computer/Initialize()
	. = ..()
	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = 0
	radio.recalculateChannels()

/obj/machinery/computer/ship/ftl_computer/update_icon()
	return //Override computer updates

/obj/machinery/computer/ship/ftl_computer/process()
	if(!is_operational())
		depower()
		return
	if(state == FTL_STATE_SPOOLING)
		icon_state = "ftl_charging"
		use_power = 500 //Eats up a fuckload of power as it takes 2 minutes to spool up.
		return
	if(state == FTL_STATE_READY)
		icon_state = "ftl_ready"
		use_power = 300 //Keeping the FTL spooled requires a fair bit of power
		return
	depower() //If it's not ready or spooling, it doesn't need to eat power.

/obj/machinery/computer/ship/ftl_computer/proc/depower()
	icon_state = "ftl_off"
	state = FTL_STATE_IDLE
	use_power = 0
	for(var/datum/X in active_timers)
		qdel(X)