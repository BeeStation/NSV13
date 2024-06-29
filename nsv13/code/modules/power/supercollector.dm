/obj/machinery/power/rad_collector/solgov
	name = "Advanced Radiation Collector Array"
	desc = "A highly advanced Radiation collector used by SolGov to power their space vessels. This one uses bluespace lensing effects to achieve more efficient radiation to energy conversion."
	circuit = /obj/item/circuitboard/machine/super_rad_collector
	rad_collector_coefficent = 3600 //360% more power than a normal one
	rad_collector_stored_out = 0.3 //STOP SITTING ON THE POWER

/obj/item/circuitboard/machine/super_rad_collector
	name = "advanced radiation collector (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/rad_collector/solgov
	req_components = list(
		/obj/item/stack/cable_coil = 30,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/sheet/plasmarglass = 2,
		/obj/item/stock_parts/capacitor = 4,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/mineral/uranium = 5,
		/obj/item/stack/ore/bluespace_crystal = 5)
	needs_anchored = FALSE
