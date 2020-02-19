#define MSTATE_PRIEDOUT 3

/obj/machinery/ship_weapon/pdc_mount
	name = "PDC loading rack"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "pdc"
	desc = "Seegson's all-in-one PDC targeting computer, ammunition loader, and human interface has proven extremely popular in recent times. It's rare to see a ship without one of these."
	anchored = TRUE
	density = FALSE
	pixel_y = 26

	circuit = /obj/item/circuitboard/machine/pdc_mount

	fire_mode = FIRE_MODE_PDC
	weapon_type = new/datum/ship_weapon/pdc_mount
	magazine_type = /obj/item/ammo_box/magazine/pdc

	auto_load = TRUE
	semi_auto = TRUE
	maintainable = FALSE
	max_ammo = 100

	// We're fully automatic, so just the loading sound is enough
	mag_load_sound = 'sound/weapons/autoguninsert.ogg'
	mag_unload_sound = 'sound/weapons/autoguninsert.ogg'
	feeding_sound = null
	fed_sound = null
	chamber_sound = null

	load_delay = 50
	unload_delay = 50

	// No added delay between shots or for feeding rounds
	feed_delay = 0
	chamber_delay_rapid = 0
	chamber_delay = 0

/obj/machinery/ship_weapon/pdc_mount/north //Things mounted on a north wall face south, etc.
	dir = SOUTH
	pixel_x = 0
	pixel_y = 26

/obj/machinery/ship_weapon/pdc_mount/south
	dir = NORTH
	pixel_x = 0
	pixel_y = -26

/obj/machinery/ship_weapon/pdc_mount/east
	dir = WEST
	pixel_y = 0
	pixel_x = 26

/obj/machinery/ship_weapon/pdc_mount/west
	dir = EAST
	pixel_y = 0
	pixel_x = -26

/obj/machinery/ship_weapon/pdc_mount/New(loc, ndir=dir)
	. = ..()
	if(ndir)
		setDir(ndir)
	adjust_sprite_direction()

/obj/machinery/ship_weapon/pdc_mount/setDir(newdir)
	. = ..()
	adjust_sprite_direction()

/obj/machinery/ship_weapon/pdc_mount/proc/adjust_sprite_direction()
	pixel_x = (dir & 3)? 0 : (dir == EAST ? -26 : 26)
	pixel_y = (dir & 3)? (dir == NORTH ? -26 : 26) : 0

	update_icon()

/obj/machinery/ship_weapon/pdc_mount/on_construction(ndir)
	if(!isnull(ndir))
		setDir(ndir)

// Update the icon to reflect how far our magazine is depleted
/obj/machinery/ship_weapon/pdc_mount/update_icon()
	if(!magazine)
		icon_state = "[initial(icon_state)]_0"
		return
	var/progress = calculate_progress()
	icon_state = "[initial(icon_state)]_[progress]"

/obj/machinery/ship_weapon/pdc_mount/proc/calculate_progress()
	if(!magazine)
		return 0
	var/progress = magazine.ammo_count() //How damaged is this shield? We examine the position of index "I" in the for loop to check which directional we want to check
	var/goal = magazine.max_ammo //How much is the max hp of the shield? This is constant through all of them
	progress = CLAMP(progress, 0, goal)
	progress = round(((progress / goal) * 100), 20)//Round it down to 20%. We now apply visual damage
	return progress

//////////////////////////////////////////////////////////////////
// Update the icon after things that affect how much ammo we have

/obj/machinery/ship_weapon/pdc_mount/load_magazine()
	..()
	update_icon()

/obj/machinery/ship_weapon/pdc_mount/unload_magazine()
	..()
	update_icon()

/obj/machinery/ship_weapon/pdc_mount/after_fire()
	..()
	update_icon()

// Don't animate us on fire, the above takes care of all the icon updates we need
/obj/machinery/ship_weapon/pdc_mount/do_animation()
	return

/obj/machinery/ship_weapon/pdc_mount/animate_projectile(atom/target, lateral=TRUE)
	sleep(1)
	if(lateral)
		linked.fire_lateral_projectile(/obj/item/projectile/bullet/pdc_round, target)
	else
		linked.fire_projectiles(/obj/item/projectile/bullet/pdc_round, target)

/obj/machinery/ship_weapon/pdc_mount/examine()
	. = ..()
	if(panel_open)
		. += "The maintenance panel is <b>unscrewed</b> and the machinery could be <i>pried out</i>."

/obj/machinery/ship_weapon/pdc_mount/spawn_frame(disassembled)
	var/obj/structure/frame/machine/ship_weapon/pdc_mount/M = new /obj/structure/frame/machine/ship_weapon/pdc_mount(loc)
	M.state = 2
	if(magazine)
		magazine.forceMove(loc)
		ammo = list()

	for(var/obj/O in component_parts)
		O.forceMove(loc)
	component_parts = list()

	. = M
	M.setAnchored(anchored)
	M.setDir(dir)
	if(!disassembled)
		M.obj_integrity = M.max_integrity * 0.5 //the frame is already half broken
	transfer_fingerprints_to(M)

	qdel(src)

/obj/machinery/ship_weapon/pdc_mount/screwdriver_act(mob/user, obj/item/tool)
	var/icon_state_open = initial(icon_state)
	var/icon_state_closed
	if(!panel_open)
		icon_state_closed = icon_state
	else
		var/progress = calculate_progress()
		icon_state_closed = "[initial(icon_state)]_[progress]"
	. = default_deconstruction_screwdriver(user, icon_state_open, icon_state_closed, tool)

/obj/machinery/ship_weapon/pdc_mount/crowbar_act(mob/user, obj/item/tool)
	if(panel_open)
		tool.play_tool_sound(src, 50)
		deconstruct(TRUE)
		return TRUE
	. = default_deconstruction_crowbar(user, tool)

#undef MSTATE_PRIEDOUT
