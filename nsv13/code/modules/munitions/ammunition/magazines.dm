/obj/item/ammo_box/magazine/nsv
	name = "generic ammo"
	desc = "An ammo magazine for an overly generic ship weapon. This probably shouldn't be here."
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "pdc"
	ammo_type = /obj/item/ammo_casing/pdc
	caliber = "mm30.12"
	max_ammo = 300
	var/overlay_name = "pdc_overlay"
	var/overlay_frames = 17	//how many frames are in the "animation" of the ammo overlay
	var/last_frame //what the last frame was

/obj/item/ammo_box/magazine/nsv/forceMove()
	..()
	update_icon()//update icon when removed from a machine

/obj/item/ammo_box/magazine/nsv/update_icon()
	if (isobj(loc)) //don't update if it's in an object
		if (!(istype(loc, /obj/item/storage)||istype(loc, /obj/item/clothing)))//unless it's a backpack or something
			return FALSE
	var/count = length(stored_ammo) //faster than ammo_count()
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
	
	add_overlay(icon("[icon]","[overlay_name]",frame = new_frame))
	return TRUE

/obj/item/ammo_box/magazine/nsv/examine(mob/user)
	. = ..()
	. += "<span class ='notice'>It has [ammo_count()] bullets left.</span>"

/obj/item/ammo_box/magazine/nsv/pdc
	name = "point defense cannon ammo (30.12x82mm)"
	desc = "A box of PDC rounds which can be loaded into a ship's point defense emplacements. These are typically used to shoot down oncoming missiles, and provide close quarters combat relief for large ships."
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "pdc"
	ammo_type = /obj/item/ammo_casing/pdc
	caliber = "mm30.12"
	max_ammo = 300

/obj/item/ammo_casing/pdc
	name = "30.12x82mm bullet casing"
	desc = "A 30.12x82mm bullet casing."
	projectile_type = /obj/item/projectile/bullet/pdc_round
	caliber = "mm30.12"

/obj/item/ammo_box/magazine/nsv/flak
	name = "40mm flak rounds"
	icon_state = "flak"
	ammo_type = /obj/item/ammo_casing/flak
	caliber = "mm40"
	max_ammo = 150

/obj/item/ammo_casing/flak
	name = "mm40 flak round casing"
	desc = "A mm40 bullet casing."
	projectile_type = /obj/item/projectile/bullet/flak
	caliber = "mm40"

/obj/item/ammo_box/magazine/nsv/anti_air
	name = "AA turret rounds" // Just going to rename the current box to avoid a bunch of map changes, or creating duplicate code for a rename
	ammo_type = /obj/item/ammo_casing/anti_air
	caliber = "mm50pdc"
	max_ammo = 300
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_casing/anti_air
	name = "50mm round casing"
	desc = "A 50mm bullet casing."
	projectile_type = /obj/item/projectile/bullet/aa_round
	caliber = "mm50pdc"
