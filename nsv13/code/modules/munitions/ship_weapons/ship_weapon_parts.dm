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
	icon = 'icons/obj/module.dmi'
	icon_state = "mcontroller"

/**
 * Railgun loading tray
 */
/obj/item/ship_weapon/parts/loading_tray
	name = "loading tray"
	icon = 'nsv13/icons/obj/items_and_weapons.dmi'
	icon_state = "railgun_tray"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'

/obj/item/ship_weapon/parts/loading_tray/Initialize()
	..()
	AddComponent(/datum/component/twohanded/required)

/**
 * Railgun rail
 */
/obj/item/ship_weapon/parts/railgun_rail
	name = "rail"
	icon = 'nsv13/icons/obj/items_and_weapons.dmi'
	icon_state = "railgun_rail"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'

/obj/item/ship_weapon/parts/railgun_rail/Initialize()
	..()
	AddComponent(/datum/component/twohanded/required)