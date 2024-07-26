//Torpedo construction//

/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	name = "\improper NTB-M4A1-IB prebuilt torpedo-casing"
	icon_state = "case"
	desc = "The outer casing of a 30mm torpedo."
	claimable_gulag_points = 0
	volatility = 0
	var/state = 0
	var/obj/item/ship_weapon/parts/missile/warhead/wh = null
	var/obj/item/ship_weapon/parts/missile/guidance_system/gs = null
	var/obj/item/ship_weapon/parts/missile/propulsion_system/ps = null
	var/obj/item/ship_weapon/parts/missile/iff_card/iff = null
	projectile_type = /obj/item/projectile/guided_munition/torpedo/dud //Forget to finish your torpedo? You get a dud torpedo that doesn't do anything


/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/examine(mob/user) //No better guide than an in-game play-by-play guide
	. = ..()
	switch(state)
		if(0)
			. += "<span class='notice'>The casing is empty, awaiting the installation of a propulsion system.</span>"
		if(1)
			. += "<span class='notice'>The propulsion system is sitting loose the casing. There are bolts to secure it.</span>"
		if(2)
			. += "<span class='notice'>The propulsion system is secured in the tail half of the casing, now for the guidance system.</span>"
		if(3)
			. += "<span class='notice'>The guidance system is sitting loose in the casing next to the propulsion system. There are places for screws to secure the guidance system to the casing. </span>"
		if(4)
			. += "<span class='notice'>The propulsion and guidance systems are secured in the casing. The guidance system has a currently empty slot for an IFF card.</span>"
		if(5)
			. += "<span class='notice'>The IFF card is sitting loose in its slot in the guidance system. There are holes for screws in each corner of the slot.</span>"
		if(6)
			. += "<span class='notice'>The propulsion system, guidance system and IFF card are all secured. There is space at the nose end for a warhead.</span>"
		if(7)
			. += "<span class='notice'>The warhead is sitting snug at the nose end of the casing. The bolts could be tighter.</span>"
		if(8)
			. += "<span class='notice'>The casing contains the warhead, an IFF chip, guidance and propulsion systems. They are not yet wired together.</span>"
		if(9)
			. += "<span class='notice'>The casing has the following components installed: [wh?.name], [iff?.name], [gs?.name], [ps?.name]. It looks ready to close and bolt shut. </span>"
		if(10)
			. += "<span class='notice'>The casing has been closed and bolted shut. It only requires sealing with a welding tool to be ready for action.</span>"

/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/ship_weapon/parts/missile/warhead))
		var/obj/item/ship_weapon/parts/missile/warhead/WW = W
		if(WW.fits_type && !istype(src, WW.fits_type))
			to_chat(user, "<span class='notice'>That warhead won't fit onto [src].</span>")
			return FALSE
		if(state == 6)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			wh = W
			state = 7
			update_icon()
			W.forceMove(src)
		return TRUE
	else if(istype(W, /obj/item/ship_weapon/parts/missile/guidance_system))
		if(state == 2)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			gs = W
			state = 3
			update_icon()
			W.forceMove(src)
		return TRUE
	else if(istype(W, /obj/item/ship_weapon/parts/missile/propulsion_system))
		if(state == 0)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			ps = W
			state = 1
			update_icon()
			W.forceMove(src)
		return TRUE
	else if(istype(W, /obj/item/ship_weapon/parts/missile/iff_card))
		if(state == 4)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			iff = W
			state = 5
			update_icon()
			W.forceMove(src)
		return TRUE
	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(state == 8)
			if(C.get_amount() < 3)
				to_chat(user, "<span class='notice'>You need at least three cable pieces to wire [src]!</span>") //for 'realistic' wire spaghetti
				return
			to_chat(user, "<span class='notice'>You start wiring [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			W.use(3)
			to_chat(user, "<span class='notice'>You wire [src].</span>")
			state = 9
			update_icon()
		return TRUE

/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/wrench_act(mob/user, obj/item/tool)
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
	. = ..()

/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/screwdriver_act(mob/user, obj/item/tool)
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
	. = ..()

/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/wirecutter_act(mob/user, obj/item/tool)
	if(state == 9)
		to_chat(user, "<span class='notice'>You start cutting the wiring in [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You cut the wiring in [src].</span>")
			var/obj/item/stack/cable_coil/C = new (loc, 3)
			C.add_fingerprint(user)
			state = 8
			update_icon()
		return TRUE
	. = ..()

/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/welder_act(mob/user, obj/item/tool)
	//Fixes #620 (https://github.com/BeeStation/NSV13/issues/620)
	if(istype(loc, /obj/structure))
		to_chat(user, "<span class='notice'>[src] is loaded in [loc]. Unload it first.</span>")
		return
	switch(state)
		if(0)
			to_chat(user, "<span class='notice'>You start disassembling [src]...</span>")
			if(tool.use_tool(src, user, 40, amount=1, volume=100))
				to_chat(user, "<span class='notice'>You disassmeble [src].</span>")
				new /obj/item/stack/sheet/iron(loc, 15)
				add_fingerprint(user)
				qdel(src)
			return TRUE
		if(10)
			to_chat(user, "<span class='notice'>You start sealing the casing on [src]...</span>")
			if(tool.use_tool(src, user, 40, amount=1, volume=100))
				to_chat(user, "<span class='notice'You seal the casing on [src].</span>")
				state = 11
				check_completion()
			return TRUE
	. = ..()

/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/proc/check_completion()
	update_icon()
	if(state >= 11)
		new_torpedo(wh, gs, ps, iff)
		return TRUE

/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/crowbar_act(mob/user, obj/item/tool)
	switch(state)
		if(1)
			to_chat(user, "<span class='notice'>You start removing [ps.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [ps.name] from [src].</span>")
				ps?.forceMove(get_turf(src))
				ps = null
				state = 0
				update_icon()
			return TRUE
		if(3)
			to_chat(user, "<span class='notice'>You start removing [gs.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [gs.name] from [src].</span>")
				gs?.forceMove(get_turf(src))
				gs = null
				state = 2
				update_icon()
			return TRUE
		if(5)
			to_chat(user, "<span class='notice'>You start removing [iff.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [iff.name] from [src].</span>")
				iff?.forceMove(get_turf(src))
				iff = null
				state = 4
				update_icon()
			return TRUE
		if(7)
			to_chat(user, "<span class='notice'>You start removing [wh.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [wh.name] from [src].</span>")
				wh?.forceMove(get_turf(src))
				wh = null
				state = 6
				update_icon()
			return TRUE
	. = ..()

/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/update_icon()
	cut_overlays()
	switch(state)
		if(1)
			icon_state = "case_prop"
		if(2)
			icon_state = "case_prop_bolt"
		if(3)
			icon_state = "case_guide"
		if(4)
			icon_state = "case_guide_screw"
		if(5)
			icon_state = "case_iff"
		if(6)
			icon_state = "case_iff_screw"
		if(7)
			icon_state = "case_warhead"
		if(8)
			icon_state = "case_warhead_screw"
		if(9)
			icon_state = "case_warhead_wired"
		if(10)
			icon_state = "case_warhead_complete"

/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/proc/new_torpedo()
	wh = locate(/obj/item/ship_weapon/parts/missile/warhead) in src
	new wh.build_path(get_turf(src))
	for(var/I in contents)
		qdel(I) //Change this if we ever need to add more component factoring in to performance. This avoids infinite torpedo parts because the torpedo gets Qdel'd
	qdel(src)
