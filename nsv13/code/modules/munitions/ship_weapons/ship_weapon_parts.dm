/obj/item/ship_weapon/parts //Base item
	name = "Weapon electronics"
	desc = "This piece of equipment is a figment of your imagination, let the coders know how you got it!"
	icon = 'icons/obj/module.dmi'
	icon_state = "mcontroller"

/**
 * Firing electronics - used in construction of <s>new</s> old munitions machinery
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

/**
 * MAC Barrel
 */
/obj/item/ship_weapon/parts/mac_barrel
	name = "barrel"
	icon = 'nsv13/icons/obj/items_and_weapons.dmi'
	icon_state = "mac_barrel"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'

/obj/item/ship_weapon/parts/mac_barrel/Initialize()
	..()
	AddComponent(/datum/component/twohanded/required)