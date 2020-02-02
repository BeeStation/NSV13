/obj/machinery/ship_weapon/torpedo_launcher //heavily modified CM sprite
	name = "M4-B Torpedo tube"
	desc = "A weapon system that's employed by nigh on all modern ships. It's capable of delivering a self-propelling warhead with pinpoint accuracy to utterly annihilate a target."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "torpedo"
	bound_height = 32
	bound_width = 96
	pixel_y = -72
	pixel_x = -32
	dir = 4

	firing_sound = 'nsv13/sound/effects/ship/plasma.ogg'
	load_sound = 'nsv13/sound/effects/ship/freespace2/m_load.wav'
	fire_mode = FIRE_MODE_TORPEDO
	ammo_type = /obj/item/ship_weapon/ammunition/torpedo
	fire_mode = 2
	weapon_type = new/datum/ship_weapon/torpedo_launcher

/obj/machinery/ship_weapon/torpedo_launcher/north
	dir = NORTH

/obj/machinery/ship_weapon/torpedo_launcher/south
	dir = SOUTH

/obj/machinery/ship_weapon/torpedo_launcher/east
	dir = EAST

/obj/machinery/ship_weapon/torpedo_launcher/west
	dir = WEST

/obj/machinery/ship_weapon/torpedo_launcher/Initialize()
	..()
	component_parts = list()
	component_parts += new/obj/item/ship_weapon/parts/firing_electronics

/obj/machinery/ship_weapon/torpedo_launcher/examine()
	. = ..()
	if(maint_state == MSTATE_PRIEDOUT)
		. += "The door panel could be <i>unscrewed</i>."

/obj/machinery/ship_weapon/torpedo_launcher/screwdriver_act(mob/user, obj/item/tool)
	if(maint_state == MSTATE_PRIEDOUT)
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You unscrew the door panel on the [src].</span>")
			spawn_frame(TRUE)
			return TRUE
	. = ..()

/obj/machinery/ship_weapon/torpedo_launcher/spawn_frame(disassembled)
	var/obj/structure/ship_weapon/torpedo_launcher_assembly/M = new /obj/structure/ship_weapon/torpedo_launcher_assembly(loc)

	for(var/obj/O in component_parts)
		O.forceMove(M)
	component_parts = list()

	. = M
	M.setAnchored(anchored)
	M.set_final_state()
	if(!disassembled)
		M.obj_integrity = M.max_integrity * 0.5 //the frame is already half broken
	transfer_fingerprints_to(M)

	qdel(src)

/obj/machinery/ship_weapon/torpedo_launcher/animate_projectile(atom/target, lateral=TRUE)
	// We have different sprites and behaviors for each torpedo
	var/obj/item/ship_weapon/ammunition/torpedo/T = chambered
	if(T)
		if(istype(T, /obj/item/projectile/bullet/torpedo/dud)) //Some brainlet MAA loaded an incomplete torp
			linked.fire_projectile(T.projectile_type, target, homing = FALSE, speed=T.speed, explosive = TRUE)
		else
			linked.fire_projectile(T.projectile_type, target, homing = TRUE, speed=T.speed, explosive = TRUE)
