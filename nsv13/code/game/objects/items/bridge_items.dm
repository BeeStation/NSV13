/obj/item/radio/headset/headset_bridge
	name = "bridge radio headset"
	desc = "A headset used by those who think they have power, but don't."
	icon_state = "com_headset"
	keyslot = new /obj/item/encryptionkey/bridge_staff

/obj/item/encryptionkey/bridge_staff
	name = "bridge staff encryption key"
	icon_state = "xo_cypherkey"
	channels = list(RADIO_CHANNEL_COMMAND = 1)
