/*
This file contains various storage items in this order:

	ammo boxes
	normal boxes
	syndie kit boxes
	first aid/medikits
	reagent containers

*/

//Ammo Boxes

/obj/item/storage/toolbox/ammo/shotgun
	name = "ammo box (12ga buckshot)"
	desc = "It contains a few buckshot rounds."

/obj/item/storage/toolbox/ammo/shotgun/PopulateContents()
	new /obj/item/ammo_casing/shotgun/buckshot(src)
	new /obj/item/ammo_casing/shotgun/buckshot(src)
	new /obj/item/ammo_casing/shotgun/buckshot(src)
	new /obj/item/ammo_casing/shotgun/buckshot(src)
	new /obj/item/ammo_casing/shotgun/buckshot(src)
	new /obj/item/ammo_casing/shotgun/buckshot(src)
	new /obj/item/ammo_casing/shotgun/buckshot(src)

/obj/item/storage/toolbox/ammo/shotgun/beanbag
	name = "ammo box (12ga beanbag)"
	desc = "It contains a few beanbag slugs."

/obj/item/storage/toolbox/ammo/shotgun/beanbag/PopulateContents()
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)

//Regular Boxes

/obj/item/storage/box/cookie
	name = "box of cookies"
	desc = "It contains a few cookies for good patients."

/obj/item/storage/box/cookie/PopulateContents()
	new /obj/item/reagent_containers/food/snacks/cookie( src )
	new /obj/item/reagent_containers/food/snacks/cookie( src )
	new /obj/item/reagent_containers/food/snacks/cookie( src )
	new /obj/item/reagent_containers/food/snacks/oatmealcookie( src )
	new /obj/item/reagent_containers/food/snacks/oatmealcookie( src )
	new /obj/item/reagent_containers/food/snacks/sugarcookie/spookyskull( src )
	new /obj/item/reagent_containers/food/snacks/sugarcookie/spookyskull( src )

/obj/item/storage/box/beakers/large_mix/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/beaker/large( src )
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/glass/beaker( src )

/obj/item/storage/box/suitbox/maid
	name = "compression box of maid uniforms"
	desc = "Contains a state of the art maid uniform."

/obj/item/storage/box/suitbox/maid/PopulateContents()
	new /obj/item/clothing/head/maidheadband(src)
	new /obj/item/clothing/neck/maid(src)
	new /obj/item/clothing/gloves/maid(src)
	new /obj/item/clothing/under/costume/maid(src)

/obj/item/storage/box/radiokey/mun
	name = "box of munitions radio keys"
	desc = "Grants access to munitions and supply radio."
	radio_key = /obj/item/encryptionkey/munitions_tech

/obj/item/storage/box/radiokey/pilot
	name = "box of pilot radio keys"
	desc = "Grants access to air traffic control and munitions radio."
	radio_key = /obj/item/encryptionkey/pilot

/obj/item/storage/box/squad_lanyards
	name = "Spare squad lanyards"
	desc = "A box filled with lanyards for assigning personnel into squads. Repaint them using the squad management console and pass them out."
	icon = 'nsv13/icons/obj/storage.dmi'
	illustration = "lanyard"

/obj/item/storage/box/squad_lanyards/PopulateContents()
	generate_items_inside(list(/obj/item/clothing/neck/squad = 10),src)

//Syndie Kit Boxes

/obj/item/storage/box/syndie_kit/maid
	name = "emergency maid kit"

/obj/item/storage/box/syndie_kit/maid/PopulateContents()
	new /obj/item/clothing/head/maidheadband/syndicate(src)
	new /obj/item/clothing/under/syndicate/maid(src)
	new /obj/item/clothing/gloves/combat/maid(src)
	new /obj/item/clothing/accessory/maidapron/syndicate(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/soap/syndie(src)
	new /obj/item/reagent_containers/glass/bucket(src)
	new /obj/item/mop/sharp(src)

/obj/item/storage/box/syndie_kit/plushie
	name = "\improper DIY plushbomb kit"

/obj/item/storage/box/syndie_kit/plushie/PopulateContents()
	new /obj/item/toy/plush/lfighter/synlfighter(src)
	new /obj/item/kitchen/knife/combat/survival(src)
	new /obj/item/grenade/syndieminibomb(src)
	new /obj/item/screwdriver(src)

//First aid kits

/obj/item/storage/firstaid/robot
	name = "robotic treatment kit"
	desc = "Used to treat wounds and afflictions of robotic lifeforms."
	icon = 'nsv13/icons/obj/storage.dmi'
	icon_state = "firstaid-robot"
	item_state = "firstaid-robot"
	lefthand_file = 'nsv13/icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/equipment/medical_righthand.dmi'
	skin_type = MEDBOT_SKIN_ROBOT

/obj/item/storage/firstaid/robot/Initialize(mapload)
	. = ..()
	icon_state = pick("firstaid-robot","firstaid-robotalt")

/obj/item/storage/firstaid/robot/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/weldingtool = 1,
		/obj/item/clothing/glasses/welding = 1,
		/obj/item/stack/cable_coil/random = 1,
		/obj/item/reagent_containers/hypospray/medipen/system_cleaner = 2,
		/obj/item/reagent_containers/glass/bottle/radioactive_disinfectant = 1,
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

//Reagent containers

/obj/item/reagent_containers/glass/bottle/solder
	name = "solder bottle"
	label_name = "solder"
	desc = "A small bottle. Contains liquid solder. Useful for repairing synthethic brain damage."
	list_reagents = list(/datum/reagent/medicine/liquid_solder = 30)

/obj/item/reagent_containers/glass/bottle/radioactive_disinfectant
	name = "radioactive disinfectant bottle"
	label_name = "radioactive disinfectant"
	desc = "A small bottle. Contains radioactive disinfectant. Useful for purging irradiation from synthethics."
	list_reagents = list(/datum/reagent/medicine/radioactive_disinfectant = 30)

/obj/item/reagent_containers/glass/bottle/system_cleaner
	name = "system cleaner bottle"
	label_name = "system cleaner"
	desc = "A small bottle. Contains system cleaner. Useful for purging toxic chemicals and toxins from synthetics."
	list_reagents = list(/datum/reagent/medicine/system_cleaner = 30)

/obj/item/reagent_containers/hypospray/medipen/system_cleaner
	name = "system cleaner medipen"
	icon = 'nsv13/icons/obj/nsv13_syringe.dmi'
	icon_state = "syscleanpen"
	item_state = "syscleanpen"
	lefthand_file = 'nsv13/icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A autoinjector containing system cleaner, used to purge toxins from synthetics quickly."
	list_reagents = list(/datum/reagent/medicine/system_cleaner = 10)
