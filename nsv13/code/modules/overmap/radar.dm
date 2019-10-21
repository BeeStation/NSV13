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
	popup.set_window_options("can_close=1;can_minimize=1;can_maximize=0;can_resize=0;titlebar=1;focus=false;")
	popup.open()

/obj/machinery/computer/ship/dradis
	var/health = 100

/*
/obj/machinery/computer/ship/dradis/ui_base_html(html)
	if(!has_overmap() || !on || !is_operational())
		soundloop?.stop()
		return
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
	html += dat
	to_chat(world, html)
	return html
*/

/obj/machinery/computer/ship/dradis/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/dradis)
		assets.send(user)
		ui = new(user, src, ui_key, "dradis", name, 700, 580, master_ui, state)
		ui.set_style("dradis")
		ui.open()

//obj/machinery/computer/ship/dradis/ui_base_html(html) //i'm so deep in this shit now fucking help me
//	return

/obj/machinery/computer/ship/dradis
	var/list/radar_dots = list()

/obj/machinery/computer/ship/dradis/ui_data(mob/user)
	if(last_scanning_speed != scanning_speed)
		soundloop.stop()
		soundloop.mid_length = scanning_speed SECONDS //Allow for faster sweeps
		last_scanning_speed = scanning_speed
		for(var/datum/X in soundloop.active_timers)
			qdel(X)
		soundloop.start()
	var/list/data = list()
	radar_dots = list()
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.z == linked.z)
			var/list/this = list()
			this["x"] = OM.x
			this["y"] = OM.y
			var/thecolour = "#FFFFFF"
			if(OM == linked)
				thecolour = "#00FFFF"
			else if(OM.faction == linked.faction)
				thecolour = "#32CD32"
			else
				thecolour = "#FF0000"
			this["colour"] = thecolour
			radar_dots += OM
/*
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.z == linked.z)
			count ++
			if(OM == linked)
				data[radar_dots] += ".p[count] { background: cyan; bottom: [OM?.y/8]em; left: [OM?.x/8]em; }"
				continue
			if(OM.faction == linked.faction)
				data[radar_dots] += ".p[count] { background: lightgreen; bottom: [OM?.y/8]em; left: [OM?.x/8]em; }"
				continue
			data[radar_dots] += ".p[count] { background: red; bottom: [OM?.y/8]em; left: [OM?.x/8]em; }"
*/
	data["radar_dots"] = radar_dots
	to_chat(world, "radar dots!")
	return data


/datum/asset/simple/overmap_flight
	assets = list(
		"background.png"	= 'nsv13/icons/overmap/gui/flight_console/background.png',
		"monitor.png"		= 'nsv13/icons/overmap/gui/flight_console/monitor.png',
		"brake_off.png"		= 'nsv13/icons/overmap/gui/flight_console/brake_off.png',
		"brake_on.png"		= 'nsv13/icons/overmap/gui/flight_console/brake_on.png',
		"flighttoggle.png"		= 'nsv13/icons/overmap/gui/flight_console/flighttoggle.png',
		"hull0.png"		= 'nsv13/icons/overmap/gui/flight_console/hull0.png',
		"hull25.png"		= 'nsv13/icons/overmap/gui/flight_console/hull25.png',
		"hull50.png"		= 'nsv13/icons/overmap/gui/flight_console/hull50.png',
		"hull75.png"		= 'nsv13/icons/overmap/gui/flight_console/hull75.png',
		"hull100.png"		= 'nsv13/icons/overmap/gui/flight_console/hull100.png',
		"rotation_keyboard.png"		= 'nsv13/icons/overmap/gui/flight_console/rotation_keyboard.png',
		"rotation_mouse.png"		= 'nsv13/icons/overmap/gui/flight_console/rotation_mouse.png',
		"rotationtoggle.png"		= 'nsv13/icons/overmap/gui/flight_console/rotationtoggle.png',
		)

/obj/structure/overmap
	var/left_value = 400 //ui shit
	var/top_value = 400

/obj/structure/overmap/proc/show_flight_ui()
	var/mob/user = pilot
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/overmap_flight)
	assets.send(user)
	var/dat = "\
	<!DOCTYPE html>\
	<html>\
	<style>\
	.bg\
    {\
      position: relative;\
      top: 0;\
      left: 0;\
    }\
    .overlay\
    {\
      position: absolute;\
      top: [top_value];\
      left: [left_value];\
    }\
    </style>\
	<body background='background.png'>\
	<div style='position: relative; left: 0; top: 0;'>\
		<img src='monitor.png' alt='Monitor' class='overlay'>\
		<img src='brake_off.png' alt='Brake off' class='overlay'>\
		<img src='flighttoggle.png' alt='Flighttoggle' class='overlay'>\
		<img src='hull100.png' alt='Hull' class='overlay'>\
		<img src='rotation_mouse.png' alt='Mouse rotation' class='overlay'>\
		<img src='rotationtoggle.png' alt='Rotationtoggle' class='overlay'>\
	</div>\
	</html>"
	user.set_machine(src)
	var/datum/browser/popup = new(user, "Flight console", name, 400, 400)
	popup.set_content(dat)
	popup.open()