/obj/item/wallframe/pdc_frame
	name = "PDC loading rack frame"
	desc = "Used for building PDC loading racks."
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "pdc_frame"
	result_path = /obj/structure/frame/machine/ship_weapon/pdc_mount
	materials = list(/datum/material/iron=MINERAL_MATERIAL_AMOUNT*5)

/obj/structure/frame/machine/ship_weapon/pdc_mount
	name = "PDC loading rack frame"
	desc = "Used for building PDC loading racks."
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "pdc_frame"
	pixel_y = 26
	density = FALSE

/obj/structure/frame/machine/ship_weapon/pdc_mount/examine(mob/user)
	. = ..()
	switch(state)
		if(1)
			if(anchored)
				. += "It is <b>bolted</b> to the wall, but lacks <i>wires</i>."
			else
				. += "The <i>bolts</i> are loose. You could probably <b>lift</b> it off."
		if(2)
			. += "The frame is <b>wired</b> but missing its <i>circuitboard</i>."

/obj/structure/frame/machine/ship_weapon/pdc_mount/New(loc, ndir=dir)
	. = ..()
	if(ndir)
		setDir(ndir)

	update_icon()

/obj/structure/frame/machine/ship_weapon/pdc_mount/setDir(newdir)
	. = ..()
	pixel_x = (dir & 3)? 0 : (dir == 4 ? -26 : 26)
	pixel_y = (dir & 3)? (dir == 1 ? -26 : 26) : 0

	update_icon()

/obj/structure/frame/machine/ship_weapon/pdc_mount/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/circuitboard/machine) && !istype(P, /obj/item/circuitboard/machine/pdc_mount))// Only accept our specific circuitboard
		to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
		return TRUE
	if((state == 1) && (P.tool_behaviour == TOOL_SCREWDRIVER) && !anchored)
		to_chat(user, "<span class='warning'>Remove it from the wall first!</span>")
		return TRUE
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/frame/machine/ship_weapon/pdc_mount/wrench_act(mob/user, obj/item/tool)
	if(circuit)
		to_chat(user, "<span class='warning'>Remove the circuitboard first!</span>")
		return TRUE
	. = ..()

/obj/structure/frame/machine/ship_weapon/pdc_mount/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/structure/frame/machine/ship_weapon/pdc_mount/attack_hand(mob/user)
	. = ..()
	switch(state)
		if(1)
			if(!do_after(user, 2 SECONDS, target=src))
				return TRUE
			to_chat(user, "<span class='notice'>You remove the frame from the wall.</span>")
			new /obj/item/wallframe/pdc_frame(loc)
			qdel(src)
			return TRUE
		if(2)
			if(anchored)
				to_chat(user, "<span class='warning'>You need to unbolt the frame to do that!</span>")
			else
				to_chat(user, "<span class='warning'>Remove the wires first!</span>")
			return TRUE
