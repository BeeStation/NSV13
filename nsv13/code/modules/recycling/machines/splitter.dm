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
	var/obj/effect/decal/cleanable/splitter/new_sp = new /obj/effect/decal/cleanable/splitter(get_turf(src))
	new_sp.parent_item = src
	spawned_splitters += new_sp

/obj/effect/decal/cleanable/splitter
	name = "Splitter"
	desc = "This mark pushes incoming objects equally into two to three directions"
	icon = 'nsv13/icons/effects/splitter_effect.dmi'
	icon_state = "sorter"
	layer = OBJ_LAYER
	plane = GAME_PLANE
	dir = NORTH
	//the direction that the items will be moved to
	var/sorted_direction = NORTH
	//are we moving items in multiple directions?
	var/multi_direction = FALSE
	var/direction_movement = null
	var/obj/item/splitter_placer/parent_item

	light_range = 3
	light_color = COLOR_RED_LIGHT

/obj/effect/decal/cleanable/splitter/Destroy()
	if(parent_item)
		parent_item.spawned_splitters -= src
		parent_item = null
	return ..()

/obj/effect/decal/cleanable/splitter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Slap with an empty hand to change the direction.</span>"
	. += "<span class='notice'>Alt-Click to remove.</span>"

/obj/effect/decal/cleanable/splitter/proc/input_choice(mob/living/user)
	var/input_choice = tgui_input_list(user, "Choose which direction to insert from", "Input choices", list(
		"North",
		"South",
		"West",
		"East"
	))
	var/output = output_choice(input_choice, user)
	return output

/obj/effect/decal/cleanable/splitter/proc/output_choice(intake, mob/living/user)
	var/user_choice = null
	if(intake == "North")
		user_choice = tgui_input_list(user, "Choose which direction or directions to split to", "Direction choices", list(
			"South",
			"SouthWest",
			"SouthEast",
			"SouthEastWest",
			"West",
			"WestEast",
			"East",
		))
		return user_choice
	if(intake == "South")
		user_choice = tgui_input_list(user, "Choose which direction or directions to split to", "Direction choices", list(
			"North",
			"NorthWest",
			"NorthEast",
			"NorthEastWest",
			"West",
			"WestEast",
			"East"
		))
		return user_choice
	if(intake == "West")
		user_choice = tgui_input_list(user, "Choose which direction or directions to split to", "Direction choices", list(
			"North",
			"NorthSouth",
			"NorthEast",
			"NorthEastSouth",
			"East",
			"South",
			"SouthEast"
		))
		return user_choice
	if(intake == "East")
		user_choice = tgui_input_list(user, "Choose which direction or directions to split to", "Direction choices", list(
			"North",
			"NorthSouth",
			"NorthWest",
			"NorthWestSouth",
			"West",
			"South",
			"SouthWest"
		))
		return user_choice

/obj/effect/decal/cleanable/splitter/attack_hand(mob/living/user)
	var/option = input_choice(user)

	if(!option)
		return ..()
	switch(option) //ABANDON ALL FUCKING HOPE FOR A SENSIBLE WAY OF DIRECTION
		if("North")
			sorted_direction = NORTH
			dir = NORTH
		if("NorthSouth")
			sorted_direction = "NorthSouth"
			multi_direction = TRUE
		if("NorthEast")
			sorted_direction = NORTHEAST
			multi_direction = TRUE
		if("NorthWest")
			sorted_direction = NORTHWEST
			multi_direction = TRUE
		if("NorthEastWest")
			sorted_direction = "NorthEastWest"
			multi_direction = TRUE
		if("NorthEastSouth")
			sorted_direction = "NorthEastSouth"
			multi_direction = TRUE
		if("NorthWestSouth")
			sorted_direction = "NorthWestSouth"
			multi_direction = TRUE
		if("South")
			sorted_direction = SOUTH
			dir = SOUTH
		if("SouthWest")
			sorted_direction = SOUTHWEST
			multi_direction = TRUE
		if("SouthEast")
			sorted_direction = SOUTHEAST
			multi_direction = TRUE
		if("SouthEastWest")
			sorted_direction = "SouthEastWest"
			multi_direction = TRUE
		if("West")
			sorted_direction = WEST
		if("WestEast")
			sorted_direction = "WestEast"
			multi_direction = TRUE
		if("East")
			sorted_direction = EAST
			dir = EAST
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)

/obj/effect/decal/cleanable/splitter/AltClick(mob/user)
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	qdel(src)

/obj/effect/decal/cleanable/splitter/on_entered(datum/source, atom/movable/AM)
	. = ..()
	if(multi_direction)
		if(sorted_direction == "NorthSouth")
			if(direction_movement == NORTH)
				AM.Move(get_step(src, direction_movement))
				direction_movement = SOUTH
				dir = SOUTH
			else if(direction_movement == SOUTH)
				AM.Move(get_step(src, direction_movement))
				direction_movement = NORTH
				dir = NORTH
			else
				AM.Move(get_step(src, NORTH))
				direction_movement = SOUTH
				dir = SOUTH

		if(sorted_direction == NORTHEAST)
			if(direction_movement == NORTH)
				AM.Move(get_step(src, direction_movement))
				direction_movement = EAST
				dir = EAST
			else if(direction_movement == EAST)
				AM.Move(get_step(src, direction_movement))
				direction_movement = NORTH
				dir = NORTH
			else
				AM.Move(get_step(src, NORTH))
				direction_movement = EAST
				dir = EAST

		if(sorted_direction == NORTHWEST)
			if(direction_movement == NORTH)
				AM.Move(get_step(src, direction_movement))
				direction_movement = WEST
				dir = WEST
			else if(direction_movement == WEST)
				AM.Move(get_step(src, direction_movement))
				direction_movement = NORTH
				dir = NORTH
			else
				AM.Move(get_step(src, NORTH))
				direction_movement = WEST
				dir = WEST

		if(sorted_direction == "NorthEastWest")
			if(direction_movement == NORTH)
				AM.Move(get_step(src, direction_movement))
				direction_movement = EAST
				dir = EAST
			else if(direction_movement == EAST)
				AM.Move(get_step(src, direction_movement))
				direction_movement = WEST
				dir = WEST
			else if(direction_movement == WEST)
				AM.Move(get_step(src, direction_movement))
				direction_movement = NORTH
				dir = NORTH
			else
				AM.Move(get_step(src, NORTH))
				direction_movement = EAST
				dir = EAST

		if(sorted_direction == "NorthEastSouth")
			if(direction_movement == NORTH)
				AM.Move(get_step(src, direction_movement))
				direction_movement = SOUTH
				dir = SOUTH
			else if(direction_movement == SOUTH)
				AM.Move(get_step(src, direction_movement))
				direction_movement = EAST
				dir = EAST
			else if(direction_movement == EAST)
				AM.Move(get_step(src, direction_movement))
				direction_movement = NORTH
				dir = NORTH
			else
				AM.Move(get_step(src, NORTH))
				direction_movement = SOUTH
				dir = SOUTH

		if(sorted_direction == "NorthWestSouth")
			if(direction_movement == NORTH)
				AM.Move(get_step(src, direction_movement))
				direction_movement = SOUTH
				dir = SOUTH
			else if(direction_movement == WEST)
				AM.Move(get_step(src, direction_movement))
				direction_movement = NORTH
				dir = NORTH
			else if(direction_movement == SOUTH)
				AM.Move(get_step(src, direction_movement))
				direction_movement = WEST
				dir = WEST
			else
				AM.Move(get_step(src, NORTH))
				direction_movement = WEST
				dir = WEST

		if(sorted_direction == SOUTHWEST)
			if(direction_movement == SOUTH)
				AM.Move(get_step(src, direction_movement))
				direction_movement = WEST
				dir = WEST
			else if(direction_movement == WEST)
				AM.Move(get_step(src, direction_movement))
				direction_movement = SOUTH
				dir = SOUTH
			else
				AM.Move(get_step(src, SOUTH))
				direction_movement = WEST
				dir = WEST

		if(sorted_direction == SOUTHEAST)
			if(direction_movement == SOUTH)
				AM.Move(get_step(src, direction_movement))
				direction_movement = EAST
				dir = EAST
			else if(direction_movement == EAST)
				AM.Move(get_step(src, direction_movement))
				direction_movement = SOUTH
				dir = SOUTH
			else
				AM.Move(get_step(src, SOUTH))
				direction_movement = EAST
				dir = EAST

		if(sorted_direction == "SouthEastWest")
			if(direction_movement == SOUTH)
				AM.Move(get_step(src, direction_movement))
				direction_movement = EAST
				dir = EAST
			else if(direction_movement == EAST)
				AM.Move(get_step(src, direction_movement))
				direction_movement = WEST
				dir = WEST
			else if(direction_movement == WEST)
				AM.Move(get_step(src, direction_movement))
				direction_movement = SOUTH
				dir = SOUTH
			else
				AM.Move(get_step(src, SOUTH))
				direction_movement = EAST
				dir = EAST

		if(sorted_direction == "WestEast")
			if(direction_movement == WEST)
				AM.Move(get_step(src, direction_movement))
				direction_movement = EAST
				dir = EAST
			else if(direction_movement == EAST)
				AM.Move(get_step(src, direction_movement))
				direction_movement = WEST
				dir = WEST
			else
				AM.Move(get_step(src, WEST))
				direction_movement = EAST
				dir = EAST

	else
		AM.Move(get_step(src, sorted_direction))
