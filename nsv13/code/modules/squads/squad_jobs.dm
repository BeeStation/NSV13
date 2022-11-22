/datum/job/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	. = ..()
	addtimer(CALLBACK(src, .proc/register_squad, H), 5 SECONDS)

/datum/job/proc/register_squad(mob/living/H)
	if(!ishuman(H))
		return //No

	var/datum/squad/squad = null
	if(H.client?.prefs?.active_character.preferred_squad)
		squad = GLOB.squad_manager.get_squad(H.client.prefs.active_character.preferred_squad)
	if(!squad || (length(squad.members) > squad.max_members) || (LAZYFIND(squad.disallowed_jobs, type) && !LAZYFIND(squad.allowed_jobs, type)))
		squad = GLOB.squad_manager.get_joinable_squad(src)
	if(!squad)
		return
	squad.add_member(H, give_items=TRUE)
