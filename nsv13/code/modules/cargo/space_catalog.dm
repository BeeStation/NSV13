#define SORT_OF_CLOSE 20
#define TOO_FAR 40
#define UPDATE_COOLDOWN 2 MINUTES

/obj/item/book/space_yellow_pages
	unique = 1
	window_size = "570x680"
	desc = "A book full of useful information about nearby space stations"
	icon = 'nsv13/icons/obj/library.dmi'
	icon_state = "space_yellow_pages"

	var/datum/star_system/my_system = null
	var/datum/faction/my_faction = 0
	var/nearby_traders = null

	var/dat_cache = ""
	var/next_update = 0 // It magically stays kind of up to date with price changes

/obj/item/book/space_yellow_pages/on_read(mob/user)
	update_info()
	return ..()

/obj/item/book/space_yellow_pages/proc/set_basic_info(datum/trader/owner)
	my_system = owner.system
	my_faction = SSstar_system.faction_by_id(owner.faction_type)
	title = "[my_system.name] yellow pages"
	name = title
	author = my_faction.name

	nearby_traders = list()
	for(var/datum/trader/T as() in SSstar_system.traders)
		if(T.system.sector != my_system.sector)
			continue
		if(my_system.dist(T.system) > TOO_FAR)
			continue
		// Sanctions
		if(T.faction_type in my_faction.preset_enemies)
			continue
		nearby_traders |= T

/obj/item/book/space_yellow_pages/proc/update_info()
	if(world.time < next_update)
		return
	dat = "<h2>[title]</h2>"

	for(var/datum/trader/T as() in nearby_traders)
		// Clear any traders that were deleted
		if(QDELETED(T))
			nearby_traders -= T
			continue
		var/dist = my_system.dist(T.system)
	 	// Anything nearby is guaranteed to be on the list
		// Anything in long range has a 50% chance of being on the list
		if(dist > SORT_OF_CLOSE && prob(50))
			continue

		// Don't ask me why len worked but length() didn't
		if(!T.stonks.len)
			T.stock_items()
		// Add the station to the buffer
		dat += T.yellow_pages_dat

	next_update = world.time + UPDATE_COOLDOWN

#undef SORT_OF_CLOSE
#undef TOO_FAR
#undef UPDATE_COOLDOWN
