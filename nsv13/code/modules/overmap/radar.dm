/obj/machinery/computer/ship/dradis
	name = "DRADIS computer"
	desc = "The DRADIS system is a series of highly sensitive detection, identification, navigation and tracking systems used to determine the range and speed of objects. This forms the most central component of a spaceship's navigational systems, as it can project the whereabouts of enemies that are out of visual sensor range by tracking their engine signatures."
	icon_screen = "teleport"
	var/stored = "blank"
	var/datum/looping_sound/dradis/soundloop
	var/on = TRUE //Starts on by default.
	var/scanning_speed = 2 //Duration of each pulse.
	var/last_scanning_speed = 2 //To update the sound loop

/datum/looping_sound/dradis
	mid_sounds = list('nsv13/sound/effects/ship/dradis.ogg')
	mid_length = 2 SECONDS
	volume = 70

/datum/asset/simple/dradis
	assets = list(
		"dradis.gif"	= 'nsv13/icons/assets/dradis.gif')

/obj/machinery/computer/ship/dradis/updateUsrDialog() //Expand updateusrdialogue to encompass ship pilots.
	if((obj_flags & IN_USE) && !(obj_flags & USES_TGUI))
		var/is_in_use = FALSE
		var/list/nearby = viewers(1, src)
		for(var/mob/M in linked?.operators) //Separate check to avoid fuckery
			is_in_use = TRUE
			ui_interact(M)
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = TRUE
				ui_interact(M)
		if(issilicon(usr) || IsAdminGhost(usr))
			if (!(usr in nearby))
				if (usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
					is_in_use = TRUE
					ui_interact(usr)

		// check for TK users

		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			if(!(usr in nearby))
				if(usr.client && usr.machine==src)
					if(H.dna.check_mutation(TK))
						is_in_use = TRUE
						ui_interact(usr)
		if (is_in_use)
			obj_flags |= IN_USE
		else
			obj_flags &= ~IN_USE

/obj/machinery/computer/ship/dradis/power_change()
	..()
	if(stat & NOPOWER)
		soundloop?.stop()
	else
		soundloop?.start()

/obj/machinery/computer/ship/dradis/proc/update_dialogue()
	if(!is_operational())
		soundloop?.stop()
		return
	if(!has_overmap())
		return
	soundloop?.start()
	updateUsrDialog()

/obj/machinery/computer/ship/dradis/set_position()
	linked.dradis = src

/obj/machinery/computer/ship/dradis/Initialize()
	. = ..()
	soundloop = new(list(src), FALSE)
	RegisterSignal(soundloop, COMSIG_LOOPINGSOUND_PLAYED, .proc/update_dialogue) //Add a listener on ship move. If you move out of range of the salvage target, it explodes because youre not there to stabilize it anymore.
	soundloop?.start()

/obj/machinery/computer/ship/dradis/attack_hand(mob/user)
	. = ..()
	ui_interact(user)

/obj/machinery/computer/ship/dradis/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	if(!has_overmap() || !on || !is_operational())
		soundloop?.stop()
		return
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/dradis)
	assets.send(user)
	var/dat = "\
	<!DOCTYPE html>\
	<html>\
	<body background='dradis.gif'>\
	<head>\
	<style>\
	.body{\
	    background-color: black;\
	}\
	.map {\
	    position: relative;\
	    width: 31.875em;\
	    height: 31.875em;\
	    margin: 0 auto;\
	}\
	.point {\
	    display: block;\
	    position: absolute;\
	    width: 1em;\
	    height: 1em;\
	    border-radius: 50%;\
        -webkit-animation: fadeinout [scanning_speed]s linear forwards;\
        animation: fadeinout [scanning_speed]s linear forwards;\
        opacity: 0;\
	}\
	@-webkit-keyframes fadeinout {\
	  50% { opacity: 1; }\
	}\
	\
	@keyframes fadeinout {\
	  50% { opacity: 1; }\
	}"
	if(last_scanning_speed != scanning_speed)
		soundloop.stop()
		soundloop.mid_length = scanning_speed SECONDS //Allow for faster sweeps
		last_scanning_speed = scanning_speed
		for(var/datum/X in soundloop.active_timers)
			qdel(X)
		soundloop.start()
	var/count = 0 //em is NOT px! It's around 16px :)
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.z == linked.z)
			count ++
			if(OM == linked)
				dat += ".p[count] { background: cyan; bottom: [OM?.y/8]em; left: [OM?.x/8]em; }"
				continue
			if(OM.faction == linked.faction)
				dat += ".p[count] { background: lightgreen; bottom: [OM?.y/8]em; left: [OM?.x/8]em; }"
				continue
			dat += ".p[count] { background: red; bottom: [OM?.y/8]em; left: [OM?.x/8]em; }"
	var/max_count = count+1
	dat += "</style>"
	dat += "<div class='map'>"
	for(var/i = 0, i < max_count, i++)
		if(i <= 0)
			i = 1
		dat += "<span class='point p[i]'></span>"
	dat += "</div>"
	dat += "</html>"
	stored = dat
	user.set_machine(src)
	var/datum/browser/popup = new(user, "Dradis", name, 700, 580)
	popup.set_content(dat)
	popup.open()