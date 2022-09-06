/obj/item/splitter_placer
	name = "splitter placer"
	desc = "A tool that is used to place down splitters."
	icon = 'nsv13/icons/obj/items/splitter_summoner.dmi'
	icon_state = "splitter"
	///the list of splitters spawned by
	var/list/spawned_splitters = list()

/obj/item/splitter_placer/Destroy()
	for(var/deleting_splitter in spawned_splitters)
		qdel(deleting_splitter)
	return ..()

/obj/item/splitter_placer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Use it to place down a splitter, up to three.</span>"

/obj/item/splitter_placer/attack_self(mob/user)
	if(length(spawned_splitters) >= 3)
		to_chat(user, "<span class'warning'>You may only have three spawned splitters!</span>")
		return
	var/obj/effect/decal/splitter/new_sp = new /obj/effect/decal/splitter(get_turf(src))
	new_sp.parent_item = src
	spawned_splitters += new_sp

/obj/effect/decal/splitter
	name = "Splitter"
	desc = "This mark pushes incoming objects equally into two to three directions"
	icon = 'nsv13/icons/effects/splitter_effect.dmi'
	icon_state = "splitter"
	layer = OBJ_LAYER
	plane = GAME_PLANE
	dir = NORTH
	//the direction that the items will be moved to
	var/sorted_direction = NORTH
	//are we moving items in multiple directions?
	var/multi_direction = FALSE
	var/direction_movement = null
	var/obj/item/splitter_placer/parent_item
	var/forbidden_split = null
	var/iteration = 1
	var/list/directions = list(
		"NORTH",
		"SOUTH",
		"WEST",
		"EAST"
	)

	light_range = 3
	light_color = COLOR_RED_LIGHT

/obj/effect/decal/splitter/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/decal/splitter/Destroy()
	if(parent_item)
		parent_item.spawned_splitters -= src
		parent_item = null
	return ..()

/obj/effect/decal/splitter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Slap with an empty hand to change the direction.</span>"
	. += "<span class='notice'>Alt-Click to remove.</span>"

/obj/effect/decal/splitter/attack_hand(mob/living/user)
	directions = list(
		"NORTH",
		"SOUTH",
		"WEST",
		"EAST"
	) //Reset Choices

	var/split = tgui_input_list(user, "Choose how many outputs", "Number of Outputs", list(1, 2, 3))
	var/option = tgui_input_list(user, "Choose which direction to insert from", "Input choices", directions)
	directions -= option
	switch(split)
		if(1)
			multi_direction = FALSE
			var/choice = tgui_input_list(user, "Choose which direction to output to", "Output Choices", directions)
			switch(choice)
				if("NORTH")
					direction_movement = NORTH
				if("SOUTH")
					direction_movement = SOUTH
				if("WEST")
					direction_movement = WEST
				if("EAST")
					direction_movement = EAST
		if(2)
			multi_direction = TRUE
			var/forbid = tgui_input_list(user, "Choose which direction to not output to", "Choices", directions)
			switch(forbid)
				if("NORTH")
					forbidden_split = NORTH
				if("SOUTH")
					forbidden_split = SOUTH
				if("WEST")
					forbidden_split = WEST
				if("EAST")
					forbidden_split = EAST
		if(3)
			multi_direction = TRUE

	if(!option)
		return ..()

	switch(option)
		if("NORTH")
			sorted_direction = NORTH
		if("SOUTH")
			sorted_direction = SOUTH
		if("WEST")
			sorted_direction = WEST
		if("EAST")
			sorted_direction = EAST

	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)

/obj/effect/decal/splitter/AltClick(mob/user)
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	qdel(src)

/obj/effect/decal/splitter/proc/on_entered(datum/source, atom/movable/AM)
	if(multi_direction)
		if(forbidden_split == null)
			if(!(iteration > 3))
				direction_movement = turn(sorted_direction, 90 * iteration)
				if(direction_movement != sorted_direction)
					dir = direction_movement
					AM.Move(get_step(src, direction_movement))
					iteration++
			else
				iteration = 1
				direction_movement = turn(sorted_direction, 90 * iteration)
				dir = direction_movement
				AM.Move(get_step(src, direction_movement))
				iteration++
		else
			if(!(iteration > 3))
				direction_movement = turn(sorted_direction, 90 * iteration)
				if(direction_movement != forbidden_split && direction_movement != sorted_direction)
					dir = direction_movement
					AM.Move(get_step(src, direction_movement))
					iteration++
				else
					iteration++
					direction_movement = turn(sorted_direction, 90 * iteration)
					if(direction_movement == forbidden_split)
						direction_movement = turn(forbidden_split, 90 * iteration)
						dir = direction_movement
						AM.Move(get_step(src, direction_movement))
						iteration++
					else
						dir = direction_movement
						AM.Move(get_step(src, direction_movement))
						iteration++
			else
				iteration = 1
				direction_movement = turn(sorted_direction, 90 * iteration)
				if(direction_movement == forbidden_split)
					direction_movement = turn(forbidden_split, 90 * iteration)
					dir = direction_movement
					AM.Move(get_step(src, direction_movement))
				else
					dir = direction_movement
					AM.Move(get_step(src, direction_movement))
					iteration++
	else
		AM.Move(get_step(src, direction_movement))
