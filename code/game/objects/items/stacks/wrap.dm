

/*
 * Wrapping Paper
 */

/obj/item/stack/wrapping_paper
	name = "wrapping paper"
	desc = "Wrap packages with this festive paper to make gifts."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "wrap_paper"
	item_flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	resistance_flags = FLAMMABLE

/obj/item/stack/wrapping_paper/use(used, transfer)
	var/turf/T = get_turf(src)
	. = ..()
	if(QDELETED(src) && !transfer)
		new /obj/item/c_tube(T)


/*
 * Package Wrap
 */

/obj/item/stack/package_wrap
	name = "package wrapper"
	singular_name = "wrapping sheet"
	desc = "You can use this to wrap items in."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "deliveryPaper"
	item_flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	resistance_flags = FLAMMABLE

/obj/item/stack/package_wrap/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] begins wrapping [user.p_them()]self in \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if(use(3))
		var/obj/structure/big_delivery/P = new /obj/structure/big_delivery(get_turf(user.loc))
		P.icon_state = "deliverypackage5"
		user.forceMove(P)
		P.add_fingerprint(user)
		return OXYLOSS
	else
		to_chat(user, "<span class='warning'>You need more paper!</span>")
		return SHAME

/obj/item/proc/can_be_package_wrapped() //can the item be wrapped with package wrapper into a delivery package
	return 1

/obj/item/storage/can_be_package_wrapped()
	return 0

/obj/item/storage/box/can_be_package_wrapped()
	return 1

/obj/item/small_delivery/can_be_package_wrapped()
	return 0

/obj/item/stack/package_wrap/afterattack(obj/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!istype(target))
		return
	if(target.anchored)
		return
	///NSV13 - Cargo Borgs - Start
	if(!amount)
		return
	///NSV13 - Cargo Borgs - Stop

	if(isitem(target))
		var/obj/item/I = target
		if(!I.can_be_package_wrapped())
			return
		if(user.is_holding(I))
			if(!user.dropItemToGround(I))
				return
		else if(!isturf(I.loc))
			return
		if(use(1))
			//NSV13 - no bypassing "you cannot pick this up" limits, also adds twohand requirement for WEIGHT_CLASS_GIGANTIC items & inherits density properties.
			var/obj/item/small_delivery/P = new /obj/item/small_delivery(get_turf(I.loc))
			I.forceMove(P)
			var/size = round(I.w_class)
			P.name = "[weight_class_to_text(size)] parcel"
			P.w_class = size
			if(!CHECK_BITFIELD(I.interaction_flags_item, INTERACT_ITEM_ATTACK_HAND_PICKUP))
				DISABLE_BITFIELD(P.interaction_flags_item, INTERACT_ITEM_ATTACK_HAND_PICKUP)
			if(size >= WEIGHT_CLASS_GIGANTIC)
				P.AddComponent(/datum/component/two_handed, require_twohands = TRUE)
			if(I.density)
				P.density = TRUE
			size = min(size, 5)
			P.icon_state = "deliverypackage[size]"
			if(user.Adjacent(P))
				P.add_fingerprint(user)
				I.add_fingerprint(user)
				if(CHECK_BITFIELD(P.interaction_flags_item, INTERACT_ITEM_ATTACK_HAND_PICKUP))
					user.put_in_hands(P)
		//NSV13 end.

	else if(istype (target, /obj/structure/closet))
		var/obj/structure/closet/O = target
		if(O.opened)
			return
		if(!O.delivery_icon) //no delivery icon means unwrappable closet (e.g. body bags)
			to_chat(user, "<span class='warning'>You can't wrap this!</span>")
			return
		if(use(3))
			var/obj/structure/big_delivery/P = new /obj/structure/big_delivery(get_turf(O.loc))
			P.icon_state = O.delivery_icon
			O.forceMove(P)
			P.add_fingerprint(user)
			O.add_fingerprint(user)
		else
			to_chat(user, "<span class='warning'>You need more paper!</span>")
			return
	else
		to_chat(user, "<span class='warning'>The object you are trying to wrap is unsuitable for the sorting machinery!</span>")
		return

	user.visible_message("<span class='notice'>[user] wraps [target].</span>")
	user.log_message("has used [name] on [key_name(target)]", LOG_ATTACK, color="blue")

/obj/item/stack/package_wrap/use(used, transfer = FALSE)
	var/turf/T = get_turf(src)
	. = ..()
	if(QDELETED(src) && !transfer)
		new /obj/item/c_tube(T)

/obj/item/c_tube
	name = "cardboard tube"
	desc = "A tube... of cardboard."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "c_tube"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 5
