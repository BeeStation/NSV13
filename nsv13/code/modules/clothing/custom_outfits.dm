/datum/outfit/syndicate/sleeper/pilot
	name = "Syndicate Pilot - Sleeper"
	gloves = /obj/item/clothing/gloves/color/black
	back = null
	l_pocket = null
	belt = null
	id = /obj/item/card/id/syndicate_command //create new id at some point
	tc = 0

/datum/outfit/syndicate/sleeper/soldier
	name = "Syndicate Soldier - Sleeper"
	suit = /obj/item/clothing/suit/armor/vest
	head = /obj/item/clothing/head/helmet
	back = null
	l_pocket = /obj/item/kitchen/knife/combat/survival
	belt = null
	id = /obj/item/card/id/syndicate_command //create new id at some point
	tc = 0

/datum/outfit/sleeper/prisoner
	name = "NT Prisoner - Sleeper"
	uniform = /obj/item/clothing/under/rank/prisoner
	shoes = /obj/item/clothing/shoes/sneakers/orange
	id = /obj/item/card/id/prisoner

/datum/outfit/syndicate/odst
	suit = /obj/item/clothing/suit/space/syndicate/odst
	head = /obj/item/clothing/head/helmet/space/syndicate/odst
	belt = /obj/item/storage/belt/utility/syndicate
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/syndicate
	ears = /obj/item/radio/headset/syndicate/alt
	id = /obj/item/card/id/syndicate
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
	r_pocket = /obj/item/gun/ballistic/automatic/pistol/APS
	tc = 0

/datum/outfit/syndicate/odst/smg
	name = "Syndicate Boarder - SMG Kit"
	back = /obj/item/storage/backpack/duffelbag/syndie/c20rbundle
	backpack_contents = list(/obj/item/storage/box/syndie=1,/obj/item/kitchen/knife/combat/survival=1, /obj/item/ammo_box/magazine/smgm45=1)

/datum/outfit/syndicate/odst/shotgun
	name = "Syndicate Boarder - Shotgun Kit"
	back = /obj/item/storage/backpack/duffelbag/syndie/bulldogbundle
	backpack_contents = list(/obj/item/storage/box/syndie=1,/obj/item/kitchen/knife/combat/survival=1, /obj/item/grenade/flashbang=1)

/datum/outfit/syndicate/odst/medic
	name = "Syndicate Boarder - Medic Kit"
	back = /obj/item/storage/backpack/duffelbag/syndie/med/medicalbundle
	backpack_contents = list(/obj/item/storage/box/syndie=1,/obj/item/kitchen/knife/combat/survival=1, /obj/item/ammo_box/magazine/pistolm9mm=1)

/datum/outfit/pirate/space/boarding
	suit = /obj/item/clothing/suit/space/pirate/boarder
	head = /obj/item/clothing/head/helmet/space/pirate/bandana/boarder
	mask = /obj/item/clothing/mask/breath
	back = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/utility/full
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
	ears = /obj/item/radio/headset/pirate
	id = /obj/item/card/id
	r_pocket = /obj/item/gps

/datum/outfit/pirate/space/boarding/lead
	name = "Space Pirate Boarder - Lead Kit"
	suit = /obj/item/clothing/suit/space/pirate/boarder/lead
	head = /obj/item/clothing/head/helmet/space/pirate/boarder
	l_pocket = /obj/item/melee/transforming/energy/sword/pirate
	backpack_contents = list(/obj/item/gun/ballistic/automatic/pistol/glock/makarov=1, /obj/item/ammo_box/magazine/pistolm9mm/glock=3, /obj/item/storage/firstaid/regular=1, /obj/item/loot_locator=1)

/datum/outfit/pirate/space/boarding/sapper
	name = "Space Pirate Boarder - Sapper Kit"
	l_pocket = /obj/item/kitchen/knife
	backpack_contents = list(/obj/item/gun/ballistic/automatic/pistol/glock/makarov=1, /obj/item/ammo_box/magazine/pistolm9mm/glock=2, /obj/item/grenade/smokebomb=2, /obj/item/grenade/plastic/x4=2)

/datum/outfit/pirate/space/boarding/gunner
	name = "Space Pirate Boarder - Gunner Kit"
	r_hand = /obj/item/gun/ballistic/rifle/boltaction
	l_pocket = /obj/item/kitchen/knife/combat/survival
	backpack_contents = list(/obj/item/ammo_box/a762=4)

/obj/item/storage/box/hug/clown_uniform
	name = "Clown's formal attire"
	desc = "A comically small box which contains the clown's formal uniform, used only on special occasions."

/obj/item/storage/box/hug/clown_uniform/PopulateContents()
	new /obj/item/clothing/under/rank/civilian/clown(src)
	new /obj/item/clothing/shoes/clown_shoes(src)

/datum/outfit/job/clown/delinquent
	name = "Delinquent clown"
	uniform = /obj/item/clothing/under/ship/delinquent
	suit = /obj/item/clothing/suit/ship/delinquent
	head = /obj/item/clothing/head/delinquent
	shoes = /obj/item/clothing/shoes/clown_shoes/delinquent
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn
	satchel = /obj/item/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/storage/box/hug/clown_uniform = 1,
		)

/datum/outfit/job/assistant_ship
	name = "Assistant (ship)"
	jobtype = /datum/job/assistant
	uniform = /obj/item/clothing/under/ship/assistant
	head = /obj/item/clothing/head/soft/assistant_soft
	suit = /obj/item/clothing/suit/ship/assistant_jacket
	shoes = /obj/item/clothing/shoes/sneakers/black

/datum/outfit/centcom_admiral
	name = "Admiral (NSV13)"
	uniform = /obj/item/clothing/under/ship/officer/admiral
	suit = /obj/item/clothing/suit/ship/officer/admiral
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	glasses = /obj/item/clothing/glasses/sunglasses
	ears = /obj/item/radio/headset/headset_cent/commander
	head = /obj/item/clothing/head/beret/ship/admiral
	belt = /obj/item/melee/classic_baton/telescopic/stunsword
	r_pocket = /obj/item/lighter
	back = /obj/item/storage/backpack/satchel/leather
	id = /obj/item/card/id

/datum/outfit/centcom_admiral/fleet
	name = "Admiral (Fleet)"
	uniform = /obj/item/clothing/under/ship/officer/admiral/fleet
	suit = /obj/item/clothing/suit/ship/officer/admiral/fleet
	head = /obj/item/clothing/head/ship/fleet_admiral

//These should only be brought out when the crew have REALLY fucked up.

/datum/outfit/centcom_admiral/grand
	name = "Admiral (Grand Admiral)"
	uniform = /obj/item/clothing/under/ship/officer/admiral/grand
	suit = /obj/item/clothing/suit/ship/officer/admiral/grand
	head = /obj/item/clothing/head/ship/fleet_admiral
	neck = /obj/item/clothing/neck/cloak/ship/admiral

/datum/outfit/centcom_admiral/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_centcom_access("Admiral")
	W.assignment = "Admiral"
	W.registered_name = H.real_name
	W.update_label()

//Solgov

/datum/outfit/centcom_admiral/solgov_admiral
	name = "Admiral (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/admiral
	suit = null
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	glasses = /obj/item/clothing/glasses/sunglasses
	ears = /obj/item/radio/headset/headset_cent/commander
	head = /obj/item/clothing/head/beret/ship/admiral
	belt = null
	r_pocket = /obj/item/lighter
	back = /obj/item/storage/backpack/satchel
	id = /obj/item/card/id

//ERT+ Direct Spawn Only

/datum/outfit/ert/engineer/plus
	name = "ERT Engineer+"
	id = /obj/item/card/id/ert/Engineer
	suit = /obj/item/clothing/suit/space/hardsuit/ert/engi
	glasses =  /obj/item/clothing/glasses/meson/engine
	back = /obj/item/storage/backpack/ert/engineer
	belt = /obj/item/storage/belt/utility/full
	mask = /obj/item/clothing/mask/gas
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
	l_pocket = /obj/item/modular_computer/tablet/preset/advanced
	r_pocket = /obj/item/geiger_counter
	backpack_contents = list(/obj/item/storage/box/engineer=1,\
		/obj/item/storage/firstaid/medical=1,\
		/obj/item/analyzer=1,\
		/obj/item/construction/rcd/loaded=1,\
		/obj/item/rcd_ammo/large=1,\
		/obj/item/inducer=1)
	r_hand = null
