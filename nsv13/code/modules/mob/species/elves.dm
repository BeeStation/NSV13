#define iself(A) (is_species(A, /datum/species/elf))

GLOBAL_LIST_INIT(elf_first, world.file2list("strings/names/elf_first.txt"))
GLOBAL_LIST_INIT(elf_last, world.file2list("strings/names/elf_first.txt"))

/datum/species/elf
	name = "Elf"
	id = "elf"
	fixed_mut_color = "ffe0d1" //Elves all come out caucasian, as different colors of elves are other races.
	hair_color = "ffc125" //GOLDENROD HAIR straight from google.
	use_skintones = FALSE //Dark elves would cause too much crime.
	species_traits = list(MUTCOLORS,EYECOLOR,HAIR,LIPS)
	mutant_bodyparts = list("ears")
	default_features = list("ears" = "Elf")
	limbs_id = "human"
	liked_food = VEGETABLES | FRUIT //They like natural shit man.
	disliked_food = JUNKFOOD | FRIED //Elves hate unnaturally processed foods.
	speedmod = -0.7 //A bit faster than the standard human, elves are nimble, quick, and crumple easy.
	brutemod = 1.6 //They take greatly more damage than any other metahuman, as they are graceful not durable.
	burnmod = 1.5 //Lasers hurt worse too.
	heatmod = 1.5 //They also die in fires easier.
	coldmod = 1.8 //And space... space definitely hurts them almost twice as bad. Clearly better not in it.
	punchdamagelow = 1
	punchdamagehigh = 8//their punches are weaker
	punchstunthreshold = 8 //Because its the maximum here.
	skinned_type = /obj/item/stack/sheet/animalhide/human
	mutantears = /obj/item/organ/ears/elf

//spawn menu path
/mob/living/carbon/human/species/elf
	race = /datum/species/elf

//Elf Name shit
/proc/elf_name()
	return "[pick(GLOB.elf_first)] [pick(GLOB.elf_last)]"

/datum/species/elf/random_name(gender,unique,lastname)
	return elf_name()

//Elf rank shit
/datum/species/elf/qualifies_for_rank(rank, list/features)
	return TRUE

//Elf species on gain and loss shit
/datum/species/elf/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H.dna.features["ears"] == "Elf")
			var/obj/item/organ/ears/elf/ears = new
			ears.Insert(H, drop_if_replaced = FALSE)
		else
			mutantears = /obj/item/organ/ears

	if(C.client)
		if(C.client.prefs.real_name == C.real_name) //Random name if this isnt their chosen name
			return
	var/new_name = random_name()
	C.real_name = new_name
	C.name = new_name


/datum/species/elf/on_species_loss(mob/living/carbon/H, datum/species/new_species, pref_load)
	var/obj/item/organ/ears/elf/ears = H.getorgan(/obj/item/organ/ears/elf)

	if(ears)
		var/obj/item/organ/ears/NE
		if(new_species && new_species.mutantears)
			new_species.mutantears = initial(new_species.mutantears)
			if(new_species.mutantears)
				NE = new new_species.mutantears
		if(!NE)
			NE = new /obj/item/organ/ears
		NE.Insert(H, drop_if_replaced = FALSE)
	
//The fucking thing it draws onto the elf, holy fuck fuck this dumb shit.
/datum/sprite_accessory/ears/elf
	name = "Elf"
	icon_state = "elf"
	color_src = 0 //Due to my findings regarding species stuff, this is gonna be it pal.

//gay elf ears
/obj/item/organ/ears/elf
	name = "elf ears" // They only come in one color ok?
	desc = "The torn ears off a elf metahuman variant."
	icon = 'nsv13/icons/obj/clothing/hats.dmi' //obj icon when removed, made in 5 mins.
	icon_state = "elf" //and their state
	damage_multiplier = 2 // And they take more hearing damage? idk

/obj/item/organ/ears/elf/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		H.dna.species.mutant_bodyparts |= "ears"
		H.dna.features["ears"] = "Elf"
		H.update_body()

/obj/item/organ/ears/elf/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	if(istype(H))
		H.dna.features["ears"] = "None"
		H.dna.species.mutant_bodyparts -= "ears"
		H.update_body()