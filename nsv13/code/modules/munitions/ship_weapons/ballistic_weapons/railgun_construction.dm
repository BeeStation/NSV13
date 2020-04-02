#define BS_MOUNT_UNBOLTED 1		// 4 sheets of plasteel
#define BS_MOUNT_BOLTED 2
#define BS_MOUNT_WELDED 3
#define BS_BARREL_PLACED 4		// 4 nanocarbon glass
#define BS_BARREL_BOLTED 5
#define BS_RAILS_PLACED 6		// 2 rails
#define BS_RAILS_BOLTED 7
#define BS_CAPACITORS_PLACED 8	// 2 _added
#define BS_CAPACITORS_SECURED 9
#define BS_WIRED 10				// 4 pieces of wire
#define BS_WIRES_SOLDERED 11
#define BS_ELECTRONICS_LOOSE 12	// Firing electronics
#define BS_ELECTRONICS_SECURE 13
#define BS_CASING_ADDED 14		// 2 sheets of plasteel
// Final step - insert loading tray

/obj/structure/ship_weapon/railgun_assembly
	name = "NT-STC4 Ship railgun mount"
	desc = "An incomplete assembly for an NT-STC4 ship mounted railgun chamber."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "railgun_platform"
	bound_width = 128
	bound_height = 64
	pixel_y = -64
	anchored = FALSE
	density = TRUE

	var/state = BS_MOUNT_UNBOLTED
	var/capacitors_added = 0
	var/rails_added = 0

	// Material costs so we can rebalance them easily
	var/num_rails = 2
	var/num_capacitors = 4
	var/num_sheets_frame = 4
	var/num_sheets_casing = 2
	var/num_sheets_insulation = 4
	var/num_cables = 4

/obj/structure/ship_weapon/railgun_assembly/Initialize()
	..()
	if(!contents)
		contents = list()

/obj/structure/ship_weapon/railgun_assembly/examine(mob/user)
	. = ..()
	switch(state)
		if(BS_MOUNT_UNBOLTED)
			. += "It is <i>unbolted</i> from the floor and could be <b>cut apart</b>."
		if(BS_MOUNT_BOLTED)
			. += "It is <b>bolted</b> down and can be <i>welded</i> to the floor."
		if(BS_MOUNT_WELDED)
			. += "It is <b>welded</b> to the floor and has empty slots for <i>nanocarbon insulation</i> along the barrel."
		if(BS_BARREL_PLACED)
			. += "The <i>bolts</i> on the nanocarbon insulation are loose. It could be <b>pried out</b>."
		if(BS_BARREL_BOLTED)
			var/rails_left = num_rails - rails_added
			. += "The nanocarbon insulation is <b>bolted</b> to the barrel and there is room for <i>[rails_left] rail[(rails_left != 1) ? "s" : ""]</i>."
		if(BS_RAILS_PLACED)
			. += "The condductive rails are loose in the frame. They could be <b>pried out</b> or <i>bolted</i> down."
		if(BS_RAILS_BOLTED)
			var/capacitors_left = num_capacitors - capacitors_added
			. += "The rails are <b>bolted</b> in place. There is space for <i>[capacitors_left] capacitor[(capacitors_left != 1) ? "s" : ""]</i>."
		if(BS_CAPACITORS_PLACED)
			. += "The capacitors are in place. The <i>screws</i> are loose, and they could be <b>removed</b> by hand."
		if(BS_CAPACITORS_SECURED)
			. += "The capacitors are <b>screwed</b> in place, but lack <i>wiring</i>."
		if(BS_WIRED)
			. += "The capacitors are <b>wired</b> to the rails and can be <i>soldered<i/> in place."
		if(BS_WIRES_SOLDERED)
			. += "The capacitors are <b>soldered</b> to the rails, and the <i>firing electronics</i> are missing."
		if(BS_ELECTRONICS_LOOSE)
			. += "The firing electronics sit loose in the frame. They could be <b>pried out</b> or <i>screwed</i> into place."
		if(BS_ELECTRONICS_SECURE)
			. += "The firing electronics are <b>screwed</b> into place. The railgun is missing a <i>metal casing</i>."
		if(BS_CASING_ADDED)
			. += "The metal casing can be <b>cut away</b>. The <i>loading tray</i> is missing."

// We just took apart a railgun, put us at the end of the construction sequence
/obj/structure/ship_weapon/railgun_assembly/proc/set_final_state()
	state = BS_CASING_ADDED

/obj/structure/ship_weapon/railgun_assembly/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/stack/sheet/nanocarbon_glass) && (state == BS_MOUNT_WELDED))
		var/obj/item/stack/sheet/nanocarbon_glass/S = W
		if(S.get_amount() < num_sheets_insulation)
			to_chat(user, "<span class='warning'>You need four sheets of [S] to insulate the railgun!</span>")
			return
		if(!do_after(user, 2 SECONDS, target=src))
			return
		if(S.get_amount() < num_sheets_insulation) // Check whether they used too much while standing here...
			to_chat(user, "<span class='warning'>You need four sheets of [S] to insulate the railgun!</span>")
			return
		S.use(num_sheets_insulation)
		to_chat(user, "<span class='notice'>You line the frame with insulating nanocarbon glass.</span>")
		state = BS_BARREL_PLACED
		return TRUE

	else if(istype(W, /obj/item/ship_weapon/parts/railgun_rail))
		if(state == BS_BARREL_BOLTED)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			W.forceMove(src)
			rails_added++
			to_chat(user, "<span class='notice'>You add the [W] to the [src].</span>")
			if(rails_added >= num_rails)
				state = BS_RAILS_PLACED
			return TRUE

	else if((istype(W, /obj/item/stock_parts/capacitor)) && (state == BS_RAILS_BOLTED))
		W.forceMove(src)
		capacitors_added++
		to_chat(user, "<span class='notice'>You add the [W] to the [src].</span>")
		if(capacitors_added >= num_capacitors)
			state = BS_CAPACITORS_PLACED
		return TRUE

	else if(istype(W, /obj/item/stack/cable_coil) && (state == BS_CAPACITORS_SECURED))
		var/obj/item/stack/cable_coil/S = W
		if(S.get_amount() < num_cables)
			to_chat(user, "<span class='warning'>You need four pieces of [S] to wire the railgun!</span>")
			return
		if(!do_after(user, 2 SECONDS, target=src))
			return
		if(S.get_amount() < num_cables)
			to_chat(user, "<span class='warning'>You need four pieces of [S] to wire the railgun!</span>")
			return
		S.use(num_cables)
		to_chat(user, "<span class='notice'>You wire the power supply to the rails.</span>")
		state = BS_WIRED
		return TRUE

	else if((istype(W, /obj/item/ship_weapon/parts/firing_electronics)) && (state = BS_WIRES_SOLDERED))
		if(!do_after(user, 2 SECONDS, target=src))
			return
		W.forceMove(src)
		to_chat(user, "<span class='notice'>Add the electronic firing mechanism.</span>")
		state = BS_ELECTRONICS_LOOSE
		return TRUE

	else if((istype(W, /obj/item/stack/sheet/plasteel)) && (state == BS_ELECTRONICS_SECURE))
		var/obj/item/stack/sheet/plasteel/S = W
		if(S.get_amount() < num_sheets_casing)
			to_chat(user, "<span class='warning'>You need four sheets of [S] to finish the [src]!</span>")
			return
		if(!do_after(user, 2 SECONDS, target=src))
			return
		if(S.get_amount() < num_sheets_casing)
			to_chat(user, "<span class='warning'>You need four sheets of [S] to finish the [src]!</span>")
			return
		S.use(num_sheets_casing)
		to_chat(user, "<span class='notice'>You add the outer casing to the assembly.</span>")
		state = BS_CASING_ADDED
		return TRUE

	else if((istype(W, /obj/item/ship_weapon/parts/loading_tray)) && (state == BS_CASING_ADDED))
		if(!do_after(user, 2 SECONDS, target=src))
			return
		W.forceMove(src)
		to_chat(user, "<span class='notice'>You slide the loading tray into place.</span>")
		var/obj/machinery/ship_weapon/railgun/RG = new(loc)
		RG.dir = dir
		RG.setAnchored(anchored)
		RG.on_construction()
		for(var/obj/O in RG.component_parts)
			qdel(O)
			stoplag()
		transfer_fingerprints_to(RG)
		RG.component_parts = list()
		for(var/obj/O in src)
			O.moveToNullspace()
			RG.component_parts += O
			stoplag()
		qdel(src)
		return TRUE

	..()

/obj/structure/ship_weapon/railgun_assembly/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/structure/ship_weapon/railgun_assembly/attack_hand(mob/user)
	. = ..()
	if(state == BS_CAPACITORS_PLACED)
		if(!do_after(user, 2 SECONDS, target=src))
			return
		to_chat(user, "<span class='notice'>You remove the capacitors.</span>")
		var/obj/item/stock_parts/capacitor/C = (locate(/obj/item/stock_parts/capacitor) in src)
		while(C)
			C.forceMove(loc)
			C = (locate(/obj/item/stock_parts/capacitor) in src)
			stoplag()
		state = BS_RAILS_BOLTED
		return TRUE

/obj/structure/ship_weapon/railgun_assembly/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_MOUNT_UNBOLTED)
			if(!anchored && tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You bolt the [src] to the floor.</span>")
				anchored = TRUE
				state = BS_MOUNT_BOLTED
				return TRUE

		if(BS_BARREL_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You secure the insulated barrel.</span>")
				state = BS_BARREL_BOLTED
				return TRUE

		if(BS_RAILS_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You bolt the conductive rails to the frame.</span>")
				state = BS_RAILS_BOLTED
				return TRUE

		if(BS_RAILS_BOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the rails from the frame.</span>")
				state = BS_RAILS_PLACED
				return TRUE

		if(BS_BARREL_BOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the nanocarbon insulation from the barrel.</span>")
				state = BS_BARREL_PLACED
				return TRUE

		if(BS_MOUNT_BOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the [src] from the floor.</span>")
				state = BS_MOUNT_UNBOLTED
				return TRUE

/obj/structure/ship_weapon/railgun_assembly/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_MOUNT_BOLTED)
			if(anchored && tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>You weld the [src] to the floor.</span>")
				state = BS_MOUNT_WELDED
				return TRUE

		if(BS_WIRED)
			if(tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>You solder the wiring into place.</span>")
				state = BS_WIRES_SOLDERED
				return TRUE

		if(BS_CASING_ADDED)
			if(tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>You slice away the outer casing.</span>")
				new/obj/item/stack/sheet/plasteel(loc, num_sheets_casing)
				state = BS_ELECTRONICS_SECURE
				return TRUE

		if(BS_WIRES_SOLDERED)
			if(tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>You desolder the wires.</span>")
				state = BS_WIRED
				return TRUE

		if(BS_MOUNT_WELDED)
			if(tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>You unweld the [src] from the floor.</span>")
				state = BS_MOUNT_BOLTED
				return TRUE

		if(BS_MOUNT_UNBOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>You cut apart the frame.</span>")
				new/obj/item/stack/sheet/plasteel(loc, num_sheets_frame)
				qdel(src)
				return TRUE

/obj/structure/ship_weapon/railgun_assembly/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_ELECTRONICS_LOOSE)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				var/obj/item/ship_weapon/parts/firing_electronics/F = (locate(/obj/item/ship_weapon/parts/firing_electronics) in src)
				if(F)
					F.forceMove(loc)
				to_chat(user, "<span class='notice'>You pry the firing electronics loose.</span>")
				state = BS_WIRES_SOLDERED
				return TRUE

		if(BS_RAILS_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				var/obj/item/ship_weapon/parts/railgun_rail/R = (locate(/obj/item/ship_weapon/parts/railgun_rail) in src)
				while(R)
					R.forceMove(loc)
					R = (locate(/obj/item/ship_weapon/parts/railgun_rail) in src)
					stoplag()
				to_chat(user, "<span class='notice'>You pry the rails loose.</span>")
				state = BS_BARREL_BOLTED
				return TRUE

		if(BS_BARREL_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				new/obj/item/stack/sheet/nanocarbon_glass(loc, num_sheets_insulation)
				to_chat(user, "<span class='notice'>You pry the nanocargon glass free.</span>")
				state = BS_MOUNT_WELDED
				return TRUE

/obj/structure/ship_weapon/railgun_assembly/wirecutter_act(mob/living/user, obj/item/tool)
	. = ..()
	if(state == BS_WIRED)
		if(tool.use_tool(src, user, 2 SECONDS, volume=100))
			new/obj/item/stack/cable_coil(loc, num_cables)
			to_chat(user, "<span class='notice'>You cut the wires from the frame.</span>")
			state = BS_CAPACITORS_SECURED
			return TRUE

/obj/structure/ship_weapon/railgun_assembly/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_CAPACITORS_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You screw the capacitors into place.</span>")
				state = BS_CAPACITORS_SECURED
				return TRUE

		if(BS_ELECTRONICS_LOOSE)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You secure the firing electronics.</span>")
				state = BS_ELECTRONICS_SECURE
				return TRUE

		if(BS_ELECTRONICS_SECURE)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You unsecure the firing electronics.</span>")
				state = BS_ELECTRONICS_LOOSE
				return TRUE

		if(BS_CAPACITORS_SECURED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You unscrew the capacitors.</span>")
				state = BS_CAPACITORS_PLACED
				return TRUE

#undef BS_MOUNT_UNBOLTED
#undef BS_MOUNT_BOLTED
#undef BS_MOUNT_WELDED
#undef BS_BARREL_PLACED
#undef BS_BARREL_BOLTED
#undef BS_RAILS_PLACED
#undef BS_RAILS_BOLTED
#undef BS_CAPACITORS_PLACED
#undef BS_CAPACITORS_SECURED
#undef BS_WIRED
#undef BS_WIRES_SOLDERED
#undef BS_ELECTRONICS_LOOSE
#undef BS_ELECTRONICS_SECURE
#undef BS_CASING_ADDED
