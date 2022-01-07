/////Here we handle ghost role overmap ships

/obj/structure/overmap/proc/add_as_pilot(var/target)
	//Prevent the mainship being skeleton crewed
	if(src.role == MAIN_OVERMAP)
		message_admins("[src] is the main overmap and cannot be ghost controlled! Take manual control via the Z-level")
		return

	if(istype(src, /obj/structure/overmap/fighter))
		message_admins("[src] is a fighter subtype and cannot be ghost controlled! Take manual control the mob!")
		return

	ai_controlled = FALSE //Remove the AI control

	//Remove the dummies
	if(pilot)
		QDEL_NULL(pilot)
	if(gunner)
		QDEL_NULL(gunner)

	//Insert trackable player pilot here
	var/mob/living/carbon/human/species/skeleton/ghost = new (src.contents)
	ghost.loc = src
	ghost.name = src.name
	ghost.real_name = src.name
	ghost.hud_type = /datum/hud //Mostly blank hud
	src.start_piloting(ghost, "all_positions")

	if(target)
		//Needs to be able to plug in a player here
	else
		ghost.set_playable()

/*
kill ai control
remove dummy pilot/gunner
create new player pilot/gunner
insert player
*/
