//=============
// Overrides shuttle creator to do some WACKY things.
// Basically custom shuttles no longer exist.
// Instead the marked turfs get sent to some reserved place and a fighter is created.
// If you bump the fighter you get teleported to the reserved placed.
// If you use the shuttle flight computer you get put inside the cockpit of the fighter.
// Now with 10% less readability.
//=============

/obj/item/shuttle_creator
	//The actually fighter object
	var/obj/structure/overmap/fighter/custom_shuttle/linked_fighter
	//The output turfs in the reserved land
	var/list/output_turfs

/obj/item/shuttle_creator/afterattack(atom/target, mob/user, proximity_flag)
	if(ready && proximity_flag && istype(target, /obj/machinery/computer/custom_shuttle))
		if(!linked_fighter)
			to_chat(user, "<span class='warning'>Error, no defined fighter linked to device</span>")
			return
		var/obj/machinery/computer/custom_shuttle/console = target
		console.linked_fighter = linked_fighter
		to_chat(user, "<span class='notice'>Console linked successfully.</span>")
		return
	. = ..()

/obj/item/shuttle_creator/shuttle_create_docking_port(atom/target, mob/user)

	if(loggedTurfs.len == 0 || !recorded_shuttle_area)
		to_chat(user, "<span class='warning'>Invalid shuttle (No recorded turfs / No recorded area), restarting bluespace systems...</span>")
		return FALSE

	//Lets just make it at the first turfs location
	var/turf/T = loggedTurfs[1]
	//Calculate width and height of our shuttle bounds
	//Add 1 so we can have a border.
	var/list/all_turfs = loggedTurfs
	//Lets get the boundaries
	var/min_x = INFINITY
	var/min_y = INFINITY
	var/max_x = -INFINITY
	var/max_y = -INFINITY

	//Do the searching. Doesnt matter too much if its a slow loop, this happens once.
	for(var/i in 1 to all_turfs.len)
		var/turf/curT = all_turfs[i]
		min_x = min(min_x, curT.x)
		min_y = min(min_y, curT.y)
		max_x = max(max_x, curT.x)
		max_y = max(max_y, curT.y)

	//Validation
	if(min_x == INFINITY || min_y == INFINITY || max_x == INFINITY || max_y == INFINITY)
		to_chat(user, "<span class='warning'>Invalid shuttle turfs, restarting bluespace systems...</span>")
		return FALSE
	//Get width and height
	var/width = max_x - min_x
	var/height = max_y - min_y

	//Reserve an area
	var/datum/turf_reservation/storageReservation = SSmapping.RequestBlockReservation(width + 4, height + 4)
	if(!storageReservation)
		to_chat(user, "<span class='warning'>Failed to reserve turfs.</span>")
		return FALSE

	//Offset by 2 to have a border (There has to be a way to leave.)
	var/reservation_x = storageReservation.bottom_left_coords[1] + 2
	var/reservation_y = storageReservation.bottom_left_coords[2] + 2
	var/reservation_z = storageReservation.bottom_left_coords[3]

	//Reuse these
	var/min_x_new = INFINITY
	var/min_y_new = INFINITY
	var/max_x_new = -INFINITY
	var/max_y_new = -INFINITY

	//Create the fighter
	//Instantiate in nullspace and force move later
	linked_fighter = new(null)
	//Firstly set up our area, create the containment turfs and set the back turfs
	for(var/turf/reserved_turf in block(locate(storageReservation.bottom_left_coords[1], storageReservation.bottom_left_coords[2], reservation_z), locate(storageReservation.top_right_coords[1], storageReservation.top_right_coords[2], reservation_z)))
		//Its a border turf.
		if(reserved_turf.x == storageReservation.bottom_left_coords[1] || reserved_turf.x == storageReservation.top_right_coords[1] || reserved_turf.y == storageReservation.bottom_left_coords[2] || reserved_turf.y == storageReservation.top_right_coords[2])
			reserved_turf.ChangeTurf(/turf/closed/indestructible/shuttle_border)
		else
			var/turf/open/indestructible/shuttle_bottom_place/new_turf = reserved_turf.ChangeTurf(/turf/open/indestructible/shuttle_bottom_place)
			new_turf.linked_shuttle = linked_fighter

	//Lets copy all the turfs to the reserved space.
	output_turfs = list()
	for(var/i in 1 to all_turfs.len)
		var/turf/curT = all_turfs[i]
		var/offset_x = curT.x - min_x
		var/offset_y = curT.y - min_y
		var/turf/newT = locate(reservation_x + offset_x, reservation_y + offset_y, reservation_z)
		//Copy the turf
		newT.CopyOnTop(curT)
		//Copy contents
		for(var/atom/movable/AM in curT.contents)
			AM.forceMove(newT)
		//Delete old turf
		curT.empty()
		//Log new turfs
		output_turfs += newT
		min_x_new = min(min_x_new, newT.x)
		min_y_new = min(min_y_new, newT.y)
		max_x_new = max(max_x_new, newT.x)
		max_y_new = max(max_y_new, newT.y)

	//Set the fighters reserved area
	linked_fighter.storageReservation = storageReservation
	//Move the fighter somewhere decent
	linked_fighter.forceMove(T)
	//Set the fighters sprite
	linked_fighter.link_to_turfs(min_x_new, min_y_new, max_x_new, max_y_new, output_turfs)
	//Enter at the airlock.
	linked_fighter.entry_point = get_turf(target)
	//Error: Just enter randomly
	if(!(linked_fighter.entry_point in output_turfs))
		linked_fighter.entry_point = pick(output_turfs)

	//bayyyysed
	GLOB.custom_shuttle_count ++
	message_admins("[ADMIN_LOOKUPFLW(user)] created a new custom fighter with a [src] at [ADMIN_VERBOSEJMP(user)] ([GLOB.custom_shuttle_count] custom shuttles, limit is [CUSTOM_SHUTTLE_LIMIT])")
	log_game("[key_name(user)] created a new custom fighter with a [src] at [AREACOORD(user)] ([GLOB.custom_shuttle_count] custom shuttles, limit is [CUSTOM_SHUTTLE_LIMIT])")
	return TRUE

/obj/machinery/computer/custom_shuttle
	var/obj/structure/overmap/fighter/custom_shuttle/linked_fighter

/obj/machinery/computer/custom_shuttle/ui_interact(mob/user)
	if(!linked_fighter)
		to_chat(user, "<span class='notice'>Console not linked to fighter.</span>")
		return
	if(linked_fighter.allowed(user))
		if(linked_fighter.pilot)
			to_chat(user, "<span class='notice'>[linked_fighter] already has a pilot.</span>")
			return
		linked_fighter.enter(user)
		linked_fighter.start_piloting(user, "all_positions")
		linked_fighter.ui_interact(user)
