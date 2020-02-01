/**
 * Munitions computer circuitboard
 */
/obj/item/circuitboard/computer/ship/munitions_computer
	name = "circuit board (munitions control computer)"
	build_path = /obj/machinery/computer/ship/munitions_computer

/**
 * PDC mount circuitboard
 */
/obj/item/circuitboard/machine/pdc_mount
	name = "circuit board (pdc mount)"
	build_path = /obj/machinery/ship_weapon/pdc_mount
	req_components = list(
		/obj/item/stock_parts/manipulator = 4,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/ship_weapon/parts/firing_electronics = 1
	)

/**
 * Firing electronics - used for pdcs, torp tubes, and railguns
 */
/obj/item/ship_weapon/parts/firing_electronics
	name = "firing electronics"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcl-0"

/**
 * Railgun loading tray
 */
/obj/item/ship_weapon/parts/loading_tray
	name = "loading tray"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcl-0"

/**
 * Railgun rail
 */
/obj/item/ship_weapon/parts/railgun_rail
	name = "rail"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcl-0"