#define MIN_RADAR_DELAY 5 SECONDS
#define MAX_RADAR_DELAY 60 SECONDS
#define RADAR_VISIBILITY_PENALTY 5 SECONDS
#define SENSOR_MODE_PASSIVE 1
#define SENSOR_MODE_RADAR 2

/obj/machinery/computer/ship/dradis
	name = "\improper DRADIS computer"
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
	var/sensor_range = 0 //Automatically set to equal base sensor range on init.
	var/base_sensor_range = SENSOR_RANGE_DEFAULT //In tiles. How far your sensors can pick up precise info about ships.
	var/zoom_factor = 0.5 //Lets you zoom in / out on the DRADIS for more precision, or for better info.
	var/next_hail = 0
	var/hail_range = 50 //Decent distance.
	//For traders. Lets you link supply pod beacons to designate where traders land.
	var/usingBeacon = FALSE //Var copied from express consoles so this doesn't break. I love abusing inheritance ;)
	var/obj/item/supplypod_beacon/beacon
	var/sensor_mode = SENSOR_MODE_PASSIVE
	var/radar_delay = MIN_RADAR_DELAY

/obj/machinery/computer/ship/dradis/proc/can_radar_pulse()
	var/obj/structure/overmap/OM = get_overmap()
	var/next_pulse = OM.last_radar_pulse + radar_delay
	if(world.time >= next_pulse)
		return TRUE

/obj/machinery/computer/ship/dradis/internal/can_radar_pulse()
	return FALSE

/obj/machinery/computer/ship/dradis/internal/awacs/can_radar_pulse()
	var/obj/structure/overmap/OM = loc
	if(!OM)
		return
	var/next_pulse = OM.last_radar_pulse + radar_delay
	if(world.time >= next_pulse)
		return TRUE
f
/obj/machinery/computer/ship/dradis/minor/can_radar_pulse()
	return FALSE


/*
Adds a penalty to from how far away you can be detected.
This is completely independant from normal tracking, you get detected either if you are within their sensor range, or if your sensor profile is big enough to be detected by them
args:
penalty: The amount of additional sensor profile
remove_in: Optional arg, if > 0: Will remove the effect in that amount of ticks
*/
/obj/structure/overmap/proc/add_sensor_profile_penalty(penalty, remove_in = -1)
	sensor_profile += penalty
	if(remove_in < 1)
		return
	addtimer(CALLBACK(src, .proc/remove_sensor_profile_penalty, penalty), remove_in)

/*
Reduces sensor profile by the amount given as arg.
Called by add_sensor_profile_penalty if remove_in is used.
*/
/obj/structure/overmap/proc/remove_sensor_profile_penalty(amount)
	sensor_profile -= amount

/obj/structure/overmap/proc/send_radar_pulse()
	var/next_pulse = last_radar_pulse + RADAR_VISIBILITY_PENALTY
	if(world.time < next_pulse)
		return FALSE
	relay('nsv13/sound/effects/ship/sensor_pulse_send.ogg')
	relay_to_nearby('nsv13/sound/effects/ship/sensor_pulse_hit.ogg', ignore_self=TRUE, sound_range=255, faction_check=TRUE)
	last_radar_pulse = world.time
	addtimer(VARSET_CALLBACK(src, max_tracking_range, max_tracking_range), RADAR_VISIBILITY_PENALTY)
	max_tracking_range *= 2
	add_sensor_profile_penalty(max_tracking_range, RADAR_VISIBILITY_PENALTY)

/obj/machinery/computer/ship/dradis/proc/send_radar_pulse()
	var/obj/structure/overmap/OM = get_overmap()
	if(!can_radar_pulse())
		return FALSE
	OM?.send_radar_pulse()
	addtimer(VARSET_CALLBACK(src, sensor_range, base_sensor_range), RADAR_VISIBILITY_PENALTY)
	sensor_range = world.maxx
	OM?.add_sensor_profile_penalty(sensor_range, RADAR_VISIBILITY_PENALTY)

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
	name = "\improper Air traffic control console"

/obj/machinery/computer/ship/dradis/mining
	name = "mining DRADIS computer"
	desc = "A modified dradis console which links to the mining ship's mineral scanners, able to pick up asteroids that can be mined."
	req_one_access_txt = "31;48"
	circuit = /obj/item/circuitboard/computer/ship/dradis/mining
	show_asteroids = TRUE

/obj/machinery/computer/ship/dradis/internal
	name = "integrated dradis console"
	use_power = 0
	start_with_sound = FALSE
	base_sensor_range = SENSOR_RANGE_FIGHTER
	hail_range = 30

/obj/machinery/computer/ship/dradis/internal/has_overmap()
	return linked

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
	sensor_range = base_sensor_range

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

/obj/machinery/computer/ship/dradis/ui_state(mob/user)
	return  GLOB.always_state


/obj/machinery/computer/ship/dradis/ui_interact(mob/user, datum/tgui/ui)
	if(!has_overmap())
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Dradis")
		ui.open()

/obj/machinery/computer/ship/dradis/ui_act(action, params, datum/tgui/ui, mob/user)
	. = ..()
	if(isobserver(user))
		return
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
		if("radar_pulse")
			send_radar_pulse()
		if("sensor_mode")
			sensor_mode = (sensor_mode == SENSOR_MODE_PASSIVE) ? SENSOR_MODE_RADAR : SENSOR_MODE_PASSIVE
		if("radar_delay")
			var/newDelay = input(usr, "Set a new radar delay (seconds)", "Radar Delay", null) as num|null
			if(!newDelay)
				return
			newDelay = newDelay SECONDS
			newDelay = CLAMP(newDelay, MIN_RADAR_DELAY, MAX_RADAR_DELAY)
			radar_delay = newDelay

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
	//If we fired off a radar, we're visible to _every ship_
	if(last_radar_pulse+RADAR_VISIBILITY_PENALTY > world.time)
		return SENSOR_VISIBILITY_FULL
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
			while(alpha > cloak_factor)
				stoplag()
				alpha -= 5
			mouse_opacity = FALSE
			return
		if(FALSE)
			while(alpha < 255)
				stoplag()
				alpha += 5
			mouse_opacity = TRUE
			return
		if(CLOAK_TEMPORARY_LOSS) //Flicker the cloak so that you can fire.
			if(alpha >= 255) //No need to re-cloak us if we were never cloaked...
				return
			while(alpha < 255)
				stoplag()
				alpha += 15
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
		var/sensor_visible = (OM != linked && OM.faction != linked.faction) ? ((get_dist(linked, OM) > max(sensor_range * 2, OM.sensor_profile)) ? 0 : OM.is_sensor_visible(linked)) : SENSOR_VISIBILITY_FULL //You can always see your own ship, or allied, cloaked ships.
		if(OM.z == linked.z && sensor_visible >= SENSOR_VISIBILITY_FAINT)
			var/inRange = (get_dist(linked, OM) <= max(sensor_range,OM.sensor_profile)) || OM.faction == linked.faction	//Allies broadcast encrypted IFF so we can see them anywhere.
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
	data["can_radar_pulse"] = can_radar_pulse()
	data["sensor_mode"] = (sensor_mode == SENSOR_MODE_PASSIVE) ? "Passive Radar" : "Active Radar"
	data["pulse_delay"] = "[radar_delay / 10]"
	if(sensor_mode == SENSOR_MODE_RADAR)
		send_radar_pulse()
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
