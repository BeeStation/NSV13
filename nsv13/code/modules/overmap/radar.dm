/obj/item/circuitboard/computer/ship/dradis
	name = "circuit board (dradis computer)"
	build_path = /obj/machinery/computer/ship/dradis

/datum/design/board/dradis_circuit
	name = "Computer Design (Dradis Computer)"
	desc = "Allows for the construction of a dradis console."
	id = "dradis_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 500)
	build_path = /obj/item/circuitboard/computer/ship/dradis
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/obj/item/circuitboard/computer/ship/dradis/mining
	name = "circuit board (minig dradis computer)"
	build_path = /obj/machinery/computer/ship/dradis/mining

/datum/design/board/mining_dradis_circuit
	name = "Computer Design (Mining dradis Computer)"
	desc = "Allows for the construction of a dradis console."
	id = "mining_dradis_circuit"
	materials = list(/datum/material/glass = 5000, /datum/material/copper = 1000)
	build_path = /obj/item/circuitboard/computer/ship/dradis/mining
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/obj/machinery/computer/ship/dradis
	name = "DRADIS computer"
	desc = "The DRADIS system is a series of highly sensitive detection, identification, navigation and tracking systems used to determine the range and speed of objects. This forms the most central component of a spaceship's navigational systems, as it can project the whereabouts of enemies that are out of visual sensor range by tracking their engine signatures."
	icon_screen = "teleport"
	req_access = list()
	circuit = /obj/item/circuitboard/computer/ship/dradis
	var/stored = "blank"
	var/on = TRUE //Starts on by default.
	var/scanning_speed = 2 //Duration of each pulse.
	var/last_scanning_speed = 2 //To update the sound loop
	var/start_with_sound = FALSE //Used to stop fighters playing dradis sounds all at once and being annoying.
	var/show_asteroids = FALSE //Used so that mining can track what they're supposed to be drilling.
	var/mining_sensor_tier = 1
	var/last_ship_count = 0 //Plays a tone when ship count changes
	//Alpha sliders to let you filter out info you don't want to see.
	var/showFriendlies = 100
	var/showEnemies= 100
	var/showAsteroids = 100 //add planets to this eventually.
	var/showAnomalies = 100
	var/sensor_range = SENSOR_RANGE_DEFAULT //In tiles. How far your sensors can pick up precise info about ships.
	var/zoom_factor = 0.5 //Lets you zoom in / out on the DRADIS for more precision, or for better info.
	var/next_hail = 0
	var/hail_range = 50 //Decent distance.
	//For traders. Lets you link supply pod beacons to designate where traders land.
	var/usingBeacon = FALSE //Var copied from express consoles so this doesn't break. I love abusing inheritance ;)
	var/obj/item/supplypod_beacon/beacon

/obj/machinery/computer/ship/dradis/examine(mob/user)
	. = ..()
	. += "<span class='sciradio'>You can link supplypod beacons to it to tell traders where to deliver your goods! Hit it with a multitool to swap between delivery locations.</span>"
	if(beacon)
		. += "<span class='sciradio'>It's currently linked to [beacon] in [get_area(beacon)]. You can use a multitool to switch whether it delivers here, or to your cargo bay.</span>"

/obj/machinery/computer/ship/dradis/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/supplypod_beacon))
		var/obj/item/supplypod_beacon/sb = W
		if(linked?.dradis != src)
			to_chat(user, "<span class='warning'>Supplypod beacons can only be linked to the primary DRADIS of a ship (try the one in CIC?).")
			return FALSE
		if (sb.express_console != src)
			sb.link_console(src, user)
			return TRUE
		else
			to_chat(user, "<span class='notice'>[src] is already linked to [sb].</span>")
	..()

/obj/machinery/computer/ship/dradis/multitool_act(mob/living/user, obj/item/I)
	usingBeacon = !usingBeacon
	to_chat(user, "<span class='sciradio'>You switch [src]'s trader delivery location to [usingBeacon ? "target supply beacons" : "target the default landing location on your ship"]")
	return FALSE

/obj/machinery/computer/ship/dradis/minor //Secondary dradis consoles usable by people who arent on the bridge.
	name = "Air traffic control console"

/obj/machinery/computer/ship/dradis/mining
	name = "Mining DRADIS computer"
	desc = "A modified dradis console which links to the mining ship's mineral scanners, able to pick up asteroids that can be mined."
	req_one_access_txt = "31;48"
	circuit = /obj/item/circuitboard/computer/ship/dradis/mining
	show_asteroids = TRUE

/obj/machinery/computer/ship/dradis/internal
	name = "Integrated dradis console"
	use_power = 0
	start_with_sound = FALSE
	sensor_range = SENSOR_RANGE_FIGHTER
	hail_range = 30

/obj/machinery/computer/ship/dradis/internal/has_overmap()
	if(linked)
		return TRUE
	return FALSE

/obj/machinery/computer/ship/dradis/minor/set_position(obj/structure/overmap/OM)
	RegisterSignal(OM, COMSIG_FTL_STATE_CHANGE, .proc/reset_dradis_contacts, override=TRUE)
	return

/datum/looping_sound/dradis
	mid_sounds = list('nsv13/sound/effects/ship/dradis.ogg')
	mid_length = 2 SECONDS
	volume = 60

/obj/machinery/computer/ship/dradis/power_change()
	..()

/obj/machinery/computer/ship/dradis/set_position(obj/structure/overmap/OM) //This tells our overmap what kind of console we are. This is useful as pilots need to see the dradis pop-up as they enter the ship view.
	OM.dradis = src
	RegisterSignal(OM, COMSIG_FTL_STATE_CHANGE, .proc/reset_dradis_contacts, override=TRUE)

/obj/machinery/computer/ship/dradis/proc/reset_dradis_contacts()
	last_ship_count = 0

/obj/machinery/computer/ship/dradis/Initialize()
	. = ..()

/obj/machinery/computer/ship/dradis/attack_hand(mob/user)
	. = ..()
	if(.)
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

/obj/machinery/computer/ship/dradis/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	if(!has_overmap())
		return
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Dradis", name, 700, 750, master_ui, state)
		ui.open()

/obj/machinery/computer/ship/dradis/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!has_overmap())
		return
	var/alphaSlide = text2num(params["alpha"])
	alphaSlide = CLAMP(alphaSlide, 0, 100) //Just in case we have a malformed input.
	switch(action)
		if("showFriendlies")
			if(!alphaSlide)
				return
			showFriendlies = alphaSlide
		if("showEnemies")
			if(!alphaSlide)
				return
			showEnemies = alphaSlide
		if("showAsteroids")
			if(!alphaSlide)
				return
			showAsteroids = alphaSlide
		if("showAnomalies")
			if(!alphaSlide)
				return
			showAnomalies = alphaSlide
		if("zoomout")
			zoom_factor -= 0.5
			zoom_factor = (zoom_factor >= 0.5) ? zoom_factor : 0.5
		if("zoomin")
			zoom_factor += 0.5
			zoom_factor = (zoom_factor <= 2) ? zoom_factor : 2
		if("hail")
			var/obj/structure/overmap/target = locate(params["target"])
			if(!target) //Anomalies don't count.
				return
			if(world.time < next_hail)
				return
			if(target == linked)
				return
			next_hail = world.time + 10 SECONDS //I hate that I need to do this, but yeah.
			if(get_dist(target, linked) <= hail_range)
				target.try_hail(usr, linked)

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

//Cloaking and sensors!

/obj/structure/overmap/proc/is_sensor_visible(obj/structure/overmap/observer) //How visible is this enemy ship to sensors? Sometimes ya gotta get real up close n' personal.
	var/dist = get_dist(src, observer)
	if(dist <= 0)
		dist = 1
	var/distance_factor = (1/dist) //Visibility inversely scales with distance. If you get too close to a target, even with a stealth ship, you'll ping their sensors.
	//Convert alpha to an opacity reading.
	switch(alpha)
		if(0 to 50) //Nigh on invisible. You cannot detect ships that are this cloaked by any means.
			return SENSOR_VISIBILITY_GHOST
		if(51 to 100) //Barely visible at all.
			return CLAMP(SENSOR_VISIBILITY_VERYFAINT + distance_factor, SENSOR_VISIBILITY_GHOST, SENSOR_VISIBILITY_FULL)
		if(101 to 250)
			return CLAMP(SENSOR_VISIBILITY_FAINT + distance_factor, SENSOR_VISIBILITY_GHOST, SENSOR_VISIBILITY_FULL)
		if(251 to 255)
			return SENSOR_VISIBILITY_FULL

/obj/structure/overmap
	var/cloak_factor = SENSOR_VISIBILITY_GHOST

/obj/structure/overmap/proc/handle_cloak(state)
	set waitfor = FALSE
	switch(state)
		if(TRUE)
			while(alpha > cloak_factor){
				stoplag()
				alpha -= 5
			}
			mouse_opacity = FALSE
			return
		if(FALSE)
			while(alpha < 255){
				stoplag()
				alpha += 5
			}
			mouse_opacity = TRUE
			return
		if(CLOAK_TEMPORARY_LOSS) //Flicker the cloak so that you can fire.
			if(alpha >= 255) //No need to re-cloak us if we were never cloaked...
				return
			while(alpha < 255){
				stoplag()
				alpha += 15
			}
			mouse_opacity = TRUE
			addtimer(CALLBACK(src, .proc/handle_cloak, TRUE), 15 SECONDS)

/obj/machinery/computer/ship/dradis/ui_data(mob/user) //NEW AND IMPROVED DRADIS 2.0. NOW FEATURING LESS LAG AND CLICKSPAM. ~~This was a pain to code. Don't make me do it again..please? -Kmc~~ 2020 Kmc here, I recoded it. You're right! It was painful, also your code sucked :)
	var/list/data = list()
	var/list/blips = list() //2-d array declaration
	var/ship_count = 0
	for(var/obj/effect/overmap_anomaly/OA in linked?.current_system?.system_contents)
		if(OA && istype(OA) && OA.z == linked?.z)
			blips.Add(list(list("x" = OA.x, "y" = OA.y, "colour" = "#eb9534", "name" = "[(OA.scanned) ? OA.name : "anomaly"]", opacity=showAnomalies*0.01, alignment = "uncharted")))
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects) //Iterate through overmaps in the world!
		var/sensor_visible = (OM != linked || OM.faction != linked.faction) ? OM.is_sensor_visible(linked) : SENSOR_VISIBILITY_FULL //You can always see your own ship, or allied, cloaked ships.
		if(OM.z == linked.z && sensor_visible >= SENSOR_VISIBILITY_FAINT)
			var/inRange = get_dist(linked, OM) <= sensor_range
			var/thecolour = "#FFFFFF"
			var/filterType = showEnemies
			if(istype(OM, /obj/structure/overmap/asteroid))
				if(!show_asteroids)
					continue
				var/obj/structure/overmap/asteroid/AS = OM
				if(AS.required_tier > mining_sensor_tier)
					continue
				thecolour = "#80523c"
				switch(AS.required_tier) //Better asteroids show up in different colours
					if(2)
						thecolour = "#ffcc00"
					if(3)
						thecolour = "#cc66ff"
				filterType = showAsteroids
			else
				if(OM == linked)
					thecolour = "#00FFFF"
					filterType = 100 //No hiding yourself kid.
				else if(OM.faction == linked.faction)
					thecolour = "#32CD32"
					filterType = showFriendlies
				else
					thecolour = "#FF0000"
					filterType = showEnemies
					ship_count ++
			var/thename = (inRange) ? OM.name : "UNKNOWN"
			var/thefaction = ((OM.faction == "nanotrasen" || OM.faction == "syndicate") && inRange) ? OM.faction : "unaligned" //You runnin with the blues or reds? Obfuscate faction too :)
			thecolour = (inRange) ? thecolour : "#a66300"
			filterType = (inRange) ? filterType : 100 //Can't hide things that you don't have sensor resolution on, this is to stop you being able to say, turn off enemy vision, see a target outside of scanner range go dark, and then go HMM.
			if(sensor_visible <= SENSOR_VISIBILITY_FAINT) //For "transparent" / Somewhat hidden ships, show a reduced sensor ping.
				filterType = sensor_visible //Sensor_visible already returns a CSS compliant opacity figure.
			else
				filterType *= 0.01 //Scale the number down to be an opacity figure for CSS
			filterType = CLAMP(filterType, 0, 1)
			blips[++blips.len] = list("x" = OM.x, "y" = OM.y, "colour" = thecolour, "name"=thename, opacity=filterType ,alignment = thefaction, "id"="\ref[OM]") //So now make a 2-d array that TGUI can iterate through. This is just a list within a list.
	if(ship_count > last_ship_count) //Play a tone if ship count changes
		var/delta = ship_count - last_ship_count
		last_ship_count = ship_count
		visible_message("<span class='warning'>[icon2html(src, viewers(src))] [delta <= 1 ? "DRADIS contact" : "Multiple DRADIS contacts"]</span>")
		playsound(src, 'nsv13/sound/effects/ship/contact.ogg', 100, FALSE)
	data["zoom_factor"] = zoom_factor
	data["focus_x"] = linked.x
	data["focus_y"] = linked.y
	data["ships"] = blips //Create a category in data called "ships" with our 2-d arrays.
	data["showFriendlies"] = showFriendlies
	data["showEnemies"] = showEnemies
	data["showAsteroids"] = showAsteroids //add planets to this eventually.
	data["showAnomalies"] = showAnomalies
	data["sensor_range"] = sensor_range
	data["width_mod"] = sensor_range / SENSOR_RANGE_DEFAULT
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
