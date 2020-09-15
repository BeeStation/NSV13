/obj/item/ammo_box/magazine/light_cannon
	name = "Light cannon ammo (20x102mm)"
	desc = "A box of .s0 caliber rounds which can be loaded into a light fighter cannon."
	icon_state = "pdc"
	ammo_type = /obj/item/ammo_casing/light_cannon
	caliber = "mm20"
	max_ammo = 100

/obj/item/ammo_box/magazine/heavy_cannon
	name = "Heavy cannon ammo (30x173mm)"
	desc = "A box of .30 caliber rounds which can be loaded into a heavy fighter cannon."
	icon_state = "pdc"
	ammo_type = /obj/item/ammo_casing/heavy_cannon
	caliber = "mm30"
	max_ammo = 100

/obj/item/ammo_casing/light_cannon
	name = "20x102mm bullet casing"
	desc = "A 20x102mm bullet casing."
	projectile_type = /obj/item/projectile/bullet/light_cannon_round

/obj/item/ammo_casing/heavy_cannon
	name = "30x173mm bullet casing"
	desc = "A 30x173mm bullet casing."
	projectile_type = /obj/item/projectile/bullet/heavy_cannon_round