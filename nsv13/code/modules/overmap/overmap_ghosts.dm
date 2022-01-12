/////Here we handle ghost role overmap ships

/obj/structure/overmap/proc/ghost_ship(var/target)
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

	//Insert the extra machines
	if(!dradis)
		dradis = new /obj/machinery/computer/ship/dradis/internal(src)
		dradis.linked = src

	if(!tactical)
		tactical = new /obj/machinery/computer/ship/tactical/internal(src)
		tactical.linked = src

	//Insert trackable player pilot here
	var/mob/living/carbon/human/species/skeleton/ghost = new (src.contents)
	ghost.loc = src
	ghost.name = src.name
	ghost.real_name = src.name
	ghost.hud_type = /datum/hud //Mostly blank hud

	//Add some verbs
	overmap_verbs = list(.verb/toggle_brakes, .verb/toggle_inertia, .verb/show_dradis, .verb/show_tactical, .verb/overmap_help, .verb/toggle_move_mode, .verb/cycle_firemode)

	if(target)
		//Needs to be able to plug in a player here - not a question
		//ghost.give_mind(target)
	else
		ghost.set_playable()

	ghost_key_check(ghost)

/obj/structure/overmap/proc/ghost_key_check(var/mob/living/carbon/human/species/skeleton/ghost)
	if(ghost.key)
		src.start_piloting(ghost, "all_positions")

	else
		addtimer(CALLBACK(src, .proc/ghost_key_check, ghost), 2 SECONDS)

