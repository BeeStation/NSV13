/datum/job/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	. = ..()
	addtimer(CALLBACK(src, .proc/register_squad, H), 5 SECONDS)

/datum/job/proc/register_squad(mob/living/H)
	if(!ishuman(H))
		return //No
	var/datum/squad/squad = GLOB.squad_manager.get_joinable_squad(src)
	squad?.add_member(H, give_items=TRUE)
