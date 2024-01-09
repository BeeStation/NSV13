/datum/uplink_item
	var/surplus_nullcrates

/datum/uplink_item/New()
	. = ..()
	if(isnull(surplus_nullcrates))
		surplus_nullcrates = surplus

/datum/uplink_item/dangerous/guardian
	surplus_nullcrates = 0

/datum/uplink_item/stealthy_weapons/martialarts
	surplus_nullcrates = 0

/datum/uplink_item/device_tools/fakenucleardisk
	surplus_nullcrates = 0
