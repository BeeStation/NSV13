/obj/item/clothing/head/mod
	name = "MOD helmet"
	desc = "A helmet for a MODsuit."
	icon = 'nsv13/icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "helmet"
	worn_icon = 'nsv13/icons/mob/clothing/mod.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	body_parts_covered = HEAD
	heat_protection = HEAD
	cold_protection = HEAD
	dynamic_hair_suffix = ""
	obj_flags = IMMUTABLE_SLOW
	var/alternate_layer = NECK_LAYER
	var/obj/item/mod/control/mod

/obj/item/clothing/head/mod/Destroy()
	if(!QDELETED(mod))
		mod.helmet = null
		mod.mod_parts -= src
		QDEL_NULL(mod)
	return ..()

/obj/item/clothing/head/mod/obj_destruction(damage_flag)
	return mod.obj_destruction(damage_flag)

/obj/item/clothing/suit/mod
	name = "MOD chestplate"
	desc = "A chestplate for a MODsuit."
	icon = 'nsv13/icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "chestplate"
	worn_icon = 'nsv13/icons/mob/clothing/mod.dmi'
	blood_overlay_type = "armor"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	body_parts_covered = CHEST|GROIN
	heat_protection = CHEST|GROIN
	cold_protection = CHEST|GROIN
	obj_flags = IMMUTABLE_SLOW
	var/obj/item/mod/control/mod

/obj/item/clothing/suit/mod/Destroy()
	if(!QDELETED(mod))
		mod.chestplate = null
		mod.mod_parts -= src
		QDEL_NULL(mod)
	return ..()

/obj/item/clothing/suit/mod/obj_destruction(damage_flag)
	return mod.obj_destruction(damage_flag)

/obj/item/clothing/gloves/mod
	name = "MOD gauntlets"
	desc = "A pair of gauntlets for a MODsuit."
	icon = 'nsv13/icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "gauntlets"
	worn_icon = 'nsv13/icons/mob/clothing/mod.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	body_parts_covered = HANDS|ARMS
	heat_protection = HANDS|ARMS
	cold_protection = HANDS|ARMS
	obj_flags = IMMUTABLE_SLOW
	var/obj/item/mod/control/mod
	var/obj/item/clothing/overslot

/obj/item/clothing/gloves/mod/Destroy()
	if(!QDELETED(mod))
		mod.gauntlets = null
		mod.mod_parts -= src
		QDEL_NULL(mod)
	return ..()

/obj/item/clothing/gloves/mod/obj_destruction(damage_flag)
	overslot.forceMove(drop_location())
	overslot = null
	return mod.obj_destruction(damage_flag)

/// Replaces these gloves on the wearer with the overslot ones
/obj/item/clothing/gloves/mod/proc/show_overslot()
	if(!overslot)
		return
	if(!mod.wearer.equip_to_slot_if_possible(overslot, overslot.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		mod.wearer.dropItemToGround(overslot, force = TRUE)
	overslot = null

/obj/item/clothing/shoes/mod
	name = "MOD boots"
	desc = "A pair of boots for a MODsuit."
	icon = 'nsv13/icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "boots"
	worn_icon = 'nsv13/icons/mob/clothing/mod.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	body_parts_covered = FEET|LEGS
	heat_protection = FEET|LEGS
	cold_protection = FEET|LEGS
	obj_flags = IMMUTABLE_SLOW
	item_flags = IGNORE_DIGITIGRADE
	var/obj/item/mod/control/mod
	var/obj/item/clothing/overslot

/obj/item/clothing/shoes/mod/Destroy()
	if(!QDELETED(mod))
		mod.boots = null
		mod.mod_parts -= src
		QDEL_NULL(mod)
	return ..()

/obj/item/clothing/shoes/mod/obj_destruction(damage_flag)
	overslot.forceMove(drop_location())
	overslot = null
	return mod.obj_destruction(damage_flag)

/// Replaces these shoes on the wearer with the overslot ones
/obj/item/clothing/shoes/mod/proc/show_overslot()
	if(!overslot)
		return
	if(!mod.wearer.equip_to_slot_if_possible(overslot, overslot.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		mod.wearer.dropItemToGround(overslot, force = TRUE)
	overslot = null
