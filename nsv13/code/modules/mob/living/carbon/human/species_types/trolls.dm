#define istroll(A) (is_species(A, /datum/species/troll))

//Trolls also don't have any naming conventions, forever destined to be a servant race.
//Downside is they are incapable of upward mobility, completely scary to be around due to size and strength.
//And you'll more than likely never see anything other than what you are hired with for equipment.
//They also burn and freeze a lot easier, all of their armors are inferior too.

//Hint: Who is going to listen to a naked troll, or one in service clothes?
//Security is going to be completely loyal and rigid anyways.
//You'll also more than likely never see a troll sized eva suit, so no leaving the ship safely.

/datum/species/troll //the largest variant of metahuman.
	name = "Troll" //The largest variant of orkoid metahuman, lower lifespan, slower, tough, stupid.
	id = "troll" //Also called Homo sapiens ingentis
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,NO_UNDERWEAR)
	inherent_traits = list(TRAIT_STRONG_GRABBER) 
	mutant_bodyparts = list("teeth")
	default_features = list("mcolor" = "FFF", "wings" = "None", "teeth" = "Troll")
	limbs_id = "troll" 
	use_skintones = 1 //Like the ork they can interbreed with humanity.
	damage_overlay_type = "monkey" //TODO: Make troll damage overlays for the larger bodytype.
	skinned_type = /obj/item/stack/sheet/animalhide/human
	liked_food = ALCOHOL | JUNKFOOD | FRIED //Trolls like meat, and junkfood, basically imagine a really slobbish human.
	disliked_food = VEGETABLES //They aren't a big fan of vegetables.
	brutemod = 0.9 //Some damage reduction due to being tough
	burnmod = 1.1 //More Laser damage cause troll.
	coldmod = 1.3 //Takes more damage from cold.
	heatmod = 1.7 //More damage from heat, since burning trolls and all.
	armor = 25 // Very tough skin with muscle behind it.
	speedmod = 1 // Slow, but has long legs.
	punchdamagelow = 5 // If a troll is punching you then ouchies
	punchdamagehigh = 22 //Has to hit harder than a ork, and be comparable to using a object.
	attack_sound = 'nsv13/sound/effects/strongerpunch.ogg' //A sound effect that lets you know things break.
	//Otherwise you'll probably never see a troll opt to punch someone over grab a axe or sword.

	//Pixel X, and Pixel Y.
	offset_features = list(
		OFFSET_UNIFORM = list(0,0), 
		OFFSET_ID = list(0,0), 
		OFFSET_GLOVES = list(0,0), 
		OFFSET_GLASSES = list(0,3), 
		OFFSET_EARS = list(0,3), 
		OFFSET_SHOES = list(0,0), 
		OFFSET_S_STORE = list(0,0), 
		OFFSET_FACEMASK = list(0,3), 
		OFFSET_HEAD = list(0,3), 
		OFFSET_HAIR = list(0,3), //3 pixel taller than a human
		OFFSET_FHAIR = list(0,3), 
		OFFSET_FACE = list(0,3), 
		OFFSET_BELT = list(0,1), 
		OFFSET_BACK = list(0,3), 
		OFFSET_SUIT = list(0,0), 
		OFFSET_NECK = list(0,3)
		)

/mob/living/carbon/human/species/troll //species spawn path
	race = /datum/species/troll //and the race the path is set to.

/datum/species/troll/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!H.dna.features["teeth"])
			H.dna.features["teeth"] = "Troll"
			handle_mutant_bodyparts(H)

/datum/species/troll/qualifies_for_rank(rank, list/features) //Based on intelligence mostly.
	if(rank in GLOB.command_positions) //no trolls in ANY command job
		return 0
	if(rank in GLOB.medical_positions) //no trolls in ANY medical job
		return 0
	if(rank in GLOB.science_positions) //and no trolls in ANY science job
		return 0
	if(rank in GLOB.engineering_positions) //Engineering? haha nope.
		return 0
	//List of Civ positions not allowed in as they can take some
	var/list/civpositions = list("Lawyer","Curator","Clown","Mime","Chaplain")
	if(rank in civpositions)
		return 0
	//List of Sec positions not allowed in as they can take some
	var/list/secpositions = list("Master At Arms","Detective")
	if(rank in secpositions)
		return 0
	//List of Supply positions not allowed in as they can take some
	var/list/supplypositions = list("Shaft Miner","Quartermaster")
	if(rank in supplypositions)
		return 0
	return 1 //Otherwise you can enjoy being too stupid to be hired on for nearly everything.

/datum/species/troll/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	var/current_job = J.title
	var/datum/outfit/ork/O = new /datum/outfit/troll //Species Job Outfits
	switch(current_job) //See: nsv13/code/modules/clothing/outfits/troll.dm for the object paths

		if("Assistant") //Basically it runs before job equip, the normal job equip happens after.
			O = new /datum/outfit/troll/assistant //The normal job outfit is only equipped if possible.

		if("Botanist")
			O = new /datum/outfit/troll/botany 

		if("Janitor")
			O = new /datum/outfit/troll/janitor

		if("Bartender")
			O = new /datum/outfit/troll/bar 

		if("Cook")
			O = new /datum/outfit/troll/chef

		if("Security Officer")
			O = new /datum/outfit/troll/security

		if("Cargo Technician")
			O = new /datum/outfit/troll/cargotech 

	H.equipOutfit(O, visualsOnly)
	return 0

/datum/sprite_accessory/teeth/troll
	name = "Troll"
	icon = 'nsv13/icons/mob/mutantbodyparts.dmi'
	icon_state = "troll"
	color_src = 0 //we handle this on mobicon. basically sets recoloring to false.