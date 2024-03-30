/datum/ai_controller/monkey/angry/slow
	movement_delay = 1 SECONDS

/mob/living/carbon/human/species/felinid/npc
	ai_controller = /datum/ai_controller/monkey/angry/slow
	faction = list("Syndicate","Pirate")

/mob/living/carbon/human/species/felinid/npc/Initialize(mapload)
	. = ..()
	randomize_human(src)
	equipOutfit(/datum/outfit/maid)
	var/obj/item/organ/tail/tail = getorganslot(ORGAN_SLOT_TAIL)
	if(tail)
		tail.set_wagging(src, TRUE)

/mob/living/carbon/human/ai_boarder/assistant/felinid
	outfit = list(/datum/outfit/maid, /datum/outfit/maid/knpc_pistol, /datum/outfit/maid/knpc_smg)
	taunts = list(
		"Tee hee!~ UwU",
		"Nya. I'm youw boawderw. Pwepawe to be pawned!",
		"Hiss!"
	)
	call_lines = list(
		"I nyeed backuwp!",
		"Fwends, come hewe!"
	)
	response_lines = list(
		"Nya~? What's ovew hewe?",
		"Be wight thewe! =^.^="
	)

	faction = list("Syndicate","Pirate")

/mob/living/carbon/human/ai_boarder/assistant/felinid/Initialize(mapload)
	. = ..()
	var/obj/item/organ/tail/tail = getorganslot(ORGAN_SLOT_TAIL)
	if(tail)
		tail.set_wagging(src, TRUE)

/mob/living/carbon/human/ai_boarder/assistant/felinid/smg

// Can't believe this didn't exist already
/datum/outfit/maid
	name = "Maid (KNPC)"
	head = /obj/item/clothing/head/maidheadband
	ears = /obj/item/radio/headset/syndicate/alt
	uniform = /obj/item/clothing/under/costume/maid
	gloves = /obj/item/clothing/gloves/maid
	neck = /obj/item/clothing/neck/maid
	shoes = /obj/item/clothing/shoes/jackboots
	id = /obj/item/card/id/job/assistant
	back = /obj/item/storage/backpack/duffelbag/syndie
	backpack_contents = list(/obj/item/storage/toolbox/syndicate)

/datum/outfit/maid/knpc_pistol
	name = "Maid - Pistol (KNPC)"
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	belt = /obj/item/storage/belt/utility/syndicate
	back = /obj/item/storage/backpack/duffelbag/syndie
	backpack_contents = list(/obj/item/storage/box/syndie=1, /obj/item/gun/ballistic/automatic/pistol=1,  /obj/item/ammo_box/magazine/m10mm=5)
	can_be_admin_equipped = FALSE // This presents problems

/datum/outfit/maid/knpc_smg
	name = "Maid - SMG (KNPC)"
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	belt = /obj/item/storage/belt/utility/syndicate
	back = /obj/item/storage/backpack/duffelbag/syndie
	backpack_contents = list(/obj/item/storage/box/syndie=1, /obj/item/gun/ballistic/automatic/c20r=1,  /obj/item/ammo_box/magazine/smgm45=5)
	can_be_admin_equipped = FALSE // This presents problems
