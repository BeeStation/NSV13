
PROCESSING_SUBSYSTEM_DEF(physics_processing)
	name = "Physics"
	wait = 1.5
	priority = FIRE_PRIORITY_PHYSICS
	stat_tag = "PHYS"
	var/list/physics_levels = list() // key = (string) z_level, value = list()
	var/datum/collision_response/c_response = new /datum/collision_response()
	var/list/quadtrees = list() // key = (string) z_level, value = root quadtree

/datum/controller/subsystem/processing/physics_processing/proc/AddToLevel(datum/component/physics2d/newP, target_z)
	var/z_str = "[target_z]"
	if(!physics_levels[z_str])
		quadtrees[z_str] = new /datum/quadtree(null, 0, GLOB.max_pixel_x / 2, GLOB.max_pixel_y / 2, GLOB.max_pixel_x, GLOB.max_pixel_y)
	physics_levels[z_str] += newP
	var/datum/quadtree/Q = quadtrees[z_str]
	return Q.Add(newP.collider2d)

/datum/controller/subsystem/processing/physics_processing/proc/RemoveFromLevel(datum/component/physics2d/P, target_z)
	if(target_z)
		var/z_str = "[target_z]"
		var/list/za_warudo = physics_levels[z_str]
		za_warudo -= P
		if(!length(za_warudo))
			qdel(quadtrees[z_str])
			quadtrees[z_str] = null


/datum/controller/subsystem/processing/physics_processing/fire(resumed)
	. = ..()
	var/list/nearby
	var/list/za_warudo
	for(var/z_key in physics_levels)
		za_warudo = physics_levels[z_key]
		var/datum/quadtree/quad = quadtrees[z_key]
		for(var/datum/component/physics2d/body as() in za_warudo)
			//Precondition: They're actually somewhat near each other. This is a nice and simple way to cull collisions that would never happen, and save some CPU time.
			nearby = quad.get_nearby_objects(body.collider2d) - src
			for(var/datum/component/physics2d/neighbour as() in nearby)
				if(!isovermap(body.holder))
					if(!body.holder.physics_collide(neighbour.holder))
						continue //Bullets don't want to "bump" into each other, we actually handle that code in "crossed()"
					if(body.collider2d.collides(neighbour.collider2d))
						body.holder.Bump(neighbour.holder)
				//OK, now we get into the expensive calculation. This is our absolute last resort because it's REALLY expensive.
				else if(isovermap(neighbour.holder) && body.collider2d.collides(neighbour.collider2d, c_response)) // Dirty, but necessary. I want to minimize in-depth collision calc wherever I possibly can, so only overmap prototypes use it.
					body.holder.Bump(neighbour.holder, c_response) //More in depth calculation required, so pass this information on.


/datum/component/physics2d
	var/atom/movable/holder = null
	var/datum/shape/collider2d = null //Our box collider. See the collision module for explanation
	var/datum/quadtree/tree = null // What tree we're in, changes with z
	var/datum/quadtree/last_node = null // The last quadtree node we were at.
	var/datum/vector2d/position = null //Positional vector, used exclusively for collisions with overmaps
	var/last_registered_z = 0
	var/static_collider = FALSE // does this object move?

	var/poscache // lightweight position cache. Format is pixel_x * max_pixel_x + pixel_y

/datum/component/physics2d/Initialize(IsStatic = FALSE)
	. = ..()
	holder = parent
	if(!istype(holder))
		return COMPONENT_INCOMPATIBLE //Precondition: This is a subtype of atom/movable.
	last_registered_z = holder.z
	static_collider = IsStatic
	RegisterSignal(holder, COMSIG_MOVABLE_Z_CHANGED, .proc/update_z)

/datum/component/physics2d/Destroy(force, silent)
	last_node.FastRemove(collider2d)
	//Stop fucking referencing this I sweAR
	if(holder)
		UnregisterSignal(holder, COMSIG_MOVABLE_Z_CHANGED)
		// TODO: remove physics2d component references in definitions.	This is very silly, the whole point of components is that datums don't have to actively reference them like this >:(
		var/obj/structure/overmap/OM = holder
		if(istype(OM))
			OM.physics2d = null
		var/obj/item/projectile/P = holder
		if(istype(P))
			P.physics2d = null
	if(last_registered_z)
		SSphysics_processing.physics_levels["[last_registered_z]"] -= src
	else
		for(var/z_key in SSphysics_processing.physics_levels)
			SSphysics_processing.physics_levels[z_key] -= src
	//De-alloc references.
	QDEL_NULL(collider2d)
	QDEL_NULL(position)
	return ..()

/datum/component/physics2d/proc/setup(list/hitbox, angle)
	position = new /datum/vector2d(holder.x*32,holder.y*32)
	collider2d = new /datum/shape(position, hitbox, angle) // -TORADIANS(src.angle-90)
	last_registered_z = holder.z
	poscache = position.x * GLOB.max_pixel_x + position.y
	SSphysics_processing.AddToLevel(src, last_registered_z)

/// Uses pixel coordinates
/datum/component/physics2d/proc/update(x, y, angle)
	collider2d.set_angle(angle) //Turn the box collider
	collider2d._set(x, y)
	if(static_collider)
		return
	var/NP = x * GLOB.max_pixel_x + y
	if(poscache != NP)
		last_node = last_node.Walk(collider2d)
		poscache = NP

/datum/component/physics2d/proc/update_z()
	if(holder.z != last_registered_z) //Z changed? Update this unit's processing chunk.
		if(!holder.z) // Something terrible has happened. Kill ourselves to prevent runtime spam
			qdel(src)
			message_admins("WARNING: [holder] has been moved out of bounds at [ADMIN_VERBOSEJMP(holder.loc)]. Deleting physics component.")
			CRASH("Physics component holder located in nullspace.")
		SSphysics_processing.RemoveFromLevel(src, last_registered_z)
		last_registered_z = holder.z
		SSphysics_processing.AddToLevel(src, last_registered_z)


// While I'd love to make a perfect QuadTree data structure with trunk index list, leaf datums, element nodes and all that juicy low level stuff;
// I'm fairly confident that those further optimizations would end up making things *slower* due to BYOND's slow ass backend.
// But if you're daring (and willing to benchmark the performance gain), feel free to try!

#define TOPLEFT_QUADRANT 1
#define TOPRIGHT_QUADRANT 2
#define BOTTOMLEFT_QUADRANT 3
#define BOTTOMRIGHT_QUADRANT 4
/// Max amount of objects we can have in a quadrant before subdividing
#define MAX_OBJECTS_PER_NODE 15
/// Max recursion depth of subnode creation
#define MAX_DEPTH 4
/// Nodes with subnodes are marked for pruning below this weight
#define PRUNE_WEIGHT 5

/datum/quadtree
	var/datum/quadtree/parent
	var/list/objects = list()
	var/weight = 0 // how many objects are stored within this tree/leaf recursively.
	var/depth = 0
	var/list/subnodes // dynamically initialized because length() is slower than a reference check
	var/datum/vector2d/pos // pixel coordinates
	// pixel rectangle bounds relative to world (AABB).
	var/XMin
	var/XMax
	var/YMin
	var/YMax

/datum/quadtree/New(parent, depth, x, y, Width, Height)
	src.parent = parent // should be null for root
	src.depth = depth
	pos = new(x, y)

	var/W = Width / 2
	XMin = x - W
	XMax = x + W
	var/H = Height / 2
	YMin = y - H
	YMax = y + H

/datum/quadtree/Destroy()
	. = ..()
	if(weight)
		Clear()

/datum/quadtree/proc/Clear()
	objects.len = 0
	weight = 0
	if(!subnodes)
		return
	for(var/datum/quadtree/Q as() in subnodes)
		Q.Clear()
		qdel(Q)
	subnodes = null

/// Prunes unused/unnecessary subnodes by destroying and rebuilding the quadtree, can be pretty expensive for deeper quadtrees so try to use this sparingly
/datum/quadtree/proc/Rebuild()
	if(weight < MAX_OBJECTS_PER_NODE)
		return
	var/list/all_objects = get_all_objects()
	Clear()
	for(var/datum/shape/O as() in all_objects)
		Add(O)

/datum/quadtree/proc/get_all_objects()
	. = objects
	if(subnodes)
		for(var/datum/quadtree/Q as() in subnodes)
			. += Q.get_all_objects()

/datum/quadtree/proc/subdivide()
	var/childLevel = depth + 1
	var/childWidth = (XMax - XMin) / 2
	var/childHeight = (YMax - YMin) / 2
	subnodes = list()
	subnodes[TOPLEFT_QUADRANT] = new /datum/quadtree(src, childLevel, pos.x + childWidth, pos.y, childWidth, childHeight)
	subnodes[TOPRIGHT_QUADRANT] = new /datum/quadtree(src, childLevel, pos.x, pos.y, childWidth, childHeight)
	subnodes[BOTTOMLEFT_QUADRANT] = new /datum/quadtree(src, childLevel, pos.x, pos.y + childHeight, childWidth, childHeight)
	subnodes[BOTTOMRIGHT_QUADRANT] = new /datum/quadtree(src, childLevel, pos.x + childWidth, pos.y + childHeight, childWidth, childHeight)

#define TOP_QUADRANT 1
#define BOTTOM_QUADRANT 2
/// Used by a parent node to determine what subnode an object belongs to
/datum/quadtree/proc/get_node_index(datum/shape/O)
	var/quadIndex = 0

	var/vertQuad = 0 // whether we're in the topleft/topright or bottomleft/bottomright quadrant.
	if(O.position.y > pos.y)
		vertQuad = TOP_QUADRANT
	else if(O.position.y < pos.y && O.position.y + O.height < pos.y)
		vertQuad = BOTTOM_QUADRANT
	// are we in the right quadrant?
	if(O.position.x > pos.x)
		switch(vertQuad)
			if(TOP_QUADRANT)
				quadIndex = TOPRIGHT_QUADRANT
			if(BOTTOM_QUADRANT)
				quadIndex = BOTTOMRIGHT_QUADRANT

	// or are we in the left quadrant?
	else if(O.position.x < pos.x && O.position.x + O.width < pos.x)
		switch(vertQuad)
			if(TOP_QUADRANT)
				quadIndex = TOPLEFT_QUADRANT
			if(BOTTOM_QUADRANT)
				quadIndex = BOTTOMLEFT_QUADRANT

	return quadIndex

#undef TOP_QUADRANT
#undef BOTTOM_QUADRANT

/// Adds an element and returns the specific node the element is stored in
/datum/quadtree/proc/Add(datum/shape/O)
	weight++
	if(subnodes)
		var/node = get_node_index(O)
		if(node)
			var/datum/quadtree/Q = subnodes[node]
			return Q.Add(O)
	objects += O
	if(depth < MAX_DEPTH && weight > MAX_OBJECTS_PER_NODE)
		if(!subnodes)
			subdivide()
		var/i = 0 // increments every time an object has finished moving to a valid subnode
		while(i < length(objects))
			var/object = objects[i]
			var/node = get_node_index(object)
			if(node)
				var/datum/quadtree/Q = subnodes[node]
				objects -= object
				Q.Add(object)
				if(object == O)
					. = Q
			else
				i++
	if(!.)
		return src

/datum/quadtree/proc/Remove(datum/shape/O)
	weight--
	if(subnodes)
		var/node = get_node_index(O)
		if(node)
			var/datum/quadtree/Q = subnodes[node]
			Q.Remove(O)
			return
	objects -= O

// Should be used when an element is relocated (moved) to a nearby cell.
// ONLY CALL THIS DIRECTLY ON SUBNODES. e.g lastnode.Walk(object)
/// walks from the supplied node, moving back a level if we can't find a placement in our node (reverse lookup). Returns node location
/datum/quadtree/proc/Walk(datum/shape/O)
	var/node = get_node_index(O)
	if(node)
		var/datum/quadtree/Q = subnodes[node]
		objects -= O
		return Q.Add(O)
	objects -= O
	weight--

	var/datum/quadtree/Q = src
	for(var/i = depth, 0 < i, i--)
		Q = Q.parent
		if(!Q)
			break
		var/node = Q.get_node_index(O)
		if(node)
			Q = Q.subnodes[node]
			return Q.Add(O)
		// keeping lookin'
		Q.weight--

/// Similar to Walk() in that it traverses the tree in reverse but instead of updating object position it deletes it
/datum/quadtree/proc/FastRemove(datum/shape/O)
	objects -= O
	weight--
	var/datum/quadtree/Q = src
	for(var/i = depth, 0 < i, i--)
		Q = Q.parent
		if(Q)
			Q.weight--

/datum/quadtree/proc/get_nearby_objects(datum/shape/O)
	. = list()

	var/node = get_node_index(O)
	if(node && subnodes)
		var/datum/quadtree/Q = subnodes[node]
		. += Q.get_nearby_objects(O)
	. += objects // add any objects that don't fit in our subnodes (or just all objects, if we don't have subnodes)
	return nearby

#undef TOPLEFT_QUADRANT
#undef TOPRIGHT_QUADRANT
#undef BOTTOMLEFT_QUADRANT
#undef BOTTOMRIGHT_QUADRANT

#undef MAX_OBJECTS_PER_NODE
#undef MAX_DEPTH
