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
	name = "Syndicate Soldier - Drop Trooper"
	suit = /obj/item/clothing/suit/space/syndicate/odst
	head = /obj/item/clothing/head/helmet/space/syndicate/odst
	back = /obj/item/storage/backpack/duffelbag/syndie/c20rbundle
	belt = /obj/item/storage/belt/utility/syndicate
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/syndicate
	ears = /obj/item/radio/headset/syndicate/alt
	id = /obj/item/card/id/syndicate
	l_pocket = /obj/item/tank/internals/emergency_oxygen/double
	r_pocket = /obj/item/gun/ballistic/automatic/pistol/APS
	backpack_contents = list(/obj/item/storage/box/syndie=1,/obj/item/kitchen/knife/combat/survival=1, /obj/item/ammo_box/magazine/smgm45=1, /obj/item/ammo_box/magazine/smgm45=1)
	tc = 0

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