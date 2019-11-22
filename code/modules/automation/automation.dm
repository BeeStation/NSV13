//An attempt at a assembly line for the vault or possibly as a wasteland ruin, put in recycling due to proximity towards conveyors

//Basic parent type that handles inserting objects into itself when getting Bumped() and changing output direction with multitool
/obj/machinery/automation
	name = "Shouldn't exist reeeee"
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-o0"
	density = TRUE
	speed_process = TRUE //Every 0.2 seconds instead of 2
	var/list/radial_categories = list(
	)
	var/current_work_tick = 0 //Don't want to do stuff every 0.2 seconds? throw a % at it
	//Used for machines to know where to output in a proper way (onto a conveyor belt NOT pointing towards the machine
	var/list/acceptable_output = list("north" = null, "south" = null, "west" = null, "east" = null)
	var/jammed = FALSE //If this is TRUE, then we couldn't output a thing because there's no conveyors going outwards
	var/turf/last_turf //Last turf were at; update acceptable output if this isn't the same as last process()

	/*
	var/list/i_o_radial_options = list(
	"Change Input",
	"Change Output"
	)
	*/

/obj/machinery/automation/RefreshParts()
	..()

/obj/machinery/automation/Initialize()
	. = ..()
	last_turf = loc
	/*
	radial_categories["I/O Settings"] = image(icon = 'icons/mob/radial.dmi', icon_state = "auto_change_io")
	i_o_radial_options["Change Input"] = image(icon = 'icons/mob/radial.dmi', icon_state = "auto_change_input")
	i_o_radial_options["Change Output"] = image(icon = 'icons/mob/radial.dmi', icon_state = "auto_change_output")
	*/

/obj/machinery/automation/proc/try_output(atom/movable/a) //Try to output a onto a turf,
	for(var/index in shuffle(acceptable_output))
		if(acceptable_output[index])
			a.loc = get_step(src, text2dir(index))
			break
	if(a.loc == src) //Item is still stuck in here, no outputted directions located
		jammed = TRUE
		return

/obj/machinery/automation/process()
	. = ..()
	if(loc != last_turf)
		update_acceptable_outputs()
	if(.)
		current_work_tick += 1
	if(jammed)
		if(current_work_tick % 20 == 0) //Check every 2 seconds to update inputs
			update_acceptable_outputs()
		return FALSE

/obj/machinery/automation/proc/update_acceptable_outputs()
	for(var/obj/machinery/conveyor/convey in orange(1, src))
		if(convey)
			if(get_dir(convey, src) == convey.movedir) //Don't make the automatic machine output into a conveyor delivering into it
				return
			else
				acceptable_output[dir2text(get_dir(src, convey))] = convey

/obj/machinery/automation/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>Alt click the machine to configure settings!</span>")
	if(jammed)
		to_chat(user, "<span class='warning'>This machine is jammed due to a lack of conveyors to output to!!!</span>")
	if(get_dist(src, user) < 2)
		to_chat(user, "This machine seems to be outputting information about it's current status described in the following:")
		return TRUE
	else
		to_chat(user, "If you get closer to this machine, you can perhaps figure out more information about it's current status.")
		return FALSE

/obj/machinery/automation/Bumped(atom/input)
	if(!ismob(input)) //No mobs into the machine please thank you
		contents += input
	return ..()

//Radial settings instead of TGUI
/obj/machinery/automation/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	MakeRadial(user)
	return ..()

/obj/machinery/automation/proc/MakeRadial(mob/living/user)
	return
	/*
	var/category = show_radial_menu(user, src, radial_categories, null, require_near = TRUE)
	if(category)
		switch(category)
			if("I/O Settings") //Adjust the IO settings
				var/i_or_o = show_radial_menu(user, src, i_o_radial_options, null, require_near = TRUE)
				if(i_or_o)
					return
	*/
