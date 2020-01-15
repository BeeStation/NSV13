/obj/machinery/ship_weapon/pdc_mount
	name = "PDC loading rack"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "pdc"
	desc = "Seegson's all-in-one PDC targeting computer, ammunition loader, and human interface has proven extremely popular in recent times. It's rare to see a ship without one of these."
	anchored = TRUE
	density = FALSE
	pixel_y = 26
	var/obj/item/ammo_box/magazine/pdc/magazine = null
	magazine_type = /obj/item/ammo_box/magazine/pdc
	linked = null

/obj/machinery/ship_weapon/pdc_mount/attack_hand(mob/user)
	. = ..()
	if(magazine)
		to_chat(user, "<span class='notice'>You start to unload [magazine] from [src].</span>")
		if(do_after(user,50, target = src))
			user.put_in_hands(magazine)
			magazine = null
			update_icon()
			playsound(src, 'sound/weapons/autoguninsert.ogg', 100, 1)

/obj/machinery/ship_weapon/pdc_mount/attackby(obj/item/I, mob/user)
	if(!linked)
		var/area/AR = get_area(src)
		if(AR.linked_overmap)
			linked = AR.linked_overmap
			linked?.pdcs += src
	if(istype(I, /obj/item/ammo_box/magazine/pdc))
		to_chat(user, "<span class='notice'>You start to load [I] into [src].</span>")
		if(do_after(user,50, target = src))
			to_chat(user, "<span class='notice'>You load [I] into [src].</span>")
			playsound(src, 'sound/weapons/autoguninsert.ogg', 100, 1)
			if(magazine)
				user.put_in_hands(magazine)
				magazine = null
			I.forceMove(src)
			magazine = I
			update_icon()
	else
		. = ..()

/obj/machinery/ship_weapon/pdc_mount/update_icon()
	if(!magazine)
		icon_state = "[initial(icon_state)]_0"
		return
	var/progress = magazine.ammo_count() //How damaged is this shield? We examine the position of index "I" in the for loop to check which directional we want to check
	var/goal = magazine.max_ammo //How much is the max hp of the shield? This is constant through all of them
	progress = CLAMP(progress, 0, goal)
	progress = round(((progress / goal) * 100), 20)//Round it down to 20%. We now apply visual damage
	icon_state = "[initial(icon_state)]_[progress]"

/obj/machinery/ship_weapon/pdc_mount/can_fire(shots) //We need to fire 3 shots. Can we do that?
	if(magazine?.ammo_count() > shots)
		return TRUE
	else
		return FALSE

/obj/machinery/ship_weapon/pdc_mount/fire(shots)
	if(can_fire(shots))
		for(var/i = 0, i < shots, i++)
			var/obj/item/projectile/P = magazine.get_round(FALSE)
			qdel(P)
			update_icon()
		return TRUE
	else
		return FALSE

/obj/item/ammo_box/magazine/pdc
	name = "Point defense cannon ammo (30.12x82mm)"
	desc = "A box of .30 caliber rounds which can be loaded into a ship's point defense emplacements. These are typically used to shoot down oncoming missiles, and provide close quarters combat relief for large ships."
	icon_state = "pdc"
	ammo_type = /obj/item/ammo_casing/pdc
	caliber = "mm30.12"
	max_ammo = 100


/obj/item/ammo_box/magazine/pdc/update_icon()
	if(ammo_count() > 10)
		icon_state = "pdc"
	else
		icon_state = "pdc_empty"

/obj/item/ammo_casing/pdc
	name = "30.12x82mm bullet casing"
	desc = "A 30.12x82mm bullet casing."
	projectile_type = /obj/item/projectile/bullet/pdc_round