#define BS_MOUNT_UNBOLTED 1
#define BS_MOUNT_BOLTED 2
#define BS_MOUNT_WELDED 3
#define BS_ELECTRONICS_LOOSE 4
#define BS_ELECTRONICS_SECURE 5
#define BS_UPGRADE_LOOSE 6// Upgrade can be skipped
#define BS_UPGRADE_SECURED 7
#define BS_IGNITERS_PLACED 8
#define BS_IGNITERS_SECURED 9
#define BS_WIRED 10
#define BS_WIRES_SOLDERED 11
#define BS_CASING_ADDED 12
#define BS_BARRELS_PLACED 13
#define BS_BARRELS_SECURED 14
// Final step - insert loading tray

/obj/structure/ship_weapon/artillery_frame
	name = "naval artillery frame"
	desc = "The beginnings of a huge deck gun, internals notwithstanding."
	icon = 'nsv13/icons/obj/munitions/deck_turret.dmi'
	icon_state = "platform"
	anchored = TRUE
	density = TRUE
	pixel_x = -43
	pixel_y = -64
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32

	var/state = BS_MOUNT_UNBOLTED
	var/max_barrels = 1
	var/igniters_added = 0
	var/barrels_added = 0

	var/num_sheets_frame = 20
	var/num_sheets_casing = 2
	var/num_cables = 4
	var/output_path = /obj/machinery/ship_weapon/deck_turret

/obj/structure/ship_weapon/artillery_frame/Initialize(mapload)
	. = ..()
	LAZYINITLIST(contents)

/obj/structure/ship_weapon/artillery_frame/examine(mob/user)
	. = ..()
	var/sare = (max_barrels != 1) ? "s are" : " is"
	var/thit = (max_barrels != 1) ? "they" : "it"
	//shorthands for if barrels are plural or not
	switch(state)
		if(BS_MOUNT_UNBOLTED)
			. += "It is <i>unbolted</i> from the floor and could be <b>cut apart</b>."
		if(BS_MOUNT_BOLTED)
			. += "It is <b>bolted</b> down and can be <i>welded</i> to the floor."
		if(BS_MOUNT_WELDED)
			. += "It is <b>welded</b> to the floor and the <i>firing electronics</i> are missing."
		if(BS_ELECTRONICS_LOOSE)
			. += "The firing electronics sit loose in the frame. They could be <b>pried out</b> or <i>screwed</i> into place."
		if(BS_ELECTRONICS_SECURE)
			. += "The firing electronics are <b>screwed</b> into place. There is a slot for a <i>multibarrel upgrade</i>, or an <i>igniter</i>."
		if(BS_UPGRADE_LOOSE)
			. += "The multibarrel upgrade is loose in the frame. The <i>screws</i> are loose, and it can be <b>pried out</b> of the frame."
		if(BS_UPGRADE_SECURED)
			var/igniters_left = max_barrels - igniters_added
			. += "The multibarrel upgrade is <b>screwed</b> into place. There [(igniters_left != 1) ? "are [igniters_left] slots for <i>igniters</i>." : "is 1 slot for an <i>igniter</i>."]"
		if(BS_IGNITERS_PLACED)
			. += "The igniter[sare] unsecured, and [thit] can either be <b>removed</b> by hand, or <i>screwed</i> into place."
		if(BS_IGNITERS_SECURED)
			. += "The igniter[sare] <b>screwed</b> in place, but lack <i>wiring</i>."
		if(BS_WIRED)
			. += "The igniter[sare] <b>wired</b> to the electronics and the wiring can be <i>soldered<i/>."
		if(BS_WIRES_SOLDERED)
			. += "The wiring has been <b>soldered</b>, and can be covered with a <i>plasteel casing</i>."
		if(BS_CASING_ADDED)
			var/barrels_left = max_barrels - barrels_added
			. += "The plasteel casing can be <b>cut away</b>, and there [(barrels_left != 1) ? "are [barrels_left] slots for <i>barrels</i>." : "is 1 slot for a <i>barrel</i>."]"
		if(BS_BARRELS_PLACED)
			. += "The barrel[sare] loose in the frame, and [thit] can either be <i>welded<i> to the frame or <b>pried out</b>."
		if(BS_BARRELS_SECURED)
			. += "The barrel[sare] <b>welded</b> to the frame, and the assembly can be finished with a <i>loading tray</i>."

/obj/structure/ship_weapon/artillery_frame/proc/set_final_state()
	state = BS_BARRELS_SECURED

/obj/structure/ship_weapon/artillery_frame/attackby(obj/item/W, mob/user, params)
	switch(state)
		if(BS_MOUNT_WELDED)
			if(istype(W, /obj/item/ship_weapon/parts/firing_electronics))
				if(!do_after(user, 2 SECONDS, target=src))
					return
				W.forceMove(src)
				to_chat(user, "<span class='notice'>You add the electronic firing mechanism.</span>")
				state = BS_ELECTRONICS_LOOSE
				return TRUE

		if(BS_ELECTRONICS_SECURE, BS_UPGRADE_SECURED)
			if ((istype(W, /obj/item/circuitboard/multibarrel_upgrade)) && (state == BS_ELECTRONICS_SECURE))
				var/obj/item/circuitboard/multibarrel_upgrade/S = W
				if(!do_after(user, 2 SECONDS, target=src))
					return
				if(state != BS_ELECTRONICS_SECURE)// check again in case someone else inserts an igniter or something
					return
				W.forceMove(src)
				max_barrels = S.barrels
				to_chat(user, "<span class='notice'>You install the [S].</span>")
				state = BS_UPGRADE_LOOSE
				return TRUE
			if(istype(W, /obj/item/assembly/igniter))
				W.forceMove(src)
				igniters_added++
				to_chat(user, "<span class='notice'>You add the [W] to the [src].</span>")
				if(igniters_added >= max_barrels)
					state = BS_IGNITERS_PLACED
				return TRUE

		if(BS_IGNITERS_SECURED)
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/S = W
				if(S.get_amount() < num_cables)
					to_chat(user, "<span class='warning'>You need four pieces of [S] to wire the NAC!</span>")
					return
				if(!do_after(user, 2 SECONDS, target=src))
					return
				if(S.get_amount() < num_cables)
					to_chat(user, "<span class='warning'>You need four pieces of [S] to wire the NAC!</span>")
					return
				S.use(num_cables)
				to_chat(user, "<span class='notice'>You wire up the electronics.</span>")
				state = BS_WIRED
				return TRUE

		if(BS_WIRES_SOLDERED)
			if(istype(W, /obj/item/stack/sheet/plasteel))
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

		if(BS_CASING_ADDED)
			if(istype(W, /obj/item/ship_weapon/parts/mac_barrel))
				W.forceMove(src)
				barrels_added++
				to_chat(user, "<span class='notice'>You add the [W] to the [src].</span>")
				if(barrels_added >= max_barrels)
					state = BS_BARRELS_PLACED
				return TRUE

		if(BS_BARRELS_SECURED)
			if(istype(W, /obj/item/ship_weapon/parts/loading_tray))//finish
				if(!do_after(user, 2 SECONDS, target=src))
					return
				W.forceMove(src)
				to_chat(user, "<span class='notice'>You slide the loading tray into place.</span>")
				if(ispath(text2path("/obj/machinery/ship_weapon/deck_turret/_[max_barrels]")))
					output_path = text2path("/obj/machinery/ship_weapon/deck_turret/_[max_barrels]")
				var/obj/machinery/ship_weapon/built = new output_path(loc)
				built.setDir(dir)
				built.setAnchored(anchored)
				built.on_construction()
				built.max_ammo = max_barrels

				for(var/obj/O in built.component_parts)
					qdel(O)
					stoplag()
				transfer_fingerprints_to(built)
				built.component_parts = list()
				for(var/obj/O in src)
					O.moveToNullspace()
					built.component_parts += O
					stoplag()
				qdel(src)
				return TRUE
	return ..()

/obj/structure/ship_weapon/artillery_frame/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/structure/ship_weapon/artillery_frame/attack_hand(mob/user)
	. = ..()
	if(state == BS_IGNITERS_PLACED)
		if(!do_after(user, 2 SECONDS, target=src))
			return
		to_chat(user, "<span class='notice'>You remove the igniter[(max_barrels != 1) ? "s" : ""].</span>")
		for(var/obj/item/assembly/igniter/C in src)
			C.forceMove(user.loc)
		igniters_added = 0
		state = (max_barrels > 1) ? BS_UPGRADE_SECURED : BS_ELECTRONICS_SECURE
		return TRUE

/obj/structure/ship_weapon/artillery_frame/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_MOUNT_UNBOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You bolt the [src] to the floor.</span>")
				anchored = TRUE
				state = BS_MOUNT_BOLTED
				return TRUE

		if(BS_MOUNT_BOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the [src] from the floor.</span>")
				state = BS_MOUNT_UNBOLTED
				return TRUE

/obj/structure/ship_weapon/artillery_frame/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_MOUNT_BOLTED)
			if(anchored && tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>You weld the [src] to the floor.</span>")
				state = BS_MOUNT_WELDED
				return TRUE

		if(BS_BARRELS_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>You weld the barrel[(max_barrels != 1) ? "s" : ""] to the frame.</span>")
				state = BS_BARRELS_SECURED
				return TRUE

		if(BS_BARRELS_SECURED)
			if(tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>You cut the barrel[(max_barrels != 1) ? "s" : ""] free from the frame.</span>")
				state = BS_BARRELS_PLACED
				return TRUE

		if(BS_WIRED)
			if(tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>You solder the wiring into place.</span>")
				state = BS_WIRES_SOLDERED
				return TRUE

		if(BS_CASING_ADDED)
			if(tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>You slice away the outer casing.</span>")
				new/obj/item/stack/sheet/plasteel(user.loc, num_sheets_casing)
				if(barrels_added)
					to_chat(user, "<span class='notice'>The barrel[(barrels_added != 1) ? "s fall" : " falls"] out of the frame!</span>")
					for(var/obj/item/ship_weapon/parts/mac_barrel/R in src)
						R.forceMove(user.loc)
				barrels_added = 0
				state = BS_WIRES_SOLDERED
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
				new/obj/item/stack/sheet/plasteel(user.loc, num_sheets_frame)
				qdel(src)
				return TRUE

/obj/structure/ship_weapon/artillery_frame/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_ELECTRONICS_LOOSE)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				var/obj/item/ship_weapon/parts/firing_electronics/F = (locate(/obj/item/ship_weapon/parts/firing_electronics) in src)
				if(F)
					F.forceMove(user.loc)
				to_chat(user, "<span class='notice'>You pry the firing electronics loose.</span>")
				state = BS_MOUNT_WELDED
				return TRUE

		if(BS_BARRELS_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				for(var/obj/item/ship_weapon/parts/mac_barrel/R in src)
					R.forceMove(user.loc)
				to_chat(user, "<span class='notice'>You pry the barrel[(max_barrels != 1) ? "s" : ""] loose.</span>")
				barrels_added = 0
				state = BS_CASING_ADDED
				return TRUE

		if(BS_UPGRADE_LOOSE)
			if(tool.use_tool(src,user, 2 SECONDS, volume=100))
				var/obj/item/circuitboard/multibarrel_upgrade/C = (locate(/obj/item/circuitboard/multibarrel_upgrade) in src)
				if(C)
					C.forceMove(user.loc)
				to_chat(user, "<span class='notice'>You pry the [C] loose.</span>")
				max_barrels = 1
				lazy_icon()
				state = BS_ELECTRONICS_SECURE
				return TRUE

/obj/structure/ship_weapon/artillery_frame/wirecutter_act(mob/living/user, obj/item/tool)
	. = ..()
	if(state == BS_WIRED)
		if(tool.use_tool(src, user, 2 SECONDS, volume=100))
			new/obj/item/stack/cable_coil(user.loc, num_cables)
			to_chat(user, "<span class='notice'>You cut the wires from the frame.</span>")
			state = BS_IGNITERS_SECURED
			return TRUE

/obj/structure/ship_weapon/artillery_frame/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	switch(state)

		if(BS_ELECTRONICS_LOOSE)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You secure the firing electronics.</span>")
				state = BS_ELECTRONICS_SECURE
				return TRUE

		if(BS_IGNITERS_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You screw the igniter[(max_barrels != 1) ? "s" : ""] into place.</span>")
				state = BS_IGNITERS_SECURED
				return TRUE

		if(BS_UPGRADE_LOOSE)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				var/obj/item/circuitboard/multibarrel_upgrade/C = locate(/obj/item/circuitboard/multibarrel_upgrade)
				to_chat(user, "<span class='notice'>You secure the [(C) ? "[C]" : "upgrade"].</span>")
				lazy_icon()
				state = BS_UPGRADE_SECURED
				return TRUE

		if(BS_UPGRADE_SECURED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				var/obj/item/circuitboard/multibarrel_upgrade/C = locate(/obj/item/circuitboard/multibarrel_upgrade)
				to_chat(user, "<span class='notice'>You unsecure the [(C) ? "[C]" : "upgrade"].</span>")
				if(igniters_added)
					to_chat(user, "<span class='notice'>The igniter[(igniters_added != 1) ? "s fall" : " falls"] out of the frame!</span>")
					for(var/obj/item/assembly/igniter/D in src)
						D.forceMove(user.loc)
					igniters_added = 0
				lazy_icon()
				state = BS_UPGRADE_LOOSE
				return TRUE

		if(BS_IGNITERS_SECURED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You unscrew the igniter[(max_barrels != 1) ? "s" : ""].</span>")
				state = BS_IGNITERS_PLACED
				return TRUE

		if(BS_ELECTRONICS_SECURE)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You unsecure the firing electronics.</span>")
				state = BS_ELECTRONICS_LOOSE
				return TRUE

/obj/item/circuitboard/multibarrel_upgrade
	name = "Naval Artillery Cannon Multibarrel Upgrade"
	desc = "this should not exist"
	var/barrels = 1
	build_path = null

/datum/design/board/multibarrel_upgrade/_3
	name = "Naval Artillery Cannon Triple Barrel Upgrade (Circuit)"
	desc = "An upgrade that allows you to add two more barrels to a Naval Artillery Cannon."
	id = "deck_gun_triple"
	materials = list(/datum/material/titanium = 30000,/datum/material/iron = 25000, /datum/material/diamond = 15000, /datum/material/copper = 35000)
	build_path = /obj/item/circuitboard/multibarrel_upgrade/_3
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/obj/item/circuitboard/multibarrel_upgrade/_3
	name = "Naval Artillery Cannon Triple Barrel Upgrade"
	desc = "An upgrade that allows you to add two more barrels to a Naval Artillery Cannon. You must partially deconstruct the cannon to install this."
	barrels = 3
	build_path = null


/obj/structure/ship_weapon/artillery_frame/setDir()
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_x = -43
			pixel_y = -32
			bound_width = 96
			bound_height = 96
			bound_x = -32
			bound_y = -32
		if(SOUTH)
			pixel_x = -43
			pixel_y = -64
			bound_width = 96
			bound_height = 96
			bound_x = -32
			bound_y = -32
		if(EAST)
			pixel_x = -30
			pixel_y = -42
			bound_width = 96
			bound_height = 96
			bound_x = -32
			bound_y = -32
		if(WEST)
			pixel_x = -63
			pixel_y = -42
			bound_width = 96
			bound_height = 96
			bound_x = -32
			bound_y = -32

//because I'm too lazy to make a proper proc
/obj/structure/ship_weapon/artillery_frame/proc/lazy_icon()
	if(max_barrels == 3)
		icon_state = "platform_dual"
	else
		icon_state = "platform"

//let me leave please
/obj/structure/ship_weapon/artillery_frame/CanPass(atom/movable/mover, turf/target)
	if(get_turf(mover) in locs)
		return TRUE
	return ..()

/obj/structure/ship_weapon/artillery_frame/AltClick(mob/user)
	. = ..()
	setDir(turn(dir, -90))

#undef BS_MOUNT_UNBOLTED
#undef BS_MOUNT_BOLTED
#undef BS_MOUNT_WELDED
#undef BS_ELECTRONICS_LOOSE
#undef BS_ELECTRONICS_SECURE
#undef BS_UPGRADE_LOOSE
#undef BS_UPGRADE_SECURED
#undef BS_IGNITERS_PLACED
#undef BS_IGNITERS_SECURED
#undef BS_WIRED
#undef BS_WIRES_SOLDERED
#undef BS_CASING_ADDED
#undef BS_BARRELS_PLACED
#undef BS_BARRELS_SECURED
