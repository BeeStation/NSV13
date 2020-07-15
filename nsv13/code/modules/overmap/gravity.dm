/* Gravity component, for all objects that you want to have a gravitational effect on overmap objects.
This was made a component because overmap anomalies and overmap objects have two completely different inheritances, because of somebody *cough*

grav_maker is added to things that should exert gravity, and the _modifier parameter affects how strong their gravitational effect is. 1 being on part with that of stars, and so forth,

grav_taker is added to things that should be affected by gravity, and the _modifier parameter affects how influenced they are by gravity. for the most part this should be 1, but setting it to 0.5
for example would be a nice upgrade possibly to a ship that makes it easier to pilot in gravity fields
*/

GLOBAL_LIST_EMPTY(grav_makers)
GLOBAL_LIST_EMPTY(grav_takers)

/datum/component/grav_maker
	var/strength = 1
	var/last_process = 0

/datum/component/grav_maker/Initialize(_modifier = 1)
	strength = _modifier

	GLOB.grav_makers += src
	START_PROCESSING(SSovermap, src)

/datum/component/grav_maker/process()
	var/time = min(world.time - last_process, 10)
	time /= 10 // fuck off deciseconds

	last_process = world.time

	var/used_pos_src = null
	var/used_pos_rec = null

	var/obj/_parent = parent
	if(!parent)
		return qdel(src) //we go bye bye if we have no parent we're attatched to TODO: Make this actually work. I don't think this actually works and we get grav_makers attatched to nothing that runtime

	if(!istype(/obj/structure/overmap, parent)) //make a position vector for us if we don't already have one (e.g. anomalies)
		used_pos_src = new /datum/vector2d(_parent.x*32,_parent.y*32)
	else
		var/obj/structure/overmap/O = parent
		used_pos_src = O.position //otherwise use the one we already have

	for(var/datum/component/grav_taker/G in GLOB.grav_takers)
		var/obj/G_parent = G.parent
		if(!G_parent)
			return qdel(G) //stop those pesky runtimes!
		if (G_parent.z != _parent.z) //only affect grav_takers on our z-level
			continue

		if(!istype(/obj/structure/overmap, G.parent)) //make a position vector for them if they don't already have one (e.g. anomalies)
			used_pos_rec = new /datum/vector2d(G_parent.x*32,G_parent.y*32)
		else
			var/obj/structure/overmap/O = G.parent
			used_pos_rec = O.position //otherwise use the one they already have

		var/datum/vector2d/to_vector = used_pos_src - used_pos_rec //vector from them to us. (tip - tail)
		if(!to_vector) //ignore zero vectors
			continue
		var/dist = to_vector.ln() //distance between them and us (magnitude of the to vector)
		dist = max(1, dist)

		var/g_accel = ((GLOB.grav_const * strength) / dist ** 2)  //get the raw acceleration (in pixels) experienced by the receiver, this will be the magnitude of the normalized to_vector

		var/datum/vector2d/g_vector = to_vector.normalize() * g_accel //the accleration they experience, from us. other grav_makers may modify this of course to yield a different net sum
		if(!g_vector)
			continue //avoid wierd issues

		g_vector /= 32 //divide by 32 since velocity for some reason is in units 32x larger than position



		var/obj/structure/overmap/affected = G.parent

		//limit gravitational acceleration to slightly less than the max thrust of the given craft. a little gamey but chock it down to "inertial dampening" or some such. makes it so you can get unstuck
		//This only considers the component of the acceleration that is directly opposing the velocity of the craft, to still allow for some crazy maneuvers
		if(G.thrust_limited && affected.user_thrust_dir) //only do this math stuff if the object is actively trying to break orbit
			if(affected.velocity.ln() >= 1)
				//get scalar projection of gravity acceleration vector on direction vector, basically, only count the component of gravity that acts parallel to our velocity for limiting its effect -- so we can still rocket around bodies
				var/scalar = g_vector.dot(affected.velocity) / -max(affected.velocity.ln(), 0.1)
				g_vector /= max((scalar / (affected.forward_maxthrust -0.2)), 1) //reduce the overall vector to the point where we can thrust out of the gravity well
			else //which is a great idea except it's terribly broken at close range and small velocities
				var/normal = g_vector.normalize()
				g_vector = normal * min(g_vector.ln(), affected.forward_maxthrust - 0.2)


		affected.velocity += (g_vector * G.attenuation * time)


/datum/component/grav_taker/
	var/attenuation = 1
	var/thrust_limited = TRUE

/datum/component/grav_taker/Initialize(_modifier = 1, _thrust_limited = TRUE)
	attenuation = _modifier
	thrust_limited = _thrust_limited

	GLOB.grav_takers += src
	START_PROCESSING(SSovermap, src)

	to_chat(thrust_limited, world)

