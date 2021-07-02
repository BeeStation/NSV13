/obj/item/ammo_box/magazine/pdc
	name = "point defense cannon ammo (30.12x82mm)"
	desc = "A box of .50 caliber rounds which can be loaded into a ship's point defense emplacements. These are typically used to shoot down oncoming missiles, and provide close quarters combat relief for large ships."
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "pdc"
	ammo_type = /obj/item/ammo_casing/pdc
	caliber = "mm30.12"
	max_ammo = 300
	var/fancy_start = 25	//the pixel position of the first 'bullet' shown in the magazine
	var/fancy_end   = 8		//the pixel position of the last 'bullet'
	var/last_pixel	//the last pixel position to be used

/obj/item/ammo_casing/pdc
	name = "30.12x82mm bullet casing"
	desc = "A 30.12x82mm bullet casing."
	projectile_type = /obj/item/projectile/bullet/pdc_round
	caliber = "mm30.12"

/obj/item/ammo_box/magazine/pdc/forceMove()
	..()
	update_icon()//update icon when removed from a machine

/obj/item/ammo_box/magazine/pdc/update_icon()
	if (istype(loc, /obj))//don't update if it's in an object
		if (istype(loc, /obj/item/storage)||istype(loc, /obj/item/clothing))//unless it's a backpack or something
			fancy_icon()
		return FALSE
	fancy_icon()

/obj/item/ammo_box/magazine/pdc/examine(mob/user)
	. = ..()
	. += "<span class ='notice'>It has [ammo_count()] bullets left.</span>"

/obj/item/ammo_box/magazine/pdc/proc/fancy_icon()//new proc because it's probably too slow for all the times update_icon gets called
	var/count = stored_ammo.len //faster than ammo_count()
	var/new_pixel = round(((count/max_ammo)*(fancy_start - fancy_end)) + fancy_end + 1)

	if (!count)
		icon_state = "[initial(icon_state)]_empty"
		cut_overlays()
		last_pixel = null
		return FALSE
	icon_state = "[initial(icon_state)]"

	if (new_pixel == last_pixel) 
		return FALSE
	last_pixel = new_pixel
	cut_overlays()

	if (count >= max_ammo)
		return FALSE
	
	var/icon/mask = icon("[icon]","[initial(icon_state)]_empty")
	mask.Crop(new_pixel,1,(32 + new_pixel),32)
	mask.Shift(EAST,(new_pixel - 1))
	add_overlay(mask)
	return TRUE
	

