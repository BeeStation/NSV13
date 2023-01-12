/mob/living/silicon/examine(mob/user) //Displays a silicon's laws to ghosts
	. = ..()
	if(laws && isobserver(user))
		. += "<b>[src] has the following laws:</b>"
		for(var/law in laws.get_law_list(include_zeroth = TRUE))
			. += law

	//NSV13 - Silicon Flavor Text - Start
	if(client)
		var/line = "<span class='notice'><a href='?src=[REF(src)];lookup_info=1'>Examine closely...</a></span>"
		if(line)
			. += line
	//NS13 - Silicon Flavor Text - End
