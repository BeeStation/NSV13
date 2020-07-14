#define MSTATE_CLOSED 0
#define MSTATE_UNSCREWED 1
#define MSTATE_UNBOLTED 2
#define MSTATE_PRIEDOUT 3

/obj/machinery/ship_weapon/railgun
	name = "NT-STC4 coaxial railgun"
	desc = "A railgun which fires directly out of the front of the ship, its projectiles are entirely unguided, so the firing solution must be perfect."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "OBC"
	bound_width = 128
	bound_height = 64
	pixel_y = -64

	fire_mode = FIRE_MODE_RAILGUN
	ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo

	dir = 4
	semi_auto = TRUE
	max_ammo = 4 //Until you have to manually load it back up again. Battleships IRL have 3-4 shots before you need to reload the rack

	var/req_components = list(
		/obj/item/stock_parts/capacitor = 4,
		/obj/item/ship_weapon/parts/loading_tray = 1,
		/obj/item/ship_weapon/parts/firing_electronics = 1,
		/obj/item/ship_weapon/parts/railgun_rail = 2
		)

/obj/machinery/ship_weapon/railgun/north // South-facing monitor looks for a gun to its north that's probably facing north
	dir = NORTH

/obj/machinery/ship_weapon/railgun/south
	dir = SOUTH

/obj/machinery/ship_weapon/railgun/east
	dir = EAST

/obj/machinery/ship_weapon/railgun/west
	dir = WEST

/obj/machinery/ship_weapon/railgun/Initialize()
	..()
	apply_default_parts()

/obj/machinery/ship_weapon/railgun/proc/apply_default_parts()
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

/obj/machinery/ship_weapon/railgun/examine()
	. = ..()
	if(maint_state == MSTATE_PRIEDOUT)
		. += "The loading tray could be removed by hand."

/obj/machinery/ship_weapon/railgun/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/ship_weapon/railgun/attack_hand(mob/user)
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

/obj/machinery/ship_weapon/railgun/spawn_frame(disassembled)
	var/obj/structure/ship_weapon/railgun_assembly/M = new /obj/structure/ship_weapon/railgun_assembly(loc)

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

/obj/machinery/ship_weapon/railgun/after_fire()
	if(!ammo.len)
		say("Autoloader has depleted all ammunition sources. Reload required.")
		return
	..()

/obj/machinery/ship_weapon/railgun/MouseDrop_T(obj/structure/A, mob/user)
	return

/obj/machinery/ship_weapon/railgun/animate_projectile(atom/target)
	linked.fire_projectile(weapon_type.default_projectile_type, target, TRUE)