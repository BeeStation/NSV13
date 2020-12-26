//Radio Stuff

/obj/item/radio/headset/pirate
	name = "space pirate radio headset"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	desc = "replaceme"
	icon_state = "mun_headset_alt"
	keyslot = new /obj/item/encryptionkey/pirate
	freqlock = TRUE

/obj/item/encryptionkey/pirate
	name = "space pirate radio encryption key"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "mun_cypherkey"
	channels = list(RADIO_CHANNEL_PIRATE = 1)
	independent = TRUE
