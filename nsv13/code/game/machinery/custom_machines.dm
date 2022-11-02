/obj/machinery/telecomms/relay/preset/mining/nostromo
	icon = 'nsv13/icons/obj/cm_ai.dmi' //Credit to CM for this one
	bound_x = 96

/obj/structure/fluff/bleepypanel
	name = "Seegson computational node"
	desc = "A large mainframe panel which processes data at a transfer speed of 1Kb/s through magnetised tape. These mainframes were made all but obsolete by fibre optic technology, but sufficiently old ships still rely heavily on them for signal processing."
	icon = 'nsv13/icons/obj/computers.dmi'
	icon_state = "bleepypanel"
	density = FALSE
	anchored = TRUE
	light_color = LIGHT_COLOR_ORANGE


/obj/structure/fluff/bleepypanel/Initialize()
	. = ..()
	set_light(1)

//Drop trooper space suit storage units.
/obj/machinery/suit_storage_unit/syndicate/odst
	suit_type = /obj/item/clothing/suit/space/syndicate/odst
	mask_type = /obj/item/clothing/mask/gas/syndicate
	helmet_type = /obj/item/clothing/head/helmet/space/syndicate/odst

/obj/machinery/suit_storage_unit/syndicate/odst/marine
	suit_type = /obj/item/clothing/suit/space/syndicate/odst/marine
	helmet_type = /obj/item/clothing/head/helmet/space/syndicate/odst/marine