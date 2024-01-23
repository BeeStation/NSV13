/obj/item/clothing/suit/hooded/aquila/ghostcostume
	name = "spooky ghost costume"
	desc = "Spooky ghost costume costume."
	icon_state = "ghostcostume"
	hoodtype = /obj/item/clothing/head/hooded/aquila/huge/ghostcosstumehood
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/hooded/aquila/ghostcostume/Initialize(mapload)
	. = ..()
	allowed = GLOB.civilian_storage_allowed
