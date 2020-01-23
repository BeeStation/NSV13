#define BS_MOUNT_UNBOLTED 1		// 4 sheets of plasteel
#define BS_MOUNT_BOLTED 2
#define BS_MOUNT_WELDED 3
#define BS_BARREL_ADDED 4		// 4 nanocarbon glass
#define BS_BARREL_BOLTED 5
#define BS_RAILS_PLACED 6		// 2 rails
#define BS_RAILS_BOLTED 7
#define BS_CAPACITORS_PLACED 8	// 2 capacitors
#define BS_CAPACITORS_SECURED 9
#define BS_WIRED 10				// 4 pieces of wire
#define BS_WIRES_SOLDERED 11
#define BS_ELECTRONICS_LOOSE 12	// Firing electronics
#define BS_ELECTRONICS_SECURE 13
#define BS_CASING_ADDED 14		// 2 sheets of plasteel
#define BS_LOADING_TRAY_INSERTED 15	// Loading tray

/obj/structure/ship_weapon/railgun_assembly
	name = "NT-STC4 Ship railgun mount"
	desc = "An incomplete assembly for an NT-STC4 ship mounted railgun chamber."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "OBC"
	bound_width = 128
	bound_height = 64
	pixel_y = -64
	anchored = FALSE
	density = TRUE

	var/state = BS_MOUNT_UNBOLTED
	var/capacitors = 0
	var/rails = 0

/obj/structure/ship_weapon/railgun_assembly/examine()
	. = ..()
	switch(state)
	if(BS_MOUNT_UNBOLTED)
		. += "It is <i>unbolted</i> from the floor."
	if(BS_MOUNT_BOLTED)
		. += "It is <b>bolted</b> down and can be <i>welded</i> to the floor."
	if(BS_MOUNT_WELDED)
		. += "It is <b>welded</i> to the floor and has empty slots for <i>nanocarbon insulation</i> along the barrel."
	if(BS_BARREL_BOLTED)
		. += "The <i>bolts</i> on the nanocarbon insulation are loose. It could be <b>pried out</b>."
	if(BS_BARREL_BOLTED)
		var/rails_needed = 2 - rails
		. += "The nanocarbon insulation is <b>bolted</b> to the barrel and there is room for [rails_needed] rail[(rails_needed != 1) ? "s"]."
	if(BS_RAILS_PLACED)
		. += "The condductive rails are loose in the frame. They could be <b>pried out</b> or <i>bolted</i> down."
	if(BS_RAILS_BOLTED)
		var/capacitors_needed = 4 - capacitors
		. += "The rails are secured. There is space for [capacitors_needed] capacitor[(capacitors_needed != 1) ? "s"]."
	if(BS_CAPACITORS_PLACED)
		. += "The capacitors are in place. The <i>screws</i> are loose, and they could be <b>removed</b> by hand."
	if(BS_CAPACITORS_SECURED)
		. += "The capacitors are <b>screwed</b> in place, but lack <i>wiring</i>."
	if(BS_WIRED)
		. += "The capacitors are <b>wired</b> to the rails and can be <i>soldered<i/> in place."
	if(BS_WIRES_SOLDERED)
		. += "The capacitors are <b>soldered</b> to the rails, and the <i>firing electronics</i> are missing."
	if(BS_ELECTRONICS_LOOSE)
		. += "The firing electronics sit loose in the frame. They could be <b>pried out<b> or <i>screwed</i> into place."
	if(BS_ELECTRONICS_SECURE)
		. += "The firing electronics are <b>screwed</b> into place. The railgun is missing a <i>metal casing</i>."
	if(BS_CASING_ADDED)
		. += "The metal casing can be <b>sliced away</b>. The <i>loading tray</i> is missing."


/obj/structure/ship_weapon/railgun_assembly/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(W.tool_behaviour == TOOL_WRENCH)
		if(!anchored && (state == BS_MOUNT_UNBOLTED))
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You bolt the [src] to the floor.</span>")
			anchored = TRUE
			state = BS_MOUNT_BOLTED
			return

		if(state == BS_BARREL_ADDED)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You secure the insulated barrel.</span>")
			state = BS_BARREL_BOLTED
			return

		if(state == BS_RAILS_PLACED)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You bolt the conductive rails to the frame.</span>")
			state = BS_RAILS_BOLTED
			return
		return

	else if(W.tool_behaviour == TOOL_WELDER)
		if(anchored && (state == BS_MOUNT_BOLTED))
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You weld the [src] to the floor.</span>")
			state = BS_MOUNT_WELDED
			return

		if(state == BS_WIRED)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You solder the wiring into place.</span>")
			state = BS_WIRES_SOLDERED
			return
		return

	else if(istype(W, /obj/item/stack/sheet/nanocarbon_glass) && (state == BS_MOUNT_WELDED))
		var/obj/item/stack/sheet/nanocarbon_glass/S = W
		if(S.get_amount() < 4)
			to_chat(user, "<span class='warning'>You need four sheets of [S] to insulate the railgun!</span>")
			return
		if(!do_after(user, 2 SECONDS, target=src))
			return
		if(S.get_amount() < 4) // Check whether they used too much while standing here...
			to_chat(user, "<span class='warning'>You need four sheets of [S] to insulate the railgun!</span>")
			return
		S.use(4)
		to_chat(user, "<span class='notice'>You line the frame with insulating nanocarbon glass.</span>")
		state = BS_BARREL_ADDED
		return

	else if(istype(W, /obj/item/ship_weapon/parts/railgun_rail))
		if(state == BS_BARREL_BOLTED)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			W.forceMove(src)
			rails++
			to_chat(user, "<span class='notice'>You add the [W] to the [src].</span>")
			if(rails >= 2)
				state = BS_RAILS_PLACED
			return
		return

	else if((istype(W, /obj/item/stock_parts/capacitor)) && (state == BS_RAILS_BOLTED))
		W.forceMove(src)
		capacitors++
		to_chat(user, "<span class='notice'>You add the [W] to the [src].</span>")
		if(capacitors >= 4)
			state = BS_CAPACITORS_PLACED
		return

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(state == BS_CAPACITORS_PLACED)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You screw the capacitors into place.</span>")
			state = BS_CAPACITORS_SECURED
			return

		else if(state == BS_ELECTRONICS_LOOSE)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You secure the electronic firing mechanism.</span>")
			state = BS_ELECTRONICS_SECURE
			return

	else if(istype(W, /obj/item/stack/cable_coil) && (state == BS_CAPACITORS_SECURED))
		var/obj/item/stack/cable_coil/S = W
		if(S.get_amount() < 4)
			to_chat(user, "<span class='warning'>You need four pieces of [S] to wire the railgun!</span>")
			return
		if(!do_after(user, 2 SECONDS, target=src))
			return
		if(S.get_amount() < 4)
			to_chat(user, "<span class='warning'>You need four pieces of [S] to wire the railgun!</span>")
			return
		S.use(4)
		to_chat(user, "<span class='notice'>You wire the power supply to the rails.</span>")
		state = BS_WIRED
		return

	else if((istype(W, /obj/item/ship_weapon/parts/firing_mechanism)) && (state = BS_WIRES_SOLDERED))
		if(!do_after(user, 2 SECONDS, target=src))
			return
		W.forceMove(src)
		to_chat(user, "<span class='notice'>Add the electronic firing mechanism.</span>")
		state = BS_ELECTRONICS_LOOSE
		return

	else if((istype(W, /obj/item/stack/sheet/iron)) && (state == BS_ELECTRONICS_SECURE))
		var/obj/item/stack/sheet/iron/S = W
		if(S.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need four sheets of [S] to finish the [src]!</span>")
			return
		if(!do_after(user, 2 SECONDS, target=src))
			return
		if(S.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need four sheets of [S] to finish the [src]!</span>")
			return
		S.use(2)
		to_chat(user, "<span class='notice'>You add the outer casing to the assembly.</span>")
		state = BS_CASING_ADDED
		return

	else if((istype(W, /obj/item/ship_weapon/parts/loading_tray)) && (state == BS_CASING_ADDED))
		if(!do_after(user, 2 SECONDS, target=src))
			return
		W.forceMove(src)
		to_chat(user, "<span class='notice'>You slide the loading tray into place.</span>")
		var/obj/machinery/ship_weapon/railgun/RG = new(loc)
		RG.setAnchored(anchored)
		RG.on_construction()
		for(var/obj/O in RG.component_parts)
			qdel(O)
		transfer_fingerprints_to(RG)
		RG.component_parts = list()
		for(var/obj/O in src)
			O.moveToNullspace()
			RG.component_parts += O
		qdel(src)
		return
	..()