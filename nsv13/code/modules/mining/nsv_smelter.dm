/obj/machinery/mineral/processing_unit/RefreshParts()
	var/point_upgrade_temp = 1
	var/smelt_amount_temp = 5
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		smelt_amount_temp = 3.25 + (0.35 * B.rating)
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		point_upgrade_temp = 0.65 + (0.35 * L.rating)
	point_upgrade = point_upgrade_temp
	smelt_amount = round(smelt_amount_temp, 0.01)
