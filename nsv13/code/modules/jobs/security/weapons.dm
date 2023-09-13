
/obj/item/gun/ballistic/tazer
	name = "X24 Tazer"
	desc = "A stunning weapon developed by Czanek Corp. It can deliver an extremely powerful electric shock via a specialised electrode, though the electrodes must be manually replaced after each shot. <b>It has an effective range of 2 meters</b>"
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
	can_flashlight = TRUE
	flight_x_offset = 15
	flight_y_offset = 12

/obj/item/gun/ballistic/automatic/pistol/glock
	name = "Glock-13"
	desc = "A small 9mm handgun used by Nanotrasen crewmen. It has a polymer handle and a full durasteel body construction, giving it a nice weight."
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	icon_state = "crewglock"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/guns_righthand.dmi'
	item_state = "glock"
	fire_sound = 'nsv13/sound/weapons/glock.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/glock
	can_suppress = TRUE
	automatic = FALSE
	can_flashlight = TRUE
	flight_x_offset = 15
	flight_y_offset = 12
	fire_rate = 2

/obj/item/gun/ballistic/automatic/pistol/glock/security
	name = "Glock-13BR"
	desc = "A small 9mm handgun used by Nanotrasen security forces. It has burst-fire capabilities and a weighted grip to tame the recoil."
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	icon_state = "secglock"
	item_state = "glock"
	fire_sound = 'nsv13/sound/weapons/glock.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/glock
	can_suppress = TRUE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)
	automatic = FALSE
	can_flashlight = TRUE
	flight_x_offset = 15
	flight_y_offset = 12
	fire_rate = 2

/obj/item/gun/ballistic/automatic/pistol/glock/makarov
	name = "Makarov NT"
	desc = "An older handgun used by NT security forces, produced by H&KC but slowly being phased out by the Glock-13. One of the designers of the weapon went on record saying: 'There are no brakes on this commie fucktrain.'"
	icon_state = "makarov"

/obj/item/gun/ballistic/automatic/pistol/glock/makarov/lethal //Starts with lethal bullets loaded
	mag_type = /obj/item/ammo_box/magazine/glock/lethal

/obj/item/gun/ballistic/automatic/pistol/m1911/m9le
	name = "\improper M9LE"
	desc = "A military surplus pistol no longer in service, but boasting a higher muzzle velocity than other handguns. It's a reliable damage dealer despite its age."
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	icon_state = "m9"
	item_state = "glock"
	fire_sound = 'nsv13/sound/weapons/glock.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/m45
	can_suppress = FALSE

/obj/item/ammo_box/c45/m45 // .45 ammobox intended for m1911
	max_ammo = 24

/datum/design/gulagpack
	name = "Gulagpack"
	id = "gulagpack"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=10000, /datum/material/glass=2500)
	build_path = /obj/item/storage/backpack/gulagpack
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	category = list("Equipment")


/obj/item/gun/ballistic/automatic/pistol/glock/command
	name = "Command Glock-13"
	desc = "A small 9mm handgun used by high ranking Nanotrasen officers, it's been customized with a nice wooden handle painted with a small emblem and blue stripes."
	icon_state = "commandglock"

/obj/item/gun/ballistic/automatic/pistol/glock/security/hos
	name = "Winona"
	desc = "A handgun that's never let its owner down before. It's got a pleasant wooden grip with plenty of detailing etched into it. A nice, all round weapon to defend yourself with."
	icon_state = "commandglock"
	full_auto = TRUE
	requires_wielding = FALSE //While the HoS's upgraded energy gun gets a ion setting, Winona gets to fire with one hand without decreased accuracy.
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/datum/design/lethal9mm
	name = "9mm Ammo Box"
	id = "glock_lethalammo"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 30000)
	build_path = /obj/item/ammo_box/c9mm
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/lethalglockmag
	name = "Glock Magazine"
	id = "glock_lethalmag"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 16500)
	build_path = /obj/item/ammo_box/magazine/glock/lethal
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/rubbershot
	name = "9mm rubber Glock round"
	id = "glock_ammo"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500)
	build_path = /obj/item/ammo_casing/c9mm/rubber
	category = list("initial", "Security")

/datum/design/rubber9mm
	name = "9mm Ammo Box (Rubber)"
	id = "glock_rubberammo"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000)
	build_path = /obj/item/ammo_box/c9mm/rubber
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/glockmag
	name = "Glock Magazine (Rubber)"
	id = "glock_rubbermag"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 14000)
	build_path = /obj/item/ammo_box/magazine/glock
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/ap9mm
	name = "9mm Ammo Box (Armour Piercing)"
	id = "glock_apammo"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/titanium = 4000, /datum/material/silver = 1000)
	build_path = /obj/item/ammo_box/c9mm/ap
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/apglockmag
	name = "Glock Magazine (Armour Piercing)"
	id = "glock_apmag"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 14000, /datum/material/titanium = 150, /datum/material/silver = 150)
	build_path = /obj/item/ammo_box/magazine/glock/ap
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/inc9mm
	name = "9mm Ammo box (Incendiary)"
	id = "glock_incammo"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/plasma = 4000, /datum/material/glass = 500, /datum/material/gold = 500)
	build_path = /obj/item/ammo_box/c9mm/inc
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/incglockmag
	name = "Glock Magazine (Incendiary)"
	id = "glock_incmag"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 14000, /datum/material/plasma = 150, /datum/material/glass = 50, /datum/material/gold = 50)
	build_path = /obj/item/ammo_box/magazine/glock/inc
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/tazer
	name = "3mm electro-shock tazer round"
	id = "tazer_ammo"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 800)
	build_path = /obj/item/ammo_casing/tazer
	category = list("initial", "Security")

/obj/item/ammo_box/magazine/glock/lethal
	name = "pistol magazine (9mm Lethal)"
	desc = "Loaded with lead bullets that excel in dealing with hostile threats onboard or offboard the ship."
	icon_state = "Glock-lethal"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 15

/obj/item/ammo_box/magazine/glock
	name = "pistol magazine (9mm Non-lethal)"
	desc = "Loaded with rubber bullets that excel in disabling limbs and pacifying at range."
	icon_state = "Glock-nonlethal"
	ammo_type = /obj/item/ammo_casing/c9mm/rubber
	caliber = "9mm"
	max_ammo = 15

/obj/item/ammo_box/magazine/glock/ap
	name = "pistol magazine (9mm Armour Piercing)"
	desc = "Loaded with titanium tipped bullets that excel in dealing with armored hostile threats onboard or offboard the ship."
	icon_state = "Glock-ap"
	ammo_type = /obj/item/ammo_casing/c9mm/ap
	caliber = "9mm"
	max_ammo = 15

/obj/item/ammo_box/magazine/glock/inc
	name = "pistol magazine (9mm Incendiary)"
	desc = "Loaded with plasma tipped bullets that excel in setting any living target on fire."
	icon_state = "Glock-lethal"
	ammo_type = /obj/item/ammo_casing/c9mm/inc
	caliber = "9mm"
	max_ammo = 15

/obj/item/ammo_box/magazine/glock/update_icon()
    ..()
    icon_state = "[initial(icon_state)][ammo_count() ? "" : "-0"]"

/obj/item/ammo_box/c9mm/ap // for colouring
	name = "ammo box (9mm Armour Piercing)"
	icon_state = "45box"
	ammo_type = /obj/item/ammo_casing/c9mm/ap
	max_ammo = 30

/obj/item/ammo_box/c9mm/inc
	name = "ammo box (9mm Incendiary)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/c9mm/inc
	max_ammo = 30

/obj/item/ammo_casing/c9mm/rubber
	name = "9mm rubber bullet casing"
	desc = "A 9mm rubber bullet casing."
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/c9mm/rubber

/obj/item/ammo_box/c9mm/rubber
	name = "ammo box (9mm Rubber)"
	icon_state = "9mmbox"
	ammo_type = /obj/item/ammo_casing/c9mm/rubber
	max_ammo = 30

/obj/item/projectile/bullet/c9mm/rubber
	name = "9mm bullet"
	damage = 20
	damage_type = STAMINA
	icon = 'nsv13/icons/obj/projectiles_nsv.dmi'
	icon_state = "pdc"

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
	name =  "3mm electro-shock tazer round"
	desc = "A tazer cartridge."
	caliber = "3mm"
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "tasershell"
	projectile_type = /obj/item/projectile/energy/electrode/hitscan
	materials = list(/datum/material/iron=4000)
	harmful = TRUE

/obj/item/projectile/energy/electrode/hitscan
	range = 2 //Real life tazers have an effective range of 4.5 meters.
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


//Secborg guns
/obj/item/gun/energy/printer/taser
	name = "Cyborg X25 Taser"
	desc = "A stunning weapon developed by Czanek Corp. It can deliver an extremely powerful electric shock via a specialised electrode, the electrodes are resupplied using the cyborg's internal power source. <b>It has an effective range of 2 meters</b>"
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	icon_state = "taser"
	recoil = 2 //BZZZZTTTTTTT
	ammo_type = list(/obj/item/ammo_casing/energy/taser)
	automatic = FALSE
	fire_rate = 0.2

/obj/item/ammo_casing/energy/taser
	projectile_type = /obj/item/projectile/energy/electrode/hitscan
	select_name = "electrode"
	fire_sound = 'sound/weapons/zapbang.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect
	e_cost = 600 //uses a lot more energy

/obj/item/gun/energy/printer/glock
	name = "Cyborg Glock-13BR"
	desc = "An integrated 9mm handgun for use by Nanotrasen security cyborgs. Designed to fire lethal bullets"
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	icon_state = "secborgglock"
	ammo_type = list(/obj/item/ammo_casing/energy/c9mmbullet/rubber, /obj/item/ammo_casing/energy/c9mmbullet) //Switch between lethal or rubber bullets with attack_self
	automatic = FALSE
	fire_rate = 2

/obj/item/ammo_casing/energy/c9mmbullet
	projectile_type = /obj/item/projectile/bullet/c9mm
	select_name = "9mm"
	fire_sound = 'nsv13/sound/weapons/glock.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect

/obj/item/ammo_casing/energy/c9mmbullet/rubber
	projectile_type = /obj/item/projectile/bullet/c9mm/rubber
	select_name = "9mm (Rubber)"
