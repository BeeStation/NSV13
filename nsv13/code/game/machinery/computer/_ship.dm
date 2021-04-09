//Generic console base for consoles that interact with the overmap
//If you are looking for the Dradis console look in nsv13/modules/overmap/radar.dm
//If you're looking for the FTL navigation computer look in nsv13/modules/overmap/starmap.dm
GLOBAL_LIST_INIT(computer_beeps, list('nsv13/sound/effects/computer/beep.ogg','nsv13/sound/effects/computer/beep2.ogg','nsv13/sound/effects/computer/beep3.ogg','nsv13/sound/effects/computer/beep4.ogg','nsv13/sound/effects/computer/beep5.ogg','nsv13/sound/effects/computer/beep6.ogg','nsv13/sound/effects/computer/beep7.ogg','nsv13/sound/effects/computer/beep8.ogg','nsv13/sound/effects/computer/beep9.ogg','nsv13/sound/effects/computer/beep10.ogg','nsv13/sound/effects/computer/beep11.ogg','nsv13/sound/effects/computer/beep12.ogg'))
//Yes beeps are here because reasons

/obj/machinery/computer/ship
	name = "Ship console"
	icon_keyboard = "helm_key"
	var/obj/structure/overmap/linked
	var/position = null
	var/can_sound = TRUE //Warning sound placeholder
	var/sound_cooldown = 10 SECONDS //For big warnings like enemies firing on you, that we don't want repeating over and over

/obj/machinery/computer/ship/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/ship/LateInitialize()
	has_overmap()

/obj/machinery/computer/ship/proc/relay_sound(sound, message)
	if(!can_sound)
		return
	if(message)
		visible_message(message)
	if(sound)
		playsound(src, sound, 100, 1)
		can_sound = FALSE
		addtimer(CALLBACK(src, .proc/reset_sound), sound_cooldown)

/obj/machinery/computer/ship/proc/reset_sound()
	can_sound = TRUE

/obj/machinery/computer/ship/proc/has_overmap()
	var/obj/structure/overmap/OM = get_overmap()
	linked = OM
	if(OM)
		set_position(OM)
	return linked

/obj/machinery/computer/ship/proc/set_position(obj/structure/overmap/OM)
	return

/obj/machinery/computer/ship/ui_interact(mob/user)
	if(isobserver(user))
		return FALSE
	if(!has_overmap())
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>A warning flashes across [src]'s screen: Unable to locate thrust parameters, no registered ship stored in microprocessor.</span>")
		return FALSE
	playsound(src, 'nsv13/sound/effects/computer/startup.ogg', 75, 1)
	if(!position)
		return TRUE
	return linked.start_piloting(user, position)

//Viewscreens for regular crew to watch combat
/obj/machinery/computer/ship/viewscreen
	name = "Seegson model M viewscreen"
	desc = "A large CRT monitor which shows an exterior view of the ship."
	icon = 'nsv13/icons/obj/computers.dmi'
	icon_state = "viewscreen"
	idle_power_usage = 15
	mouse_over_pointer = MOUSE_HAND_POINTER
	pixel_y = 26
	density = FALSE
	anchored = TRUE
	req_access = null

/obj/machinery/computer/ship/viewscreen/examine(mob/user)
	. = ..()
	if(!has_overmap())
		return
	if(isobserver(user))
		var/mob/dead/observer/O = user
		O.ManualFollow(linked)
		return
	playsound(src, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
	linked.start_piloting(user, "observer")

/obj/machinery/computer/ship/viewscreen/ui_interact(mob/user)
	if(!has_overmap())
		return
	if(isobserver(user))
		var/mob/dead/observer/O = user
		O.ManualFollow(linked)
		return
	playsound(src, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
	linked.start_piloting(user, "observer")
