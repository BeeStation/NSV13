/obj/machinery/mineral_magnet
	name = "Asteroid Magnet"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	var/datum/map_template/asteroid/current_asteroid
	var/turf/target_location

/obj/machinery/mineral_magnet/Initialize()
	. = ..()
	target_location = get_turf(GLOB.asteroid_spawn_markers[1])

/obj/machinery/mineral_magnet/attack_hand(mob/user)
	. = ..()
	if(!target_location)
		return
	var/dat
	dat += "<h2>Current asteroid:  </h2>"
	if(!current_asteroid)
		dat += "<A href='?src=\ref[src];pull_asteroid=1'>Pull in asteroid</font></A><BR>" 
	else
		dat += "<A href='?src=\ref[src];push_asteroid=1'>Push away asteroid</font></A><BR>"
	var/datum/browser/popup = new(user, "Pull Asteroids", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/mineral_magnet/Topic(href, href_list)
	if(!in_range(src, usr))
		return

	if(href_list["pull_asteroid"])
		pull_in_asteroid()
	if(href_list["push_asteroid"])
		push_away_asteroid()

	attack_hand(usr) //Refresh window

/obj/machinery/mineral_magnet/proc/pull_in_asteroid()
	current_asteroid = new /datum/map_template/asteroid(pick("_maps/asteroids/asteroid1.dmm")) //Set up an asteroid, can specify a core composition as argument
	current_asteroid.load(target_location, TRUE)
	message_admins("gay")
	//addtimer(CALLBACK(src, .proc/load_asteroid), 20) //2 seconds to fuck off

/obj/machinery/mineral_magnet/proc/load_asteroid()
	current_asteroid.load(target_location, TRUE)
	message_admins("gay2")


/obj/machinery/mineral_magnet/proc/push_away_asteroid()
	for(var/i in current_asteroid.get_affected_turfs()) //nuke
		var/turf/T = i
		for(var/atom/A in T.contents)
			qdel(A)
	QDEL_NULL(current_asteroid)
