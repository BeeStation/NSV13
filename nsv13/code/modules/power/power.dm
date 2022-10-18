/**
 * Attempts to draw power directly from the APC's Powernet rather than the APC's battery. For high-draw machines, like the cell charger
 *
 * Checks the surplus power on the APC's powernet, and compares to the requested amount. If the requested amount is available, this proc
 * will add the amount to the APC's usage and return that amount. Otherwise, this proc will return FALSE.
 * If the take_any var arg is set to true, this proc will use and return any surplus that is under the requested amount, assuming that
 * the surplus is above zero.
 * Args:
 * - amount, the amount of power requested from the Powernet. In standard loosely-defined SS13 power units.
 * - take_any, a bool of whether any amount of power is acceptable, instead of all or nothing. Defaults to FALSE
 */
/obj/machinery/proc/use_power_from_net(amount, take_any = FALSE)
	if(amount <= 0) //just in case
		return FALSE
	var/area/home = get_area(src)

	if(!home)
		return FALSE //apparently space isn't an area
	if(!home.requires_power)
		return amount //Shuttles get free power, don't ask why

	var/obj/machinery/power/apc/local_apc = home.get_apc()
	if(!local_apc)
		return FALSE
	var/surplus = local_apc.surplus()
	if(surplus <= 0) //I don't know if powernet surplus can ever end up negative, but I'm just gonna failsafe it
		return FALSE
	if(surplus < amount)
		if(!take_any)
			return FALSE
		amount = surplus
	local_apc.add_load(amount)
	return amount
 
