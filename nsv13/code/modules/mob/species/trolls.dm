#define istroll(A) (is_species(A, /datum/species/troll))

//Trolls also don't have any naming conventions.

/datum/species/troll //the largest variant of metahuman.
	name = "Troll" //The largest variant of orkoid metahuman, lower lifespan, slower, tough, stupid.
	id = "troll" //Also called Homo sapiens ingentis
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,NO_UNDERWEAR)
	inherent_traits = list(TRAIT_STRONG_GRABBER) 
	default_features = list("mcolor" = "FFF", "wings" = "None")
	limbs_id = "troll" 
	use_skintones = 1
	damage_overlay_type = "monkey" //TODO: Make troll damage overlays for the larger bodytype.
	skinned_type = /obj/item/stack/sheet/animalhide/human
	liked_food = ALCOHOL | MEAT | DAIRY //Dwarves like alcohol, meat, and dairy products.
	disliked_food = JUNKFOOD | FRIED //Dwarves hate foods that have no nutrition other than alcohol.
	brutemod = 0.9 //Some damage reduction due to being tough
	burnmod = 1.1 //More Laser damage cause troll.
	coldmod = 1.3 //Takes more damage from cold.
	heatmod = 1.5 //More damage from heat, since burning trolls and all.
	armor = 25 // Very tough skin with muscle behind it.
	speedmod = 1 // Slow, but has long legs.
	punchdamagelow = 5 // If a troll is punching you then ouchies
	punchdamagehigh = 22 //Has to hit harder than a ork, and be comparable to using a object. Still rng

	//Pixel X, and Pixel Y.
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
		OFFSET_HAIR = list(0,3), //3 pixel taller than a human
		OFFSET_FHAIR = list(0,3), 
		OFFSET_FACE = list(0,3), 
		OFFSET_BELT = list(0,0), 
		OFFSET_BACK = list(0,0), 
		OFFSET_SUIT = list(0,0), 
		OFFSET_NECK = list(0,0)
		)

/mob/living/carbon/human/species/troll //species spawn path
	race = /datum/species/troll //and the race the path is set to.

/datum/species/troll/qualifies_for_rank(rank, list/features)
	if(rank in GLOB.command_positions) //no trolls in command
		return 0
	if(rank in GLOB.medical_positions) //no trolls in medical
		return 0
	if(rank in GLOB.science_positions) //and no trolls in science
		return 0
	return 1 //Otherwise you can enjoy being security, engineering, or service.