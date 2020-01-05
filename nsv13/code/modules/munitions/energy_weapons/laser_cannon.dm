#define STATE_DISCONNECTED 1
#define STATE_OFF 2
#define STATE_CHARGING 3
#define STATE_READY 4
#define STATE_FIRING 5

/*
 * A ship-to-ship laser cannon that charges by drawing a large amount of power from the ship's grid.
 * Can be researched by science and built by the crew.
 */
/obj/structure/ship_weapon/laser_cannon
	name = "NT-WMG2 Laser cannon"
	desc = "An experimental ship-to-ship energy weapon which fires a powerful destructive blast."
	icon = 'nsv13/icons/obj/laser_cannon.dmi'
	icon_state = "laser_cannon"

	pixel_y = 0
	pixel_x = 0
	bound_width = 64
	bound_height = 32
	dir = 4

	fire_sound = 'sound/weapons/lasercannonfire.ogg'
	var/obj/machinery/computer/ship/laser_cannon_computer/computer
	var/obj/item/stock_parts/cell/laser_cannon/cell
	var/obj/structure/cable/attached
	state = STATE_OFF

	var/projectile_type = /obj/item/projectile/beam/laser/heavylaser

	// Variables used for construction and deconstruction, copied from _machinery.dm
	var/list/component_parts = null
	var/panel_open = FALSE
	var/obj/item/circuitboard/machine/laser_cannon/circuit // Circuit to be created and inserted when the machinery is created

/*
 * Overmap projectile
 */
/obj/item/projectile/bullet/laser
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "heavylaser"
	damage = 250

/*
 * Make sure we have a wire to drain power from, a circuitboard, and all the required parts for construction/deconstruction.
 */
/obj/structure/ship_weapon/laser_cannon/Initialize()
	..()

	attached = locate() in loc.contents // I don't know why I had to specify this but regular locate didn't work

	if(!attached)
		state = STATE_DISCONNECTED // Otherwise STATE_OFF as in the initial declaration

	//This is duplicate _machinery.dm code
	circuit = new /obj/item/circuitboard/machine/laser_cannon
	circuit.apply_default_parts(src)

	// Set charge to 0 for brand new cannons (i.e. map-placed cannons)
	cell = locate(/obj/item/stock_parts/cell/laser_cannon) in component_parts
	cell.charge = 0

/*
 * Destroys the cannon and its components. Copied from _machinery.dm
 */
/obj/structure/ship_weapon/laser_cannon/Destroy()
	//This is duplicate _machinery.dm code
	if(length(component_parts))
		for(var/atom/A in component_parts)
			qdel(A)
		component_parts.Cut()
	return ..()

/*
 * Adds the laser cannon to the list of laser cannons available to the overmap ship.
 */
/obj/structure/ship_weapon/laser_cannon/set_position(obj/structure/overmap/OM)
	OM.ship_lasers += src

	OM.laser_overlay = new()
	OM.laser_overlay.appearance_flags |= KEEP_APART
	OM.laser_overlay.appearance_flags |= RESET_TRANSFORM
	OM.vis_contents += OM.laser_overlay

/*
 * Handles power drain.
 * The laser cannon functions similarly to a powersink, without the exploding.
 */
/obj/structure/ship_weapon/laser_cannon/process()
	if(!attached || !anchored) // No cable or we're not wrenched down
		state = STATE_DISCONNECTED
	if (state == STATE_OFF || state == STATE_DISCONNECTED) // Turned off or not connected to the grid, don't draw power
		STOP_PROCESSING(SSobj, src)
		return

	var/datum/powernet/PN = attached.powernet
	if(PN)
		var/drained // Amount of power we've drained this tick
		var/amount_to_drain // Amount we're going to drain from the thing we're looking at

		// First try to drain from the powernet
		amount_to_drain = min(cell.chargerate, attached.newavail()) // Drain either our drain rate or however much is left
		attached.add_delayedload(amount_to_drain)
		cell.give(amount_to_drain)
		drained += amount_to_drain

		// If we need more than is available on powernet, look for APCs and drain their cells
		if((drained < cell.chargerate) && (cell.charge < cell.maxcharge))
			for(var/obj/machinery/power/terminal/T in PN.nodes)
				if(istype(T.master, /obj/machinery/power/apc))
					var/obj/machinery/power/apc/A = T.master
					if(A.operating && A.cell) // Drain the cell
						amount_to_drain = min(A.cell.charge, 50)
						A.cell.charge -= amount_to_drain
						cell.give(amount_to_drain)
						drained += amount_to_drain

						if(A.charging == 2) // If the cell was full
							A.charging = 1 // It's no longer full
				if(drained >= cell.chargerate) // We've now taken the amount of power per tick we're supposed to, stop
					break

		if(cell.charge >= cell.maxcharge) // The gun is fully charged
			STOP_PROCESSING(SSobj, src)
			state = STATE_READY

/*
 * Checks whether the laser cannon is able to fire.
 * If all goes well, STATE_READY should be the only indicator needed, but I won't assume anything.
 */
/obj/structure/ship_weapon/laser_cannon/can_fire()
	if (state != STATE_READY)
		return FALSE
	if (!attached)
		return FALSE // No power cable
	if (cell.charge < cell.maxcharge)
		return FALSE // Not fully charged
	if (!anchored)
		return FALSE // Need to wrench it down first
	if (safety)
		return FALSE // You left the safety on
	return TRUE

/*
 * Fires the laser cannon.
 * Depowers the non-essential areas of the ship for 10 seconds as the grid check event.
 * Causes a bright flash in the cannon's area and fires a laser bolt forwards.
 */
/obj/structure/ship_weapon/laser_cannon/fire()
	if(!can_fire())
		return
	spawn(0)
		// Fire on the main map
		playsound(src, fire_sound, 100, 1)
		var/obj/item/projectile/P = new projectile_type(get_step(src, 4))
		P.fire(dir2angle(dir))
		do_animation()

	state = STATE_FIRING

	power_fail(0, 6) // Kill the power for a moment
	apply_flash()

	cell.use(cell.maxcharge) // Used all the power we'd stored
	state = STATE_OFF
	toggle_charging() // Start charging again

	after_fire()

/*
 * Flash all mobs that are near open space or the laser
 */
/obj/structure/ship_weapon/laser_cannon/proc/apply_flash()
	// Mobs near laser
	for(var/mob/living/M in get_hearers_in_view(7, get_turf(src)))
		if(M.stat != DEAD)
			M.flash_act(affect_silicon = 1)

	for(var/mob/living/M in linked.mobs_in_ship)
		// Mobs in space
		if(istype(get_turf(M), /turf/open/space))
			if(M.stat != DEAD)
				M.flash_act(affect_silicon = 1)
		else
			// Mobs that are looking at space
			for(var/turf/T in view(M, 4))
				if(istype(T, /turf/open/space) && (M.stat != DEAD))
					M.flash_act(affect_silicon = 1)
					break // Only need to flash each mob once

/*
 * Switches whether the laser cannon is charging.
 */
/obj/structure/ship_weapon/laser_cannon/proc/toggle_charging()
	if(state == STATE_CHARGING)
		STOP_PROCESSING(SSobj, src)
		state = STATE_OFF
	else if(state == STATE_OFF)
		state = STATE_CHARGING
		START_PROCESSING(SSobj, src)

/*
 * Switches the weapon safety.
 */
/obj/structure/ship_weapon/laser_cannon/proc/toggle_safety()
	if(safety)
		safety = FALSE
	else
		safety = TRUE