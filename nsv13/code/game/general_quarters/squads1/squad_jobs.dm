//Begin job overrides.
/datum/job/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	. = ..()
	addtimer(CALLBACK(src, .proc/register_squad, H), 5 SECONDS)

/datum/job/proc/register_squad(mob/living/H)
	if(!ishuman(H))
		return //No
	var/datum/squad/squad = (H.client && H.client?.prefs?.preferred_squad) ? GLOB.squad_manager.get_squad(H.client.prefs.preferred_squad) : GLOB.squad_manager.get_joinable_squad()
	if(squad.members.len >= squad.max_members) //Too many people! Make a new squad and pop us in it.
		squad = GLOB.squad_manager.get_joinable_squad()
	for(var/path in squad.blacklist)
		if(type == path)
			return
	if(H.client?.prefs?.be_leader)
		if(!squad.leader)
			squad.set_leader(H)
			return
		else
			for(var/datum/squad/S in GLOB.squad_manager.squads)
				if(!S.leader)
					S.set_leader(H)
					return
	squad += H
