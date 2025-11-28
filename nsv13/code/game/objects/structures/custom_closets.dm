/obj/structure/closet/secure_closet/master_at_arms
	name = "\proper master at arms' locker"
	req_access = list(ACCESS_MAA)
	icon = 'nsv13/icons/obj/custom_closets.dmi'
	icon_state = "maa"
	anchored = TRUE

/obj/structure/closet/secure_closet/master_at_arms/PopulateContents()
	..()
	new /obj/item/card/id/departmental_budget/mun(src)
	new /obj/item/door_remote/master_at_arms(src)
	new /obj/item/radio/headset/heads/master_at_arms(src)
	new /obj/item/clothing/suit/ship/maa_jacket(src)
	new /obj/item/clothing/suit/hazardvest(src)
	new /obj/item/clothing/head/bomb_hood(src)
	new /obj/item/clothing/suit/bomb_suit(src)
	new /obj/item/clothing/head/hardhat/orange(src)
	new /obj/item/clothing/head/ship/maa_hat(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/clothing/neck/petcollar(src)
	new /obj/item/storage/box/radiokey/mun(src)
	new /obj/item/storage/box/radiokey/pilot(src)
	new /obj/item/encryptionkey/atc(src)
	new /obj/item/circuitboard/machine/techfab/department/munitions(src)
	new /obj/item/stamp/maa(src)
	new /obj/item/pinpointer/munitions(src)

/obj/structure/closet/secure_closet/munitions_technician
	name = "munitions technician's locker"
	req_access = list(ACCESS_MUNITIONS_STORAGE)
	icon = 'nsv13/icons/obj/custom_closets.dmi'
	icon_state = "mun"
	anchored = TRUE

/obj/structure/closet/secure_closet/munitions_technician/PopulateContents()
	..()
	new /obj/item/radio/headset/munitions/munitions_tech(src)
	new /obj/item/clothing/under/rank/munitions_tech(src)
	new /obj/item/clothing/under/ship/decktech(src)
	new /obj/item/clothing/suit/ship/munitions_jacket(src)
	new /obj/item/clothing/head/helmet/decktech(src)
	new /obj/item/storage/belt/utility/full/engi(src)

/obj/structure/closet/secure_closet/deck_technician
	name = "deck technician's locker"
	req_access = list(ACCESS_MUNITIONS_STORAGE)
	icon = 'nsv13/icons/obj/custom_closets.dmi'
	icon_state = "deck"
	anchored = FALSE

/obj/structure/closet/secure_closet/deck_technician/PopulateContents()
	..()
	new /obj/item/radio/headset/munitions/munitions_tech(src)
	new /obj/item/clothing/under/ship/decktech(src)
	new /obj/item/clothing/head/helmet/decktech(src)
	new /obj/item/clothing/suit/hazardvest(src)
	new /obj/item/storage/belt/utility/full/engi(src)
	new /obj/item/key/fighter_tug(src)

/obj/structure/closet/secure_closet/atc
	name = "air traffic controller's locker"
	req_access = list(ACCESS_MUNITIONS)
	icon = 'nsv13/icons/obj/custom_closets.dmi'
	icon_state = "atc"
	anchored = FALSE

/obj/structure/closet/secure_closet/atc/PopulateContents()
	..()
	new /obj/item/binoculars(src)
	new /obj/item/radio/headset/munitions/atc(src)
	new /obj/item/clothing/under/ship/officer(src)
	new /obj/item/clothing/head/beret/ship/pilot(src)
	new /obj/item/clothing/suit/hazardvest(src)
	new /obj/item/flashlight/atc_wavy_sticks(src)

/obj/structure/closet/secure_closet/combat_pilot
	name = "combat pilot's locker"
	req_access = list(ACCESS_COMBAT_PILOT)
	icon = 'nsv13/icons/obj/custom_closets.dmi'
	icon_state = "pilot"
	icon_door = "cpilot"
	anchored = TRUE

/obj/structure/closet/secure_closet/combat_pilot/PopulateContents()
	..()
	new /obj/item/radio/headset/munitions/pilot(src)
	new /obj/item/clothing/under/ship/pilot(src)
	new /obj/item/clothing/head/beret/ship/pilot(src)
	new /obj/item/clothing/gloves/color/black(src)

/obj/structure/closet/secure_closet/transport_pilot
	name = "transport pilot's locker"
	req_access = list(ACCESS_TRANSPORT_PILOT)
	icon = 'nsv13/icons/obj/custom_closets.dmi'
	icon_door = "tpilot"
	icon_state = "pilot"
	anchored = TRUE

/obj/structure/closet/secure_closet/transport_pilot/PopulateContents()
	..()
	new /obj/item/radio/headset/munitions/pilot(src)
	new /obj/item/clothing/under/ship/pilot/transport(src)
	new /obj/item/clothing/head/helmet/transport_pilot(src)
	new /obj/item/clothing/gloves/color/brown(src)
	new /obj/item/clothing/glasses/sunglasses(src)

/obj/structure/closet/secure_closet/bridge
	name = "bridge staff's locker"
	req_access = list(ACCESS_HEADS)
	icon = 'nsv13/icons/obj/custom_closets.dmi'
	icon_state = "bridge"
	anchored = FALSE

/obj/structure/closet/secure_closet/bridge/PopulateContents()
	..()
	new /obj/item/radio/headset/headset_bridge(src)
	new /obj/item/clothing/under/ship/officer(src)
	new /obj/item/clothing/head/beret/durathread(src)
	new /obj/item/clothing/glasses/sunglasses(src)

/obj/structure/closet/secure_closet/puce
	name = "puce closet"
	req_access = list(ACCESS_CENT_CAPTAIN)
	icon = 'nsv13/icons/obj/custom_closets.dmi'
	icon_state = "definitelynotpuce"
	anchored = FALSE

//solgov lockers
/obj/structure/closet/secure_closet/captains/solgov
	name = "\proper captain's locker"
	req_access = list(ACCESS_CAPTAIN)
	icon_state = "cap"

/obj/structure/closet/secure_closet/captains/solgov/PopulateContents()
	new /obj/item/storage/box/suitbox/cap(src)
	new /obj/item/storage/backpack/captain(src)
	new /obj/item/storage/backpack/satchel/cap(src)
	new /obj/item/storage/backpack/duffelbag/captain(src)
	new	/obj/item/clothing/suit/armor/vest/capcarapace/jacket(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/alt(src)
	new /obj/item/clothing/suit/hooded/wintercoat/captain(src)
	new /obj/item/clothing/suit/captunic(src)
	new /obj/item/clothing/gloves/color/captain(src)
	new /obj/item/clothing/glasses/sunglasses/advanced/gar/supergar(src)
	new /obj/item/radio/headset/heads/captain/alt(src)
	new /obj/item/radio/headset/heads/captain(src)


	new /obj/item/clothing/neck/petcollar(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/storage/photo_album/Captain(src)

	new /obj/item/storage/box/radiokey/com(src)
	new /obj/item/storage/box/command_keys(src)
	new /obj/item/megaphone/command(src)
	new /obj/item/computer_hardware/hard_drive/role/captain(src)
	new /obj/item/storage/box/silver_ids(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)

	// prioritized items
	new /obj/item/card/id/departmental_budget/civ(src)
	new /obj/item/clothing/neck/cloak/cap(src)
	new /obj/item/door_remote/captain(src)
	new /obj/item/storage/belt/sabre(src)
	new /obj/item/gun/energy/e_gun/mini/heads(src) //no balistics for solgov

/obj/structure/closet/secure_closet/hop/solgov
	name = "\proper executive officer's locker"
	req_access = list(ACCESS_HOP)
	icon_state = "hop"

/obj/structure/closet/secure_closet/hop/solgov/PopulateContents()
	new /obj/item/storage/box/suitbox/hop(src)
	new /obj/item/radio/headset/heads/xo(src) //NSV13 - HoP to XO

	new /obj/item/clothing/neck/petcollar(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/storage/photo_album/HoP(src)

	new /obj/item/storage/box/radiokey/srv(src)
	new /obj/item/storage/box/command_keys(src)
	new /obj/item/computer_hardware/hard_drive/role/hop(src)
	new /obj/item/storage/box/ids(src)
	new /obj/item/storage/box/ids(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/circuitboard/machine/techfab/department/service(src)

	// prioritized items
	new /obj/item/card/id/departmental_budget/srv(src)
	new /obj/item/clothing/neck/cloak/hop(src)
	new /obj/item/door_remote/civillian(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/clothing/glasses/sunglasses/advanced(src)
	new /obj/item/clothing/suit/armor/vest/alt(src)
	new /obj/item/megaphone/command(src)
	new /obj/item/gun/energy/e_gun/mini/heads(src)

/obj/structure/closet/secure_closet/hos/solgov
	name = "\proper head of security's locker"
	req_access = list(ACCESS_HOS)
	icon_state = "hos"

/obj/structure/closet/secure_closet/hos/solgov/PopulateContents()
	new /obj/item/storage/box/suitbox/hos(src)
	new /obj/item/clothing/suit/armor/vest/leather(src)
	new /obj/item/clothing/mask/gas/sechailer/swat(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/gars/supergars(src)
	new /obj/item/radio/headset/heads/hos/alt(src)
	new /obj/item/radio/headset/heads/hos(src)

	new /obj/item/clothing/neck/petcollar(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/storage/photo_album/HoS(src)

	new /obj/item/storage/box/radiokey/sec(src)
	new /obj/item/storage/box/command_keys(src)
	new /obj/item/megaphone/sec(src)
	new /obj/item/computer_hardware/hard_drive/role/hos(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/box/deputy(src)
	new /obj/item/storage/lockbox/medal/sec(src)
	new /obj/item/storage/lockbox/loyalty(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/circuitboard/machine/techfab/department/security(src)

	// prioritized items
	new /obj/item/card/id/departmental_budget/sec(src)
	new /obj/item/clothing/neck/cloak/hos(src)
	new /obj/item/clothing/suit/armor/hos(src)
	new /obj/item/clothing/suit/armor/hos/trenchcoat(src)
	new /obj/item/shield/riot/tele(src)
	new /obj/item/storage/belt/security/full(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/gun/energy/e_gun/hos(src)
	new /obj/item/pinpointer/nuke(src)

/obj/structure/closet/secure_closet/warden/solgov
	name = "\proper warden's locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "warden"

/obj/structure/closet/secure_closet/warden/solgov/PopulateContents()
	new /obj/item/radio/headset/headset_sec(src)
	new /obj/item/clothing/suit/armor/vest/warden(src)
	new /obj/item/clothing/head/warden(src)
	new /obj/item/clothing/head/warden/drill(src)
	new /obj/item/clothing/head/beret/sec/navywarden(src)
	new /obj/item/clothing/head/beret/corpwarden(src)
	new /obj/item/clothing/suit/armor/vest/warden/alt(src)
	new /obj/item/clothing/under/rank/security/warden/formal(src)
	new /obj/item/clothing/under/rank/security/warden(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/storage/box/zipties(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/belt/security/full(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/megaphone/sec(src)
	new /obj/item/clothing/gloves/krav_maga(src)
	new /obj/item/door_remote/head_of_security(src)
	new /obj/item/gun/energy/laser/scatter(src)
	new /obj/item/gun/energy/e_gun(src)
	new /obj/item/storage/box/deputy(src)

/obj/structure/closet/secure_closet/security/solgov
	name = "security officer's locker"
	req_access = list(ACCESS_SECURITY)
	icon_state = "sec"

/obj/structure/closet/secure_closet/security/solgov/PopulateContents()
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/head/helmet/sec(src)
	new /obj/item/radio/headset/headset_sec(src)
	new /obj/item/radio/headset/headset_sec/alt(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/flashlight/seclite(src)


