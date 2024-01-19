/obj/machinery/jukebox
	name = "Jukebox"
	desc = "Tradycyjny odtwarzacz muzyczny."
	icon = 'aquila/icons/obj/jukebox.dmi'
	icon_state = "jukebox"
	verb_say = "states"
	density = TRUE
	req_access = list(ACCESS_BAR)
	interaction_flags_machine = INTERACT_MACHINE_SET_MACHINE | INTERACT_MACHINE_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON
	max_integrity = 500
	integrity_failure = 250
	var/active = FALSE
	var/stop = 0
	var/selection = 1
	var/channel = null
	var/state_base = "jukebox"
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	var/speed_servo_regulator_cut = FALSE //vaporwave
	var/speed_servo_resistor_cut = FALSE //nightcore
	var/mains = TRUE
	var/verify = TRUE
	var/speed_potentiometer = 1.0
	var/selection_blocked = FALSE
	var/stop_blocked = FALSE
	var/list_source = list()

/obj/machinery/jukebox/disco
	name = "Disco Jukebox"
	desc = "Odtwarzacz muzyczny w wersji Disco."

/obj/machinery/jukebox/disco/indestructible
	name = "Niezniszczalny Disco Jukebox"
	req_access = null
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_1 = NODECONSTRUCT_1

/obj/machinery/jukebox/Initialize()
	. = ..()
	wires = new /datum/wires/jukebox(src)
	list_source = SSjukeboxes.song_lib
	update_icon()

/obj/machinery/jukebox/Destroy()
	if(!isnull(channel))
		SSjukeboxes.remove_jukebox(channel)
		channel = null
	QDEL_NULL(wires)
	return ..()

/obj/machinery/jukebox/power_change()
	..()
	update_icon()
	if((machine_stat & NOPOWER) || !mains)
		stop = 0

/obj/machinery/jukebox/obj_break()
	. = ..()
	if(.)
		stop = 0
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, 1)

/obj/machinery/jukebox/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return
	if(panel_open && is_wire_tool(I))
		wires.interact(user)
		return TRUE
	if(I.tool_behaviour == TOOL_WELDER && user.a_intent == INTENT_HELP)
		if(obj_integrity < max_integrity)
			if(!I.tool_start_check(user, amount=5))
				return
			to_chat(user, "<span class='notice'>You begin repairing [src].</span>")
			if(I.use_tool(src, user, 40, amount=5, volume=50))
				obj_integrity = max_integrity
				machine_stat &= ~BROKEN
				update_icon()
				to_chat(user, "<span class='notice'>You repair [src].</span>")
				return
	return ..()

/obj/machinery/jukebox/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		stop = 0
		update_icon()

/obj/machinery/jukebox/_try_interact(mob/user)
	if(seconds_electrified)
		if(shock(user, 100))
			return
	return ..()

/obj/machinery/jukebox/proc/shock(mob/user, prb)
	if(machine_stat & NOPOWER || !mains)
		return FALSE
	if(!prob(prb))
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	if(electrocute_mob(user, get_area(src), src, 0.7, check_range))
		return TRUE
	else
		return FALSE

/obj/machinery/jukebox/update_icon()
	overlays = 0
	icon_state = "[state_base]"
	if((machine_stat & MAINT) || panel_open)
		overlays += image(icon = icon, icon_state = "[state_base]-panel")
	if(!(machine_stat & NOPOWER) && anchored && mains)
		if(machine_stat & BROKEN)
			overlays += image(icon = icon, icon_state = "[state_base]-broken")
		else
			overlays += image(icon = icon, icon_state = "[state_base]-powered")
			if(active)
				overlays += image(icon = icon, icon_state = "[state_base]-playing")

/obj/machinery/jukebox/ui_interact(mob/user)
	. = ..()
	if(machine_stat & (BROKEN|NOPOWER) || !mains)
		return
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	if (!anchored)
		to_chat(user,"<span class='warning'>To urządzenie musi wpierw był przykręcone do podłoża!</span>")
		return
	if(!SSjukeboxes.songs.len)
		to_chat(user,"<span class='warning'>Błąd: nie znaleziono żadnych utworów. Skonsultuj się z Centralą.</span>")
		playsound(src,'sound/machines/deniedbeep.ogg', 50, 1)
		return
	var/list/dat = list()
	dat += "<div class='statusDisplay' style='text-align:center'>"
	dat += "<b><a href='?src=[REF(src)];action=toggle'>[!active ? "BREAK IT DOWN" : "SHUT IT DOWN"]</a><b><br>"
	dat += "</div><br>"
	dat += "<A href='?src=[REF(src)];action=select'> Select Track</A><br>"
	dat += "Track Selected: [SSjukeboxes.songs[selection].name]<br>"
	dat += "Track Length: [DisplayTimeText(SSjukeboxes.songs[selection].length)]<br><br>"
	var/datum/browser/popup = new(user, "vending", "[name]", 400, 350)
	popup.set_content(dat.Join())
	popup.open()

/obj/machinery/jukebox/Topic(href, href_list)
	if(..())
		return
	if(machine_stat & (BROKEN|NOPOWER) || !mains)
		return
	if(!anchored)
		to_chat(usr, "<span class='warning'>To urządzenie musi najpierw być przykręcone do podłoża!</span>")
		return
	if(!allowed(usr) && verify)
		to_chat(usr,"<span class='warning'>Nie masz uprawnień, aby korzystać z tego urządzenia.</span>")
		playsound(src,'sound/machines/deniedbeep.ogg', 50, 1)
		return
	add_fingerprint(usr)
	if(seconds_electrified)
		if(shock(usr, 100))
			return
	switch(href_list["action"])
		if("toggle")
			if(!active)
				attempt_playback()
			else
				if (stop_blocked)
					to_chat(usr, "<span class='warning'>Wciskasz przycisk zatrzymania odtwarzania, ale nic się nie dzieje. Dziwne.</span>")
				else
					stop = 0
		if("select")
			if(active)
				to_chat(usr, "<span class='warning'>Nie można wybrać innego utworu gdy trwa odtwarzanie.</span>")
				playsound(src, 'sound/machines/deniedbeep.ogg', 50, 1)
				return
			if(selection_blocked)
				to_chat(usr, "<span class='warning'>Wciskasz przycisk wyboru utworu, ale nic się nie dzieje. Smutne!</span>")
				return
			var/selected = input(usr, "Choose your song", "Track:") as null|anything in list_source
			if(QDELETED(src) || !selected)
				return
			selection = list_source[selected]
			updateUsrDialog()

/obj/machinery/jukebox/proc/activate_music()
	if(machine_stat & (BROKEN|NOPOWER) || !mains)
		return FALSE
	var/speed_factor = get_speed_factor()
	channel = SSjukeboxes.add_jukebox(src, selection, speed_factor)
	if(isnull(channel))
		return null
	active = TRUE
	playsound(src,'sound/machines/terminal_on.ogg',50,TRUE)
	update_icon()
	stop = world.time + (SSjukeboxes.songs[selection].length * (1/speed_factor))
	START_PROCESSING(SSobj, src)
	return TRUE

/obj/machinery/jukebox/process()
	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--
	if(world.time >= stop && active)
		active = FALSE
		STOP_PROCESSING(SSobj, src)
		playsound(src,'sound/machines/terminal_off.ogg',50,TRUE)
		updateUsrDialog()
		update_icon()
		SSjukeboxes.remove_jukebox(channel)
		channel = null
		stop = world.time + 25

/obj/machinery/jukebox/proc/get_speed_factor()
	var/speed_factor = 1.0
	if (speed_servo_regulator_cut)
		speed_factor *= 0.73
	if (speed_servo_resistor_cut)
		speed_factor *= 1.25
	speed_factor *= speed_potentiometer
	return speed_factor

/obj/machinery/jukebox/proc/pick_random(specific_list = list_source)
	var/selected = pick(specific_list)
	if(QDELETED(src) || !selected)
		return
	selection = specific_list[selected]
	updateUsrDialog()

/obj/machinery/jukebox/proc/attempt_playback()
	if (QDELETED(src))
		return
	if(stop > world.time)
		to_chat(usr, "<span class='warning'>Urządzenie wciąż parkuje płytę, spróbuj ponownie za [DisplayTimeText(stop-world.time)].</span>")
		playsound(src, 'sound/machines/deniedbeep.ogg', 50, TRUE)
		return
	if(!activate_music())
		to_chat(usr, "<span class='warning'>Błąd sprzętowy, spróbuj ponownie.</span>")
		playsound(src, 'sound/machines/deniedbeep.ogg', 50, TRUE)
		return
	updateUsrDialog()
