//This file is dedicated to FTL pathfinding. It's in here instead of ai-skynet2.dm to avoid bloating that file even more, and for easy access.


/*
	A route finding alrorytm. This will always find the shortest path to a target system if one exists, but may need quite some cycles, due to it being O(V + E)
	Returns FALSE if no route is found, an empty list if already at the target, and a list with a route to the target in all other cases
*/
/datum/fleet/proc/find_route(datum/star_system/target_system, list/allowed_alignments = list(), wormholes_allowed = TRUE)
	var/list/route = list()
	if(!target_system || !current_system)
		return FALSE	//This do be invalid

	if(current_system == target_system)
		return list()	//We are already here


	var/list/all_systems = SSstar_system.systems.Copy()

	var/systems[all_systems.len]
	var/distances[all_systems.len]
	var/parents[all_systems.len]


	for(var/i = 1; i <= all_systems.len; i++)
		var/datum/star_system/S = all_systems[i]
		systems[i] = S
		if(current_system == S)
			distances[i] = 0
		else
			distances[i] = INFINITY

	while(all_systems.len)
		var/cur_key
		var/datum/star_system/cur_sys
		for(var/i = 1; i <= all_systems.len; i++)
			var/candidate_key = systems.Find(all_systems[i])
			if(!cur_key || distances[cur_key] > distances[candidate_key])
				cur_key = candidate_key
		cur_sys = systems[cur_key]
		all_systems -= cur_sys

		if(distances[cur_key] == INFINITY)	//If infinity is our closest pick, we got to nonconnected systems and can stop this. We'll full-on return later, maaybe we did find a way beforehand.
			break

		for(var/adj in cur_sys.adjacency_list)
			var/datum/star_system/adj_sys = SSstar_system.system_by_id(adj)
			var/adj_key = systems.Find(adj_sys)

			if(!all_systems.Find(adj_sys)) //Not a crossing edge
				continue
			if(allowed_alignments.len && !allowed_alignments.Find(adj_sys.alignment))
				continue	//Ignore edge if target sys isn't allowed.
			if(!wormholes_allowed && cur_sys.wormhole_connections.Find(adj))
				continue	//No using wormholes if they're forbidden to you, bad!

			if(distances[cur_key] + cur_sys.dist(adj_sys) < distances[adj_key])
				distances[adj_key] = distances[cur_key] + cur_sys.dist(adj_sys)
				parents[adj_key] = cur_sys

	var/target_key = systems.Find(target_system)
	if(!parents[target_key])	//No path
		return FALSE

	var/datum/star_system/route_next = target_system
	while(route_next != current_system)
		route.Insert(1, route_next)
		route_next = parents[systems.Find(route_next)]
		if(!route_next)	//Something bad happened, abort, abort!
			return FALSE
	return route
