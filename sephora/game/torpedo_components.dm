/obj/structure/munition/torpedo_casing
	name = "torpedo casing"
	icon = 'icons/obj/structures.dmi'
	icon_state = "table"
	desc = "The outer casing of a 30mm torpedo."
	anchored = TRUE
	density = TRUE
	climbable = TRUE
	var/state = 0
	var/wh = null
	var/gs = null
	var/ps = null
	var/iff = null

/obj/structure/munition/torpedo_casing/examine(mob/user) //No better guide than an in-game play-by-play guide
	. = ..()
	switch(state)
		if(0)
			. += "<span class='notice'>The casing is empty, awaiting the installation of a propulsion system.</span>"
		if(1)
			. += "<span class='notice'>The propulsion system is sitting loose the casing. *wrench action*</span>"
		if(2)
			. += "<span class='notice'>The propulsion system is secured in the tail half of the casing, now for the guidance system.</span>"
		if(3)
			. += "<span class='notice'>The guidance system is sitting loose in the casing next to the propulsion system. *screwdriver action*</span>"
		if(4)
			. += "<span class='notice'>The propulsion and guidance systems are secured in the casing. Better install the IFF chip.</span>"
		if(5)
			. += "<span class='notice'>The IFF chip is sitting loose in its slot in the guidance system. *screwdriver action*</span>"
		if(6)
			. += "<span class='notice'>The propulsion system, guidance system and IFF chip are all secured. There is a space at the nose end for a warhead.</span>"
		if(7)
			. += "<span class='notice'>The warhead is loose at the nose end of the casing. *wrench action*</span>"
		if(8)
			. += "<span class='notice'>The casing contains the warhead, an IFF chip, guidance and propulsion systems. They are not yet wired together. *wire action*</span>"
		if(9)
			. += "<span class='notice'>The casing has the following components installed: [wh.name], [iff.name], [gs.name], [ps.name]. It looks ready to close and seal. *wrench action*</span>"
		if(10)
			. += "<span class='notice'>The casing has been closed and bolted shut. It only requires sealing to be ready for action. *weld action*</span>"

/obj/structure/munition/torpedo_casing/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/torpedo/warhead))
		if(state == 6)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			W.use(1)
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			wh = W
			state = 7
			update_icon()
		return
	else if(istype(W, /obj/item/torpedo/guidance_system))
		if(state == 2)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			W.use(1)
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			gs = W
			state = 3
			update_icon()
		return
	else if(istype(W, /obj/item/torpedo/propulsion_system))
		if(state == 0)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			W.use(1)
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			ps = W
			state = 1
			update_icon()
		return
	else if(istype(W, /obj/item/torpedo/iff_chip))
		if(state == 4)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			W.use(1)
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			iff = W
			state = 5
			update_icon()
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(state == 8)
			if(C.get_amount() < 3)
				to_chat(user, "<span class='notice'>You need at least three cable pieces to wire [src]!</span>") //for 'realistic' wire spaghetti'
				return
			to_chat(user, "<span class='notice'>You start wiring [src]...</span>")
			W.use(3)
			to_chat(user, "<span class='notice'>You wire [src].</span>")
			state = 9
			update_icon()
		return

/obj/structure/munition/torpedo_casing/wrench_act(mob/user, /obj/item/tool)
	. = FALSE
	switch(state)
		if(1)
			to_chat(user, "<span class='notice'>You start securing [ps.name] to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You secure [ps.name] to [src]. </span>")
				state = 2
				update_icon()
			return TRUE
		if(2)
			to_chat(user, "<span class='notice'>You start unsecuring [ps.name] to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unsecure [ps.name] to [src]. </span>")
				state = 1
				update_icon()
			return TRUE
		if(7)
			to_chat(user, "<span class='notice'>You start securing [wh.name] to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You secure [wh.name] to [src]. </span>")
				state = 8
				update_icon()
			return TRUE
		if(8)
			to_chat(user, "<span class='notice'>You start unsecuring [wh.name] to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unsecure [wh.name] to [src]. </span>")
				state = 7
				update_icon()
			return TRUE
		if(9)
			to_chat(user, "<span class='notice'>You start closing the casing and securing [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You close the casing and secure [src]. </span>")
				state = 10
				update_icon()
			return TRUE
		if(10)
			to_chat(user, "<span class='notice'>You start unsecuring [src] and opening the casing...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unsecure [src] and open the casing. </span>")
				state = 9
				update_icon()
			return TRUE

/obj/structure/munition/torpedo_casing/screwdriver_act(mob/user, /obj/item/tool)
	. = FALSE
	switch(state)
		if(3)
			to_chat(user, "<span class='notice'>You start securing [gs.name] to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You secure [gs.name] to [src]. </span>")
				state = 4
				update_icon()
			return TRUE
		if(4)
			to_chat(user, "<span class='notice'>You start unsecuring [gs.name] to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unsecure [gs.name] to [src]. </span>")
				state = 3
				update_icon()
			return TRUE
		if(5)
			to_chat(user, "<span class='notice'>You start securing [iff.name] to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You secure [iff.name] to [src]. </span>")
				state = 6
				update_icon()
			return TRUE
		if(6)
			to_chat(user, "<span class='notice'>You start unsecuring [iff.name] to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unsecure [iff.name] to [src]. </span>")
				state = 5
				update_icon()
			return TRUE

/obj/structure/munition/torpedo_casing/wirecutter_act(mob/user, /obj/item/tool)
	. = ..()
	if(state == 9)
		to_chat(user, "<span class='notice'>You start cutting the wiring in [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You cut the wiring in [src].</span>")
			var/obj/item/stack/cable_coil/C = new (loc, 3)
			C.add_fingerprint(user)
			state = 8
			update_icon()
		return TRUE

/obj/structure/munition/torpedo_casing/welder_act(mob/user, /obj/item/tool)
	. = FALSE
	switch(state)
		if(0)
			to_chat(user, "<span class='notice'>You start disassembling [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You disassmeble [src].</span>")
				var/obj/item/stack/sheet/metal/M = new (loc, 15)
				M.add_fingerprint(user)
				qdel(src)
			return TRUE
		if(10)
			to_chat(user, "<span class='notice'>You start sealing the casing on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'You seal the casing on [src].</span>")
				//new_torpedo(wh, gs, ps, iff)
			return TRUE

/obj/structure/munition/torpedo_casing/crowbar_act(mob/user, /obj/item/tool)
	. = FALSE
	switch(state)
		if(1)
			to_chat(user, "<span class='notice'>You start removing [ps.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [ps.name] from [src].</span>")
				var/obj/item/torpedo/propulsion_system/I = new (loc, 1)
				I.add_fingerprint(user)
				ps = null
				state = 0
				update_icon()
			return TRUE
		if(3)
			to_chat(user, "<span class='notice'>You start removing [gs.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [gs.name] from [src].</span>")
				var/obj/item/torpedo/guidance_system/I = new (loc, 1)
				I.add_fingerprint(user)
				gs = null
				state = 2
				update_icon()
			return TRUE
		if(5)
			to_chat(user, "<span class='notice'>You start removing [iff.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [iff.name] from [src].</span>")
				var/obj/item/torpedo/iff_chip/I = new (loc, 1)
				I.add_fingerprint(user)
				iff = null
				state = 4
				update_icon()
			return TRUE
		if(7)
			to_chat(user, "<span class='notice'>You start removing [wh.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [wh.name] from [src].</span>")
				var/obj/item/torpedo/warhead/I = new (loc, 1)
				I.add_fingerprint(user)
				wh = null
				state = 6
				update_icon()
			return TRUE

/obj/structure/munition/torpedo_casing/update_icon()
	cut_overlays()
	switch(state)
		if(1)
			add_overlay("speaking_tile")
		if(2)
			add_overlay("")
		if(3)
			add_overlay("")
		if(4)
			add_overlay("")
		if(5)
			add_overlay("")
		if(6)
			add_overlay("")
		if(7)
			add_overlay("")
		if(8)
			add_overlay("")
		if(9)
			add_overlay("")
		if(10)
			add_overlay("fancy_table")

/obj/item/torpedo/warhead
	name = "torpedo warhead"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	desc = "a torpedo warhead"
	var/payload = null

/obj/item/torpedo/guidance_system
	name = "guidance system"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "advmop"
	desc = "a torpedo guidance system"
	var/accuracy = null

/obj/item/torpedo/propulsion_system
	name = "propulsion system"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "smmop"
	desc = "a torpedo propulsion system"
	var/burntime = null
	var/turnrate = null

/obj/item/torpedo/iff_chip //use multitool to calibrate IFF? This should be abuseable via emag
	name = "IFF chip"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "adv_smmop"
	desc = "a torpedo IFF chip"
	var/calibrated = FALSE

/obj/item/torpedo/iff_chip/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	user.visible_message("<span class='warning'>[user] shorts out [src]!</span>",
						"<span class='notice'>You short out the IFF protocols on [src].</span>",
						"Bzzzt.")
