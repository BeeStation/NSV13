/**
 * Munitions computer circuitboard
 */
/obj/item/circuitboard/computer/munitions
	name = "circuit board (laser cannon control computer)"
	build_path = /obj/machinery/computer/ship/munitions_computer

/**
 * Railgun circuitboard
 */
/obj/item/circuitboard/machine/railgun
	name = "Railgun (Machine Board)"
	build_path = /obj/machinery/ship_weapon/railgun
	req_components = list(
		/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/mineral/copper = 2)

/**
 * Torpedo circuitboard
 */
/obj/item/circuitboard/machine/torpedo_launcher
	name = "Torpedo Launcher (Machine Board)"
	build_path = /obj/machinery/ship_weapon/torpedo_launcher
	req_components = list(
		/obj/item/stock_parts/micro_laser/quadultra = 1,
		/obj/item/stack/sheet/mineral/diamond = 3)

/**
 * PDC mount circuitboard
 */
/obj/item/circuitboard/machine/pdc_mount
	name = "PDC Mount (Machine Board)"
	build_path = /obj/machinery/ship_weapon/pdc_mount
	req_components = list(
		/obj/item/stock_parts/capacitor/quadratic = 5,
		/obj/item/stock_parts/micro_laser/quadultra = 5,
		/obj/item/stack/sheet/mineral/diamond = 3)
