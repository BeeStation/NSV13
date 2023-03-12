/obj/machinery/mineral/processing_unit/RefreshParts()
	var/point_upgrade_temp = 0
	var/smelt_amount_temp = 1
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		smelt_amount_temp += 1 + (1 * B.rating)
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		point_upgrade_temp += 0.65 + (0.35 * L.rating)
	point_upgrade = point_upgrade_temp
	smelt_amount = round(smelt_amount_temp, 1)

/obj/machinery/mineral/processing_unit/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, W))
		return

	if(default_unfasten_wrench(user, W))
		return

	if(default_deconstruction_crowbar(W))
		return

	return ..()

/obj/machinery/mineral/processing_unit_console/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, W))
		return

	if(default_unfasten_wrench(user, W))
		return

	if(default_deconstruction_crowbar(W))
		return

	return ..()
