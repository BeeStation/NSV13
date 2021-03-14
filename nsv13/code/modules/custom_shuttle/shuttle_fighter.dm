/obj/structure/overmap/fighter/custom_shuttle
	name = "Shuttle"
	desc = "A revolutionary shuttle, capable of moving around a bit. Basically what happens when we use 100% of our brain capacity."
	sprite_size = 32
	//Invisible, sprite is handled when we make it
	icon = 'icons/effects/effects.dmi'
	//Default components
	components = list(/obj/item/fighter_component/fuel_tank,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/countermeasure_dispenser,
						/obj/item/fighter_component/secondary/ordnance_launcher,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/primary/cannon)
	//We DO NOT want damage states
	damage_states = FALSE
	var/turf/entry_point

/obj/structure/overmap/fighter/custom_shuttle/Bumped(atom/movable/A)
	. = ..()
	enter_shuttle(A)

/obj/structure/overmap/fighter/custom_shuttle/stop_piloting(mob/living/M, force)
	. = ..()
	if(.)
		enter_shuttle(M)

//Enters the physical shuttle
/obj/structure/overmap/fighter/custom_shuttle/proc/enter_shuttle(atom/movable/A)
	//Fighters cannot enter the fighter
	if(istype(A, /obj/structure/overmap/fighter))
		return
	//Teleport to the shuttle
	A.forceMove(entry_point)

/*
 * Pretty based proc.
 * Links the overmap icon to a shuttle and causes the shuttle texture to assume the icon.
 */
/obj/structure/overmap/fighter/custom_shuttle/proc/link_to_shuttle(shuttle_id)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttle_id)
	if(!M)
		stack_trace("Error: Failed to locate shuttle id [shuttle_id]")
		return
	vis_contents.Cut()
	//Get the corners of the shuttle
	var/list/L = M.return_coords()
	var/min_x = min(L[1], L[3])
	var/min_y = min(L[2], L[4])
	var/max_x = max(L[1], L[3])
	var/max_y = max(L[2], L[4])
	link_to_turfs(min_x, min_y, max_x, max_y, M.return_turfs())

/*
 * Pretty based proc.
 * Links the overmap icon to a list of turfs. Requires the corner positions first.
 */
/obj/structure/overmap/fighter/custom_shuttle/proc/link_to_turfs(min_x, min_y, max_x, max_y, list/turfs)
	var/center_x = FLOOR((min_x + max_x) * 0.5, 1)
	var/center_y = FLOOR((min_y + max_y) * 0.5, 1)
	var/obj/effect/shuttle_fighter_contents_holder/content_holder_holder = new(src, src)
	for(var/turf/T in turfs)
		var/offset_x = T.x - center_x
		var/offset_y = T.y - center_y
		var/obj/effect/shuttle_fighter_contents_holder/content_holder = new(content_holder_holder, src)
		content_holder.vis_contents += T
		content_holder.pixel_x = offset_x * 32
		content_holder.pixel_y = offset_y * 32
		content_holder_holder.vis_contents += content_holder
	vis_contents += content_holder_holder
	//Lets scale it to be somewhat acceptable
	var/width = max_x - min_x
	var/height = max_y - min_y
	var/bigger_length = max(width, height)
	//Update sprite size to have a bounding box
	//The shuttle sprite is half the size of the shuttle before.
	sprite_size = bigger_length * 16
	transform = matrix(0.5, 0, 0, 0, 0.5, 0)

//===========
// Contents holder
//===========

/obj/effect/shuttle_fighter_contents_holder
	name = ""
	icon = 'icons/turf/floors.dmi'
	icon_state = "transparent"
	appearance_flags = KEEP_TOGETHER
	var/obj/structure/overmap/fighter/custom_shuttle/parent

/obj/effect/shuttle_fighter_contents_holder/Initialize(_parent)
	. = ..()
	parent = _parent
	//We are basically open space but a bit cooler.
	plane = OPENSPACE_PLANE
	layer = OPENSPACE_LAYER

/obj/effect/shuttle_fighter_contents_holder/MouseDrop_T(mob/living/M, mob/living/user)
	if(parent)
		parent.MouseDrop_T(M, user)
	else
		. = ..()
