#define iself(A) (is_species(A, /datum/species/elf))

GLOBAL_LIST_INIT(elf_first, world.file2list("strings/names/elf_first.txt"))
GLOBAL_LIST_INIT(elf_last, world.file2list("strings/names/elf_first.txt"))

//Its hard to say whether they are more intelligent than humanity, or how many have moved up in nanotrasen.
//Its also hard to say how long they've been around, or how long they actually live.
//Regardless, they are around, and more than capable of inhuman feats.

/datum/species/elf
	name = "Elf"
	id = "elf" //Also called Homo sapiens nobilis
	fixed_mut_color = "fcccb3" //Elves all come out perfectly caucasian2, as different colors of elves are other races.
	use_skintones = FALSE //Dark elves would cause too much crime.
	species_traits = list(MUTCOLORS,EYECOLOR,HAIR,LIPS) //No facial hair.
	mutant_bodyparts = list("ears") //Whats the difference between a human and a elf?
	default_features = list("ears" = "Elf") //Its the fuckin ears. Also luckily they can't pick cat ears.
	limbs_id = "human"
	liked_food = VEGETABLES | FRUIT | GRAIN //They like natural shit man, indifferent to the rest.
	disliked_food = JUNKFOOD | FRIED | GROSS //Elves hate unnaturally processed foods, n gross things.
	brutemod = 1.6 //They take greatly more damage than any other metahuman, graceful not durable.
	burnmod = 1.5 //Lasers hurt worse too.
	heatmod = 1.5 //They also die in fires easier.
	speedmod = -0.3 //slightly faster than a human who is at a base of 0
	coldmod = 1.5 //And space... space definitely hurts them almost twice as bad. Clearly better not in it.
	punchdamagelow = 1
	punchdamagehigh = 8//their punches are weaker
	punchstunthreshold = 8 //Because its the maximum here. They should be able to still critical hit.
	skinned_type = /obj/item/stack/sheet/animalhide/human
	mutantears = /obj/item/organ/ears/elf //yep.

	offset_features = list(
		OFFSET_UNIFORM = list(0,0), 
		OFFSET_ID = list(0,0), 
		OFFSET_GLOVES = list(0,0), 
		OFFSET_GLASSES = list(0,0), 
		OFFSET_EARS = list(0,0), 
		OFFSET_SHOES = list(0,0), 
		OFFSET_S_STORE = list(0,0), 
		OFFSET_FACEMASK = list(0,0), 
		OFFSET_HEAD = list(0,0), 
		OFFSET_HAIR = list(0,0), 
		OFFSET_FHAIR = list(0,0),
		OFFSET_FACE = list(0,0), 
		OFFSET_BELT = list(0,0), 
		OFFSET_BACK = list(0,0), 
		OFFSET_SUIT = list(0,0), 
		OFFSET_NECK = list(0,0)
		)

//spawn menu path
/mob/living/carbon/human/species/elf
	race = /datum/species/elf

//Elf Name shit
/proc/elf_name() //The elves don't care about gender being elves.
	return "[pick(GLOB.elf_first)] [pick(GLOB.elf_last)]" //We just pick from both to form one name.

/datum/species/elf/random_name(gender,unique,lastname)
	return elf_name() //and the proc calls upon the above proc and returns the value from the global lists.

//Elf rank shit
/datum/species/elf/qualifies_for_rank(rank, list/features)
	return TRUE //Elves qualify for everything, they are very persuasive at best, intolerable at worst.

//Elf species on gain and loss n shiet
/datum/species/elf/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()

	if(ishuman(C)) //two chunks of copy and pasted code ufufu. thanks felinids
		var/mob/living/carbon/human/H = C 
		if(H.dna.features["ears"] == "Elf") //This inserts a object into the mob
			var/obj/item/organ/ears/elf/ears = new //Technically the dna is handled on the organ obj too.
			ears.Insert(H, drop_if_replaced = FALSE) 
		else
			mutantears = /obj/item/organ/ears

	if(C.client) //thanks kmc
		if(C.client.prefs.real_name == C.real_name) //Random name if this isnt their chosen name
			return
	var/new_name = random_name()
	C.real_name = new_name
	C.name = new_name


/datum/species/elf/on_species_loss(mob/living/carbon/H, datum/species/new_species, pref_load)
	var/obj/item/organ/ears/elf/ears = H.getorgan(/obj/item/organ/ears/elf)

	if(ears) //Handles removal of ears.
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
	color_src = MUTCOLORS //Their color is handled thru mutantcolor, which is currently fixed.

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
		H.dna.features["ears"] = "Elf" //Funny how the dna setting part is here huh.
		H.update_body()

/obj/item/organ/ears/elf/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	if(istype(H))
		H.dna.features["ears"] = "None"
		H.dna.species.mutant_bodyparts -= "ears"
		H.update_body()