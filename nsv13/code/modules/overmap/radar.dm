/obj/machinery/computer/ship/dradis
	name = "DRADIS computer"
	desc = "The DRADIS system is a series of highly sensitive detection, identification, navigation and tracking systems used to determine the range and speed of objects. This forms the most central component of a spaceship's navigational systems, as it can project the whereabouts of enemies that are out of visual sensor range by tracking their engine signatures."
	icon_screen = "teleport"
	req_access = list()
	var/stored = "blank"
	var/datum/looping_sound/dradis/soundloop
	var/on = TRUE //Starts on by default.
	var/scanning_speed = 2 //Duration of each pulse.
	var/last_scanning_speed = 2 //To update the sound loop
	var/start_with_sound = TRUE //Used to stop fighters playing dradis sounds all at once and being annoying.
	var/show_asteroids = FALSE //Used so that mining can track what they're supposed to be drilling.
	var/mining_sensor_tier = 1

/obj/machinery/computer/ship/dradis/minor //Secondary dradis consoles usable by people who arent on the bridge.
	name = "Air traffic control console"

/obj/machinery/computer/ship/dradis/mining
	name = "Nostromo DRADIS computer"
	desc = "A modified dradis console which links to the Nostromo's mineral scanners, able to pick up asteroids that can be mined."
	req_one_access_txt = "31;48"
	show_asteroids = TRUE

/obj/machinery/computer/ship/dradis/internal
	name = "Integrated dradis console"
	use_power = 0
	start_with_sound = FALSE

/obj/machinery/computer/ship/dradis/internal/has_overmap()
	if(linked)
		return TRUE
	return FALSE

/obj/machinery/computer/ship/dradis/minor/set_position()
	return

/datum/looping_sound/dradis
	mid_sounds = list('nsv13/sound/effects/ship/dradis.ogg')
	mid_length = 2 SECONDS
	volume = 60

/datum/asset/simple/dradis
	assets = list(
		"dradis.gif"	= 'nsv13/icons/assets/dradis.gif')

/obj/machinery/computer/ship/dradis/power_change()
	..()
	if(stat & NOPOWER) //If there's no power, we shouldnt have a radar whuum noise should we?
		soundloop?.stop()
	else
		soundloop?.start()

/obj/machinery/computer/ship/dradis/set_position() //This tells our overmap what kind of console we are. This is useful as pilots need to see the dradis pop-up as they enter the ship view.
	linked.dradis = src

/obj/machinery/computer/ship/dradis/Initialize()
	. = ..()
	soundloop = new(list(src), FALSE)
	if(start_with_sound)
		soundloop?.start()

/obj/machinery/computer/ship/dradis/attack_hand(mob/user)
	. = ..()
	ui_interact(user)

/obj/machinery/computer/ship/dradis/can_interact(mob/user) //Override this code to allow people to use consoles when flying the ship.
	if(locate(user) in linked?.operators)
		return TRUE
	if(!user.can_interact_with(src)) //Theyre too far away and not flying the ship
		return FALSE
	if((interaction_flags_atom & INTERACT_ATOM_REQUIRES_DEXTERITY) && !user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_IGNORE_INCAPACITATED) && user.incapacitated((interaction_flags_atom & INTERACT_ATOM_IGNORE_RESTRAINED), !(interaction_flags_atom & INTERACT_ATOM_CHECK_GRAB)))
		return FALSE
	return TRUE

/obj/machinery/computer/ship/dradis/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	if(!has_overmap())
		return
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/dradis)
		assets.send(user)
		ui = new(user, src, ui_key, "dradis", name, 560, 600, master_ui, state)
		ui.set_style("dradis")
		ui.open()

/obj/machinery/computer/ship/dradis/attackby(obj/item/I, mob/user) //Allows you to upgrade dradis consoles to show asteroids, as well as revealing more valuable ones.
	. = ..()
	if(istype(I, /obj/item/mining_sensor_upgrade))
		if(!show_asteroids)
			show_asteroids = TRUE
		var/obj/item/mining_sensor_upgrade/MS = I
		if(MS.tier > mining_sensor_tier)
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
			to_chat(user, "<span class='notice'>You slot [I] into [src], allowing it to detect a wider variety of asteroids.</span>")
			mining_sensor_tier = MS.tier
			qdel(MS)
		else
			to_chat(user, "<span class='notice'>[src] has already been upgraded to a higher tier than [MS].</span>")

/obj/machinery/computer/ship/dradis/ui_data(mob/user) //NEW AND IMPROVED DRADIS 2.0. NOW FEATURING LESS LAG AND CLICKSPAM. This was a pain to code. Don't make me do it again..please? -Kmc
	if(last_scanning_speed != scanning_speed) //Make the scanner go at a speed that you want.
		soundloop.stop()
		soundloop.mid_length = scanning_speed SECONDS //Allow for faster sweeps
		last_scanning_speed = scanning_speed
		for(var/datum/X in soundloop.active_timers)
			qdel(X)
		soundloop.start()
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/dradis) //They need these in order to see the images
	assets.send(user)
	var/list/data = list()
	var/blips[0] //2-d array declaration
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects) //Iterate through overmaps in the world!
		if(OM.z == linked.z)
			var/thecolour = "#FFFFFF"
			if(OM == linked)
				thecolour = "#00FFFF"
			else if(OM.faction == linked.faction)
				thecolour = "#32CD32"
			else
				thecolour = "#FF0000"
			var/OMx = OM.x/6 //We're now going to scale down the X,Y coords into something we can display
			var/OMy = OM.y/6 //THESE NUMBERS ARE BASED ON TRIAL AND ERROR. DON'T ARGUE WITH ME JUST DEAL WITH IT
			if(OMx < 5) //This chain of IFs stops the dots from going off the screen. Simple as.
				OMx = 5
			if(OMx > 235)
				OMx = 235
			if(OMy < 5)
				OMy = 5
			if(OMy > 39)
				OMy = 39
			blips.Add(list(list("x" = OMx, "y" = OMy, "colour" = thecolour))) //So now make a 2-d array that TGUI can iterate through. This is just a list within a list.
	if(show_asteroids)
		for(var/obj/structure/asteroid/AS in GLOB.overmap_asteroids)
			if(AS.z == linked.z && AS.required_tier <= mining_sensor_tier)
				var/thecolor = "#80523c"
				switch(AS.required_tier) //Better asteroids show up in different colours
					if(2)
						thecolor = "#ffcc00"
					if(3)
						thecolor = "#cc66ff"
				var/OMx = AS.x/6 //We're now going to scale down the X,Y coords into something we can display
				var/OMy = AS.y/6 //THESE NUMBERS ARE BASED ON TRIAL AND ERROR. DON'T ARGUE WITH ME JUST DEAL WITH IT
				if(OMx < 5) //This chain of IFs stops the dots from going off the screen. Simple as.
					OMx = 5
				if(OMx > 235)
					OMx = 235
				if(OMy < 5)
					OMy = 5
				if(OMy > 39)
					OMy = 39
				blips.Add(list(list("x" = OMx, "y" = OMy, "colour" = thecolor))) //So now make a 2-d array that TGUI can iterate through. This is just a list within a list.
	data["ships"] = blips //Create a category in data called "ships" with our 2-d arrays.
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

/obj/structure/overmap/proc/show_flight_ui()
	return //Ignore this shit for now
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
      top: 400;\
      left: 400;\
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