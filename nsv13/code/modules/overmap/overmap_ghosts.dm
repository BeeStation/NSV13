/////Here we handle ghost role overmap ships
#define VV_HK_GHOST_SHIP "GhostShip"

/obj/structure/overmap/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_GHOST_SHIP, "Make Ghost Ship")

/obj/structure/overmap/vv_do_topic(list/href_list)
	set waitfor = FALSE
	. = ..()
	if(href_list[VV_HK_GHOST_SHIP])
		if(!check_rights(R_ADMIN))
			return
		var/target_ghost
		switch(alert(usr, "Who is going to pilot this ghost ship?", "Pilot Select Format", "Open", "Choose", "Cancel"))
			if("Cancel")
				return
			if("Open")
				var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you wish to pilot a [src.faction] [src.name]?", ROLE_GHOSTSHIP, /datum/role_preference/midround_ghost/ghost_ship, 20 SECONDS, POLL_IGNORE_GHOSTSHIP)
				if(LAZYLEN(candidates))
					var/mob/dead/observer/C = pick(candidates)
					target_ghost = C
				else
					return
			if("Choose")
				target_ghost = input(usr, "Select player to pilot ghost ship:", "Select Player") as null|anything in GLOB.clients

		ghost_ship(target_ghost)
		message_admins("[key_name_admin(usr)] has ghost shipped [src.name]!")
		log_admin("[key_name_admin(usr)] has ghost shipped [src.name]!")


//Creation of the ghost ship pilot entity
/obj/structure/overmap/proc/ghost_ship(mob/target)
	if(!target)
		return

	//Prevent the mainship being skeleton crewed
	if(src.role == MAIN_OVERMAP)
		message_admins("[src] is the main overmap and cannot be ghost controlled! Take manual control via the Z-level")
		return

	if(istype(src, /obj/structure/overmap/small_craft))
		message_admins("[src] is a small craft subtype and cannot be ghost controlled! Take manual control the mob!")
		return

	ai_controlled = FALSE //Remove the AI control

	//Remove the dummies
	if(pilot)
		QDEL_NULL(pilot)
	if(gunner)
		QDEL_NULL(gunner)

	//Buff the ships
	spec_ghostship_changes()

	//Insert the extra machines
	if(!dradis)
		if(mass >= MASS_SMALL)
			dradis = new /obj/machinery/computer/ship/dradis/internal/large_ship(src)
		else
			dradis = new /obj/machinery/computer/ship/dradis/internal(src)
		dradis.linked = src

	if(!tactical)
		tactical = new /obj/machinery/computer/ship/tactical/internal(src)
		tactical.linked = src

	//Lets ships with gauss use them
	if(weapon_types[FIRE_MODE_GAUSS])
		var/datum/ship_weapon/GA = weapon_types[FIRE_MODE_GAUSS]
		GA.allowed_roles = OVERMAP_USER_ROLE_GUNNER

	//Override AMS
	weapon_types[FIRE_MODE_AMS] = null //Resolve this later to be auto
	weapon_types[FIRE_MODE_FLAK] = null //Resolve this later to be a toggle

	//Insert trackable player pilot here
	var/mob/living/carbon/human/species/skeleton/ghost = new (src.contents)
	ghost.loc = src
	ghost.name = src.name
	ghost.real_name = src.name
	ghost.hud_type = /datum/hud //Mostly blank hud
	ghost.key = target.key

	//More or less a modified version of how the morph antag gets the antag datum.
	if(ghost.mind)
		ghost.mind.add_antag_datum(/datum/antagonist/ghost_ship)

	//Allows player to hear hails
	mobs_in_ship += ghost

	//Make sure the ship doesn't enter countdown
	overmap_deletion_traits = DAMAGE_ALWAYS_DELETES

	//Add some verbs
	overmap_verbs = list(.verb/toggle_brakes, .verb/toggle_inertia, .verb/show_dradis, .verb/show_tactical, .verb/toggle_move_mode, .verb/cycle_firemode)

	ghost_key_check(ghost)
	log_game("[target.key] was spawned as a [src]")

/obj/structure/overmap/proc/ghost_key_check(var/mob/living/carbon/human/species/skeleton/ghost)
	if(ai_controlled) //Exit this loop if we have put an AI back in control
		return

	if(ghost.key) //Is there a player in control of our ghost?
		start_piloting(ghost, (OVERMAP_USER_ROLE_PILOT | OVERMAP_USER_ROLE_GUNNER))
		ghost_controlled = TRUE

	else //Try again later
		addtimer(CALLBACK(src, PROC_REF(ghost_key_check), ghost), 1 SECONDS)

/obj/structure/overmap/proc/spec_ghostship_changes() //Proc to buff ghost ships. Currently handles only fighters. Override if you want
	if(mass == MASS_TINY) //Makes dogfighting fun
		obj_integrity *= 6
		max_integrity *= 6 //About as squishy, and fast, as a light fighter
		forward_maxthrust *= 3.5
		backward_maxthrust *= 3.5
		side_maxthrust *= 2
		integrity_failure *= 3.5
		max_angular_acceleration *= 2
		speed_limit *= 2.5
		shots_left = 500 //Having 15 max cannon shots isn't fun

