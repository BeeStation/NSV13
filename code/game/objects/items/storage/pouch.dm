/obj/item/storage/pouch
	name = "abstract pouch"
	icon = 'icons/obj/clothing/pouches.dmi'
	icon_state = "small_drop"
	w_class = WEIGHT_CLASS_BULKY //does not fit in backpack
	slot_flags = ITEM_SLOT_POCKET

/obj/item/storage/pouch/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Can be worn by attaching it to a pocket.</span>"

/obj/item/storage/pouch/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 1
	STR.max_w_class = WEIGHT_CLASS_SMALL
	..()




/obj/item/storage/pouch/general
	name = "light general pouch"
	desc = "A general purpose pouch used to carry small items."
	icon_state = "small_drop"


/obj/item/storage/pouch/general/medium
	name = "medium general pouch"
	icon_state = "medium_drop"

/obj/item/storage/pouch/general/medium/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 2
	STR.max_w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/pouch/general/large
	name = "large general pouch"
	icon_state = "large_drop"

/obj/item/storage/pouch/general/large/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 3
	STR.max_w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/pouch/survival
	name = "survival pouch"
	desc = "It can contain flashlights, a pill, a crowbar, metal sheets, and some bandages."
	icon_state = "survival"

/obj/item/storage/pouch/survival/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.set_holdable(list(
		/obj/item/flashlight,
		/obj/item/reagent_containers/pill,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/plasteel,
		/obj/item/weldingtool
		))

/obj/item/storage/pouch/survival/full/PopulateContents()
	. = ..()
	new /obj/item/flashlight(src)
	new /obj/item/reagent_containers/pill/salicyclic(src)
	new /obj/item/stack/medical/bruise_pack(src, 3)
	new /obj/item/stack/sheet/metal(src, 40)
	new /obj/item/stack/sheet/plasteel(src, 15)
	new /obj/item/weldingtool(src)




/obj/item/storage/pouch/firstaid
	name = "first-aid pouch"
	desc = "It can contain autoinjectors, ointments, and bandages."
	icon_state = "firstaid"

/obj/item/storage/pouch/firstaid/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 5
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.set_holdable(list(
		/obj/item/stack/medical/ointment,
		/obj/item/reagent_containers/hypospray,
		/obj/item/stack/medical/bruise_pack,
		))

/obj/item/storage/pouch/firstaid/full
	desc = "Contains a painkiller autoinjector, first-aid autoinjector, splints, some ointment, and some bandages."

/obj/item/storage/pouch/firstaid/full/PopulateContents()
	. = ..()
	new /obj/item/stack/medical/ointment (src)
	new /obj/item/reagent_containers/hypospray/medipen/survival (src)
	new /obj/item/stack/medical/bruise_pack (src)


/obj/item/storage/pouch/firstaid/som
	name = "mining first aid pouch"
	desc = "A basic first aid pouch used by miners due to dangerous working conditions on the mining colonies."
	icon_state = "firstaid_som"

/obj/item/storage/pouch/firstaid/som/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 5
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.set_holdable(list(
		/obj/item/stack/medical/ointment,
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/stack/medical/bruise_pack,
		))


/obj/item/storage/pouch/firstaid/som/full
	desc = "A basic first aid pouch used by miners due to dangerous working conditions on the mining colonies. Contains the necessary items already."


/obj/item/storage/pouch/firstaid/som/full/PopulateContents()
	. = ..()
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/reagent_containers/hypospray/medipen/survival (src)
	new /obj/item/stack/medical/bruise_pack(src)


//// MAGAZINE POUCHES /////

/obj/item/storage/pouch/magazine
	name = "magazine pouch"
	desc = "It can contain ammo magazines."
	icon_state = "medium_ammo_mag"

/obj/item/storage/pouch/magazine/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 2
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.set_holdable(list(
		/obj/item/ammo_box
		))

/obj/item/storage/pouch/magazine/large
	name = "large magazine pouch"
	icon_state = "large_ammo_mag"

/obj/item/storage/pouch/magazine/large/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 3
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.set_holdable(list(
		/obj/item/ammo_box
		))


/obj/item/storage/pouch/medical
	name = "medical pouch"
	desc = "It can contain small medical supplies."
	icon_state = "medical"

/obj/item/storage/pouch/medical/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 3
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.set_holdable(list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers,
		/obj/item/stack/medical,
		/obj/item/flashlight/pen,
		))

/obj/item/storage/pouch/medical/full/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/pill/patch/styptic(src)
	new /obj/item/reagent_containers/medigel/silver_sulf(src)
	new /obj/item/reagent_containers/hypospray/medipen/penacid(src)

/obj/item/storage/pouch/autoinjector
	name = "auto-injector pouch"
	desc = "A pouch specifically for auto-injectors."
	icon_state = "autoinjector"

/obj/item/storage/pouch/autoinjector/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 7
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.max_combined_w_class = 14
	STR.set_holdable(list(
		/obj/item/reagent_containers/hypospray/medipen
		))


/obj/item/storage/pouch/syringe
	name = "syringe pouch"
	desc = "It can contain syringes."
	icon_state = "syringe"

/obj/item/storage/pouch/syringe/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 5
	STR.max_combined_w_class = 10
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.set_holdable(list(
		/obj/item/reagent_containers/syringe
		))


/obj/item/storage/pouch/medkit
	name = "medkit pouch"
	w_class = WEIGHT_CLASS_BULKY //does not fit in backpack
	icon_state = "medkit"
	desc = "It's specifically made to hold a medkit."

//TODO: add medkit base class to here? or something?
/obj/item/storage/pouch/medkit/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 1
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.set_holdable(list(
		/obj/item/storage/firstaid
		))
	STR.exception_hold = list(
		/obj/item/storage/firstaid
		)


/obj/item/storage/pouch/medkit/full/PopulateContents()
	. = ..()
	new /obj/item/storage/firstaid/regular (src)


/obj/item/storage/pouch/document
	name = "document pouch"
	desc = "It can contain papers and clipboards."
	icon_state = "document"

/obj/item/storage/pouch/document/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 7
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.set_holdable(list(
		/obj/item/paper,
		/obj/item/clipboard
		))

/obj/item/storage/pouch/radio
	name = "radio pouch"
	icon_state = "radio"
	desc = "It can contain two handheld radios."

/obj/item/storage/pouch/radio/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 2
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.set_holdable(list(
		/obj/item/radio
		))

/obj/item/storage/pouch/electronics
	name = "electronics pouch"
	desc = "It is designed to hold most electronics, power cells and circuitboards."
	icon_state = "electronics"

/obj/item/storage/pouch/electronics/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.set_holdable(list(
		/obj/item/electronics,
		/obj/item/stock_parts/cell
		))

/obj/item/storage/pouch/electronics/full/PopulateContents()
	. = ..()
	new /obj/item/electronics/airlock (src)
	new /obj/item/electronics/apc (src)
	new /obj/item/stock_parts/cell/high (src)


/obj/item/storage/pouch/construction
	name = "construction pouch"
	desc = "It's designed to hold construction materials - glass/metal sheets, metal rods, barbed wire, cable coil, and empty sandbags. It also has a hook for an entrenching tool."
	icon_state = "construction"

/obj/item/storage/pouch/construction/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 3
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.set_holdable(list(
		/obj/item/stack/sheet,
		/obj/item/stack/rods,
		/obj/item/stack/cable_coil,
		))

/obj/item/storage/pouch/construction/full/PopulateContents()
	. = ..()
	new /obj/item/stack/sheet/metal/fifty (src)
	new /obj/item/stack/sheet/rglass (src, 50)
	new /obj/item/stack/cable_coil (src, 30)

/obj/item/storage/pouch/tools
	name = "tools pouch"
	desc = "It's designed to hold maintenance tools - screwdriver, wrench, cable coil, etc. It also has a hook for an entrenching tool."
	icon_state = "tools"

/obj/item/storage/pouch/tools/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 5
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.set_holdable(list(
		/obj/item/wirecutters,
		/obj/item/screwdriver,
		/obj/item/crowbar,
		/obj/item/weldingtool,
		/obj/item/multitool,
		/obj/item/wrench,
		/obj/item/stack/cable_coil,
		/obj/item/extinguisher/mini
		))

/obj/item/storage/pouch/tools/full/PopulateContents()
	. = ..()
	new /obj/item/screwdriver (src)
	new /obj/item/wirecutters (src)
	new /obj/item/multitool (src)
	new /obj/item/wrench (src)
	new /obj/item/crowbar (src)
