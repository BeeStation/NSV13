// ----- Outside Code segments relating to Ork Species -----

//code/__DEFINES/mobs.dm - extra icon rendering OFFSET defines
//code/__DEFINES/jobs.dm - species qualifies_for_rank check define
//code/__HELPERS/global_lists.dm - adds references to sprite accessory global list for mutantpart teeth
//code/modules/mob/living/carbon/human/species.dm - renders mutantpart teeth from global list, extra offsets
//code/modules/client/preferences_savefile.dm - saves teeth global list so they don't disappear on pref menu
//code/modules/jobs/job_types/security_officer.dm - species check that doesn't give them an attachable accessory
//code/controllers/subsystem/job.dm - job controller qualifies_for_rank species restriction checks on sorting.
//code/modules/mob/dead/new_player/new_player.dm - latejoin menu qualifies_for_rank species restriction checks

//nsv13/code/_globalvars/lists/flavor_misc.dm - creates empty global list for teeth
//nsv13/code/modules/mob/dead/new_player/sprite_accessories.dm - contains sprite accessory teeth
//nsv13/code/modules/clothing/orkequipment.dm - contains ork suit+under equipment and parent paths for it
//nsv13/code/modules/clothing/outfits/ork.dm - contains ork job outfit datum equipment paths

// ----- Icon files -----

//icons/mob/human_parts_greyscale.dmi - Contains greyscale mob body
//nsv13/icons/mob/mutantbodyparts.dmi - Contains mutantpart Ork teeth
//nsv13/icons/mob/orkequipment.dmi - Contains mobbody MOB icon equipment

/*
@author:JTGSZ
Its a ork from shadowrun, not to be confused for the 40k ork. (Which I also have a mob body and equipment for)
Basically hes a very close relative to the human, although a bit grotesque.
Mob Icon body looks more bulked up, 1 Pixel taller than the human for effect.
Comes with some longer canines, speaks with own slang.
Drastically reduced job opportunities, low avaliability of equipment to go along with that.
Be lucky to see an ork actually find a space suit.
No rage systems or anything, too greytidey.
*/


/datum/species/ork 
	name = "Ork" 
	id = "ork" //Also called Homo sapiens robustus.
	default_color = "FFFFFF" 
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,NO_UNDERWEAR,LIPS)
	inherent_traits = list(TRAIT_STRONG_GRABBER) //He can grab strong why not.
	mutant_bodyparts = list("teeth") //You know, these will probably be a organ one day.
	default_features = list("mcolor" = "FFF", "wings" = "None", "teeth" = "Long Lower Canines") //teef
	say_mod = "grunts" //peak aggression
	limbs_id = "ork"
	use_skintones = 1 //Standard skintones.
	skinned_type = /obj/item/stack/sheet/animalhide/human
	liked_food = JUNKFOOD | FRIED //Similar tastes to a humans.
	disliked_food = GROSS | PINEAPPLE //Willing to eat raw food, hates gross food and pineapples.
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | WABBAJACK
	brutemod = 0.9 //All he has going for him is a tiny bit of innate damage reduction.
	burnmod = 0.9 //Burns less to lasers.
	armor = 5 //and a slightly tougher hide
	speedmod = 0.2 //And should be faster than humans, but need more downsides.
	punchdamagelow = 3 //And greater punch potential.
	punchdamagehigh = 14 // its OKAY, for reference a toolbox is 12 force exact.

	//Pixel X, and Pixel Y.
	offset_features = list(
		OFFSET_UNIFORM = list(0,0), 
		OFFSET_ID = list(0,0), 
		OFFSET_GLOVES = list(0,0), 
		OFFSET_GLASSES = list(0,1), 
		OFFSET_EARS = list(0,1), 
		OFFSET_SHOES = list(0,0), 
		OFFSET_S_STORE = list(0,0), 
		OFFSET_FACEMASK = list(0,1), 
		OFFSET_HEAD = list(0,1), 
		OFFSET_HAIR = list(0,1), //1 pixel taller than a human.
		OFFSET_FHAIR = list(0,1), 
		OFFSET_EYES = list(0,1),
		OFFSET_LIPS = list(0,1), 
		OFFSET_BELT = list(0,0), 
		OFFSET_BACK = list(0,2), //haha ah ha
		OFFSET_SUIT = list(0,0), 
		OFFSET_NECK = list(0,1),
		OFFSET_MUTPARTS = list(0,1),
		)

/mob/living/carbon/human/species/ork //species admin spawn path
	race = /datum/species/ork //and the race the path is set to.

/datum/species/ork/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!H.dna.features["teeth"])
			H.dna.features["teeth"] = "Long Lower Canines"
			handle_mutant_bodyparts(H)
	RegisterSignal(C, COMSIG_MOB_SAY, .proc/handle_speech) //We register handle_speech is being used.

/datum/species/ork/on_species_loss(mob/living/carbon/human/H, datum/species/new_species)
	UnregisterSignal(H, COMSIG_MOB_SAY) //We register handle_speech is not being used.

//Filters out this species from taking these positions in the job selection.
/datum/species/ork/qualifies_for_rank(rank, list/features)
	if(rank in GLOB.command_positions) //no orks in command.
		return 0
	if(rank in GLOB.medical_positions) //no orks in medical, untrustworthy
		return 0
	if(rank in GLOB.science_positions) //and no orks in science, not like they live long enough.
		return 0
	if(rank in GLOB.engineering_positions) //while capable of engineering, thats not what they'd be hired for.
		return 0
	//List of Civ positions not allowed in as they can take some
	var/list/civpositions = list("Lawyer","Curator","Mime","Chaplain")
	if(rank in civpositions)
		return 0
	//List of Sec positions not allowed in as they can take some
	var/list/secpositions = list("Master At Arms")
	if(rank in secpositions)
		return 0
	//List of Supply positions not allowed in as they can take some
	var/list/supplypositions = list("Shaft Miner")
	if(rank in supplypositions)
		return 0
	return 1 //Otherwise you can enjoy security, supply or service.

//Handles special job outfit datums.
/datum/species/ork/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	var/current_job = J.title
	var/datum/outfit/ork/O = new /datum/outfit/ork //Species Job Outfits.
	switch(current_job) //See: nsv13/code/modules/clothing/outfits/ork.dm for the object paths

		if("Assistant") //Basically it runs before job equip, the normal job equip happens after.
			O = new /datum/outfit/ork/assistant //The normal job outfit is only equipped if possible.	
		if("Botanist")
			O = new /datum/outfit/ork/botany //Botanist outfit
		if("Bartender")
			O = new /datum/outfit/ork/bar //Bartender outfit
		if("Janitor")
			O = new /datum/outfit/ork/janitor //Janitor outfit
		if("Cook")
			O = new /datum/outfit/ork/chef //Cook outfit
		if("Security Officer")
			O = new /datum/outfit/ork/security //Security officer outfit
		if("Detective")
			O = new /datum/outfit/ork/detective //Detective outfit
		if("Quartermaster")
			O = new /datum/outfit/ork/quartermaster //Quartermaster outfit
		if("Cargo Technician")
			O = new /datum/outfit/ork/cargotech //Cargo Technician outfit
		if("Clown")
			O = new /datum/outfit/ork/clown //Clown outfit

	H.equipOutfit(O, visualsOnly)
	return 0

//Ork Speech handling - Basically a filter/forces them to say things. The IC helper
/datum/species/ork/proc/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE] //After many attempts, I can't devise a accent. 
	if(message) //So.... Heres shadowrun slang
		message = " [message] "
		message = replacetext(message,"s","sh")
		message = replacetext(message," friend ", " chummer ")
		message = replacetext(message," pal ", " chummer ")
		message = replacetext(message," buddy ", " chummer ")
		message = replacetext(message," corporate ", " corp ")
		message = replacetext(message," taking ", " takin' ")
		message = replacetext(message," security ", " badge ")
		message = replacetext(message," killed ", " creased ")
		message = replacetext(message," shit ", " drek ")
		message = replacetext(message," elf ", " keeb ")
		message = replacetext(message," bloody ", " krovvy ")
		speech_args[SPEECH_MESSAGE] = trim(message)
