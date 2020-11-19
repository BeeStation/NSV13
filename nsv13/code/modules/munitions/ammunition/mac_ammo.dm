/obj/item/ship_weapon/ammunition/mac_ammo //TEMP SHELLS - replace later
	name = "Y2 NTRL 500mm tungsten cased explosive shell"
	desc = "A gigantic slug that's designed to be fired out of a MAC. It's extremely heavy, and contains explosive components; handle with care."
	icon_state = "railgun_ammo"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'
	icon = 'nsv13/icons/obj/munitions.dmi'
	w_class = 5
	projectile_type = /obj/item/projectile/bullet/mac_round

/obj/item/ship_weapon/ammunition/mac_ammo/Initialize()
	..()
	AddComponent(/datum/component/twohanded/required)
