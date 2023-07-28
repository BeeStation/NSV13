/obj/item/borg/apparatus/munitions
	name = "integrated mechanical clamp"
	desc = "A mechanical clamp designed for carrying volatile equipment without causing violent reactions."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_clamp"
	storable = list(
		/obj/item/powder_bag,
		/obj/item/ship_weapon/parts,
		/obj/item/ammo_box/magazine/nsv,
		/obj/item/fighter_component,
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

/obj/item/borg/upgrade/munitions
	name = "munitions manipulation apparatus"
	desc = "An engineering cyborg upgrade allowing for manipulation of munitions related equipment."
	icon_state = "cyborg_upgrade3"
	require_module = TRUE
	module_type = list(/obj/item/robot_module/engineering, /obj/item/robot_module/saboteur)
	module_flags = BORG_MODULE_ENGINEERING

/obj/item/borg/upgrade/munitions/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/borg/apparatus/munitions/M = locate() in R.module.modules
		if(M)
			to_chat(user, "<span class='warning'>This unit is already equipped with a munitions apparatus.</span>")
			return FALSE

		M = new(R.module)
		R.module.basic_modules += M
		R.module.add_module(M, FALSE, TRUE)

/obj/item/borg/upgrade/munitions/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/borg/apparatus/munitions/M = locate() in R.module.modules
		if(M)
			R.module.remove_module(M, TRUE)
