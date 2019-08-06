/obj/item/gun/ballistic/automatic/peacekeeper
	name = "M2A45 security pulse rifle"
	desc = "A large personal defense weapon commonly employed by the colonial peacekeepers. This advanced weapon uses a magnetic acceleration system in favour of traditional gunpowder, allowing specialized 6mm rounds to be loaded."
	icon = 'sephora/icons/obj/guns/projectile.dmi'
	icon_state = "peacekeeper"
	item_state = "peacekeeper"
	mag_type = /obj/item/ammo_box/magazine/peacekeeper
	can_suppress = FALSE
	w_class = 4 //Too big for a backpack. Can fit on your belt or back.
	fire_delay = 2
	burst_size = 3
	can_bayonet = TRUE
	knife_x_offset = 25
	knife_y_offset = 12
	mag_display = TRUE
	mag_display_ammo = TRUE
	empty_indicator = TRUE
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	fire_sound = 'sephora/sound/weapons/m4_fire.wav'
	recoil = 0.1 //Tiny jolt when you fire it.

/obj/item/ammo_casing/peacekeeper
	name =  "6mm electro-shock round"
	desc = "A 6mm tungsten round."
	caliber = "6mm"
	projectile_type = /obj/item/projectile/bullet/peacekeeper/stun
	materials = list(/datum/material/iron=4000)

/obj/item/ammo_casing/peacekeeper/lethal
	name = "6mm tungsten round"
	projectile_type = /obj/item/projectile/bullet/peacekeeper

/obj/item/projectile/bullet/peacekeeper
	name = "6mm tungsten round"
	damage = 20
	icon_state = "pdc"

/obj/item/projectile/bullet/peacekeeper/stun
	name = "6mm electro-shock round"
	damage = 0
	paralyze = 100
	stutter = 5
	jitter = 20
	range = 7
	color = "#f5e3b3"

/obj/item/projectile/bullet/peacekeeper/stun/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		do_sparks(1, TRUE, src)
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "tased", /datum/mood_event/tased)
		SEND_SIGNAL(C, COMSIG_LIVING_MINOR_SHOCK)
		if(C.dna && C.dna.check_mutation(HULK))
			C.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ), forced = "hulk")

/obj/item/ammo_box/magazine/peacekeeper
	name = "M2A45 pulse rifle magazine (nonlethal)"
	icon_state = "peacekeeper_stun"
	ammo_type = /obj/item/ammo_casing/peacekeeper
	caliber = "6mm"
	max_ammo = 20

/obj/item/ammo_box/magazine/peacekeeper/lethal
	name = "M2A45 pulse rifle magazine (lethal)"
	icon_state = "peacekeeper"
	ammo_type = /obj/item/ammo_casing/peacekeeper/lethal
	caliber = "6mm"
	max_ammo = 20

/obj/item/ammo_box/magazine/peacekeeper/update_icon()
	..()
	if(ammo_count() > 0)
		icon_state = "[initial(icon_state)]-20"
	else
		icon_state = "[initial(icon_state)]-0"
