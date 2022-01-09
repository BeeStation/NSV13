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
