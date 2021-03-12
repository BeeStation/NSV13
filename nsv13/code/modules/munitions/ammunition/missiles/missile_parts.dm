/obj/item/ship_weapon/parts/missile
	var/target_state = 0
	var/fits_type = null

/obj/item/ship_weapon/parts/missile/warhead
	name = "NTP-2 standard guided munition payload"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "warhead"
	desc = "A heavy warhead designed to be fitted to a torpedo. It's currently inert."
	w_class = WEIGHT_CLASS_HUGE
	target_state = 6
	var/build_path = /obj/item/ship_weapon/ammunition/missile
	fits_type = /obj/item/ship_weapon/ammunition/missile/missile_casing //Used for warheads, missiles are different from torp.

/obj/item/ship_weapon/parts/missile/warhead/decoy
	name = "NTP-0x 'DCY' electronic countermeasure guided munition payload"
	desc = "a decoy torpedo warhead"
	icon_state = "warhead_decoy"
	desc = "A simple electronic countermeasure wrapped in a metal casing. While these form inert missiles, they can be used to distract enemy anti-missile defenses to divert their flak away from other targets."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/decoy

/obj/item/ship_weapon/parts/missile/guidance_system
	name = "missile guidance system"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "guidance"
	desc = "A guidance module for a missile which allows them to lock onto a target inside their operational range. The microcomputer inside it is capable of performing thousands of calculations a second."
	w_class = WEIGHT_CLASS_NORMAL
	target_state = 2
	var/accuracy = null

/obj/item/ship_weapon/parts/missile/propulsion_system
	name = "missile propulsion system"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "propulsion"
	desc = "A gimballed thruster with an attachment nozzle, designed to be mounted in missile."
	w_class = WEIGHT_CLASS_BULKY
	target_state = 0
	var/speed = 1

/obj/item/ship_weapon/parts/missile/iff_card //This should be abuseable via emag
	name = "missile IFF card"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "iff"
	desc = "An IFF chip which allows a missile to distinguish friend from foe. The electronics contained herein are relatively simple, but they form a crucial part of any good missile."
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