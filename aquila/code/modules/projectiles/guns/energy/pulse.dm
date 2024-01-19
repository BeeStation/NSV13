/obj/item/gun/energy/pulse/research
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse, /obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	cell_type = "/obj/item/stock_parts/cell/pgun" //płatek śniegu by ta broń działała poprawnie z balansem
	can_flashlight = TRUE
	flight_x_offset = 18
	flight_y_offset = 12
	dual_wield_spread = 60
	pin = null

/obj/item/stock_parts/cell/pgun //nie chciało mi się robić kolejnego pliku, jeżeli się nie mylę to będą dodawane magazynki energetyczne w bliskim czasie
	name = "you should not be seeing this"
	maxcharge = 3000 //15 strzałów, było do wyboru 10, 25 lub 200, wydaję mi się że 15 będzie działać najlepiej
	materials = list(/datum/material/glass=300)
	chargerate = 2000
	rating = 2
