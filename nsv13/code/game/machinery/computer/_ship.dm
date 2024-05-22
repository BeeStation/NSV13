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
	var/list/ui_users = list()

/obj/machinery/computer/ship/Initialize(mapload)
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
		addtimer(CALLBACK(src, PROC_REF(reset_sound)), sound_cooldown)

/obj/machinery/computer/ship/proc/reset_sound()
	can_sound = TRUE

/obj/machinery/computer/ship/proc/has_overmap()
	linked = get_overmap()
	if(linked)
		set_position(linked)
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
	if((position & (OVERMAP_USER_ROLE_PILOT | OVERMAP_USER_ROLE_GUNNER)) && linked.ai_controlled)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>A warning flashes across [src]'s screen: Automated flight protocols are still active. Unable to comply.</span>")
		return FALSE
	playsound(src, 'nsv13/sound/effects/computer/startup.ogg', 75, 1)
	if(!position)
		return TRUE
	ui_users += user
	if(linked.mass < MASS_SMALL)
		to_chat(user, "<span class='notice'>Small craft use directional keys (WASD in hotkey mode) to accelerate/decelerate in a given direction and the mouse to change the direction of craft.\
					Mouse 1 will fire the selected weapon (if applicable).</span>")
		to_chat(user, "<span class='warning'>=Hotkeys=</span>")
		to_chat(user, "<span class='notice'> Use <b>tab</b> to activate hotkey mode, then:</span>")
		to_chat(user, "<span class='notice'>Use the <b> Ctrl + Scroll Wheel</b> to zoom in / out. \
					Press <b>Space</b> to cycle fire modes. \
					Press <b>X</b> to cycle inertial dampners. \
					Press <b>Alt<b> to cycle the handbrake.</span>")

	else
		to_chat(user, "<span class='notice'>Large craft use the up and down arrow keys (W & S in hotkey mode) to accelerate/decelerate craft. Use the left and right arrow keys (A & D) to rotate the craft. \
					Mouse 1 will fire the selected weapon (if applicable).</span>")
		to_chat(user, "<span class='warning'>=Hotkeys=</span>")
		to_chat(user, "<span class='notice'> Use <b>tab</b> to activate hotkey mode, then:</span>")
		to_chat(user, "<span class='notice'> Use the <b> Ctrl + Scroll Wheel</b> to zoom in / out. \
						Press <b>C</b> to cycle between mouse and keyboard steering. \
						Press <b>X</b> to cycle inertial dampners. \
						Press <b>Alt<b> to cycle the handbrake.</span>")

	return linked.start_piloting(user, position)

/obj/machinery/computer/ship/ui_close(mob/user)
	ui_users -= user
	return ..()

/obj/machinery/computer/ship/Destroy()
	for(var/mob/living/M in ui_users)
		ui_close(M)
		linked?.stop_piloting(M)
	linked = null
	ui_users = null //drop list to the GC
	return ..()

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
	var/obj/machinery/computer/ship/dradis/minor/internal_dradis

/obj/machinery/computer/ship/viewscreen/Initialize(mapload)
	. = ..()
	internal_dradis = new(src)

/obj/machinery/computer/ship/viewscreen/examine(mob/user)
	. = ..()
	if(!linked)
		return
	if(isobserver(user))
		var/mob/dead/observer/O = user
		O.ManualFollow(linked)
		return
	playsound(src, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
	linked.observe_ship(user)
	internal_dradis.attack_hand(user)

/obj/machinery/computer/ship/viewscreen/ui_interact(mob/user)
	if(!has_overmap())
		return
	if(isobserver(user))
		var/mob/dead/observer/O = user
		O.ManualFollow(linked)
		return
	playsound(src, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
	linked.start_piloting(user, OVERMAP_USER_ROLE_OBSERVER)
