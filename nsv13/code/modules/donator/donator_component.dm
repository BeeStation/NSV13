/datum/component/donator
	var/owner_ckey //Admin tracking.

/datum/component/donator/Initialize(new_owner)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	owner_ckey = new_owner

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)

/datum/component/donator/proc/examine(datum/source, mob/user, list/examine_list)
	if(user.ckey == owner_ckey)
		examine_list += "<span class='hypnophrase'>It's your special item.</span>"
	else
		examine_list += "<span class='hypnophrase'>It's a special item!</span>"
		examine_list += "<span class='notice'>Consider donating to get one of these for yourself!</span>"
