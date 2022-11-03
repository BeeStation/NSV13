/datum/hud/human
	var/atom/movable/screen/squad_lead_finder/squad_lead_finder = null

/datum/hud/human/New(mob/living/carbon/human/owner)
	. = ..()
	squad_lead_finder = new /atom/movable/screen/squad_lead_finder()
	squad_lead_finder.hud = src
	squad_lead_finder.alpha = 0
	squad_lead_finder.invisibility = INVISIBILITY_ABSTRACT
	infodisplay += squad_lead_finder

/atom/movable/screen/squad_lead_finder
	icon = 'nsv13/icons/mob/screen_squad.dmi'
	icon_state = "leadfinder"
	name = "Squad Lead Locator"
	desc = "Allows you to track your squad leader anywhere in the world!"
	screen_loc = "EAST-1:28,CENTER-4:10"
	var/datum/squad/squad = null
	var/mob/user = null
	var/mutable_appearance/pointer

/atom/movable/screen/squad_lead_finder/examine(mob/user)
	. = ..()
	if(squad && squad.leader)
		. += "<span class='warning'>Your squad leader is: [squad.leader.real_name]</span>"

/atom/movable/screen/squad_lead_finder/proc/set_squad(datum/squad/squad, mob/living/user)
	src.squad = squad
	src.user = user
	pointer = mutable_appearance(src.icon, "arrow")
	pointer.dir = dir
	add_overlay(pointer)
	START_PROCESSING(SSobj, src)

/atom/movable/screen/squad_lead_finder/Destroy()
	if(pointer)
		cut_overlay(pointer)
		QDEL_NULL(pointer)
	STOP_PROCESSING(SSobj, src)
	return ..()

/atom/movable/screen/squad_lead_finder/process()
	var/mob/SL = squad?.leader
	if(!SL)
		return
	var/turf/Q = get_turf(SL)
	var/turf/A = get_turf(user)
	if(Q.z != A.z) //Different Z-level.
		return
	var/Qdir = get_dir(user, Q)
	var/finder_icon = "arrow" //Overlay showed when adjacent to or on top of the queen!
	if(squad.leader == user)
		finder_icon = "youaretheleader"
	pointer.dir = Qdir
	pointer.icon_state = finder_icon
