/obj/structure/munition/torpedo_casing
	name = "NTB-M4A1-IB prebuilt torpedo-casing"
	icon_state = "case"
	desc = "The outer casing of a 30mm torpedo."
	anchored = TRUE
	density = TRUE
	climbable = TRUE
	var/state = 0
	var/obj/item/torpedo/warhead/wh = null
	var/obj/item/torpedo/guidance_system/gs = null
	var/obj/item/torpedo/propulsion_system/ps = null
	var/obj/item/torpedo/iff_card/iff = null
	torpedo_type = /obj/item/projectile/bullet/torpedo/dud //Forget to finish your torpedo? You get a dud torpedo that doesn't do anything

/obj/structure/munition/torpedo_casing/examine(mob/user) //No better guide than an in-game play-by-play guide
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

/obj/structure/munition/torpedo_casing/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/torpedo/warhead))
		if(state == 6)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			do_after(user, 2 SECONDS, target=src)
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			wh = W
			state = 7
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/torpedo/guidance_system))
		if(state == 2)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			do_after(user, 2 SECONDS, target=src)
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			gs = W
			state = 3
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/torpedo/propulsion_system))
		if(state == 0)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			do_after(user, 2 SECONDS, target=src)
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			ps = W
			state = 1
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/torpedo/iff_card))
		if(state == 4)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			do_after(user, 2 SECONDS, target=src)
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			iff = W
			state = 5
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(state == 8)
			if(C.get_amount() < 3)
				to_chat(user, "<span class='notice'>You need at least three cable pieces to wire [src]!</span>") //for 'realistic' wire spaghetti
				return
			to_chat(user, "<span class='notice'>You start wiring [src]...</span>")
			do_after(user, 2 SECONDS, target=src)
			W.use(3)
			to_chat(user, "<span class='notice'>You wire [src].</span>")
			state = 9
			update_icon()
		return

/obj/structure/munition/torpedo_casing/wrench_act(mob/user, obj/item/tool)
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

/obj/structure/munition/torpedo_casing/screwdriver_act(mob/user, obj/item/tool)
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

/obj/structure/munition/torpedo_casing/wirecutter_act(mob/user, obj/item/tool)
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

/obj/structure/munition/torpedo_casing/welder_act(mob/user, obj/item/tool)
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
				var/obj/structure/munition/bomb = new_torpedo(wh, gs, ps, iff)
				bomb.speed = ps.speed //Placeholder, but allows for faster torps if we ever add that
				qdel(src)
			return TRUE

/obj/structure/munition/torpedo_casing/crowbar_act(mob/user, obj/item/tool)
	. = FALSE
	switch(state)
		if(1)
			to_chat(user, "<span class='notice'>You start removing [ps.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [ps.name] from [src].</span>")
				ps = new (loc, 1)
				ps = null
				state = 0
				update_icon()
			return TRUE
		if(3)
			to_chat(user, "<span class='notice'>You start removing [gs.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [gs.name] from [src].</span>")
				gs = new (loc, 1)
				gs = null
				state = 2
				update_icon()
			return TRUE
		if(5)
			to_chat(user, "<span class='notice'>You start removing [iff.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [iff.name] from [src].</span>")
				iff = new (loc, 1)
				iff = null
				state = 4
				update_icon()
			return TRUE
		if(7)
			to_chat(user, "<span class='notice'>You start removing [wh.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [wh.name] from [src].</span>")
				wh = new (loc, 1)
				wh = null
				state = 6
				update_icon()
			return TRUE

/obj/structure/munition/torpedo_casing/update_icon()
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

/obj/structure/munition/torpedo_casing/proc/new_torpedo(obj/item/torpedo/warhead, obj/item/torpedo/guidance_system, obj/item/torpedo/propulsion_system, obj/item/torpedo/iff_card)
	if(istype(warhead, /obj/item/torpedo/warhead))
		switch(warhead.type)
			if(/obj/item/torpedo/warhead)
				return new /obj/structure/munition(get_turf(src))
			if(/obj/item/torpedo/warhead/bunker_buster)
				return new /obj/structure/munition/hull_shredder(get_turf(src))
			if(/obj/item/torpedo/warhead/lightweight)
				return new /obj/structure/munition/fast(get_turf(src))
			if(/obj/item/torpedo/warhead/decoy)
				return new /obj/structure/munition/decoy(get_turf(src))
			if(/obj/item/torpedo/warhead/nuclear)
				return new /obj/structure/munition/nuke(get_turf(src))

/obj/item/torpedo/warhead
	name = "NTP-2 standard torpedo warhead"
	icon = 'sephora/icons/obj/munitions.dmi'
	icon_state = "warhead"
	desc = "A heavy warhead designed to be fitted to a torpedo. It's currently inert."
	w_class = WEIGHT_CLASS_HUGE
	var/payload = null

/obj/item/torpedo/warhead/bunker_buster
	name = "NTP-4 'BNKR' torpedo warhead"
	desc = "a bunker buster torpedo warhead"
	icon_state = "warhead_shredder"
	desc = "An extremely heavy warhead designed to be fitted to a torpedo. This one has an inbuilt plasma charge to amplify its damage."

/obj/item/torpedo/warhead/lightweight
	name = "NTP-1 'SPD' lightweight torpedo warhead"
	desc = "a lightweight torpedo warhead"
	icon_state = "warhead_highvelocity"
	desc = "A stripped down warhead designed to be fitted to a torpedo. Due to its reduced weight, torpedoes with these equipped will travel more quickly."

/obj/item/torpedo/warhead/decoy
	name = "NTP-0x 'DCY' electronic countermeasure torpedo payload"
	desc = "a decoy torpedo warhead"
	icon_state = "warhead_decoy"
	desc = "A simple electronic countermeasure wrapped in a metal casing. While these form inert torpedoes, they can be used to distract enemy PDC emplacements to divert their flak away from other targets."

/obj/item/torpedo/warhead/nuclear
	name = "nuclear torpedo warhead"
	desc = "a nuclear torpedo warhead"
	icon_state = "warhead_nuclear"
	desc = "An advanced warhead which carries a nuclear fission explosive. Torpedoes equipped with these can quickly annihilate targets with extreme prejudice, however they are extremely costly to produce."

/obj/item/torpedo/guidance_system
	name = "torpedo guidance system"
	icon = 'sephora/icons/obj/munitions.dmi'
	icon_state = "guidance"
	desc = "A guidance module for a torpedo which allows them to lock onto a target inside their operational range. The microcomputer inside it is capable of performing thousands of calculations a second."
	w_class = WEIGHT_CLASS_NORMAL
	var/accuracy = null

/obj/item/torpedo/propulsion_system
	name = "torpedo propulsion system"
	icon = 'sephora/icons/obj/munitions.dmi'
	icon_state = "propulsion"
	desc = "A gimballed thruster with an attachment nozzle, designed to be mounted in torpedoes."
	w_class = WEIGHT_CLASS_BULKY
	var/speed = 1

/obj/item/torpedo/iff_card //This should be abuseable via emag
	name = "torpedo IFF card"
	icon = 'sephora/icons/obj/munitions.dmi'
	icon_state = "iff"
	desc = "An IFF chip which allows a torpedo to distinguish friend from foe. The electronics contained herein are relatively simple, but they form a crucial part of any good torpedo."
	w_class = WEIGHT_CLASS_SMALL
	var/calibrated = FALSE

/obj/item/torpedo/iff_card/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	user.visible_message("<span class='warning'>[user] shorts out [src]!</span>",
						"<span class='notice'>You short out the IFF protocols on [src].</span>",
						"Bzzzt.")

/datum/techweb_node/basic_torpedo_components
	id = "basic_torpedo_components"
	display_name = "Basic Torpedo Components"
	description = "A how-to guide of fabricating torpedos while out in the depths of space."
	prereq_ids = list("explosive_weapons")
	design_ids = list("warhead", "bb_warhead", "lw_warhead", "decoy_warhead", "nuke_warhead", "guidance_system", "propulsion_system", "iff_card")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/design/warhead
	name = "Torpedo Warhead"
	desc = "The stock standard warhead design for torpedos"
	id = "warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/glass = 5000)
	build_path = /obj/item/torpedo/warhead
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/bb_warhead
	name = "Bunker Buster Torpedo Warhead"
	desc = "A bunker buster warhead design for torpedos"
	id = "bb_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/plasma = 5000, /datum/material/glass = 5000)
	build_path = /obj/item/torpedo/warhead/bunker_buster
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/lw_warhead
	name = "Lightweight Torpedo Warhead"
	desc = "A lightweight warhead design for torpedos"
	id = "lw_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500)
	build_path = /obj/item/torpedo/warhead/lightweight
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/decoy_warhead
	name = "Decoy Torpedo Warhead"
	desc = "A decoy warhead design for torpedos"
	id = "decoy_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000)
	build_path = /obj/item/torpedo/warhead/decoy
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/nuclear_warhead
	name = "Nuclear Torpedo Warhead"
	desc = "A nuclear warhead design for torpedos"
	id = "nuke_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/plasma = 10000, /datum/material/uranium = 5000)
	build_path = /obj/item/torpedo/warhead/nuclear
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/guidance_system
	name = "Torpedo Guidance System"
	desc = "The stock standard guidance system design for torpedos"
	id = "guidance_system"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000)
	build_path = /obj/item/torpedo/guidance_system
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/propulsion_system
	name = "Torpedo Propulsion System"
	desc = "The stock standard propulsion system design for torpedos"
	id = "propulsion_system"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000)
	build_path = /obj/item/torpedo/propulsion_system
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/iff_card
	name = "Torpedo IFF Card"
	desc = "The stock standard IFF card design for torpedos"
	id = "iff_card"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 20000, /datum/material/iron = 5000)
	build_path = /obj/item/torpedo/iff_card
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO