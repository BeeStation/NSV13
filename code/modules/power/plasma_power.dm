/////////////////////////////
// Definitions
/////////////////////////////

/obj/machinery/power/magnetic_constrictor
	var/const/unconstructed  = 0
	var/const/wrenched       = 1
	var/const/screwed        = 2
	var/const/welded         = 3
	var/const/welded_unwired = 4

	name = "Magnetic Constrictor"
	icon = 'icons/obj/reactor_parts.dmi'
	icon_state = "constrictor_assembly"
	desc = "Magnetic device which manipulates plasma into a constricted plasma flow."
	anchored = FALSE
	density = TRUE
	var/state = unconstructed
//

/obj/machinery/power/magnetic_constrictor/examine(mob/user) //No better guide than an in-game play-by-play guide
	. = ..()
	switch(state)
		if(unconstructed)
			. += "<span class='notice'>The device lies in pieces on the ground, it must be assembled and the bolts wrenched to secure it into place.</span>"
		if(wrenched)
			. += "<span class='notice'>The devices internal wire harnesses must be connected and screwed into place.</span>"
		if(screwed)
			. += "<span class='notice'>Per specifications, the maintenance hatches must be welded shut, normally this device is not tampered with once assembled.</span>"
		if(welded)
			. += "<span class='notice'>You can use a welder to open the device to begin disassembly.</span>"
//

/obj/machinery/power/magnetic_constrictor/wrench_act(mob/user, obj/item/tool)
	. = FALSE
	switch(state)
		if(unconstructed)
			to_chat(user, "<span class='notice'>You start assembly on [src], securing its components into place with bolts...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You complete initial assembly on [src]. </span>")
				anchored = TRUE
				state = wrenched
				update_icon()
			return TRUE
		if(wrenched)
			to_chat(user, "<span class='notice'>You start to disassemble [src] into sheets of metal...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You complete disassembly on [src]. </span>")
				var/obj/item/stack/sheet/metal/M = new (loc, 15)
				M.add_fingerprint(user)
				qdel(src)
			return TRUE
//


/obj/machinery/power/magnetic_constrictor/screwdriver_act(mob/user, obj/item/tool)
	. = FALSE
	switch(state)
		if(wrenched)
			to_chat(user, "<span class='notice'>You start running wires and securing wire harnesses on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You have assembled the wiring on [src]. </span>")
				state = screwed
				update_icon()
			return TRUE
		if(screwed)
			to_chat(user, "<span class='notice'>You start unsecuring wiring harnesses and re-coiling wires on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You undo the wiring of [src]. </span>")
				state = wrenched
				update_icon()
			return TRUE
//

/obj/machinery/power/magnetic_constrictor/welder_act(mob/user, obj/item/tool)
	. = FALSE
	switch(state)
		if(screwed)
			to_chat(user, "<span class='notice'>You start securing the maintenance hatches on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You secure the maintenance hatches on [src].</span>")
				state = welded
				update_icon()
			return TRUE
		if(welded)
			to_chat(user, "<span class='notice'>You start unwelding the maintenance hatches on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'You unweld the maintenance hatches on [src].</span>")
				state = screwed
				update_icon()
			return TRUE
		if(wrenched)
			to_chat(user, "<span class='notice'>You start securing the maintenance hatches on [src] without the wiring...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You secure the maintenance hatches on [src].</span>")
				state = welded_unwired
				update_icon()
			return TRUE
//


/obj/machinery/power/magnetic_constrictor/update_icon()
	cut_overlays()
	switch(state)
		if(unconstructed)
			icon_state = "constrictor_assembly"
		if(wrenched)
			icon_state = "constrictor_wrench"
		if(screwed)
			icon_state = "constrictor_screw"
		if(welded)
			icon_state = "constrictor_assembled"
		if(welded_unwired)
			icon_state = "constrictor_assembled"
//