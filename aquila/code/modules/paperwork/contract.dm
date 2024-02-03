/obj/item/paper/contract/infernal/pleasure
	name = "paper- contract of pleasure"
	contractType = CONTRACT_PLEASURE

/obj/item/paper/contract/infernal/pleasure/update_text(signature = "____________", blood = 0)
	default_raw_text = "<center><B>Contract of pleasure</B></center><BR><BR><BR>I, [target] of sound mind, do hereby willingly offer my soul to the infernal hells by way of the infernal agent [devil_datum.truename], in exchange for boundless pleasure.  I understand that upon my demise, my soul shall fall into the infernal hells, and my body may not be resurrected, cloned, or otherwise brought back to life.  I also understand that this will prevent my brain from being used in an MMI.<BR><BR><BR>Signed, "
	if(blood)
		default_raw_text += "<font face=\"Nyala\" color=#600A0A size=6><i>[signature]</i></font>"
	else
		default_raw_text += "<i>[signature]</i>"

/obj/item/paper/contract/infernal/pleasure/fulfillContract(mob/living/user = target.current, blood = 0)
	if(!istype(user) || !user.mind)
		return -1
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/sex(null))
	return ..()
