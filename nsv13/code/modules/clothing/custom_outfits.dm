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
	backpack_contents = list(/obj/item/storage/box/syndie=1,/obj/item/kitchen/knife/combat/survival=1)
	tc = 0

/obj/item/storage/box/hug/clown_uniform
	name = "Clown's formal attire"
	desc = "A comically small box which contains the clown's formal uniform, used only on special occasions."

/obj/item/storage/box/hug/clown_uniform/PopulateContents()
	new /obj/item/clothing/under/rank/clown(src)
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