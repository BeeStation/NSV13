#define BS_MOUNT_UNBOLTED 1		// 4 sheets of plasteel
#define BS_MOUNT_BOLTED 2
#define BS_MOUNT_WELDED 3
#define BS_BARREL_PLACED 4		// 4 nanocarbon glass
#define BS_BARREL_BOLTED 5
#define BS_WIRED 6				// 2 pieces of wire
#define BS_ELECTRONICS_LOOSE 7	// Firing electronics
#define BS_ELECTRONICS_SECURE 8
#define BS_DOOR_PLACED 9		// 2 nanocarbon glass
#define BS_DOOR_BOLTED 10
// Then screw it shut

/obj/structure/ship_weapon/torpedo_launcher_assembly
	name = "M4-B Torpedo tube mount"
	desc = "An incomplete assembly for an M4-B ship mounted torpedo launcher."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "torpedo_launcher_platform"
	bound_height = 32
	bound_width = 96
	pixel_y = -72
	pixel_x = -32
	anchored = TRUE
	density = TRUE

	var/state = BS_MOUNT_UNBOLTED

	// Material costs so we can rebalance them easily
	var/num_cables = 2
	var/num_sheets_door = 2
	var/num_sheets_barrel = 4
	var/num_sheets_frame = 4

/obj/structure/ship_weapon/torpedo_launcher_assembly/Initialize()
	..()
	if(!contents)
		contents = list()

/obj/structure/ship_weapon/torpedo_launcher_assembly/examine(mob/user)
	. = ..()
	switch(state)
		if(BS_MOUNT_UNBOLTED)
			. += "It is <i>unbolted</i> from the floor and could be <b>cut apart</b>."
		if(BS_MOUNT_BOLTED)
			. += "It is <b>bolted</b> down and can be <i>welded</i> to the floor."
		if(BS_MOUNT_WELDED)
			. += "It is <b>welded</b> to the floor and is ready for a <i>nanocarbon</i> barrel."
		if(BS_BARREL_PLACED)
			. += "The <i>bolts</i> on the barrel are loose. It could be <b>pried off</b>."
		if(BS_BARREL_BOLTED)
			. += "The barrel is <b>bolted</b> in place. The assembly is <i>unwired</i>.</i>."
		if(BS_WIRED)
			. += "The assembly is <b>wired</b> but has no <i>firing electronics</i>."
		if(BS_ELECTRONICS_LOOSE)
			. += "The firing electronics sit loose in the frame. They could be <b>pried out</b> or <i>screwed</i> into place."
		if(BS_ELECTRONICS_SECURE)
			. += "The firing electronics are <b>screwed</b> into place. The tube is missing a <i>nanocarbon door</i>."
		if(BS_DOOR_PLACED)
			. += "The nanocarbon door is loose. It could be <b>pried off</b> or <i>bolted</i> into place."
		if(BS_DOOR_BOLTED)
			. += "The door is <b>bolted</b> in place, and the maintenance hatch is <i>unscrewed</i>."

// We just took apart a torp tube, put us at the end of the construction sequence
/obj/structure/ship_weapon/torpedo_launcher_assembly/proc/set_final_state()
	state = BS_DOOR_BOLTED

/obj/structure/ship_weapon/torpedo_launcher_assembly/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)

	if(istype(W, /obj/item/stack/sheet/nanocarbon_glass))
		if(state == BS_MOUNT_WELDED)
			var/obj/item/stack/sheet/nanocarbon_glass/S = W
			if(S.get_amount() < num_sheets_barrel)
				to_chat(user, "<span class='warning'>You need four sheets of [S] to build the tube!</span>")
				return
			if(!do_after(user, 2 SECONDS, target=src))
				return
			if(S.get_amount() < num_sheets_barrel) // Check whether they used too much while standing here...
				to_chat(user, "<span class='warning'>You need four sheets of [S] to build the tube!</span>")
				return
			S.use(num_sheets_barrel)
			to_chat(user, "<span class='notice'>You shape the nanocarbon torpedo tube.</span>")
			state = BS_BARREL_PLACED
			return TRUE

		else if(state == BS_ELECTRONICS_SECURE)
			var/obj/item/stack/sheet/nanocarbon_glass/S = W
			if(S.get_amount() < num_sheets_door)
				to_chat(user, "<span class='warning'>You need two sheets of [S] to build the door!</span>")
				return
			if(!do_after(user, 2 SECONDS, target=src))
				return
			if(S.get_amount() < num_sheets_door) // Check whether they used too much while standing here...
				to_chat(user, "<span class='warning'>You need two sheets of [S] to build the door!</span>")
				return
			S.use(num_sheets_door)
			to_chat(user, "<span class='notice'>You add the door to the [src].</span>")
			state = BS_DOOR_PLACED
			return TRUE

	else if(istype(W, /obj/item/stack/cable_coil) && (state == BS_BARREL_BOLTED))
		var/obj/item/stack/cable_coil/S = W
		if(S.get_amount() < num_cables)
			to_chat(user, "<span class='warning'>You need two pieces of [S] to wire the railgun!</span>")
			return
		if(!do_after(user, 2 SECONDS, target=src))
			return
		if(S.get_amount() < num_cables)
			to_chat(user, "<span class='warning'>You need two pieces of [S] to wire the railgun!</span>")
			return
		S.use(num_cables)
		to_chat(user, "<span class='notice'>You wire the torpedo launcher.</span>")
		state = BS_WIRED
		return TRUE

	else if((istype(W, /obj/item/ship_weapon/parts/firing_electronics)) && (state == BS_WIRED))
		if(!do_after(user, 2 SECONDS, target=src))
			return
		W.forceMove(src)
		to_chat(user, "<span class='notice'>Add the electronic firing mechanism.</span>")
		state = BS_ELECTRONICS_LOOSE
		return TRUE

	. = ..()

/obj/structure/ship_weapon/torpedo_launcher_assembly/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/structure/ship_weapon/torpedo_launcher_assembly/screwdriver_act(mob/user, obj/item/tool)
	. = ..()
	switch(state)
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

		if(BS_DOOR_BOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You finish the torpedo launcher.</span>")
				var/obj/machinery/ship_weapon/torpedo_launcher/TL = new(loc)
				TL.dir = dir
				TL.setAnchored(anchored)
				TL.on_construction()
				for(var/obj/O in TL.component_parts)
					qdel(O)
					stoplag()
				transfer_fingerprints_to(TL)
				TL.component_parts = list()
				for(var/obj/O in src)
					O.moveToNullspace()
					TL.component_parts += O
					stoplag()
				qdel(src)
				return TRUE

/obj/structure/ship_weapon/torpedo_launcher_assembly/wrench_act(mob/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_MOUNT_UNBOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You bolt the [src] to the floor.</span>")
				anchored = TRUE
				state = BS_MOUNT_BOLTED
				return TRUE

		if(BS_BARREL_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You secure the barrel.</span>")
				state = BS_BARREL_BOLTED
				return TRUE

		if(BS_BARREL_BOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the the barrel.</span>")
				state = BS_BARREL_PLACED
				return TRUE

		if(BS_MOUNT_BOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the [src] from the floor.</span>")
				state = BS_MOUNT_UNBOLTED
				return TRUE

		if(BS_DOOR_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You bolt the door to the frame.</span>")
				state = BS_DOOR_BOLTED
				return TRUE

		if(BS_DOOR_BOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the door from the frame.</span>")
				state = BS_DOOR_PLACED
				return TRUE

/obj/structure/ship_weapon/torpedo_launcher_assembly/welder_act(mob/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_MOUNT_BOLTED)
			if(anchored && tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>You weld the [src] to the floor.</span>")
				state = BS_MOUNT_WELDED
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

/obj/structure/ship_weapon/torpedo_launcher_assembly/crowbar_act(mob/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_DOOR_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You pry the door loose from the [src].</span>")
				new/obj/item/stack/sheet/nanocarbon_glass(loc, num_sheets_door)
				state = BS_ELECTRONICS_SECURE
				return TRUE

		if(BS_ELECTRONICS_LOOSE)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				var/obj/item/ship_weapon/parts/firing_electronics/F = (locate(/obj/item/ship_weapon/parts/firing_electronics) in contents)
				F.forceMove(loc)
				to_chat(user, "<span class='notice'>You pry the firing electronics loose from the [src].</span>")
				state = BS_WIRED
				return TRUE

		if(BS_BARREL_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>You pry the nanocarbon barrel off the [src].</span>")
				new/obj/item/stack/sheet/nanocarbon_glass(loc, num_sheets_barrel)
				state = BS_MOUNT_WELDED
				return TRUE

/obj/structure/ship_weapon/torpedo_launcher_assembly/wirecutter_act(mob/living/user, obj/item/tool)
	. = ..()
	if(state == BS_WIRED)
		if(tool.use_tool(src, user, 2 SECONDS, volume=100))
			new/obj/item/stack/cable_coil(loc, num_cables)
			to_chat(user, "<span class='notice'>You cut the wires from the frame.</span>")
			state = BS_BARREL_BOLTED
			return TRUE
