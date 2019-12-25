#define STATE_DISCONNECTED 1
#define STATE_OFF 2
#define STATE_CHARGING 3
#define STATE_READY 4
#define STATE_FIRING 5

/obj/item/stock_parts/cell/laser_cannon // As long as the gun isn't machinery they can't do replace_parts so it should be fine
	name = "laser cannon power collector"
	icon_state = "hpcell"

	// TODO: figure out how game balance works
	maxcharge = 200000
	materials = list(/datum/material/glass=800)
	chargerate = 3000

/obj/item/stock_parts/cell/laser_cannon/corrupt() // No we will not explode thanks
	return

/obj/structure/ship_weapon/laser_cannon
	name = "MODEL_HERE Ship mounted laser"
	desc = "A ship-to-ship weapon which fires a destructive energy burst."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"

	fire_sound = 'sound/weapons/lasercannonfire.ogg'
	var/obj/item/stock_parts/cell/laser_cannon/cell
	var/obj/structure/cable/attached
	state = STATE_OFF

/obj/structure/ship_weapon/laser_cannon/Initialize()
	..()
	cell = new /obj/item/stock_parts/cell/laser_cannon
	cell.charge = 0
	var/turf/T = loc
	if(isturf(T))
		attached = locate() // Find the power cable we're sitting on

	if(!attached)
		state = STATE_DISCONNECTED // Otherwise STATE_OFF as in the initial declaration

/obj/structure/ship_weapon/laser_cannon/set_position(obj/structure/overmap/OM)
	OM.ship_lasers += src

/obj/structure/ship_weapon/laser_cannon/process()
	if(!attached || !anchored) // No cable or we're not wrenched down
		state = STATE_DISCONNECTED
		STOP_PROCESSING(SSobj, src)
		return
	if (state == STATE_OFF || state == STATE_DISCONNECTED) // Turned off or not connected to the grid, don't draw power
		STOP_PROCESSING(SSobj, src)
		return

	// Yes this is modified powersink code, why do you ask?
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

/obj/structure/ship_weapon/laser_cannon/can_fire() // STATE_READY *should* be enough indication but I won't assume anything
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

/obj/structure/ship_weapon/laser_cannon/fire()
	if(!can_fire())
		return
	// TODO: No animation for this yet
	// spawn(0) //Branch so that there isnt a fire delay for the helm.
	//	do_animation()
	state = STATE_FIRING

	playsound(src, fire_sound, 100, 1)

	power_fail(0, 10) // Kill the power for a moment
	for(var/mob/living/M in get_hearers_in_view(7, get_turf(src)))
		if(M.stat != DEAD)
			M.flash_act(affect_silicon = 1)

	cell.use(cell.maxcharge) // Used all the power we'd stored
	state = STATE_CHARGING
	after_fire()

// Parts

// Techweb

// Designs
