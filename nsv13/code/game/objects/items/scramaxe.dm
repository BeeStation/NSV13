/obj/item/twohanded/fireaxe/scramaxe
	name = "SCRAM Axe"
	desc = "A artifact from the old days. Where we werent dependent on expensive computers to help with our nuclear reactors. Where all that was between you and certain death was 1 man. With a trusty axe. To cut the control rod rope"

/obj/item/twohanded/fireaxe/scramaxe/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(SEND_SIGNAL(src, COMSIG_ITEM_IS_WIELDED) & COMPONENT_WIELDED)
		if(istype(A, /obj/machinery/atmospherics/components/binary/stormdrive_reactor))
			var/obj/machinery/atmospherics/components/binary/stormdrive_reactor/W = A
			W.control_rod_percent = 100
			W.update_icon()
			to_chat(user,"<span class='danger'>Your not sure why. But hitting the reactor with the axe caused the control rods to drop!</span>")
