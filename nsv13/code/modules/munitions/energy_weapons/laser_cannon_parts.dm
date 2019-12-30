// Techweb, designs, and parts for the ship-to-ship laser cannon

/* **********
 * PARTS
 * **********/

/*
 * Machine circuit board for the actual laser cannon
 * Cannon construction requires 5 tier 3 capacitors and lasers, a torpedo IFF card because targeting is good, a special power cell, and diamonds for a lens
 */
/obj/item/circuitboard/machine/laser_cannon
	name = "Laser Cannon (Machine Board)"
	build_path = /obj/structure/ship_weapon/laser_cannon
	req_components = list(
		/obj/item/stock_parts/capacitor/super = 5,
		/obj/item/stock_parts/micro_laser/ultra = 5,
		/obj/item/stock_parts/cell/laser_cannon = 1,
		/obj/item/torpedo/iff_card = 1,
		/obj/item/stack/sheet/mineral/diamond = 3)

/*
 * Special power cell for the laser cannon
 *
 * IMPORTANT: If ship weapons are ever moved under /obj/machinery, rework this.
 *			  Replacing it will cause the weapon to have different charge rates and amounts, and we should probably
 *			  either scale damage or make replace_parts not work on this.
 */
/obj/item/stock_parts/cell/laser_cannon
	name = "laser cannon power collector"
	icon_state = "hpcell"

	// TODO: figure out how game balance works
	maxcharge = 200000
	materials = list(/datum/material/glass=800)
	chargerate = 10000
	var/maxchargerate = 100000

/*
 * EMP shield the power cell - don't explode munitions
 */
/obj/item/stock_parts/cell/laser_cannon/corrupt() // No we will not explode thanks
	return

/*
 * Computer circuit board for the control console
 */
/obj/item/circuitboard/computer/laser_cannon
	name = "circuit board (laser cannon control computer)"
	build_path = /obj/machinery/computer/ship/laser_cannon_computer

/*
 * Machine frame for the laser cannon. Mostly works like the regular kind, but made of plasteel and with fancy sprites.
 */
/obj/structure/frame/machine/laser_cannon
	name = "MODEL_HERE laser cannon frame"
	icon = 'nsv13/icons/obj/laser_cannon.dmi'
	icon_state = "laser_frame_loose"

/*
 * Clue people in to what's unusual about assembly
 */
/obj/structure/frame/machine/laser_cannon/examine(user)
	. = ..()
	. += " It uses a special power cell, a torpedo IFF card, and a diamond focusing lens."

/* *************
 * TECHWEB AND DESIGNS
 * Requires beam weapons because it's a laser, torpedo for the IFF card, computers for the console,
 * and advanced power because it has a special power cell and draws power from the whole grid.
 * Three unique parts: machine circuit, computer circuit, and power cell
 * *************/
/datum/techweb_node/ship_laser_cannon
	id = "ship_laser_cannon"
	display_name = "Ship Laser Weaponry"
	description = "A powerful experimental laser for ship-to-ship combat."
	prereq_ids = list("beam_weapons", "basic_torpedo_components", "comptech", "adv_power")
	design_ids = list("laser_cannon_circuit", "laser_cannon_cell", "laser_cannon_computer")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 4000)
	export_price = 8000

/datum/design/board/laser_cannon
	name = "Machine Design (Laser Cannon)"
	desc = "Allows for the construction of a ship-to-ship laser cannon."
	id = "laser_cannon_circuit"
	build_path = /obj/item/circuitboard/machine/laser_cannon
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/laser_cannon_computer
	name = "Computer Design (Laser Cannon Control)"
	desc = "Allows for the construction of laser cannon control computer."
	id = "laser_cannon_computer_circuit"
	build_path = /obj/item/circuitboard/computer/laser_cannon
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/laser_cannon_cell
	name = "Power Cell (Laser Cannon)"
	desc = "Allows for the construction of a ship-to-ship laser cannon."
	id = "laser_cannon_cell"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 800, /datum/material/gold = 120, /datum/material/glass = 160, \
					 /datum/material/diamond = 160, /datum/material/titanium = 300, /datum/material/copper = 100)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/laser_cannon
	category = list("Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE