/* MESSAGE FOR THE NEXT POOR SOD TO STUMBLE UPON THIS SAD LITTLE THING WE CALL A SUBSYSTEM
--------------------------------------------------------------------------------------------
 * Collision detection hasn't been used in this subsystem for a while, expect to encounter unexpected behavior when re-implementing this
 * collission detection currently relies on deprecated C++ hooks in shape.dm, you'll need to either replace the hook with DM or use Rust to hook it with auxtools
 * godspeed o7.
*/

/// Max amount of objects we can have in a quadtree node before subdividing
#define MAX_OBJECTS_PER_NODE 15

PROCESSING_SUBSYSTEM_DEF(physics_processing)
	name = "Physics"
	wait = 1.5
	priority = FIRE_PRIORITY_PHYSICS
	stat_tag = "PHYS"
	var/list/physics_levels = list() // key = (string) z_level, value = list()
	var/datum/collision_response/c_response = new()
	var/list/quadtrees = list() // key = (string) z_level, value = root quadtree

	var/RBcounter = 0
	var/rebuild_frequency = 10 // How many physics ticks between rebuilds

/datum/controller/subsystem/processing/physics_processing/proc/AddToLevel(datum/component/physics2d/newP, target_z)
	var/z_str = "[target_z]"
	if(!quadtrees[z_str])
		quadtrees[z_str] = new /datum/quadtree(null, 0, GLOB.max_pixel_x / 2, GLOB.max_pixel_y / 2, GLOB.max_pixel_x, GLOB.max_pixel_y) // create new tree
	physics_levels[z_str] += newP
	var/datum/quadtree/Q = quadtrees[z_str]
	return Q.Add(newP.collider2d)

/datum/controller/subsystem/processing/physics_processing/proc/RemoveFromLevel(datum/component/physics2d/P, target_z)
	var/z_str = "[target_z]"
	var/list/za_warudo = physics_levels[z_str]
	if(za_warudo.Remove(P) && !length(za_warudo))
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
			nearby = quad.get_nearby_objects(body.collider2d) - body.collider2d
			for(var/datum/component/physics2d/neighbour as() in nearby)
				if(!isovermap(body.holder))
					if(!body.holder.physics_collide(neighbour.holder))
						continue //Bullets don't want to "bump" into each other, we actually handle that code in "crossed()"
					if(body.collider2d.collides(neighbour.collider2d))
						body.holder.Bump(neighbour.holder)
				//OK, now we get into the expensive calculation. This is our absolute last resort because it's REALLY expensive.
				else if(isovermap(neighbour.holder) && body.collider2d.collides(neighbour.collider2d, c_response)) // Dirty, but necessary. I want to minimize in-depth collision calc wherever I possibly can, so only overmap prototypes use it.
					body.holder.Bump(neighbour.holder, c_response) //More in depth calculation required, so pass this information on.
	if(++RBcounter >= rebuild_frequency)
		RBcounter = 0
		for(var/z_key in quadtrees)
			var/datum/quadtree/Q = quadtrees[z_key]
			if(Q.weight > MAX_OBJECTS_PER_NODE)
				Q.Clear(TRUE) // remove everything
				za_warudo = physics_levels[z_key]
				if(!za_warudo)
					continue
				// re-add everything
				for(var/datum/component/physics2d/P as() in za_warudo)
					P.last_node = Q.Add(P)
			// clear subnode cache before moving onto next Z
			for(var/parent in Q.cached_subnodes)
				var/list/subnodes = Q.cached_subnodes[parent]
				if(subnodes)
					QDEL_LIST(subnodes)
			Q.cached_subnodes.len = 0




/datum/component/physics2d
	var/atom/movable/holder = null
	var/datum/shape/collider2d = null //Our box collider. See the collision module for explanation
	var/datum/quadtree/last_node = null // The last quadtree node we were at.
	var/matrix/vector/position = null //Positional vector, used exclusively for collisions with overmaps
	var/last_registered_z = 0

	// rounded to multiple of 128 (changes every 4 tiles)
	var/last_x_clamped
	var/last_y_clamped

/datum/component/physics2d/Initialize()
	. = ..()
	holder = parent
	if(!istype(holder))
		return COMPONENT_INCOMPATIBLE //Precondition: This is a subtype of atom/movable.
	last_registered_z = holder.z
	RegisterSignal(holder, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(update_z))

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
		SSphysics_processing.RemoveFromLevel(src, last_registered_z)
	else
		for(var/z_key in SSphysics_processing.physics_levels)
			SSphysics_processing.RemoveFromLevel(src, z_key)
	//De-alloc references.
	QDEL_NULL(collider2d)
	QDEL_NULL(position)
	return ..()

/datum/component/physics2d/proc/setup(list/hitbox, angle)
	position = new /matrix/vector(holder.x*32,holder.y*32)
	collider2d = new /datum/shape(position, hitbox, angle) // -TORADIANS(src.angle-90)
	last_registered_z = holder.z
	last_x_clamped = round(position.a, 128)
	last_y_clamped = round(position.e, 128)
	last_node = SSphysics_processing.AddToLevel(src, last_registered_z)

/// Uses pixel coordinates
/datum/component/physics2d/proc/update(x, y, angle)
	collider2d.set_angle(angle) //Turn the box collider
	collider2d._set(x, y)
	var/new_x_clamped = round(x, 128)
	var/new_y_clamped = round(y, 128)
	// we don't need to update our quadrant every time we move, every 4 tiles should be enough for the current max grid dimensions
	if(new_x_clamped != last_x_clamped || new_y_clamped != last_y_clamped)
		last_node = last_node.Walk(collider2d)
		last_x_clamped = new_x_clamped
		last_y_clamped = new_y_clamped

/datum/component/physics2d/proc/update_z()
	if(holder.z != last_registered_z) //Z changed? Update this unit's processing chunk.
		if(!holder.z) // Something terrible has happened. Kill ourselves to prevent runtime spam
			qdel(src)
			message_admins("WARNING: [holder] has been moved out of bounds at [ADMIN_VERBOSEJMP(holder.loc)]. Deleting physics component.")
			CRASH("Physics component holder located in nullspace.")
		SSphysics_processing.RemoveFromLevel(src, last_registered_z)
		last_registered_z = holder.z
		last_node = SSphysics_processing.AddToLevel(src, last_registered_z)


// While I'd love to make a perfect Quadtree data structure with trunk index list, leaf datums, element nodes and all that juicy low level stuff;
// I'm fairly confident that those further optimizations would end up making things *slower* due to BYOND's slow ass backend.
// But if you're daring (and willing to benchmark the performance gain), feel free to try!

#define TOPLEFT_QUADRANT 1
#define TOPRIGHT_QUADRANT 2
#define BOTTOMLEFT_QUADRANT 3
#define BOTTOMRIGHT_QUADRANT 4
/// Max recursion depth of subnode creation
#define MAX_DEPTH 4

/datum/quadtree
	var/datum/quadtree/parent
	var/list/objects = list()
	var/weight = 0 // how many objects are stored within this tree/leaf recursively.
	var/depth = 0
	var/list/subnodes // dynamically initialized because length() is slower than a reference check
	var/matrix/vector/pos // pixel coordinates
	// pixel rectangle bounds relative to world (AABB).
	var/XMin
	var/XMax
	var/YMin
	var/YMax
	// contains subnodes marked for deletion, we look in here before making new nodes to see if we can just restore old nodes to save qdel calls
	// key = parent quadtree, value = list(subnodes)
	var/static/list/cached_subnodes = list()

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
		Clear(FALSE)

/datum/quadtree/proc/Clear(cache = FALSE)
	objects.len = 0
	weight = 0
	if(!subnodes)
		return
	if(cache)
		cached_subnodes[src] = subnodes
	for(var/datum/quadtree/Q as() in subnodes)
		Q.Clear(cache)
	subnodes = null

/datum/quadtree/proc/get_all_objects()
	. = objects.Copy()
	if(subnodes)
		for(var/datum/quadtree/Q as() in subnodes)
			. += Q.get_all_objects()

/datum/quadtree/proc/subdivide()
	var/childLevel = depth + 1
	var/childWidth = (XMax - XMin) / 2
	var/childHeight = (YMax - YMin) / 2

	var/list/CS = cached_subnodes[src]
	if(CS)
		subnodes = CS
	else
		subnodes = list()
		subnodes[TOPLEFT_QUADRANT] = new /datum/quadtree(src, childLevel, pos.a + childWidth, pos.e, childWidth, childHeight)
		subnodes[TOPRIGHT_QUADRANT] = new /datum/quadtree(src, childLevel, pos.a, pos.e, childWidth, childHeight)
		subnodes[BOTTOMLEFT_QUADRANT] = new /datum/quadtree(src, childLevel, pos.a, pos.e + childHeight, childWidth, childHeight)
		subnodes[BOTTOMRIGHT_QUADRANT] = new /datum/quadtree(src, childLevel, pos.a + childWidth, pos.e + childHeight, childWidth, childHeight)

#define UPPER_QUADRANT 1
#define LOWER_QUADRANT 2
/// Used by a parent node to determine what subnode an object belongs to
/datum/quadtree/proc/get_node_index(datum/shape/O)
	. = 0
	var/vertQuad = 0 // whether we're in the topleft/topright or bottomleft/bottomright quadrant.
	if(O.position.e > pos.e)
		vertQuad = UPPER_QUADRANT
	else if(O.position.e < pos.e && O.position.e + O.height < pos.e)
		vertQuad = LOWER_QUADRANT

	// are we in the right quadrant?
	if(O.position.a > pos.a)
		switch(vertQuad)
			if(UPPER_QUADRANT)
				. = TOPRIGHT_QUADRANT
			if(LOWER_QUADRANT)
				. = BOTTOMRIGHT_QUADRANT

	// or are we in the left quadrant?
	else if(O.position.a != pos.a && O.position.a + O.width < pos.a)
		switch(vertQuad)
			if(UPPER_QUADRANT)
				. = TOPLEFT_QUADRANT
			if(LOWER_QUADRANT)
				. = BOTTOMLEFT_QUADRANT

#undef UPPER_QUADRANT
#undef LOWER_QUADRANT

/// Adds an element and returns the specific node the element is stored in
/datum/quadtree/proc/Add(datum/shape/O)
	weight++
	if(subnodes)
		var/node = get_node_index(O)
		if(node)
			var/datum/quadtree/Q = subnodes[node]
			return Q.Add(O)
	objects += O
	var/objlen = length(objects)
	if(depth < MAX_DEPTH && objlen > MAX_OBJECTS_PER_NODE)
		if(!subnodes)
			subdivide()
		var/node_index = 0
		var/i = 0 // increments every time an object has finished moving to a valid subnode
		while(i < objlen)
			var/datum/shape/object = objects[i]
			node_index = get_node_index(object)
			if(node_index)
				var/datum/quadtree/Q = subnodes[node_index]
				objects -= object
				if(object == O)
					. = Q.Add(object)
				else
					Q.Add(object)
			else
				i++
	if(. == null)
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
		node = Q.get_node_index(O)
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
			continue
		return

/datum/quadtree/proc/get_nearby_objects(datum/shape/O)
	. = list()

	var/node = get_node_index(O)
	if(node && subnodes)
		var/datum/quadtree/Q = subnodes[node]
		. += Q.get_nearby_objects(O)
	. += objects // add any objects that don't fit in our subnodes (or just all objects, if we don't have subnodes)

#undef TOPLEFT_QUADRANT
#undef TOPRIGHT_QUADRANT
#undef BOTTOMLEFT_QUADRANT
#undef BOTTOMRIGHT_QUADRANT

#undef MAX_DEPTH

#undef MAX_OBJECTS_PER_NODE
