/obj/item/implant/security_down
	name = "security officer down implant"
	activated = 0

/obj/item/implant/security_down/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Localized Officer Death Notification Emission System. <BR>
				Emits an audible noise on cessation of life functions of the user.<BR>
				<b>Life:</b> Activates upon death.<BR>
				"}
	return dat

/obj/item/implant/security_down/trigger(emote, mob/source)
	if(emote == "deathgasp")
		playsound(loc, 'aquila/sound/misc/security_down.ogg', 50, 0)

/obj/item/implanter/security_down
	name = "implanter (security officer down)"
	imp_type = /obj/item/implant/security_down

/obj/item/implantcase/security_down
	name = "implant case - 'security officer down'"
	desc = "A glass case containing a security officer down implant. Emits a loud burst of static if the implanted person dies."
	imp_type = /obj/item/implant/security_down
