/obj/item/ship_weapon/parts //Base item
	name = "Weapon electronics"
	desc = "This piece of equipment is a figment of your imagination, let the coders know how you got it!"
	icon = 'icons/obj/module.dmi'
	icon_state = "mcontroller"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/item/ship_weapon/parts/Destroy(force=FALSE)
	if(!force)
		return QDEL_HINT_LETMELIVE
	return ..()

/**
 * Firing electronics - used in construction of <s>new</s> old munitions machinery
 */
/obj/item/ship_weapon/parts/firing_electronics
	name = "firing electronics"
	desc = "The firing circuitry for a large weapon."
	icon = 'icons/obj/module.dmi'
	icon_state = "mcontroller"

/**
 * Railgun loading tray
 */
/obj/item/ship_weapon/parts/loading_tray
	name = "loading tray"
	desc = "A loading tray for a large weapon."
	icon = 'nsv13/icons/obj/items_and_weapons.dmi'
	icon_state = "railgun_tray"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'

/obj/item/ship_weapon/parts/loading_tray/Initialize()
	..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/**
 * Railgun rail
 */
/obj/item/ship_weapon/parts/railgun_rail
	name = "rail"
	desc = "A magnetic rail for a railgun."
	icon = 'nsv13/icons/obj/items_and_weapons.dmi'
	icon_state = "railgun_rail"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'

/obj/item/ship_weapon/parts/railgun_rail/Initialize()
	..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/**
 * MAC Barrel
 */
/obj/item/ship_weapon/parts/mac_barrel
	name = "barrel"
	desc = "The barrel for a MAC."
	icon = 'nsv13/icons/obj/items_and_weapons.dmi'
	icon_state = "mac_barrel"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'

/obj/item/ship_weapon/parts/mac_barrel/Initialize()
	..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)
