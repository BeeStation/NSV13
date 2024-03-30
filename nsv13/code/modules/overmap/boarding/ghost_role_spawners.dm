/obj/effect/mob_spawn/human/syndicate
	name = "Syndicate Operative"
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	outfit = /datum/outfit/syndicate_empty
	assignedrole = "Space Syndicate"	//I know this is really dumb, but Syndicate operative is nuke ops

/datum/outfit/syndicate_empty
	name = "Syndicate Operative Empty"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/syndicate/alt
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/weapons_auth)
	id = /obj/item/card/id/syndicate

/datum/outfit/syndicate_empty/post_equip(mob/living/carbon/human/H)
	H.faction |= FACTION_SYNDICATE

/datum/outfit/syndicate_empty/boarding/captain
	name = "Syndicate Captain (Boarding)"
	id = /obj/item/card/id/syndicate/nuke_leader
	gloves = /obj/item/clothing/gloves/combat
	neck = /obj/item/clothing/neck/cloak/syndcap
	head = /obj/item/clothing/head/helmet/space/beret
	suit = /obj/item/clothing/suit/space/officer
	l_pocket = /obj/item/ammo_box/magazine/pistolm9mm
	r_pocket = /obj/item/gun/ballistic/automatic/pistol/APS
	implants = list()

/datum/outfit/syndicate_empty/boarding
	name = "Syndicate Crewman (Boarding)"
	head = /obj/item/clothing/head/HoS/beret/syndicate
	suit = /obj/item/clothing/suit/ship/syndicate_crew
	l_pocket = /obj/item/ammo_box/magazine/m10mm
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	back = /obj/item/storage/backpack/duffelbag/syndie
	backpack_contents = list(/obj/item/storage/box/syndie=1,\
	/obj/item/kitchen/knife/combat/survival=1)

/obj/effect/mob_spawn/human/syndicate/boarding
	name = "Syndicate Crewman"
	short_desc = "You are a Syndicate Crewman."
	flavour_text = "Your job is to follow the orders of your captain. You must decide on a role for yourself amongst your crew, then fulfill it. Defend your ship at all costs."
	important_info = "If you're stuck for what to do, ahelp!. The ship will need engineers, munitions techs, sometimes even pilots. You can even conduct counter boarding..."
	outfit = /datum/outfit/syndicate_empty/boarding
	id_access_list = list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_ENGINEERING, ACCESS_SYNDICATE_MARINE_ARMOURY)
	assignedrole = "Syndicate Crew"


/obj/effect/mob_spawn/human/syndicate/boarding/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/mob_spawn/human/syndicate/boarding/LateInitialize()
	. = ..()
	notify_ghosts("The crew has boarded a live Syndicate ship! The Syndicate navy is now recruiting...", source = src, alert_overlay = mutable_appearance(src.icon, src.icon_state), action=NOTIFY_ATTACK)

/obj/effect/mob_spawn/human/syndicate/boarding_captain
	name = "Syndicate Navy Captain"
	short_desc = "You are the captain of a Syndicate naval vessel."
	flavour_text = "Your job is to oversee your crew, defend your ship with your life. Destroy as many Nanotrasen ships as you can."
	important_info = "As the captain, you should not abandon your ship. If you desert, your bloodline may be terminated."
	outfit = /datum/outfit/syndicate_empty/boarding/captain
	id_access_list = list(ACCESS_SYNDICATE,ACCESS_SYNDICATE_LEADER)
