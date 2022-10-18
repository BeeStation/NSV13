/*
This file is for lance-related stuff. Lances are basically a team of AI ships that work together on their AI goal.
Currently only used by Fighters, which assign themselves to a lance when in the 'swarm' behavior.
*/

/datum/lance
	var/list/members = list()
	var/obj/structure/overmap/lance_leader
	var/obj/structure/overmap/lance_target
	var/obj/structure/overmap/last_finder	//Who found the last target we're targetting? Used to see if we can still 'see' them, provided they're on the correct AI goal.
	var/datum/fleet/homefleet
	var/maximum_members = 5
	var/member_count = 0


/datum/lance/New(obj/structure/overmap/initial_ship, datum/fleet/initial_fleet)
	. = ..()
	homefleet = initial_fleet
	initial_fleet.lances.Add(src)
	add_member(initial_ship)

/datum/lance/proc/add_member(obj/structure/overmap/new_member)
	members.Add(new_member)
	if(!lance_leader)
		lance_leader = new_member
	new_member.current_lance = src
	RegisterSignal(new_member, COMSIG_PARENT_QDELETING , .proc/remove_member, new_member)
	member_count++


/datum/lance/proc/remove_member(obj/structure/overmap/to_remove)
	members.Remove(to_remove)
	if(!members.len)
		qdel(src)
		return
	if(lance_leader == to_remove)
		lance_leader = pick(members)

	if(lance_target && last_finder == to_remove)
		last_finder = null
		lance_target = null
	to_remove.current_lance = null
	member_count--

/datum/lance/Destroy()
	if(homefleet)
		homefleet.lances.Remove(src)
	. = ..()
