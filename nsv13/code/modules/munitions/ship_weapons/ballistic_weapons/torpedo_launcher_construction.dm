#define BS_MOUNT_UNBOLTED 1		// 4 sheets of plasteel
#define BS_MOUNT_BOLTED 2
#define BS_MOUNT_WELDED 3
#define BS_BARREL_PLACED 4		// 4 nanocarbon glass
#define BS_BARREL_BOLTED 5
#define BS_WIRED 6				// 4 pieces of wire
#define BS_ELECTRONICS_LOOSE 7	// Firing electronics
#define BS_ELECTRONICS_SECURE 8
#define BS_DOOR_PLACED 9
#define BS_DOOR_BOLTED 10
// Then screw it shut

/obj/structure/ship_weapon/torpedo_launcher_assembly
	name = "M4-B Torpedo tube mount"
	desc = "An incomplete assembly for an M4-B ship mounted torpedo launcher."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "torpedo"
	bound_height = 32
	bound_width = 96
	pixel_y = -72
	pixel_x = -32
	anchored = FALSE
	density = TRUE

	var/state = BS_MOUNT_UNBOLTED

/obj/structure/ship_weapon/torpedo_launcher_assembly/Initialize()
	..()
	if(!contents)
		contents = list()
	dir = 4

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
	message_admins("Attacking [src] with [W]")
	add_fingerprint(user)
	if(W.tool_behaviour == TOOL_WRENCH)
		message_admins("It's a wrench and we're in state [state]")
		if(!anchored && (state == BS_MOUNT_UNBOLTED))
			W.play_tool_sound(src, 2 SECONDS)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You bolt the [src] to the floor.</span>")
			anchored = TRUE
			state = BS_MOUNT_BOLTED
			return

		else if(state == BS_BARREL_PLACED)
			W.play_tool_sound(src, 2 SECONDS)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You secure the barrel.</span>")
			state = BS_BARREL_BOLTED
			return

		else if(state == BS_BARREL_BOLTED)
			W.play_tool_sound(src, 2 SECONDS)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You unbolt the the barrel.</span>")
			state = BS_BARREL_PLACED
			return

		else if(state == BS_MOUNT_BOLTED)
			W.play_tool_sound(src, 2 SECONDS)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You unbolt the [src] from the floor.</span>")
			state = BS_MOUNT_UNBOLTED
			return

		else if(state == BS_DOOR_PLACED)
			W.play_tool_sound(src, 2 SECONDS)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You bolt the door to the frame.</span>")
			state = BS_DOOR_BOLTED
			return

		else if(state == BS_DOOR_BOLTED)
			W.play_tool_sound(src, 2 SECONDS)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You unbolt the door from the frame.</span>")
			state = BS_DOOR_PLACED
			return

	else if(W.tool_behaviour == TOOL_WELDER)
		if(anchored && (state == BS_MOUNT_BOLTED))
			W.play_tool_sound(src, 2 SECONDS)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You weld the [src] to the floor.</span>")
			state = BS_MOUNT_WELDED
			return

		if(state == BS_MOUNT_WELDED)
			W.play_tool_sound(src, 2 SECONDS)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You unweld the [src] from the floor.</span>")
			state = BS_MOUNT_BOLTED
			return

		if(state == BS_MOUNT_UNBOLTED)
			W.play_tool_sound(src, 2 SECONDS)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You cut apart the frame.</span>")
			new/obj/item/stack/sheet/plasteel(loc, 4)
			qdel(src)
			return

		return

	else if(W.tool_behaviour == TOOL_WIRECUTTER)
		if(state == BS_WIRED)
			W.play_tool_sound(src, 2 SECONDS)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			new/obj/item/stack/cable_coil(loc, 2)
			to_chat(user, "<span class='notice'>You cut the wires from the frame.</span>")
			state = BS_BARREL_BOLTED
			return

		return

	else if(istype(W, /obj/item/stack/sheet/nanocarbon_glass))
		if(state == BS_MOUNT_WELDED)
			var/obj/item/stack/sheet/nanocarbon_glass/S = W
			if(S.get_amount() < 4)
				to_chat(user, "<span class='warning'>You need four sheets of [S] to build the tube!</span>")
				return
			if(!do_after(user, 2 SECONDS, target=src))
				return
			if(S.get_amount() < 4) // Check whether they used too much while standing here...
				to_chat(user, "<span class='warning'>You need four sheets of [S] to build the tube!</span>")
				return
			S.use(4)
			to_chat(user, "<span class='notice'>You shape the nanocarbon torpedo tube.</span>")
			state = BS_BARREL_PLACED
			return

		else if(state == BS_ELECTRONICS_SECURE)
			var/obj/item/stack/sheet/nanocarbon_glass/S = W
			if(S.get_amount() < 2)
				to_chat(user, "<span class='warning'>You need two sheets of [S] to build the door!</span>")
				return
			if(!do_after(user, 2 SECONDS, target=src))
				return
			if(S.get_amount() < 2) // Check whether they used too much while standing here...
				to_chat(user, "<span class='warning'>You need two sheets of [S] to build the door!</span>")
				return
			S.use(4)
			to_chat(user, "<span class='notice'>You add the door to the [src].</span>")
			state = BS_DOOR_PLACED
			return

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(state == BS_ELECTRONICS_LOOSE)
			W.play_tool_sound(src, 2 SECONDS)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You secure the firing electronics.</span>")
			state = BS_ELECTRONICS_SECURE
			return

		else if(state == BS_ELECTRONICS_SECURE)
			W.play_tool_sound(src, 2 SECONDS)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You unsecure the firing electronics.</span>")
			state = BS_ELECTRONICS_LOOSE
			return

		else if(state == BS_DOOR_BOLTED)
			W.play_tool_sound(src, 2 SECONDS)
			if(!do_after(user, 2 SECONDS, target=src))
				return
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
			return

		return

	else if(W.tool_behaviour == TOOL_CROWBAR)
		if(state == BS_DOOR_PLACED)
			W.play_tool_sound(src, 2 SECONDS)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You pry the door loose from the [src].</span>")
			new/obj/item/stack/sheet/nanocarbon_glass(loc, 2)
			state = BS_ELECTRONICS_SECURE
			return

		else if(state == BS_ELECTRONICS_LOOSE)
			W.play_tool_sound(src, 2 SECONDS)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			var/obj/item/ship_weapon/parts/firing_electronics/F = (locate(/obj/item/ship_weapon/parts/firing_electronics) in contents)
			F.forceMove(loc)
			to_chat(user, "<span class='notice'>You pry the firing electronics loose from the [src].</span>")
			state = BS_WIRED
			return

		else if(state == BS_BARREL_PLACED)
			W.play_tool_sound(src, 2 SECONDS)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You pry the nanocarbon barrel off the [src].</span>")
			new/obj/item/stack/sheet/nanocarbon_glass(loc, 4)
			state = BS_MOUNT_WELDED
			return

	else if(istype(W, /obj/item/stack/cable_coil) && (state == BS_BARREL_BOLTED))
		var/obj/item/stack/cable_coil/S = W
		if(S.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two pieces of [S] to wire the railgun!</span>")
			return
		if(!do_after(user, 2 SECONDS, target=src))
			return
		if(S.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two pieces of [S] to wire the railgun!</span>")
			return
		S.use(4)
		to_chat(user, "<span class='notice'>You wire the torpedo launcher.</span>")
		state = BS_WIRED
		return

	else if((istype(W, /obj/item/ship_weapon/parts/firing_electronics)) && (state = BS_WIRED))
		if(!do_after(user, 2 SECONDS, target=src))
			return
		W.forceMove(src)
		to_chat(user, "<span class='notice'>Add the electronic firing mechanism.</span>")
		state = BS_ELECTRONICS_LOOSE
		return

	. = ..()

/obj/structure/ship_weapon/torpedo_launcher_assembly/attack_robot(mob/user)
	. = ..()
	attack_hand(user)
