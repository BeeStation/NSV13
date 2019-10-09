// ----- Outside Code segments relating to Troll Species -----

//code__DEFINES/mobs.dm - extra icon rendering OFFSET defines
//code/__DEFINES/jobs.dm - species qualifies_for_rank check define
//code/__HELPERS/global_lists.dm - adds references to sprite accessory global list for mutantpart teeth, troll_horns
//code/modules/jobs/job_types/security_officer.dm - species check that doesn't give them an accessory
//code/modules/client/preferences_savefile.dm - saves troll_horns, as they are pickable on pref
//code/modules/client/preferences.dm - adds options to pick troll_horns on preferences
//code/modules/mob/living/carbon/human/species.dm - renders mutantpart teeth, troll_horns from global list, extra offsets
//code/controllers/subsystem/job.dm - job controller qualifies_for_rank species restriction checks on sorting.
//code/modules/mob/dead/new_player/new_player.dm - latejoin menu qualifies_for_rank species restriction checks

//nsv13/code/_globalvars/lists/flavor_misc.dm - creates empty global list for mutantpart teeth, trollhorns
//nsv13/code/modules/clothing/trollequipment.dm - contains troll suit+under equipment and parent paths for it
//nsv13/code/modules/clothing/outfits/troll.dm - contains troll job outfit datum equipment paths

// ----- Icon files -----

//icons/mob/human_parts_greyscale.dmi - Contains greyscale mob body
//nsv13/icons/mob/mutantbodyparts.dmi - Contains mutantpart Troll teeth, troll_horns
//nsv13/icons/mob/trollequipment.dmi - Contains troll mobbody MOB icon equipment

// ----- Sound files -----

//nsv13/sound/effects/strongerpunch.ogg - Contains notable punch sound effect

/*
@author:JTGSZ
Its a troll based on the ones from shadowrun.
Large, the mob is 3 pixels taller than a human for effect, has different punch sound.
Has barely any job choices, and barely any properly sized equipment avaliable.
Technically he can burn to death in probably like 5 seconds man.
More than likely only ever going to see what nanotrasen provided to them on hire.
Speech filter, comes out dumb as smart trolls are snowflakes.
Comes with Trait_Dumb not monkeylike or clumsy, as they need to be able to use microwaves.
Speech changed to reflect this too.
Has choosable horns.
No rage systems or anything, too greytidey.
*/

/datum/species/troll 
	name = "Troll" 
	id = "troll" //Also called Homo sapiens ingentis
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,NO_UNDERWEAR)
	inherent_traits = list(TRAIT_STRONG_GRABBER, TRAIT_DUMB) 
	mutant_bodyparts = list("teeth", "troll_horns") //We have teeth and horns.
	default_features = list("mcolor" = "FFF", "wings" = "None", "teeth" = "Tusks", "troll_horns" = "Devil")
	limbs_id = "troll" 
	say_mod = "mumbles" //We mumble.
	use_skintones = 1 //Comes in many colors
	no_equip = list() //Ironically, If they choose to have horns they aren't going to wear a head object.
	damage_overlay_type = "human"
	skinned_type = /obj/item/stack/sheet/animalhide/human
	liked_food = ALCOHOL | JUNKFOOD | FRIED //Basically imagine a really slobbish human.
	disliked_food = VEGETABLES //They aren't a big fan of vegetables.
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | WABBAJACK

	brutemod = 0.9 //Some damage reduction due to being tough
	burnmod = 1.1 //More Laser damage cause troll.
	coldmod = 1.3 //Takes more damage from cold.
	heatmod = 1.7 //More damage from heat, since burning trolls and all.
	armor = 25 // Very tough skin with muscle behind it.
	speedmod = 1 // Slow, but has long legs.
	punchdamagelow = 5 // If a troll is punching you then ouchies
	punchdamagehigh = 20 //A toolbox is 12, so at least they'll punch like they should be doing.
	attack_sound = 'nsv13/sound/effects/strongerpunch.ogg' //A sound effect that lets you know things break.
	//Otherwise you'll probably never see a troll opt to punch someone over grab anything..

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
		OFFSET_EYES = list(0,3),
		OFFSET_LIPS = list(0,3),
		OFFSET_BELT = list(0,1), 
		OFFSET_BACK = list(0,3), 
		OFFSET_SUIT = list(0,0), 
		OFFSET_NECK = list(0,3),
		OFFSET_MUTPARTS = list(0,3)
		)

/mob/living/carbon/human/species/troll //species spawn path
	race = /datum/species/troll //and the race the path is set to.

//On species gain these things occur.
/datum/species/troll/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!H.dna.features["teeth"])
			H.dna.features["teeth"] = "Long Lower Canines"
			handle_mutant_bodyparts(H)
	RegisterSignal(C, COMSIG_MOB_SAY, .proc/handle_speech) //We register handle_speech is being used.

//On Species Loss these things occur.
/datum/species/troll/on_species_loss(mob/living/carbon/human/H, datum/species/new_species)
	UnregisterSignal(H, COMSIG_MOB_SAY) //We register handle_speech is not being used.

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

//Handles special job outfit datums.
/datum/species/troll/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	var/current_job = J.title
	var/datum/outfit/ork/O = new /datum/outfit/troll //Species Job Outfits
	switch(current_job) //See: nsv13/code/modules/clothing/outfits/troll.dm for the object paths

		if("Assistant") //Basically it runs before job equip, the normal job equip happens after.
			O = new /datum/outfit/troll/assistant //The normal job outfit is only equipped if possible.
		if("Botanist")
			O = new /datum/outfit/troll/botany //Botanist outfit
		if("Janitor")
			O = new /datum/outfit/troll/janitor //Janitor outfit
		if("Bartender")
			O = new /datum/outfit/troll/bar //Bartender outfit
		if("Cook")
			O = new /datum/outfit/troll/chef //Cook outfit
		if("Security Officer")
			O = new /datum/outfit/troll/security //Security officer outfit
		if("Cargo Technician")
			O = new /datum/outfit/troll/cargotech //Cargo technician outfit

	H.equipOutfit(O, visualsOnly)
	return 0

//Troll Speech handling - Basically a filter/forces them to say things. The IC helper
/datum/species/troll/proc/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = " [message] " //I don't know if this helps or makes things worse honestly.
		message = replacetext(message," stupid "," smart ")
		message = replacetext(message," dumb ", " smart ")
		message = replacetext(message," idiot ", " smart ")
		message = replacetext(message," retard ", " smart ")
		message = replacetext(message," best ", " bestest ")
		message = replacetext(message," absolute ", " abstatute ")
		message = replacetext(message," dumbass ", " very smart ")
		message = replacetext(message," shitters ", " bad people ")
		message = replacetext(message," greytide ", " bad people ")
		message = replacetext(message," I "," me ")
		message = replacetext(message," I'm "," am ")
		message = replacetext(message," your ", " you ")
		message = replacetext(message," you're ", " you ")
		message = replacetext(message," youre ", " you ")
		message = replacetext(message," janitor ", " good job ")
		message = replacetext(message," clown ", " CLOWN ")
		message = replacetext(message," hurt ", " ouchies ")
		message = replacetext(message," injured ", " ouchies ")
		message = replacetext(message," hey ", " HEY! ")
		message = replacetext(message," human ", " squishy ")
		message = replacetext(message," elf ", "squishy ")
		message = replacetext(message," lizard ", " good boy ")
		speech_args[SPEECH_MESSAGE] = trim(message)
