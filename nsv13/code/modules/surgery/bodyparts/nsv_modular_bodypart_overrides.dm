//This file is for some NSV bodypart overrides to avoid throwing them into base files.

///Bonus text to get for a given limb in its examine.
/obj/item/bodypart/proc/bonus_limb_id_text()
	return ""

//These two are here because how the name is static-built is stupid and this is a nice-ish way to attach to it.

/obj/item/bodypart/r_leg/robot/bonus_limb_id_text()
	if(bodytype & BODYTYPE_DIGITIGRADE)
		return " robotic"
	return ""

/obj/item/bodypart/l_leg/robot/bonus_limb_id_text()
	if(bodytype & BODYTYPE_DIGITIGRADE)
		return " robotic"
	return ""
