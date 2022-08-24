/**
  * General proc used to expel a holder's contents through src (for bins holder is also the src).
  */
/obj/proc/pipe_eject(obj/holder, direction, throw_em = TRUE, turf/target, throw_range = 5, throw_speed = 1)
	var/turf/src_T = get_turf(src)
	for(var/A in holder)
		var/atom/movable/AM = A
		//NSV13 - disposal stacking nerf
		if(!src_T.Enter(AM)) // something is blocking the tile
			var/turf/candidate = get_step(src_T, direction) //Take one step past it
			if(!candidate.Enter(AM, src_T))
				for(var/turf/newentry in oview(1, src_T))
					if(newentry.Enter(AM, src_T))
						src_T = newentry
						break
					CHECK_TICK
		AM.forceMove(src_T)
		SEND_SIGNAL(AM, COMSIG_MOVABLE_PIPE_EJECTING, direction)
		if(throw_em && !QDELETED(AM))
			var/turf/T = target || get_offset_target_turf(loc, rand(5)-rand(5), rand(5)-rand(5))
			AM.throw_at(T, throw_range, throw_speed)
