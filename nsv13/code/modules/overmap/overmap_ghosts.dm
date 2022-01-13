/////Here we handle ghost role overmap ships

//Creation of the ghost ship

/*
Admin Selects
- Where: Current System or Admin Location? Both as option?
- What: List selection of all AI controlled ships?
- Who: List selection of all players, or open?

*/


//Creation of the ghost ship pilot entity
/obj/structure/overmap/proc/ghost_ship(mob/target)
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

	//Override AMS
	weapon_types[FIRE_MODE_AMS] = null //Resolve this later to be auto

	//Insert trackable player pilot here
	var/mob/living/carbon/human/species/skeleton/ghost = new (src.contents)
	ghost.loc = src
	ghost.name = src.name
	ghost.real_name = src.name
	ghost.hud_type = /datum/hud //Mostly blank hud

	//Add some verbs
	overmap_verbs = list(.verb/toggle_brakes, .verb/toggle_inertia, .verb/show_dradis, .verb/show_tactical, .verb/overmap_help, .verb/toggle_move_mode, .verb/cycle_firemode)

	if(target)
		ghost.key = target.key
	else
		ghost.set_playable()
		addtimer(CALLBACK(src, .proc/ghost_revert, ghost), 10 SECONDS) //10 seconds to fill or revert to AI control

	ghost_key_check(ghost)

/obj/structure/overmap/proc/ghost_key_check(var/mob/living/carbon/human/species/skeleton/ghost)
	if(ai_controlled) //Exit this loop if we have put an AI back in control
		return

	if(ghost.key) //Is there a player in control of our ghost?
		start_piloting(ghost, "all_positions")
		ghost_controlled = TRUE

	else //Try again later
		addtimer(CALLBACK(src, .proc/ghost_key_check, ghost), 1 SECONDS)

/obj/structure/overmap/proc/ghost_revert(var/mob/living/carbon/human/species/skeleton/ghost)
	if(!ghost.key) //If no-one takes the ghost slot, revert it
		ai_controlled = TRUE
