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

/obj/item/storage/box/syndie_kit/maid/PopulateContents()
	new /obj/item/clothing/head/maidheadband/syndicate(src)
	new /obj/item/clothing/under/syndicate/maid(src)
	new /obj/item/clothing/gloves/combat/maid(src)
	new /obj/item/clothing/accessory/maidapron/syndicate(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/soap/syndie(src)
	new /obj/item/reagent_containers/glass/bucket(src)
	new /obj/item/mop/sharp(src)

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

/obj/item/storage/box/syndie_kit/plushie
	name = "\improper DIY plushbomb kit"

/obj/item/storage/box/syndie_kit/plushie/PopulateContents()
	new /obj/item/toy/plush/lfighter/synlfighter(src)
	new /obj/item/kitchen/knife/combat/survival(src)
	new /obj/item/grenade/syndieminibomb(src)
	new /obj/item/screwdriver(src)
