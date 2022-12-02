/obj/item/encryptionkey/tv
	name = "nanotrasen tv encryption key"
	channels = list(RADIO_CHANNEL_TV = 1)
	independent = TRUE

/obj/item/radio/intercom/tv
	name = "TV Show Radio"
	desc = "Almost like television, only without the picture."
	keyslot = new /obj/item/encryptionkey/tv
	freqlock = TRUE

/obj/item/radio/intercom/tv/Initialize(mapload)
	. = ..()
	set_frequency(FREQ_TV)
