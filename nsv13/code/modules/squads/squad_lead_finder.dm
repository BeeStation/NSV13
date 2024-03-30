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

/atom/movable/screen/squad_lead_finder/examine(mob/user)
	. = ..()
	if(squad && squad.leader)
		. += "<span class='warning'>Your squad leader is: [squad.leader.real_name]</span>"

/atom/movable/screen/squad_lead_finder/proc/set_squad(datum/squad/squad, mob/living/user)
	src.squad = squad
	src.user = user
	START_PROCESSING(SSobj, src)

/atom/movable/screen/squad_lead_finder/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/atom/movable/screen/squad_lead_finder/process()
	cut_overlays()
	var/mob/SL = squad?.leader
	if(!SL)
		return
	var/turf/Q = get_turf(SL)
	var/turf/A = get_turf(user)
	if(!Q || !A) //DOOR THE EXPLORER STOP EDITION
		return //We didn't get Q or A, one of them is being given a value of null randomly, hopefully this prevents a runtime error.

	var/finder_icon = "arrow" //Overlay showed when adjacent to or on top of the Squad lead!
	if(Q.get_virtual_z_level() != A.get_virtual_z_level()) //Different Z-level.
		if(Q.get_virtual_z_level() > A.get_virtual_z_level())
			finder_icon = "arrow_above" //SQUAD LEADER IS ABOVE US
		else
			finder_icon = "arrow_below" //SQUAD LEADER IS BELOW US
	if(squad.leader == user)
		finder_icon = "youaretheleader" //WE ARE THE SQUAD LEAD...OH NO!
	var/image/pointyBoi = image(src.icon, finder_icon)
	if(squad.leader != user && Q.get_virtual_z_level() == A.get_virtual_z_level()) //Same Z-level, Squad lead is hiding somewhere on this Deck.
		var/Qdir = get_dir(user, Q)
		pointyBoi = image(src.icon, finder_icon, dir = Qdir)
	add_overlay(pointyBoi) //THE RETURN OF POINTYBOI 2.0
