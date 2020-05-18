
/obj/item/gun/ballistic/tazer
	name = "X24 Tazer"
	desc = "A stunning weapon developed by Czanek Corp. It can deliver an extremely powerful electric shock via a specialised electrode, though the electrodes must be manually replaced after each shot. <b>It has an effective range of 4 meters</b>"
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	icon_state = "taser"
	mag_type = /obj/item/ammo_box/magazine/tazer_cartridge
	can_suppress = FALSE
	w_class = 2
	fire_delay = 2 SECONDS
	can_bayonet = FALSE
	mag_display = TRUE
	mag_display_ammo = FALSE
	bolt_type = BOLT_TYPE_LOCKING
	slot_flags = ITEM_SLOT_BELT
	fire_sound = 'sound/weapons/zapbang.ogg'
	recoil = 2 //BZZZZTTTTTTT

/obj/item/ammo_box/magazine/tazer_cartridge
	name = "X24 Tazer cartridge"
	desc = "A cartridge which can hold a taser electrode"
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "taser-1"
	ammo_type = /obj/item/ammo_casing/tazer
	caliber = "3mm"
	max_ammo = 1

/obj/item/ammo_box/magazine/tazer_cartridge/update_icon()
	..()
	icon_state = (ammo_count()) ? "taser-1" : "taser"

///Lets the officer have an ammo box filled with tazer cartridges ready to hotswap.

/obj/item/ammo_box/magazine/tazer_cartridge_storage
	name = "X24 cartridge storage rack"
	desc = "A small clip which you can slot tazer electrodes into."
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "taserrack-0"
	ammo_type = /obj/item/ammo_casing/tazer
	caliber = "3mm"
	max_ammo = 5

/obj/item/ammo_box/magazine/tazer_cartridge_storage/update_icon()
	..()
	icon_state = "taserrack-[ammo_count()]"

/obj/item/ammo_casing/tazer
	name =  "3mm electro-shock round"
	desc = "A tazer cartridge."
	caliber = "3mm"
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "tasershell"
	projectile_type = /obj/item/projectile/energy/electrode/hitscan
	materials = list(/datum/material/iron=4000)
	harmful = TRUE

/obj/item/projectile/energy/electrode/hitscan
	range = 4 //Real life tazers have an effective range of 4.5 meters.
	damage = 75 //4 second stun by itself
	damage_type = STAMINA
	hitscan = TRUE

/obj/item/projectile/energy/electrode/hitscan/on_hit(atom/target, blocked = FALSE)
	if(prob(10) && !blocked) //The czanek corp taser comes with a price. The price is that your victim might have a fucking heartattack.
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			if(isethereal(M))
				M.reagents.add_reagent(/datum/reagent/consumable/liquidelectricity, 5) //Ethereals like electricity! And the hellish czanek corp taser has LOTS OF IT
				return ..()
			if(!M.undergoing_cardiac_arrest() && M.can_heartattack())
				M.log_message("suffered from a heartattack caused by a tazer shot", LOG_ATTACK, color="red")
				to_chat(M, "<span class='userdanger'>You feel a terrible pain in your chest, as if your heart has stopped!</span>")
				M.visible_message("<span class='userdanger'>[M] writhes around in pain, clutching at their chest!</span>")
				M.emote("scream")
				do_sparks(5, TRUE, M)
				M.shake_animation(10)
				M.set_heartattack(TRUE)
				M.reagents.add_reagent(/datum/reagent/medicine/corazone, 3) // To give the victim a final chance to shock their heart before losing consciousness
	. = ..()