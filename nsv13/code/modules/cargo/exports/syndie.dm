
//TODO: Seperate Syndicate ship exports from NT ship exports to prevent them selling their own kit for profit
//Exports (selling stuff)
/datum/export/gear/space/syndiehelmet/odst
	cost = 300
	unit_name = "\improper Syndicate drop trooper space suit helmet"
	export_types = list(/obj/item/clothing/head/helmet/space/syndicate/odst)

/datum/export/gear/space/syndiesuit/odst
	cost = 700
	unit_name = "\improper Syndicate drop trooper space suit"
	export_types = list(/obj/item/clothing/suit/space/syndicate/odst)

/datum/export/gear/syndie_duffel
	cost = 200
	unit_name = "\improper Syndicate duffelbag"
	export_types = list(/obj/item/storage/backpack/duffelbag/syndie)

/datum/export/weapon/pistol
	cost = 250
	unit_name = "Stechkin pistol"
	export_types = list(/obj/item/gun/ballistic/automatic/pistol)
	include_subtypes = FALSE

/datum/export/weapon/c20r
	cost = 500
	unit_name = "\improper C-20R SMG"
	export_types = list(/obj/item/gun/ballistic/automatic/c20r)

/datum/export/gear/syndie_headset
	cost = 500
	unit_name = "\improper Syndicate Headset"
	export_types = list(/obj/item/encryptionkey/syndicate) //we're actually only interested in the encryption key

//Bounties
/datum/bounty/item/syndicate_gear
	name = "Syndicate Drop Trooper Equipment"
	description = "The scientists back home are very interested in Syndicate technology and kit. Send them a full set of drop trooper equipment and we'll compensate you for your effort."
	reward = 5000
	required_count = 5 //Currently the combination of items isn't a requirement. Something to add later...
	wanted_types = list(/obj/item/clothing/head/helmet/space/syndicate/odst, /obj/item/clothing/suit/space/syndicate/odst, /obj/item/storage/backpack/duffelbag/syndie, /obj/item/gun/ballistic/automatic/c20r, /obj/item/encryptionkey/syndicate)
