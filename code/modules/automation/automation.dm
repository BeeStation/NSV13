//An attempt at a assembly line for the vault or possibly as a wasteland ruin, put in recycling due to proximity towards conveyors

//Basic parent type that handles inserting objects into itself when getting Bumped() and changing output direction with multitool
/obj/machinery/automation
	name = "Shouldn't exist reeeee"
	var/outputdir = SOUTH //Outputs finished stuff south by default
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-o0"
	density = TRUE
	speed_process = TRUE //Every 0.2 seconds instead of 2
	var/list/radial_categories = list(
	)
	var/current_work_tick = 0 //Don't want to do stuff every 0.2 seconds? throw a % at it

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
	/*
	radial_categories["I/O Settings"] = image(icon = 'icons/mob/radial.dmi', icon_state = "auto_change_io")
	i_o_radial_options["Change Input"] = image(icon = 'icons/mob/radial.dmi', icon_state = "auto_change_input")
	i_o_radial_options["Change Output"] = image(icon = 'icons/mob/radial.dmi', icon_state = "auto_change_output")
	*/

/obj/machinery/automation/process()
	. = ..()
	if(.)
		current_work_tick += 1

/obj/machinery/automation/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt click the machine to configure settings!</span>")
	if(get_dist(src, user) < 2)
		to_chat(user, "This machine seems to be outputting information about it's current status described in the following:")
		to_chat(user, "<span class='notice'>It's currently outputting products in the direction of <span class='bold'>[dir2text(outputdir)].</span></span>")
		return TRUE
	else
		to_chat(user, "If you get closer to this machine, you can perhaps figure out more information about it's current status.")
		return FALSE

/obj/machinery/automation/Bumped(atom/input)
	if(!((get_dir(src, input) == outputdir)))
		return ..()
	else
		contents += input

/obj/machinery/automation/multitool_act(mob/living/user, obj/item/multitool)
	if(get_dir(src, user) in GLOB.cardinals)
		to_chat(user, "You set the output of the machine to [get_dir(src, user)].")
		outputdir = get_dir(src, user)

//Radial settings instead of TGUI as an alternative
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
