//Intercom to be contained inside the fighter
/obj/item/radio/intercom/fighter
	name = "fighter intercom unit"
	freqlock = TRUE
	freerange = TRUE
	independent = TRUE
	on = FALSE

/obj/item/radio/intercom/fighter/Initialize(mapload) //We don't actually need the intercom init - please no power
	wires = new /datum/wires/radio(src)
	secure_radio_connections = new
	. = ..()
	frequency = sanitize_frequency(frequency, freerange)
	set_frequency(frequency)

	for(var/ch_name in channels)
		secure_radio_connections[ch_name] = add_radio(src, GLOB.radiochannels[ch_name])

	become_hearing_sensitive(ROUNDSTART_TRAIT)

/obj/item/radio/intercom/fighter/AreaPowerCheck(datum/source)
	return

/obj/item/radio/intercom/overmap
	name = "NSV Interlink Relay"
	freqlock = TRUE
	freerange = TRUE
	independent = TRUE
	frequency = FREQ_OVERMAP_NANOTRASEN

/obj/item/radio/intercom/overmap/syndicate
	name = "SSV Interlink Relay"
	frequency = FREQ_OVERMAP_SYNDICATE

/obj/item/radio/intercom/overmap/pirate
	name = "Space Pirate Interlink Relay"
	frequency = FREQ_OVERMAP_PIRATE
