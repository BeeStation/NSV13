#define iself(A) (is_species(A, /datum/species/elf))

GLOBAL_LIST_INIT(elf_first, world.file2list("strings/names/elf_first.txt"))
GLOBAL_LIST_INIT(elf_last, world.file2list("strings/names/elf_first.txt"))

/datum/species/elf
	name = "Elf"
	id = "elf"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,NO_UNDERWEAR)
	mutant_bodyparts = list("tail_human", "ears", "wings")
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "Elf", "wings" = "None")
	limbs_id = "elf"
	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), OFFSET_HAIR = list(0,-4), OFFSET_FACE = list(0,-3), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))
	use_skintones = 1
	speedmod = -1 //A bit faster than the standard human
	brutemod = 1.5 //They take more damage than any other races.
	burnmod = 1.5 //Burn worse too
	heatmod = 1.3 //They also die in fires easier.
	punchdamagelow = 1
	punchdamagehigh = 8//their punches are weaker
	punchstunthreshold = 8 //Because its the maximum here.
	skinned_type = /obj/item/stack/sheet/animalhide/human

/mob/living/carbon/human/species/elf
	race = /datum/species/elf

/datum/species/elf/random_name(gender,unique,lastname)
	return elf_name()

//Elf Names
/proc/elf_name()
	return "[pick(GLOB.elf_first)] [pick(GLOB.elf_last)]"

//Fucking knife eared cunts, yep. I just reused felinid code for the ears lol
/obj/item/organ/ears/elf
	name = "elf ears"
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "kitty"

/obj/item/organ/ears/elf/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		color = H.skin_tone
		H.dna.species.mutant_bodyparts |= "ears"
		H.dna.features["ears"] = "Elf"
		H.update_body()

/obj/item/organ/ears/elf/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	if(istype(H))
		color = H.hair_color
		H.dna.features["ears"] = "None"
		H.dna.species.mutant_bodyparts -= "ears"
		H.update_body()