/obj/item/ship_weapon/parts/missile
	var/target_state = 0
	var/fits_type = null

/obj/item/ship_weapon/parts/missile/warhead
	name = "NTP-2 standard missile payload"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "warhead"
	desc = "A heavy warhead designed to be fitted to a missile. It's currently inert."
	w_class = WEIGHT_CLASS_HUGE
	target_state = 6
	var/build_path = /obj/item/ship_weapon/ammunition/missile
	fits_type = /obj/item/ship_weapon/ammunition/missile/missile_casing //Used for warheads, missiles are different from torp.


/obj/item/ship_weapon/parts/missile/guidance_system
	name = "munition guidance system"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "guidance"
	desc = "A guidance module for soon-to-be guided munitions, allowing them to lock onto a target inside their operational range. The microcomputer inside it is capable of performing thousands of calculations a second."
	w_class = WEIGHT_CLASS_NORMAL
	target_state = 2
	var/accuracy = null

/obj/item/ship_weapon/parts/missile/propulsion_system
	name = "guided munition propulsion system"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "propulsion"
	desc = "A gimballed thruster with an attachment nozzle, designed to be mounted in guided munitions."
	w_class = WEIGHT_CLASS_BULKY
	target_state = 0
	var/speed = 1

/obj/item/ship_weapon/parts/missile/iff_card //This should be abuseable via emag
	name = "guided munition IFF card"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "iff"
	desc = "An IFF chip which allows a guided munition to distinguish friend from foe. The electronics contained herein are relatively simple, but nonetheless crucial."
	w_class = WEIGHT_CLASS_SMALL
	target_state = 4
	var/calibrated = FALSE

/obj/item/ship_weapon/parts/missile/iff_card/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	user.visible_message("<span class='warning'>[user] shorts out [src]!</span>",
						"<span class='notice'>You short out the IFF protocols on [src].</span>",
						"Bzzzt.")
	icon_state = "iff_hacked"