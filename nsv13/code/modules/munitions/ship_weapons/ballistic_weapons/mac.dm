#define MSTATE_CLOSED 0
#define MSTATE_UNSCREWED 1
#define MSTATE_UNBOLTED 2
#define MSTATE_PRIEDOUT 3

/obj/machinery/ship_weapon/mac
	name = "Radial MAC cannon"
	desc = "An extremely powerful electromagnet which can accelerate a projectile to devastating speeds."
	icon_state = "MAC"
	fire_mode = FIRE_MODE_MAC
	ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo
	pixel_y = -64
	bound_width = 128
	bound_height = 64
	dir = 4

	var/req_components = list(
		/obj/item/stock_parts/capacitor = 4,
		/obj/item/ship_weapon/parts/loading_tray = 1,
		/obj/item/ship_weapon/parts/firing_electronics = 1,
		/obj/item/ship_weapon/parts/mac_barrel = 1
		)

/obj/machinery/ship_weapon/mac/north // South-facing monitor looks for a gun to its north that's probably facing north
	dir = NORTH

/obj/machinery/ship_weapon/mac/south
	dir = SOUTH

/obj/machinery/ship_weapon/mac/east
	dir = EAST

/obj/machinery/ship_weapon/mac/west
	dir = WEST

/obj/machinery/ship_weapon/mac/Initialize()
	..()
	apply_default_parts()

/obj/machinery/ship_weapon/mac/proc/apply_default_parts()
	if(!req_components)
		return

	component_parts = list() // List of components always contains a board

	for(var/comp_path in req_components)
		var/comp_amt = req_components[comp_path]
		if(!comp_amt)
			continue

		if(ispath(comp_path, /obj/item/stack))
			component_parts += new comp_path(null, comp_amt)
		else
			for(var/i in 1 to comp_amt)
				component_parts += new comp_path(null)

/obj/machinery/ship_weapon/mac/examine()
	. = ..()
	if(maint_state == MSTATE_PRIEDOUT)
		. += "The loading tray could be removed by hand."

/obj/machinery/ship_weapon/mac/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/ship_weapon/mac/attack_hand(mob/user)
	. = ..()
	if(!(maint_state == MSTATE_PRIEDOUT))
		return

	to_chat(user, "<span class='notice'>You start removing the loading tray from the [src].</span>")
	if(do_after(user, 2 SECONDS, target=src))
		var/obj/W = (locate(/obj/item/ship_weapon/parts/loading_tray) in component_parts)
		if(W)
			W.forceMove(user.loc)
			component_parts -= W
		to_chat(user, "<span class='notice'>You remove the loading tray from the [src].</span>")
		spawn_frame(TRUE)

/obj/machinery/ship_weapon/mac/spawn_frame(disassembled)
	var/obj/structure/ship_weapon/mac_assembly/M = new /obj/structure/ship_weapon/mac_assembly(loc)

	for(var/obj/O in component_parts)
		O.forceMove(M)
	component_parts = list()

	. = M
	M.setAnchored(anchored)
	M.setDir(dir)
	M.set_final_state()
	if(!disassembled)
		M.obj_integrity = M.max_integrity * 0.5 //the frame is already half broken
	transfer_fingerprints_to(M)

	qdel(src)

/obj/machinery/ship_weapon/mac/after_fire()
	if(!ammo.len)
		say("Autoloader has depleted all ammunition sources. Reload required.")
		return
	..()

/obj/machinery/ship_weapon/mac/MouseDrop_T(obj/structure/A, mob/user)
	return

/obj/machinery/ship_weapon/mac/set_position(obj/structure/overmap/OM)
	..()
	overlay = linked.add_weapon_overlay("/obj/weapon_overlay/railgun")

#undef MSTATE_CLOSED
#undef MSTATE_UNSCREWED
#undef MSTATE_UNBOLTED
#undef MSTATE_PRIEDOUT