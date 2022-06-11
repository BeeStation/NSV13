/datum/overmap_objective/cargo/donation/stock_part_bundle
	name = "Donate stock parts"
	desc = "Donate a bundle of stock parts"
	crate_name = "Stock parts crate"

/datum/overmap_objective/cargo/donation/stock_part_bundle/New()
	..()
	var/rating = rand(1,3)
	switch(rating)
		if(1)
			freight_type_group = new( list(
				new /datum/freight_type/single/object( /obj/item/stock_parts/capacitor, target = 3 ),
				new /datum/freight_type/single/object( /obj/item/stock_parts/scanning_module, target = 3 ),
				new /datum/freight_type/single/object( /obj/item/stock_parts/manipulator, target = 3 ),
				new /datum/freight_type/single/object( /obj/item/stock_parts/micro_laser, target = 3 ),
				new /datum/freight_type/single/object( /obj/item/stock_parts/matter_bin, target = 3 ),
				new /datum/freight_type/single/object( /obj/item/stock_parts/cell/high, target = 3 ),
			) )
		if(2)
			freight_type_group = new( list(
				new /datum/freight_type/single/object( /obj/item/stock_parts/capacitor/adv, target = 3 ),
				new /datum/freight_type/single/object( /obj/item/stock_parts/scanning_module/adv, target = 3 ),
				new /datum/freight_type/single/object( /obj/item/stock_parts/manipulator/nano, target = 3 ),
				new /datum/freight_type/single/object( /obj/item/stock_parts/micro_laser/high, target = 3 ),
				new /datum/freight_type/single/object( /obj/item/stock_parts/matter_bin/adv, target = 3 ),
				new /datum/freight_type/single/object( /obj/item/stock_parts/cell/super, target = 3 ),
			) )
		if(3)
			freight_type_group = new( list(
				new /datum/freight_type/single/object( /obj/item/stock_parts/capacitor/super, target = 3 ),
				new /datum/freight_type/single/object( /obj/item/stock_parts/scanning_module/phasic, target = 3 ),
				new /datum/freight_type/single/object( /obj/item/stock_parts/manipulator/pico, target = 3 ),
				new /datum/freight_type/single/object( /obj/item/stock_parts/micro_laser/ultra, target = 3 ),
				new /datum/freight_type/single/object( /obj/item/stock_parts/matter_bin/super, target = 3 ),
				new /datum/freight_type/single/object( /obj/item/stock_parts/cell/hyper, target = 3 ),
			) )
