/obj/item/ammo_box/magazine/nsv/light_cannon
	name = "light cannon ammo"
	desc = "A box of 20x102mm ammunition which can be loaded into a light fighter cannon."
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "light"
	ammo_type = /obj/item/ammo_casing/light_cannon
	caliber = "mm20"
	max_ammo = 500

/obj/item/ammo_box/magazine/nsv/heavy_cannon
	name = "heavy cannon ammo"
	desc = "A box of 30x173mm ammunition which can be loaded into a heavy fighter cannon."
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "heavy"
	ammo_type = /obj/item/ammo_casing/heavy_cannon
	caliber = "mm30"
	max_ammo = 400

/obj/item/ammo_casing/light_cannon
	name = "20x102mm bullet casing"
	desc = "A 20x102mm bullet casing."
	caliber = "mm20"
	projectile_type = /obj/item/projectile/bullet/light_cannon_round

/obj/item/ammo_casing/heavy_cannon
	name = "30x173mm bullet casing"
	desc = "A 30x173mm bullet casing."
	caliber = "mm30"
	projectile_type = /obj/item/projectile/bullet/heavy_cannon_round

//Good for a more flexible approach / multi-tagging.
/obj/item/ammo_box/magazine/nsv/jtag
	name = "J-TAG \"light\" beacon ammo"
	desc = "A box of beacons for the J-TAG, with short-lived integrated power cells. Bulkier than most ammo boxes."
	icon = 'nsv13/icons/obj/ammo.dmi' // :/ JTAG-TODO
	icon_state = "jtag_l"
	ammo_type = /obj/item/ammo_casing/caseless/jtag_beacon
	caliber = "light jtag beacon"
	max_ammo = 15
	w_class = WEIGHT_CLASS_NORMAL

//Good for keeping on target.
/obj/item/ammo_box/magazine/nsv/jtag/expanded_duration
	name = "J-TAG \"endurance\" beacon ammo"
	desc = "A box of beacons for the J-TAG. These beacons have beefier power cells, but the box can fit far less as result. Bulkier than most ammo boxes."
	icon_state = "jtag_e"
	ammo_type = /obj/item/ammo_casing/caseless/jtag_beacon/endurance
	caliber = "enduring jtag beacon"
	max_ammo = 5

/obj/item/ammo_casing/caseless/jtag_beacon
	name = "light J-TAG beacon"
	desc = "A beacon used by the J-TAG system. You should return this."
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "jtag_l_dart"
	caliber = "light jtag beacon"
	w_class = WEIGHT_CLASS_SMALL
	projectile_type = /obj/item/projectile/bullet/jtag_beacon

/obj/item/ammo_casing/caseless/jtag_beacon/endurance
	name = "enduring J-TAG beacon"
	icon_state = "jtag_e_dart"
	caliber = "enduring jtag beacon"
	projectile_type = /obj/item/projectile/bullet/jtag_beacon/enduring
