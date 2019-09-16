#define istroll(A) (is_species(A, /datum/species/troll))

//Trolls also don't have any naming conventions.

/datum/species/troll //the largest variant of metahuman.
	name = "Troll" //The largest variant of orkoid metahuman, lower lifespan, slower, tough, stupid.
	id = "troll" //Also called Homo sapiens ingentis
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,NO_UNDERWEAR)
	inherent_traits = list(TRAIT_STRONG_GRABBER) 
	default_features = list("mcolor" = "FFF", "wings" = "None")
	limbs_id = "troll"
	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), OFFSET_HAIR = list(0,0), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))
	use_skintones = 1
	damage_overlay_type = "monkey" //TODO: Make troll damage overlays for the larger bodytype.
	skinned_type = /obj/item/stack/sheet/animalhide/human
	liked_food = ALCOHOL | MEAT | DAIRY //Dwarves like alcohol, meat, and dairy products.
	disliked_food = JUNKFOOD | FRIED //Dwarves hate foods that have no nutrition other than alcohol.
	brutemod = 0.85 //Take slightly less damage than a human.
	burnmod = 0.85 //Less laser damage too.
	coldmod = 0.5 //Handle cold better too, but not their forte in life.
	heatmod = 0.3 //Of course heat also, resistant thanks to being dwarves but not invulnerable.
	punchdamagelow = 2 // Their min roll is 1 higher than a base human
	punchdamagehigh = 14 //They do more damage and have a higher chance to stunpunch since its at 10.