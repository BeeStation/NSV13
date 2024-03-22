/obj/item/ship_weapon/ammunition/railgun_ammo //The big slugs that you load into the railgun. These are able to be carried...one at a time
	name = "\improper M4 NTRS 400mm teflon coated tungsten round"
	desc = "A gigantic slug that's designed to be fired out of a railgun. It's extremely heavy, but doesn't actually contain any volatile components, so it's safe to manhandle."
	icon_state = "railgun_ammo"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'
	icon = 'nsv13/icons/obj/munitions.dmi'
	w_class = 4
	projectile_type = /obj/item/projectile/bullet/railgun_slug

/obj/item/ship_weapon/ammunition/railgun_ammo/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/obj/item/ship_weapon/ammunition/railgun_ammo/uranium
	name = "\improper U4 NTRK 400mm teflon coated uranium round"
	desc = "A gigantic slug that's designed to be fired out of a railgun. It's extremely heavy, but doesn't actually contain any volatile components, so it's safe to manhandle."
	icon_state = "railgun_ammo"
	projectile_type = /obj/item/projectile/bullet/railgun_slug/uranium
