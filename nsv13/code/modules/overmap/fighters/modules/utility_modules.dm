// Aircraft Plasma Cutter
/obj/item/fighter_component/primary/plasmacutter
	name = "217-A Heavy Plasma Cutter"
	desc = "A modified plasma cutter for mounting on Sabre-class utility vessels."
	icon_state = "mecha_plasmacutter"
	item_state = "plasmacutter"
	accepted_ammo = null
	weight = 1 // Plasma cutter + gimbal mount, pretty heavy
	burst_size = 1
	fire_delay = 0.5 SECONDS
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('sound/weapons/plasma_cutter.ogg')
	icon = 'icons/mecha/mecha_equipment.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	slot = HARDPOINT_SLOT_UTILITY_PRIMARY
	var/projectile = /obj/item/projectile/plasma/adv/sabre
	var/charge_to_fire = 2500

/obj/item/fighter_component/primary/plasmacutter/get_ammo()
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return FALSE
	var/obj/item/fighter_component/battery/B = F.loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	if(!istype(B))
		return 0
	return B.charge

/obj/item/fighter_component/primary/plasmacutter/get_max_ammo()
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return FALSE
	var/obj/item/fighter_component/battery/B = F.loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	if(!istype(B))
		return 0
	return B.maxcharge

/obj/item/fighter_component/primary/plasmacutter/fire(obj/structure/overmap/target)
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return FALSE
	var/obj/item/fighter_component/battery/B = F.loadout.get_slot(HARDPOINT_SLOT_BATTERY)

	if(B.charge < charge_to_fire)
		F.relay('sound/weapons/gun_dry_fire.ogg')
		return FALSE

	var/datum/ship_weapon/SW = F.weapon_types[fire_mode]
	SW.default_projectile_type = projectile
	SW.fire_fx_only(target, lateral = TRUE)
	B.charge -= charge_to_fire
	return TRUE

/obj/item/projectile/plasma/adv/sabre
	range = 6
	mine_range = 7 // 13 total range, 6 without rocks so people don't try to do the funny with it
