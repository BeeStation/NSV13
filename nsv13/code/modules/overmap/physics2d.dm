//In tiles, what is the range of the maximum possible collision that could take place? Please try and keep this low, as it saves a lot of time and memory because it'll just ignore physics bodies that are too far away from each other.
//That being said. If you want to make a ship that is bigger than this in tile size, then you will have to change this number. As of 11/08/2020 the LARGEST possible collision range is 25 tiles, due to the fist of sol existing. Though tbh if you make a sprite much larger than this, byond will likely just cull it from the viewport.
#define MAXIMUM_COLLISION_RANGE 12
PROCESSING_SUBSYSTEM_DEF(physics_processing)
	name = "Physics"
	wait = 1.5
	priority = FIRE_PRIORITY_PHYSICS
	stat_tag = "PHYS"
	var/list/physics_bodies = list() //All the physics bodies in the world.
	var/list/physics_levels = list()
	var/datum/collision_response/c_response = new /datum/collision_response()

// TODO: Implement a sweep and prune algorithm, a much faster alternative than our current exponential iteration
/datum/controller/subsystem/processing/physics_processing/fire(resumed)
	. = ..()
	for(var/list/za_warudo in physics_levels)
		var/list/recent_collisions = list() //So we don't collide two things together twice.
		for(var/datum/component/physics2d/body as() in za_warudo)
			for(var/datum/component/physics2d/neighbour as() in za_warudo - body) //Now we check the collisions of every other physics body with this one. I hate that I have to do this, but I can't think of a better way just yet.
				//Precondition: They're actually somewhat near each other. This is a nice and simple way to cull collisions that would never happen, and save some CPU time.
				//Precondition: we're not checking collisions that we already ran.
				if(get_dist(body.holder, neighbour.holder) > MAXIMUM_COLLISION_RANGE || (neighbour in recent_collisions))
					continue
				if(!isovermap(body.holder))
					if(!body.holder.physics_collide(neighbour.holder))
						continue //Bullets don't want to "bump" into each other, we actually handle that code in "crossed()"
					if(body.collider2d.collides(neighbour.collider2d))
						body.holder.Bump(neighbour.holder)
						recent_collisions += neighbour
				//OK, now we get into the expensive calculation. This is our absolute last resort because it's REALLY expensive.
				else if(isovermap(neighbour.holder) && body.collider2d.collides(neighbour.collider2d, c_response)) // Dirty, but necessary. I want to minimize in-depth collision calc wherever I possibly can, so only overmap prototypes use it.
					body.holder.Bump(neighbour.holder, c_response) //More in depth calculation required, so pass this information on.
					recent_collisions += neighbour


/datum/component/physics2d
	var/datum/shape/collider2d = null //Our box collider. See the collision module for explanation
	var/datum/vector2d/position = null //Positional vector, used exclusively for collisions with overmaps
	var/last_registered_z = 0
	var/atom/movable/holder = null

/datum/component/physics2d/Initialize()
	. = ..()
	holder = parent
	if(!istype(holder))
		return COMPONENT_INCOMPATIBLE //Precondition: This is a subtype of atom/movable.
	last_registered_z = holder.z
	RegisterSignal(holder, COMSIG_MOVABLE_Z_CHANGED, .proc/update_z)

/datum/component/physics2d/Destroy(force, silent)
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
		SSphysics_processing.physics_levels[last_registered_z] -= src
	else
		for(var/list/za_warudo in SSphysics_processing.physics_levels)
			za_warudo -= src
	SSphysics_processing.physics_bodies -= src
	//De-alloc references.
	QDEL_NULL(collider2d)
	QDEL_NULL(position)
	return ..()

/datum/component/physics2d/proc/setup(list/hitbox, angle)
	position = new /datum/vector2d(holder.x*32,holder.y*32)
	collider2d = new /datum/shape(position, hitbox, angle) // -TORADIANS(src.angle-90)
	last_registered_z = holder.z
	SSphysics_processing.physics_bodies += src
	SSphysics_processing.physics_levels[last_registered_z] += src

/datum/component/physics2d/proc/update(x, y, angle)
	collider2d.set_angle(angle) //Turn the box collider
	collider2d._set(x, y)

/datum/component/physics2d/proc/update_z()
	if(holder.z != last_registered_z) //Z changed? Update this unit's processing chunk.
		if(!holder.z) // Something terrible has happened. Kill ourselves to prevent runtime spam
			qdel(src)
			message_admins("WARNING: [holder] has been moved out of bounds at [ADMIN_VERBOSEJMP(holder.loc)]. Deleting physics component.")
			CRASH("Physics component holder located in nullspace.")
		var/list/stats = SSphysics_processing.physics_levels[last_registered_z]
		if(stats) //If we're already in a list.
			stats -= src
		last_registered_z = holder.z
		stats = SSphysics_processing.physics_levels[last_registered_z] += src //If the SS isn't tracking this Z yet with a list, this will take care of it.
