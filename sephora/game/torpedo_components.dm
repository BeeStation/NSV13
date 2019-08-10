#define STATE_0
#define STATE_1
#define STATE_2
#define STATE_3
#define STATE_4
#define STATE_5
#define STATE_6
#define STATE_7
#define STATE_8
#define STATE_9
#define STATE_10
#define wh
#define gs
#define ps
#define iff

/obj/structure/munition/torpedo_casing
	name = "torpedo casing"
	icon = 'icons/obj/structures.dmi'
	icon_state = "table"
	desc = "The outer casing of a 30mm torpedo."
	anchored = TRUE
	density = TRUE
	climbable = TRUE
	var/state = STATE_0
	var/wh = null
	var/gs = null
	var/ps = null
	var/iff = null

/obj/structure/munition/torpedo_casing/examine(mob/user) //No better guide than an in-game play-by-play guide
	. = ..()
	switch(state)
		if(STATE_0)
			. += "<span class='notice'>The casing is empty, awaiting the installation of a propulsion system.</span>"
		if(STATE_1)
			. += "<span class='notice'>The propulsion system is sitting loose the casing. *wrench action*</span>"
		if(STATE_2)
			. += "<span class='notice'>The propulsion system is secured in the tail half of the casing, now for the guidance system.</span>"
		if(STATE_3)
			. += "<span class='notice'>The guidance system is sitting loose in the casing next to the propulsion system. *screwdriver action*</span>"
		if(STATE_4)
			. += "<span class='notice'>The propulsion and guidance systems are secured in the casing. Better install the IFF chip.</span>"
		if(STATE_5)
			. += "<span class='notice'>The IFF chip is sitting loose in its slot in the guidance system. *screwdriver action*</span>"
		if(STATE_6)
			. += "<span class='notice'>The propulsion system, guidance system and IFF chip are all secured. There is a space at the nose end for a warhead.</span>"
		if(STATE_7)
			. += "<span class='notice'>The warhead is loose at the nose end of the casing. *wrench action*</span>"
		if(STATE_8)
			. += "<span class='notice'>The casing contains the warhead, an IFF chip, guidance and propulsion systems. They are not yet wired together. *wire action*</span>"
		if(STATE_9)
			. += "<span class='notice'>The casing has the following components installed: [name.wh], [name.iff], [name.gs], [name.ps]. It looks ready to close and seal. *wrench action*</span>"
		if(STATE_10)
			. += "<span class='notice'>The casing has been closed and bolted shut. It only requires sealing to be ready for action. *weld action*</span>"

/obj/structure/munition/torpedo_casing/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/torpedo/warhead))
		if(state == STATE_6)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			W.use(1)
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			wh = W
			state = STATE_7
			update_icon()
			return
	else if(istype(W, /obj/item/torpedo/guidance_system))
		if(state == STATE_2)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			W.use(1)
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			gs = W
			state = STATE_3
			update_icon()
			return
	else if(istype(W, /obj/item/torpedo/propulsion_system))
		if(state == STATE_0)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			W.use(1)
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			ps = W
			state = STATE_1
			update_icon()
			return
	else if(istype(W, /obj/item/torpedo/iff_chip))
		if(state == STATE_4)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			W.use(1)
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			iff = W
			state = STATE_5
			update_icon()
			return
	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(state == STATE_8)
			if(C.get_amount() < 3)
				to_chat(user, "<span class='notice'>You need at least three cable pieces to wire [src]!</span>") //for 'realistic' wire spaghetti'
				return
			to_chat(user, "<span class='notice'>You start wiring [src]...</span>")
			W.use(3)
			to_chat(user, "<span class='notice'>You wire [src].</span>")
			state = STATE_9
			update_icon()
			return

/obj/structure/munition/torpedo_casing/wrench_act(mob/user, /obj/item/tool)
	. = ..()
	if(state == STATE_1)
		to_chat(user, "<span class='notice'>You start securing [name.ps] to [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You secure [name.ps] to [src]. </span>")
			state = STATE_2
			update_icon()
			return
	else if(state == STATE_2)
		to_chat(user, "<span class='notice'>You start unsecuring [name.ps] to [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You unsecure [name.ps] to [src]. </span>")
			state = STATE_1
			update_icon()
			return
	else if(state == STATE_7)
		to_chat(user, "<span class='notice'>You start securing [name.wh] to [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You secure [name.wh] to [src]. </span>")
			state = STATE_8
			update_icon()
			return
	else if(state == STATE_8)
		to_chat(user, "<span class='notice'>You start unsecuring [name.wh] to [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You unsecure [name.wh] to [src]. </span>")
			state = STATE_7
			update_icon()
			return
	else if(state == STATE_9)
		to_chat(user, "<span class='notice'>You start closing the casing and securing [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You close the casing and secure [src]. </span>")
			state = STATE_10
			update_icon()
			return
	else if(state == STATE_10)
		to_chat(user, "<span class='notice'>You start unsecuring [src] and opening the casing...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You unsecure [src] and open the casing. </span>")
			state = STATE_9
			update_icon()
			return

/obj/structure/munition/torpedo_casing/screwdriver_act(mob/user, /obj/item/tool/)
	. = ..()
	if(state == STATE_3)
		to_chat(user, "<span class='notice'>You start securing [name.gs] to [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You secure [name.gs] to [src]. </span>")
			state = STATE_4
			update_icon()
			return
	else if(state == STATE_4)
		to_chat(user, "<span class='notice'>You start unsecuring [name.gs] to [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You unsecure [name.gs] to [src]. </span>")
			state = STATE_3
			update_icon()
			return
	else if(state == STATE_5)
		to_chat(user, "<span class='notice'>You start securing [name.iff] to [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You secure [name.iff] to [src]. </span>")
			state = STATE_6
			update_icon()
			return
	else if(state == STATE_6)
		to_chat(user, "<span class='notice'>You start unsecuring [name.iff] to [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You unsecure [name.iff] to [src]. </span>")
			state = STATE_5
			update_icon()
			return

/obj/structure/munition/torpedo_casing/wirecutter_act(mob/user, /obj/item/tool/)
	. = ..()
	if(state == STATE_9)
		to_chat(user, "<span class='notice'>You start cutting the wiring in [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You cut the wiring in [src].</span>")
			var/obj/item/stack/cable_coil/C = new (loc, 3)
			C.add_fingerprint(user)
			state = STATE_8
			update_icon()
			return

/obj/structure/munition/torpedo_casing/welder_act(mob/user, /obj/item/tool/)
	. = ..()
	if(state == STATE_0)
		to_chat(user, "<span class='notice'>You start disassembling [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You disassmeble [src].</span>")
			var/obj/item/stack/sheet/metal/M = new (loc, 15)
			M.add_fingerprint(user)
			qdel(src)
			return
	else if(state == STATE_10)
		to_chat(user, "<span class='notice'>You start sealing the casing on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'You seal the casing on [src].</span>")
			//new_torpedo(wh, gs, ps, iff)
			return

/obj/structure/munition/torpedo_casing/crowbar_act(mob/user, /obj/item/tool/)
	. = ..()
	if(state == STATE_1)
		to_chat(user, "<span class='notice'>You start removing [name.ps] from [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You remove [name.ps] from [src].</span>")
			var/obj/item/torpedo/propulsion_system/I = new (loc, 1)
			I.add_fingerprint(user)
			ps = null
			state = STATE_0
			update_icon()
			return
	else if(state == STATE_3)
		to_chat(user, "<span class='notice'>You start removing [name.gs] from [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You remove [name.gs] from [src].</span>")
			var/obj/item/torpedo/guidance_system/I = new (loc, 1)
			I.add_fingerprint(user)
			gs = null
			state = STATE_2
			update_icon()
			return
	else if(state == STATE_5)
		to_chat(user, "<span class='notice'>You start removing [name.iff] from [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You remove [name.iff] from [src].</span>")
			var/obj/item/torpedo/iff_chip/I = new (loc, 1)
			I.add_fingerprint(user)
			iff = null
			state = STATE_4
			update_icon()
			return
	else if(state == STATE_7)
		to_chat(user, "<span class='notice'>You start removing [name.wh] from [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You remove [name.wh] from [src].</span>")
			var/obj/item/torpedo/warhead/I = new (loc, 1)
			I.add_fingerprint(user)
			wh = null
			state = STATE_6
			update_icon()
			return

/obj/structure/munition/torpedo_casing/update_icon()
	cut_overlays()
	if(STATE_1)
		add_overlay("speaking_tile")
	if(STATE_2)
		add_overlay("")
	if(STATE_3)
		add_overlay("")
	if(STATE_4)
		add_overlay("")
	if(STATE_5)
		add_overlay("")
	if(STATE_6)
		add_overlay("")
	if(STATE_7)
		add_overlay("")
	if(STATE_8)
		add_overlay("")
	if(STATE_9)
		add_overlay("")
	if(STATE_10)
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

#undefine STATE_0
#undefine STATE_1
#undefine STATE_2
#undefine STATE_3
#undefine STATE_4
#undefine STATE_5
#undefine STATE_6
#undefine STATE_7
#undefine STATE_8
#undefine STATE_9
#undefine STATE_10
#undefine wh
#undefine gs
#undefine ps
#undefine iff