//Heavy Fighter
//High Max Speed, Slow turn, Slow accelerationba, Robust
//Uses Heavy Cannons and Torps (upgrades for Missiles)
/obj/structure/overmap/fighter/heavy
	name = "Su-395 Chelyabinsk"
	desc = "A space faring fighter craft."
	icon = 'nsv13/icons/overmap/nanotrasen/fighter.dmi' //temp
	icon_state = "fighter" //temp
	brakes = TRUE
	armor = list("melee" = 80, "bullet" = 50, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 80) //temp to stop easy destruction from small arms
	bound_width = 64 //Change this on a per ship basis
	bound_height = 96
	mass = MASS_TINY
	sprite_size = 32
	damage_states = FALSE //TEMP
	faction = "nanotrasen"
	max_integrity = 200 //Really really squishy!
	torpedoes = 0
	speed_limit = 6 //We want fighters to be way more maneuverable
	weapon_safety = TRUE //This happens wayy too much for my liking. Starts OFF.
	pixel_w = -26
	pixel_z = -28

/obj/structure/overmap/fighter/heavy/prebuilt
	prebuilt = TRUE
	components = list(/obj/item/fighter_component/fuel_tank/t1,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating/heavy/t1,
						/obj/item/fighter_component/targeting_sensor/heavy/t1,
						/obj/item/fighter_component/engine/heavy/t1,
						/obj/item/fighter_component/countermeasure_dispenser/t1,
						/obj/item/fighter_component/secondary/heavy/torpedo_rack/t1,
						/obj/item/fighter_component/primary/heavy/heavy_cannon/t1)

/obj/structure/overmap/fighter/heavy/attackby(obj/item/W, mob/user, params) //changing heavy equipment - used in fighters.dm maintenance mode
	.=..()
	if(maint_state == 2)  //MS_OPEN == 2
		if(istype(W, /obj/item/fighter_component/armour_plating/heavy) && !get_part(/obj/item/fighter_component/armour_plating/heavy))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 5 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			fuel_setup()
		else if(istype(W, /obj/item/fighter_component/targeting_sensor/heavy) && !get_part(/obj/item/fighter_component/targeting_sensor/heavy))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 5 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			update_stats()
		else if(istype(W, /obj/item/fighter_component/engine/heavy) && !get_part(/obj/item/fighter_component/engine/heavy))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 5 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			update_stats()
		else if(istype(W, /obj/item/fighter_component/secondary/heavy) && !get_part(/obj/item/fighter_component/secondary/heavy))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 5 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			update_stats()
		else if(istype(W, /obj/item/fighter_component/primary/heavy) && !get_part(/obj/item/fighter_component/primary/heavy))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 5 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			update_stats()