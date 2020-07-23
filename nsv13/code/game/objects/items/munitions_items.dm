///////Munitions Department Items///////

///////DEPARTMENT BUDGET CARD///////

/obj/item/card/id/departmental_budget/mun
	department_ID = ACCOUNT_MUN
	department_name = ACCOUNT_MUN_NAME
	icon_state = "warden" //placeholder

///////DEPARTMENT DOOR REMOTE//////

/obj/item/door_remote/master_at_arms
	name = "munitions door remote"
	icon_state = "gangtool-red"
	region_access = 8

///////ENCRYPTION KEYS///////

/obj/item/encryptionkey/atc
	name = "air traffic control radio encryption key"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "mun_cypherkey"
	channels = list(RADIO_CHANNEL_ATC = 1, RADIO_CHANNEL_MUNITIONS = 1, RADIO_CHANNEL_COMMAND = 1)
	independent = TRUE

/obj/item/encryptionkey/pilot
	name = "fighter pilot radio encryption key"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "mun_cypherkey"
	channels = list(RADIO_CHANNEL_ATC = 1, RADIO_CHANNEL_MUNITIONS = 1)
	independent = TRUE

/obj/item/encryptionkey/heads/master_at_arms
	name = "master at arms radio encryption key"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "mun_cypherkey"
	channels = list(RADIO_CHANNEL_MUNITIONS = 1, RADIO_CHANNEL_SUPPLY = 1, RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_ATC = 1)
	independent = TRUE

/obj/item/encryptionkey/munitions_tech
	name = "munitions department encryption key"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "mun_cypherkey"
	channels = list(RADIO_CHANNEL_MUNITIONS = 1, RADIO_CHANNEL_SUPPLY = 1)
	independent = TRUE

///////RADIO HEADSETS//////

/obj/item/radio/headset/munitions
	name = "munitions radio headset"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	desc = "A base model for every munitions headset, even comes with ear protection!"
	icon_state = "mun_headset"
	keyslot = new /obj/item/encryptionkey/munitions_tech
	bang_protect = 1

/obj/item/radio/headset/munitions/atc
	name = "air traffic controller radio headset"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	desc = "A headset capable of accessing the Nanotrasen blue channel via a special DRADIS satellite uplink, allowing fighter pilots to communicate from anywhere inside of Nanotrasen's airspace. Use :q to access the air traffic control frequency. Use :w to access the department frequency. Use :c to access the command department frequency."
	icon_state = "mun_headset_alt"
	keyslot = new /obj/item/encryptionkey/atc

/obj/item/radio/headset/munitions/pilot
	name = "pilot radio headset"
	desc = "A headset capable of accessing the Nanotrasen blue channel via a special DRADIS satellite uplink, allowing fighter pilots to communicate from anywhere inside of Nanotrasen's airspace. Use :q to access the air traffic control frequency. Use :w to access the department frequency while on the ship."
	icon_state = "mun_headset"
	keyslot = new /obj/item/encryptionkey/pilot

/obj/item/radio/headset/heads/master_at_arms
	name = "\proper the master at arms' headset"
	desc = "Use :w to access the department frequency. Use :u to access the supply frequency. Use :c to access the command frequency. Use :q to access the ATC frequency."
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "mun_headset_alt"
	keyslot = new /obj/item/encryptionkey/heads/master_at_arms
	bang_protect = 1

/obj/item/radio/headset/munitions/munitions_tech
	name = "munitions technician radio headset"
	desc = "Use :w to access the department frequency. Use :u to access the supply frequency."
	icon_state = "mun_headset"
	keyslot = new /obj/item/encryptionkey/munitions_tech