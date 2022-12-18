/obj/item/gun/ballistic/automatic
	automatic = 1

/obj/item/gun/ballistic/automatic/peacekeeper
	name = "M2A45 security pulse rifle"
	desc = "A large personal defense weapon commonly employed by Nanotrasen security forces. This advanced weapon uses a magnetic acceleration system in favour of traditional gunpowder, allowing specialized 6mm rounds to be loaded."
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	icon_state = "peacekeeper"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/guns_righthand.dmi'
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
	slot_flags = ITEM_SLOT_BACK
	fire_sound = 'nsv13/sound/weapons/m4_fire.wav'
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
	damage = 10 //Hopefully making it bias towards armorpen should make it less likely to kill people straight out.
	armour_penetration = 30
	icon = 'nsv13/icons/obj/projectiles_nsv.dmi'
	icon_state = "pdc"

/obj/item/projectile/bullet/peacekeeper/stun
	name = "6mm electro-shock round"
	damage = 6 //Straight up WAY worse than the security glock at stunning, but they serve a purpose
	armour_penetration = 0 //Less strong. Can't penetrate armor.
	stamina = 5 //20 hits required to fully stun, by that time you probably killed them anyway!
	stutter = 5
	jitter = 5
	range = 7
	color = "#f5e3b3"

/obj/item/ammo_box/magazine/peacekeeper
	name = "M2A45 pulse rifle magazine (nonlethal)"
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "peacekeeper_stun"
	ammo_type = /obj/item/ammo_casing/peacekeeper
	caliber = "6mm"
	max_ammo = 75

/obj/item/ammo_box/magazine/peacekeeper/lethal
	name = "pinned M2A45 pulse rifle magazine (lethal)"
	icon_state = "peacekeeper"
	ammo_type = /obj/item/ammo_casing/peacekeeper/lethal
	caliber = "6mm"
	max_ammo = 75

/obj/item/ammo_box/magazine/peacekeeper/update_icon()
	..()
	if(ammo_count() > 0)
		icon_state = "[initial(icon_state)]-20"
	else
		icon_state = "[initial(icon_state)]-0"

/obj/item/gun/ballistic/automatic/mp_smg
	name = "MP-16A4 'peacemaker' military police SMG"
	desc = "A bullpup style 9mm SMG used by peacekeeping forces. While bulky, it's an imposing weapon designed to instill order into the masses."
	icon = 'nsv13/icons/obj/guns/guns_big.dmi'
	icon_state = "mp16"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/guns_righthand.dmi'
	item_state = "mp16"
	mag_type = /obj/item/ammo_box/magazine/smgm9mm
	can_suppress = TRUE
	w_class = WEIGHT_CLASS_BULKY //Too big for a backpack. Can fit on your belt or back.
	fire_delay = 1
	fire_rate = 4
	burst_size = 1
	can_bayonet = TRUE
	knife_x_offset = 25
	knife_y_offset = 12
	mag_display = TRUE
	mag_display_ammo = FALSE
	empty_indicator = FALSE
	weapon_weight = WEAPON_HEAVY
	fire_sound = 'nsv13/sound/weapons/smg_fire.ogg'
	recoil = 0.2 //Tiny jolt when you fire it.
	full_auto = TRUE

/obj/item/gun/ballistic/automatic/marine_rifle
	name = "M4A-16A1 assault rifle"
	desc = "A 5.56mm caliber assault rifle used by Blue Phalanx marines in boarding operations. While it's a relatively old-fashioned design, it's proven cheap to mass produce and exceptionally reliable."
	icon = 'nsv13/icons/obj/guns/guns_big.dmi'
	icon_state = "m4a4"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/guns_righthand.dmi'
	item_state = "m4a4"
	mag_type = /obj/item/ammo_box/magazine/m556
	can_suppress = TRUE
	w_class = WEIGHT_CLASS_HUGE //Too big for a backpack. Can fit on your belt or back.
	fire_delay = 1
	burst_size = 1
	fire_rate = 4
	can_bayonet = TRUE
	knife_x_offset = 25
	knife_y_offset = 12
	mag_display = TRUE
	mag_display_ammo = FALSE
	empty_indicator = FALSE
	weapon_weight = WEAPON_HEAVY
	fire_sound = 'nsv13/sound/weapons/rifle_fire.ogg'
	recoil = 0.5 //BANG
	full_auto = TRUE
	pixel_x = -4
	pin = /obj/item/firing_pin/boarding

/obj/item/gun/ballistic/shotgun/automatic/pistol
	name = "\improper Solir 4 revolver hybrid"
	desc = "A retro high-powered shotgun revolver typically used by high ranking officials. Uses shells."
	icon_state = "shotgunpistol"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	item_state = "gun"
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	weapon_weight = WEIGHT_CLASS_NORMAL
	rack_sound = 'sound/weapons/revolverdry.ogg'
	bolt_type = BOLT_TYPE_NO_BOLT
	semi_auto = TRUE
	fire_rate = 1.5
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com
	pin = /obj/item/firing_pin/implant/pindicate

/obj/item/ammo_box/shotgun_lethal
	name = "speed loader (buckshot)"
	desc = "Designed to quickly reload shell-based revolvers."
	icon_state = "shotlethal"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	max_ammo = 6
	multiple_sprites = 1

/obj/item/gun/ballistic/rifle/boltaction/pdc
	name = "\improper Point Defence Rifle"
	desc = "A rifle made to fire PDC rounds."
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	icon_state = "pdcrifle"
	item_state = "pdcrifle"
	worn_icon_state = "moistnugget"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/guns_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/pdc
	can_bayonet = TRUE
	knife_x_offset = 27
	knife_y_offset = 13
	w_class = WEIGHT_CLASS_NORMAL // It's a syndicate weapon so weight is reduced to allow it to be hidden in backpacks
	weapon_weight = WEAPON_MEDIUM
