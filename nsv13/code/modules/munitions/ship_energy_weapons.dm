#define STATE_DISCONNECTED 1
#define STATE_OFF 2
#define STATE_CHARGING 3
#define STATE_READY 4
#define STATE_FIRING 5

/obj/structure/ship_weapon/laser_cannon
	name = "MODEL_HERE Ship mounted laser"
	desc = "A ship-to-ship weapon which fires a destructive energy burst. This particular model has an effective range of 20,000KM."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"

	fire_sound = 'sound/weapons/lasercannonfire.ogg'
	load_sound = null
	// TODO: figure out how game balance works
	var/max_power = 200000 //How much power does it cost to fire this?
	var/current_power = 0 //How much do we currently have?
	var/drain_rate = 1000 //How fast do we charge?

	var/obj/structure/cable/attached

	state = STATE_OFF

/obj/structure/ship_weapon/laser_cannon/Initialize()
	// Get the power node we're sitting on
	var/turf/T = loc
	if(isturf(T) && !T.intact)
		attached = locate() in T
	if(!attached)
		world << "didn't get the attached cable"
		state = STATE_DISCONNECTED
	else
		world << "found the power cable maybe"
	..()

/obj/structure/ship_weapon/laser_cannon/set_position(obj/structure/overmap/OM)
	OM.ship_lasers += src

/obj/structure/ship_weapon/laser_cannon/process()
	if(!attached || !anchored)
		world << "No cable or we're not wrenched down"
		state = STATE_DISCONNECTED
		return
	if (state == STATE_OFF)
		world << "The laser is off, why are we processing?"
		return
	var/datum/powernet/PN = attached.powernet
	if(PN)
		world << "Found apowernet, drawing power"
		// found a powernet, so drain up to max power from it
		var/drained = min ( drain_rate, attached.newavail() )
		attached.add_delayedload(drained)
		current_power += drained

		// if tried to drain more than available on powernet
		// now look for APCs and drain their cells
		if(drained < drain_rate)
			world << "Not enough on the powernet, looking for APCs"
			for(var/obj/machinery/power/terminal/T in PN.nodes)
				if(istype(T.master, /obj/machinery/power/apc))
					var/obj/machinery/power/apc/A = T.master
					if(A.operating && A.cell)
						A.cell.charge = max(0, A.cell.charge - 50)
						current_power += 50
						if(A.charging == 2) // If the cell was full
							A.charging = 1 // It's no longer full
				if(drained >= drain_rate)
					break
		if(current_power >= max_power)
			world << "Got enough power!"
			STOP_PROCESSING(SSobj, src)
			state = STATE_READY


/obj/structure/ship_weapon/laser_cannon/fire()
	if(!can_fire())
		return
	//spawn(0) //Branch so that there isnt a fire delay for the helm.
	//	do_animation()
	state = STATE_FIRING

	playsound(src, fire_sound, 100, 1)
	for(var/mob/living/M in get_hearers_in_view(10, get_turf(src))) //Burst unprotected eardrums
		if(M.stat == DEAD || !isliving(M))
			continue
		M.soundbang_act(1,200,10,15)
	new /obj/effect/dummy/lighting_obj (get_turf(src), LIGHT_COLOR_WHITE, 6, 4, 2) // flash
	power_fail(5, 15)

	state = STATE_CHARGING
	after_fire()

// Control computer
/obj/machinery/computer/ship/laser_computer
	name = "laser control computer"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "munitions_console"
	density = TRUE
	anchored = TRUE
	req_access = list(ACCESS_MUNITIONS)
	var/obj/structure/ship_weapon/laser_cannon //The one we're firing

/obj/machinery/computer/ship/laser_computer/Initialize()
	. = ..()
	var/atom/adjacent = locate(/obj/structure/ship_weapon) in get_turf(get_step(src, dir)) //Look at what dir we're facing, find a gun in that turf
	if(adjacent && istype(adjacent, /obj/structure/ship_weapon))
		laser_cannon = adjacent

/obj/machinery/computer/ship/laser_computer/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/laser_computer/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/laser_computer/attack_hand(mob/user)
	. = ..()
	if(!laser_cannon)
		return
	if(!laser_cannon.linked)
		laser_cannon.get_ship()
	var/dat

	// TODO: figure out desired steps/states for firing this thing
	dat += "<h2> Power: </h2>"
	if(laser_cannon.state <= STATE_OFF)
		dat += "<A href='?src=\ref[src];turn_on=1'>Begin charging</font></A><BR>" //STEP 1: Turn the gun on
	else
		dat += "<A href='?src=\ref[src];turn_off=1'>Stop charging</font></A><BR>" //OPTIONAL: Cancel loading

	dat += "<h2> Charge status: </h2>"
	if(laser_cannon.state != STATE_READY)
		// TODO: Put a progress bar, not a button
		dat += "<A href='?src=\ref[src];wait_charge=1'>The weapon is not charged.</font></A><BR>" //Step 2: Wait for it to charge
	else
		dat += "<A href='?src=\ref[src];tray_notif=1'>'[laser_cannon.name]' is ready to fire</font></A><BR>" //We have the power

	dat += "<h2> Safeties: </h2>"
	if(laser_cannon.safety)
		dat += "<A href='?src=\ref[src];disengage_safeties=1'>Disengage safeties</font></A><BR>" //Step 3: Disengage safeties. This allows the helm to fire the weapon.
	else
		dat += "<A href='?src=\ref[src];engage_safeties=1'>Engage safeties</font></A><BR>" //OPTIONAL: Re-engage safeties. Use this if some disaster happens in the tubes, and you need to forbid the helm from firing
	var/datum/browser/popup = new(user, "Fire control systems", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/ship/laser_computer/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!laser_cannon)
		return
	if(href_list["turn_on"])
		world << "starting to charge"
		laser_cannon.state = STATE_CHARGING
		START_PROCESSING(SSobj, laser_cannon)
	if(href_list["turn_off"])
		laser_cannon.state = STATE_OFF
		STOP_PROCESSING(SSobj, laser_cannon)
	//if(href_list["wait_charge"])
	if(href_list["disengage_safeties"])
		laser_cannon.safety = FALSE
	if(href_list["engage_safeties"])
		laser_cannon.safety = TRUE

	attack_hand(usr) //Refresh window


// Parts

// Techweb

// Designs
