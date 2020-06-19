/datum/gear/donator
	subtype_path = /datum/gear/donator
	unlocktype = GEAR_DONATOR
	sort_category = "Donator"
	cost = null //Unused in this category

/datum/gear/purchase(client/C)
	//This can be used to explain the code function of the item or otherwise cover ass.
	to_chat(C, "<span class='boldwarning'>Your donator item has been added to your account. It will be removed automatically if your donation lapses.</span>")

/datum/gear/donator/example
	display_name = "Example Donator Item"
	description = "Example Donator Description"
	ckey = "jimthefish" //ckey should be in canonical format.
	path = /obj/item/toy/plush/carpplushie

/**
Donator item reskin devices!
requisite_type should be the typepath of the "thing" that these reskin. If you need to change more than icon, you'll have to implement specific behaviour for each item on apply_reskin.
*/

/obj/item/donator_reskin
	name = "Donator reskin device"
	desc = "Apply your donator skin to things!"
	icon = 'nsv13/icons/obj/donator.dmi'
	icon_state = "painter"
	var/requisite_type = null
	var/ckey = null //Who owns this? Prevents random people from using it.
	var/reskin_icon = 'nsv13/icons/obj/donator.dmi' //This can be any icon. Lets you hotswap out icons

/obj/item/donator_reskin/afterattack(atom/A, mob/user)
	if(requisite_type && istype(A, requisite_type))
#ifndef TESTING
		if(user.client?.ckey != ckey)
			to_chat(user, "<span class='sciradio'>Nothing happens! (These items are usable only by the donator who it belongs to, consider donating to get one of these for yourself!)</span>")
			return
#else
		if(user.client?.ckey != ckey)
			to_chat(user, "<span class='boldwarning'>This donator item is owned by [ckey]! <code>TESTING</code> Has bypassed this check.</span>")
#endif
		apply_reskin(A)
		return
	. = ..()
/*
Override this method to apply the unique reskin for your item if you want to change more than icon.
*/
/obj/item/donator_reskin/proc/apply_reskin(atom/movable/A)
	if(!istype(A))
		return
	A.icon = reskin_icon
	A.AddComponent(/datum/component/donator, ckey)
	playsound(src, 'sound/effects/spray.ogg', 5, 1, 5)
	qdel(src)
