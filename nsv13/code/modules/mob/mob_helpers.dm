
/proc/shake_with_inertia(mob/M, duration=0, strength=1)
	var/newStrength = strength

	if ( M.ckey ) // These inertial dampener checks are probably expensive, we're only going to run calculations on people who are able to observe these camera shakes 
		message_admins( "shake_with_inertia" )
		message_admins( M )
		// var/list/dampeners = list()
		// var/list/distances = list()
		var/nearestDistance = INFINITY
		var/obj/machinery/inertial_dampener/nearestMachine = null

		for(var/obj/machinery/inertial_dampener/machine in GLOB.machines)
			// dampeners.Insert( 1, machine )
			// distances.Insert( 1, get_dist( M, machine ) )
			// dampeners.Insert( 1, list(
			// 	dist = get_dist( M, machine )
			// 	machine = machine 
			// ) )
			var/dist = get_dist( M, machine )
			if ( dist < nearestDistance )
				nearestDistance = dist 
				nearestMachine = machine

		// message_admins( "[dampeners]" )
		// message_admins( "[english_list(distances)]" )
		message_admins( english_list( list( 
			nearestDistance,
			nearestMachine 
		) ) )

		if ( nearestMachine ) 
			newStrength = nearestMachine.reduceStrength( nearestDistance, strength )

		message_admins( english_list( list( 
			strength,
			newStrength 
		) ) )

	shake_camera( M, duration, newStrength )
