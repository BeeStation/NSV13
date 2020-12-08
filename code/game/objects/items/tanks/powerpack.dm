// Atmos holofan powerpack code
/obj/item/powerpack
	name = "ATMOS Holofan Backpack"
	desc = "A portable powerpack system connected to an ATMOS holofan projector that is intended for massive breaches. Able to be used at a distance."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	item_state = "waterbackpackatmos"
	icon_state = "waterbackpackatmos"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	slowdown = 0
	actions_types = list(/datum/action/item_action/toggle_powerpack)
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 30)
	resistance_flags = FIRE_PROOF
	var/obj/item/holofan

/obj/item/powerpack/Initialize()
	. = ..()
	holofan = make_holofan()

/obj/item/powerpack/ui_action_click(mob/user)
	toggle_powerpack(user)

/obj/item/powerpack/item_action_slot_check(slot, mob/user)
	if(slot == user.getBackSlot())
		return 1

/obj/item/powerpack/proc/toggle_powerpack(mob/living/user)
	if(!istype(user))
		return
	if(user.get_item_by_slot(user.getBackSlot()) != src)
		to_chat(user, "<span class='warning'>The powerpack must be worn properly to use!</span>")
		return
	if(user.incapacitated())
		return

	if(QDELETED(holofan))
		holofan = make_holofan()
	if(holofan in src)
		//Detach the holofan into the user's hands
		if(!user.put_in_hands(holofan))
			to_chat(user, "<span class='warning'>You need a free hand to hold the holofan!</span>")
			return
	else
		//Remove from their hands and put back "into" the powerpack
		remove_holofan()

/obj/item/powerpack/verb/toggle_powerpack_verb()
	set name = "Toggle Powerpack"
	set category = "Object"
	toggle_powerpack(usr)

/obj/item/powerpack/proc/make_holofan()
	return new /obj/item/holosign_creator/atmos/powerpack(src)

/obj/item/powerpack/equipped(mob/user, slot)
	..()
	if(slot != SLOT_BACK)
		remove_holofan()

/obj/item/powerpack/proc/remove_holofan()
	if(!QDELETED(holofan))
		if(ismob(holofan.loc))
			var/mob/M = holofan.loc
			M.temporarilyRemoveItemFromInventory(holofan, TRUE)
		holofan.forceMove(src)

/obj/item/powerpack/Destroy()
	QDEL_NULL(holofan)
	return ..()

/obj/item/powerpack/attack_hand(mob/user)
	if (user.get_item_by_slot(user.getBackSlot()) == src)
		toggle_powerpack(user)
	else
		return ..()

/obj/item/powerpack/MouseDrop(obj/over_object)
	var/mob/M = loc
	if(istype(M) && istype(over_object, /obj/screen/inventory/hand))
		var/obj/screen/inventory/hand/H = over_object
		M.putItemFromInventoryInHandIfPossible(src, H.held_index)
	return ..()

/obj/item/powerpack/attackby(obj/item/W, mob/user, params)
	if(W == holofan)
		remove_holofan()
		return 1
	else
		return ..()

/obj/item/powerpack/dropped(mob/user)
	..()
	remove_holofan()
