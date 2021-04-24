#define MAXIMUM_COLLISION_RANGE 12 //In tiles, what is the range of the maximum possible collision that could take place? Please try and keep this low, as it saves a lot of time and memory because it'll just ignore physics bodies that are too far away from each other.
//That being said. If you want to make a ship that is bigger than this in tile size, then you will have to change this number. As of 11/08/2020 the LARGEST possible collision range is 25 tiles, due to the fist of sol existing. Though tbh if you make a sprite much larger than this, byond will likely just cull it from the viewport.
PROCESSING_SUBSYSTEM_DEF(physics_processing)
	name = "Physics Processing"
	wait = 1.5
	stat_tag = "PHYS"
	priority = FIRE_PRIORITY_PHYSICS
	var/list/physics_bodies = list() //All the physics bodies in the world.
	var/list/physics_levels = list()
	var/next_boarding_time = 0 //This is stupid and lazy but it's 5am and I don't care anymore
	var/datum/collision_response/c_response = new /datum/collision_response()

/datum/controller/subsystem/processing/physics_processing/fire(resumed)
	. = ..()
	for(var/I in physics_levels)
		var/list/za_warudo = physics_levels[I]
		for(var/datum/component/physics2d/body in za_warudo)
			if(!body.collider2d)
				continue
			if(!body || QDELETED(body) || !body.holder)
				za_warudo -= body
				continue
			if(body.holder.z == null || body.holder.z == 0)
				continue //If we're in nullspace.
			var/list/recent_collisions = list() //So we don't collide two things together twice.
			for(var/datum/component/physics2d/neighbour in za_warudo) //Now we check the collisions of every other physics body with this one. I hate that I have to do this, but I can't think of a better way just yet.
				//Precondition: body and neighbour both exist, and are attached to something.
				if(!neighbour?.holder || QDELETED(neighbour))
					za_warudo -= neighbour
					continue
				if(!neighbour.holder.z)
					continue //If we're in nullspace.
				//Precondition: body and neighbour are different entities.
				if(body == neighbour)
					continue
				//Precondition: we're not checking collisions that we already ran.
				if(neighbour in recent_collisions)
					continue
				//Precondition: neighbour has a collider2d (IE, hitboxes set up for it)
				if(!neighbour.collider2d)
					continue
				//Precondition: They're actually somewhat near each other. This is a nice and simple way to cull collisions that would never happen, and save some CPU time.
				if(get_dist(body.holder, neighbour.holder) > MAXIMUM_COLLISION_RANGE) //Too far away to even bother with this calculation.
					continue
				if(neighbour.holder.z != body.holder.z) //Just in case some freak accident happened
					continue
				//OK, now we get into the expensive calculation. This is our absolute last resort because it's REALLY expensive.
				if(isovermap(body.holder) && isovermap(neighbour.holder)) //Dirty, but necessary. I want to minimize in-depth collision calc wherever I possibly can, so only overmap prototypes use it.
					if(body.collider2d?.collides(neighbour.collider2d, c_response))
						body.holder.Bump(neighbour.holder, c_response) //More in depth calculation required, so pass this information on.
						recent_collisions += neighbour
				else //OK great, we get more simplified calc!
					if(isprojectile(body.holder) && isprojectile(neighbour.holder))
						continue //Bullets don't want to "bump" into each other, we actually handle that code in "crossed()"
					if(body.collider2d?.collides(neighbour.collider2d))
						body.holder.Bump(neighbour.holder)
						recent_collisions += neighbour

/datum/component/physics2d
	var/datum/shape/collider2d = null //Our box collider. See the collision module for explanation
	var/datum/vector2d/position = null //Positional vector, used exclusively for collisions with overmaps
	var/datum/vector2d/velocity = null
	var/last_registered_z = 0 //Placeholder. Overridden on process()
	var/atom/movable/holder = null
	var/next_collision = 0

/datum/component/physics2d/Initialize()
	. = ..()
	if(!istype(parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE //Precondition: This is something that actually moves.
	holder = parent
	SSphysics_processing.physics_bodies += src
	last_registered_z = holder.z
	LAZYADD(SSphysics_processing.physics_levels["[last_registered_z]"], src)

/datum/component/physics2d/Destroy(force, silent)
	//Stop fucking referencing this I sweAR
	if(holder)
		var/obj/structure/overmap/OM = holder
		if(istype(OM))
			OM.physics2d = null
		var/obj/item/projectile/P = holder
		if(istype(P))
			P.physics2d = null
	for(var/I in SSphysics_processing.physics_levels)
		var/list/za_warudo = SSphysics_processing.physics_levels[I]
		za_warudo.Remove(src)
	//De-alloc references.
	collider2d = null
	position = null
	velocity = null
	return ..()

/datum/component/physics2d/proc/setup(list/hitbox, angle)
	position = new /datum/vector2d(holder.x*32,holder.y*32)
	collider2d = new /datum/shape(position, hitbox, angle) // -TORADIANS(src.angle-90)
	last_registered_z = holder.z
	START_PROCESSING(SSphysics_processing, src)

/datum/component/physics2d/proc/update(x, y, angle)
	collider2d?.set_angle(angle) //Turn the box collider
	collider2d?._set(x, y)

/datum/component/physics2d/process()
	if(!holder || QDELETED(holder))
		RemoveComponent()
		qdel(src)
		return PROCESS_KILL
	if(holder.z != last_registered_z) //Z changed? Update this unit's processing chunk.
		var/list/stats = SSphysics_processing.physics_levels["[last_registered_z]"]
		if(stats) //If we're already in a list.
			stats -= src
		last_registered_z = holder.z
		stats = SSphysics_processing.physics_levels["[last_registered_z]"]
		LAZYADD(stats, src) //If the SS isn't tracking this Z yet with a list, this will take care of it.
