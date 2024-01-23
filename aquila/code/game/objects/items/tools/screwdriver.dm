/obj/item/screwdriver
	icon = 'aquila/icons/obj/tools.dmi'
	lefthand_file = 'aquila/icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/equipment/tools_righthand.dmi'

/obj/item/screwdriver/abductor/get_belt_overlay()
	return mutable_appearance('aquila/icons/obj/clothing/belt_overlays.dmi', "screwdriver_nuke")
