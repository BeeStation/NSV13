#define isork(A) (is_species(A, /datum/species/ork))

//Orks actually don't have any naming theme other than streetnames, although asian names are popular.

/datum/species/ork //Not to be confused with the warhammer 40k ork.
	name = "Ork" //A close relative to the human, hes just a bit stronger. With a vastly shorter lifespan.
	id = "ork" //Also called Homo sapiens robustus.
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,NO_UNDERWEAR)
	inherent_traits = list(TRAIT_STRONG_GRABBER) //Not resistant to the environment like dorves.
	default_features = list("mcolor" = "FFF", "wings" = "None")
	limbs_id = "ork"
	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), OFFSET_HAIR = list(0,0), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))
	use_skintones = 1 //Standard skintones.
	skinned_type = /obj/item/stack/sheet/animalhide/human
	liked_food = JUNKFOOD | FRIED //Similar tastes to a humans.
	disliked_food = GROSS | PINEAPPLE //Willing to eat raw food, hates gross food and pineapples.
	brutemod = 0.9 //All he has going for him is a tiny bit of innate damage reduction.
	burnmod = 0.9 //Burns less to lasers.
	armor = 5 //and a slightly tougher hide
	punchdamagelow = 3 //And greater punch potential.
	punchdamagehigh = 18 // Pretty good, but still worse than many melee weapons.