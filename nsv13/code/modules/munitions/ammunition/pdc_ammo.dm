/obj/item/ammo_box/magazine/pdc
	name = "point defense cannon ammo (30.12x82mm)"
	desc = "A box of .50 caliber rounds which can be loaded into a ship's point defense emplacements. These are typically used to shoot down oncoming missiles, and provide close quarters combat relief for large ships."
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "pdc"
	ammo_type = /obj/item/ammo_casing/pdc
	caliber = "mm30.12"
	max_ammo = 300
	var/overlay_frames = 17	//how many frames are in the "animation" of the ammo overlay
	var/last_frame //what the last frame was

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
		if (!(istype(loc, /obj/item/storage)||istype(loc, /obj/item/clothing)))//unless it's a backpack or something
			return FALSE
	var/count = stored_ammo.len //faster than ammo_count()
	if (!count)
		icon_state = "[initial(icon_state)]_empty"
		cut_overlays()
		last_frame = null
		return FALSE
	icon_state = "[initial(icon_state)]"
	if (count >= max_ammo)
		cut_overlays()
		last_frame = null
		return FALSE

	var/new_frame = round(overlay_frames * (count/max_ammo) + 1)
	if (new_frame == last_frame) 
		return FALSE
	last_frame = new_frame
	cut_overlays()

	if (count >= max_ammo)
		return FALSE
	
	add_overlay(icon("[icon]","pdc_overlay",frame = new_frame))
	return TRUE

/obj/item/ammo_box/magazine/pdc/examine(mob/user)
	. = ..()
	. += "<span class ='notice'>It has [ammo_count()] bullets left.</span>"
