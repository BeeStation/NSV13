/obj/item/borg/apparatus/munitions
	name = "integrated mechanical clamp"
	desc = "A mechanical clamp designed for carrying highly volatile equipment without causing violent reactions."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_clamp"
	storable = list(
		/obj/item/powder_bag,
		/obj/item/ship_weapon/ammunition,
		/obj/item/ship_weapon/parts,
		/obj/item/ammo_box/magazine/nsv,
	)

/obj/item/borg/apparatus/munitions/update_icon()
	cut_overlays()
	if(stored)
		COMPILE_OVERLAYS(stored)
		stored.pixel_x = 0
		stored.pixel_y = 0
		var/image/img = image("icon"=stored, "layer"=FLOAT_LAYER)
		img.plane = FLOAT_PLANE
		add_overlay(img)

/obj/item/borg/apparatus/munitions/examine()
	. = ..()
	if(stored)
		. += "The clamps are currently holding [stored]"
		. += "<span class='notice'<i>Alt-click</i> will drop the currently stored [stored].</span>"

/obj/item/borg/apparatus/munitions/AltClick(mob/living/silicon/robot/user)
	if(!stored)
		return ..()
	stored.pixel_x = initial(stored.pixel_x)
	stored.pixel_y = initial(stored.pixel_y)
	stored.forceMove(get_turf(user))
