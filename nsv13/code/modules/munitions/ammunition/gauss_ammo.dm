/obj/item/ship_weapon/ammunition/gauss //Medium sized slugs to be loaded into a gauss gun.
	name = "M4 NTRS '30mm' teflon coated tungsten round"
	desc = "A gigantic slug that's designed to be fired out of a railgun. It's extremely heavy, but doesn't actually contain any volatile components, so it's safe to manhandle."
	icon_state = "gauss"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'
	icon = 'nsv13/icons/obj/munitions.dmi'
	w_class = 4
	projectile_type = /obj/item/projectile/bullet/gauss_slug

/obj/item/ship_weapon/ammunition/gauss/Initialize()
	..()
	AddComponent(/datum/component/twohanded/required)
