/obj/item/stock_parts/cell/crystal_cell
	name = "crystal power cell"
	desc = "A very high power cell made from crystallized plasma forced into a casing"
	icon_state = "icell"
	maxcharge = 50000
	chargerate = 0
	custom_materials = null
	grind_results = null
	rating = 5

/obj/item/stock_parts/cell/crystal_cell/Initialize(mapload)
	. = ..()
	charge = 50000

/obj/item/stock_parts/cell/crystal_cell/wizard
	desc = "A very high power cell made from crystallized magic."
	chargerate = 5000
