// ----- Outside Code segments relating to Dwarf Species -----

//strings/dwarf_replacement.json - massive scottish accent json of strings that is used for handle_speech
//code/__DEFINES/mobs.dm - extra icon rendering OFFSET defines
//code/__DEFINES/jobs.dm - species qualifies_for_rank check define
//code/modules/mob/living/carbon/human/species.dm - extra offsets
//code/controllers/subsystem/job.dm - job controller qualifies_for_rank species restriction checks on sorting.
//code/modules/mob/dead/new_player/new_player.dm - latejoin menu qualifies_for_rank species restriction checks

// ----- Icon Files -----

//None - Nothing yet.

GLOBAL_LIST_INIT(dwarf_first, world.file2list("strings/names/dwarf_first.txt")) //Textfiles with first
GLOBAL_LIST_INIT(dwarf_last, world.file2list("strings/names/dwarf_last.txt")) //textfiles with last

/*
@author:JTGSZ
The lost dwarves make a return in early NT history.
Some say their main colony died on lavaland in the present timeline, causing them to never to be seen again.
They are manlets, resistant to the environment and everything else, strong.
Immensely slow due to the short legs, a moderate career selection.
But alas, they have a crippling addiction to alcohol thanks to a gland contained within them.
An accompanying Liver is there so they don't die to their liquid potential and curse.
It both fuels them to greater heights and hinders them immensely even causing death.
They also loathe filth, especially their own filth, as it too can cause death.
Thus embarks the doomed race of dwarven gland engineers into space.
*/


/datum/species/dwarf //not to be confused with the genetic manlets
	name = "Dwarf"
	id = "dwarf" //Also called Homo sapiens pumilionis
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,NO_UNDERWEAR)
	//they can grab burning objects and get hurt, and jump straight to aggro grab.
	inherent_traits = list(TRAIT_RESISTHEATHANDS,TRAIT_STRONG_GRABBER) 
	default_features = list("mcolor" = "FFF", "wings" = "None")
	limbs_id = "human"
	use_skintones = 1
	say_mod = "bellows" //high energy, EXTRA BIOLOGICAL FUEL
	damage_overlay_type = "human" 
	skinned_type = /obj/item/stack/sheet/animalhide/human
	liked_food = ALCOHOL | MEAT | DAIRY //Dwarves like alcohol, meat, and dairy products.
	disliked_food = JUNKFOOD | FRIED //Dwarves hate foods that have no nutrition other than alcohol.
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | WABBAJACK
	brutemod = 0.85 //Take slightly less damage than a human.
	burnmod = 0.85 //Less laser damage too.
	coldmod = 0.5 //Handle cold better too, but not their forte in life.
	heatmod = 0.3 //Of course heat also, resistant thanks to being dwarves but not invulnerable.
	speedmod = 1.5 //Slower than a human who is at a base of 0, short legs slowest race.
	punchdamagelow = 2 // Their min roll is 1 higher than a base human
	punchdamagehigh = 12 //They do more damage and have a higher chance to stunpunch since its at 10.
	mutanteyes = /obj/item/organ/eyes/night_vision //And they have night vision.
	mutant_organs = list(/obj/item/organ/dwarfgland) //Dwarven alcohol gland, literal gland warrior
	mutantliver = /obj/item/organ/liver/dwarf //Dwarven super liver (Otherwise they r doomed)
	
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
		OFFSET_HAIR = list(0,0), 
		OFFSET_FHAIR = list(0,0), 
		OFFSET_EYES = list(0,0),
		OFFSET_LIPS = list(0,0),
		OFFSET_BELT = list(0,0), 
		OFFSET_BACK = list(0,0), 
		OFFSET_SUIT = list(0,0), 
		OFFSET_NECK = list(0,0),
		OFFSET_MUTPARTS = list(0,0)
		)

/mob/living/carbon/human/species/dwarf //species admin spawn path
	race = /datum/species/dwarf //and the race the path is set to.

//Filters out the species from taking these jobs in the job selection.
/datum/species/dwarf/qualifies_for_rank(rank, list/features)
	if(rank in GLOB.command_positions) //no dwarves in command
		return 0
	if(rank in GLOB.medical_positions) //no dwarves in medical
		return 0
	if(rank in GLOB.science_positions) //and no dwarves in science
		return 0
	return 1 //Otherwise you can enjoy being security, engineering, or service.

/datum/species/dwarf/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	var/dwarf_hair = pick("Beard (Dwarf)", "Beard (Very Long)", "Beard (Moonshiner)") //beard roullette
	var/mob/living/carbon/human/H = C 
	H.facial_hair_style = dwarf_hair
	H.update_hair()
	H.transform = H.transform.Scale(1, 0.8) //We use scale, and yeah. Dwarves can become gnomes with DWARFISM.
	RegisterSignal(C, COMSIG_MOB_SAY, .proc/handle_speech) //We register handle_speech is being used.


/datum/species/dwarf/on_species_loss(mob/living/carbon/H, datum/species/new_species)
	. = ..()
	H.transform = H.transform.Scale(1, 1.25) //And we undo it.
	UnregisterSignal(H, COMSIG_MOB_SAY) //We register handle_speech is not being used.

//Dwarf Name stuff
/proc/dwarf_name() //hello caller: my name is urist mcuristurister
	return "[pick(GLOB.dwarf_first)] [pick(GLOB.dwarf_last)]"

/datum/species/dwarf/random_name(gender,unique,lastname)
	return dwarf_name() //hello, ill return the value from dwarf_name proc to you when called.

//Dwarf Speech handling - Basically a filter/forces them to say things. The IC helper
/datum/species/dwarf/proc/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]" //Credits to goonstation for the strings list.
		var/list/dwarf_words = strings("dwarf_replacement.json", "dwarf") //thanks to regex too.

		for(var/key in dwarf_words) //Theres like 1459 words or something man.
			var/value = dwarf_words[key] //Thus they will always be in character.
			if(islist(value)) //Whether they like it or not.
				value = pick(value) //This could be drastically reduced if needed though.

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]") //Also its scottish.

		if(prob(3))
			message += pick(" By Armok!")
	speech_args[SPEECH_MESSAGE] = trim(message)

//This mostly exists because my testdwarf's liver died while trying to also not die due to no alcohol.
/obj/item/organ/liver/dwarf
	name = "dwarf liver"
	icon_state = "liver"
	desc = "A dwarven liver, theres something magical about seeing one of these up close."
	alcohol_tolerance = 0 //dwarves really shouldn't be dying to alcohol.
	toxTolerance = 5 //Shrugs off 5 units of toxins damage.
	maxHealth = 150 //More health than the average liver, as you aren't going to be replacing this.
	//If it does need replaced with a standard human liver, prepare for hell.

/obj/item/organ/dwarfgland //alcohol gland
	name = "dwarf alcohol gland"
	icon_state = "plasma" //Yes this is a actual icon in icons/obj/surgery.dmi
	desc = "A genetically engineered gland which is hopefully a step forward for humanity."
	w_class = WEIGHT_CLASS_NORMAL
	var/stored_alcohol = 250 //They start with 250 units, that ticks down and eventaully bad effects occur
	var/max_alcohol = 500 //Max they can attain, easier than you think to OD on alcohol.
	var/heal_rate = 0.5 //The rate they heal damages over 400 alcohol stored
	var/alcohol_rate = 10 //Its times 0.025 making it tick down by .25 per loop.

/obj/item/organ/dwarfgland/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("ethanol", stored_alcohol/10)
	return S

/obj/item/organ/dwarfgland/on_life()
	if(!owner?.client || !owner?.mind) 
		return //Let's not waste resources on AFK players
	//Filth Reactions - Since miasma now exists
	var/filth_counter = 0
	for(var/fuck in view(owner,7)) //hello byond for view loop, luckily its a custom organ.
		if(istype(fuck, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = fuck
			if(H.stat == DEAD)
				filth_counter += 10
		if(istype(fuck, /obj/effect/decal/cleanable/blood))
			if(istype(fuck, /obj/effect/decal/cleanable/blood/gibs))
				filth_counter += 1
			else
				filth_counter += 0.1
		if(istype(fuck,/obj/effect/decal/cleanable/vomit)) //They are disgusted by their own vomit too.
			filth_counter += 10 //Dwarves could technically chainstun each other in a vomit tantrum spiral.
	switch(filth_counter)
		if(11 to 25)
			if(prob(5))
				to_chat(owner, "<span class = 'danger'>Someone should really clean up in here!</span>")
		if(26 to 50)
			if(prob(10)) //Probability the message appears
				to_chat(owner, "<span class = 'danger'>The stench makes you queasy.</span>")
				if(prob(20)) //And then the probability they vomit along with it.
					owner.vomit(20) //I think vomit should stay over a disgust adjustment.
		if(51 to 75)
			if(prob(10))
				to_chat(owner, "<span class = 'danger'>By Armok! You won't be able to keep alcohol down at all!</span>")
				if(prob(25))
					owner.vomit(20) //Its more funny
		if(76 to 100)
			if(prob(10))
				to_chat(owner, "<span class = 'userdanger'>You can't live in such FILTH!</span>")
				if(prob(25))
					owner.adjustToxLoss(10) //Now they start dying.
					owner.vomit(20)

	// BOOZE HANDLING
	for(var/datum/reagent/R in owner.reagents.reagent_list)
		if(istype(R, /datum/reagent/consumable/ethanol))
			var/datum/reagent/consumable/ethanol/E = R
			stored_alcohol += (E.boozepwr / 50)
			if(stored_alcohol > max_alcohol) //Dwarves technically start at 250 alcohol stored.
				stored_alcohol = max_alcohol
	var/heal_amt = heal_rate
	stored_alcohol -= alcohol_rate * 0.025 //The rate it decreases from the gland
	if(stored_alcohol > 400) //If they are over 400 they start regenerating
		owner.adjustBruteLoss(-heal_amt) //But its alcohol, there will be other issues here.
		owner.adjustFireLoss(-heal_amt) //Unless they drink casually all the time.
		owner.adjustOxyLoss(-heal_amt)
		owner.adjustCloneLoss(-heal_amt)
		owner.adjustBrainLoss(-heal_amt) //Mostly because my dwarf was becoming retarded from alcohol.
	if(prob(5))
		switch(stored_alcohol)
			if(0 to 24)
				to_chat(owner, "<span class='userdanger'>DAMNATION INCARNATE, WHY AM I CURSED WITH THIS DRY-SPELL? I MUST DRINK.</span>")
				owner.adjustToxLoss(35)
			if(25 to 50)
				to_chat(owner, "<span class='danger'>Oh DAMN, I need some brew!</span>")
			if(51 to 75)
				to_chat(owner, "<span class='warning'>Your body aches, you need to get ahold of some booze...</span>")
			if(76 to 100)
				to_chat(owner, "<span class='notice'>A pint of anything would really hit the spot right now.</span>")
			if(101 to 150)
				to_chat(owner, "<span class='notice'>You feel like you could use a good brew.</span>")
