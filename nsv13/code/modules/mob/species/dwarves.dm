#define isdwarf(A) (is_species(A, /datum/species/dwarf))

GLOBAL_LIST_INIT(dwarf_first, world.file2list("strings/names/dwarf_first.txt"))
GLOBAL_LIST_INIT(dwarf_last, world.file2list("strings/names/dwarf_last.txt"))

//lavaland dwarves make a return, in the form of space dwarves with no alcohol organ.
/datum/species/dwarf //not to be confused with the genetic manlets
	name = "Dwarf"
	id = "dwarf" //Also called Homo sapiens pumilionis
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,NO_UNDERWEAR)
	//Their livers won't fail, they can grab burning objects and get hurt, and jump straight to aggro grab.
	inherent_traits = list(TRAIT_STABLELIVER,TRAIT_RESISTHEATHANDS,TRAIT_STRONG_GRABBER) 
	default_features = list("mcolor" = "FFF", "wings" = "None")
	limbs_id = "dwarf"
	use_skintones = 1
	damage_overlay_type = "monkey" //fits surprisngly well, so why add more icons?
	skinned_type = /obj/item/stack/sheet/animalhide/human
	liked_food = ALCOHOL | MEAT | DAIRY //Dwarves like alcohol, meat, and dairy products.
	disliked_food = JUNKFOOD | FRIED //Dwarves hate foods that have no nutrition other than alcohol.
	brutemod = 0.85 //Take slightly less damage than a human.
	burnmod = 0.85 //Less laser damage too.
	coldmod = 0.5 //Handle cold better too, but not their forte in life.
	heatmod = 0.3 //Of course heat also, resistant thanks to being dwarves but not invulnerable.
	punchdamagelow = 2 // Their min roll is 1 higher than a base human
	punchdamagehigh = 14 //They do more damage and have a higher chance to stunpunch since its at 10.
	mutanteyes = /obj/item/organ/eyes/night_vision //And they have night vision.
	
	//Pixel X, and Pixel Y offsets on mob drawing. It handles the offset in update_icons.dm
	//X is Horizontal, Y is Vertical. These are general offsets, directional offsets do not exist.
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
		OFFSET_HAIR = list(0,-4), //this is at -4
		OFFSET_FHAIR = list(0,-4), //this is at -4
		OFFSET_FACE = list(0,-3), //this is at -3
		OFFSET_BELT = list(0,0), 
		OFFSET_BACK = list(0,0), 
		OFFSET_SUIT = list(0,0), 
		OFFSET_NECK = list(0,0)
		)

/mob/living/carbon/human/species/dwarf //species spawn path
	race = /datum/species/dwarf //and the race the path is set to.

/datum/species/dwarf/qualifies_for_rank(rank, list/features)
	return TRUE	//I don't think dwarves would be barred from holding rank, reliable industrious people.

/datum/species/dwarf/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	var/dwarf_hair = pick("Beard (Dwarf)", "Beard (Very Long)", "Beard (Moonshiner)", "Beard (Broken Man)") //beard roullette
	var/mob/living/carbon/human/H = C 
	H.facial_hair_style = dwarf_hair
	H.update_hair()

//Dwarf Name stuff
/proc/dwarf_name() //hello caller: my name is urist mcuristurister
	return "[pick(GLOB.dwarf_first)] [pick(GLOB.dwarf_last)]"

/datum/species/dwarf/random_name(gender,unique,lastname)
	return dwarf_name() //hello, ill return the value from dwarf_name proc to you when called.