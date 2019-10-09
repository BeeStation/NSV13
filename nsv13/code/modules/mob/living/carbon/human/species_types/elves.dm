// ----- Outside Code segments relating to Elf Species -----

//code__DEFINES/mobs.dm - extra icon rendering OFFSET defines
//code/modules/mob/living/carbon/human/species.dm - extra offsets

// ----- Icon Files -----

//nsv13/icons/mob/mutantbodyparts.dmi - sprite_accessory MOB elf ears
//nsv13/icons/obj/surgery.dmi - sprite_accessory OBJ elf ears
//nsv13/icons/mob/actions/actionbuttonicons.dmi - drainmood spell symbol icon

// ----- Sound files -----

//nsv13/sound/effects/realitywhoosh.ogg - Probability Mood modifier dodge sound

GLOBAL_LIST_INIT(elf_first, world.file2list("strings/names/elf_first.txt")) //Text files with first
GLOBAL_LIST_INIT(elf_last, world.file2list("strings/names/elf_first.txt")) //And last names

/*
@author:JTGSZ
Elves arrive with the other close members of humanity.
They are frail, capable of literally burning to death in 7 or so seconds.
They also can feed off the mood/sanity of everyone around them.
Gaining faster reflexes if they maintain high mood levels, sanity and mood feats.
They also enjoy the taste of human flesh, some say they are a ancestor to the present-day vampire.
Thanks to extreme nepotism, and manipulation; they have no limit to their upward mobility.
*/


//These elves look... FAMILIAR
/datum/species/elf
	name = "Elf"
	id = "elf" //Also called Homo sapiens nobilis
	fixed_mut_color = "fcccb3" //Elves all come out perfectly caucasian2, as different colors of elves are other races.
	use_skintones = FALSE //Dark elves would cause too much crime.
	species_traits = list(MUTCOLORS,EYECOLOR,HAIR,LIPS) //No facial hair.
	mutant_bodyparts = list("ears") //Whats the difference between a human and a elf?
	default_features = list("ears" = "Elf") //Its the fuckin ears. Also luckily they can't pick cat ears.
	limbs_id = "human"
	liked_food = GROSS | RAW //Elves have a good time eating human organs.
	disliked_food = JUNKFOOD | FRIED //Mostly because they enjoy the taste of suffering.
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | WABBAJACK
	brutemod = 1.6 //They take greatly more damage, graceful not durable.
	burnmod = 1.5 //Lasers hurt worse too.
	heatmod = 1.5 //They also die in fires easier.
	speedmod = -0.2 //slightly faster than a human who is at a base of 0
	coldmod = 1.5 //And space... space definitely hurts them almost twice as bad. Clearly better not in it.
	punchdamagelow = 1
	punchdamagehigh = 8//their punches are weaker
	punchstunthreshold = 8 //Because its the maximum here. They should be able to still critical hit.
	skinned_type = /obj/item/stack/sheet/animalhide/human
	mutantears = /obj/item/organ/ears/elf //yep.

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

/mob/living/carbon/human/species/elf //species admin spawn path
	race = /datum/species/elf

//Elf Name shit
/proc/elf_name() //The elves don't care about gender being elves.
	return "[pick(GLOB.elf_first)] [pick(GLOB.elf_last)]" //We just pick from both to form one name.

/datum/species/elf/random_name(gender,unique,lastname)
	return elf_name() //and the proc calls upon the above proc and returns the value from the global lists.

//Filters out the species from taking these jobs in the job selection.
/datum/species/elf/qualifies_for_rank(rank, list/features)
	return TRUE //Elves qualify for everything.

//Handles Mood bullet time dodging, considering a elf might go into crit from one to three bullets this feels ok
/datum/species/elf/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	var/datum/component/mood/mood = H.GetComponent(/datum/component/mood)
	if(mood && mood.sanity >= SANITY_GREAT) //If their mood has been maintained...
		if(prob(50)) //They have a probability to dodge bullets with sheer speed.
			H.visible_message("<span class='danger'>[H] twists at a speed defying reality avoiding [P]!</span>")
			playsound(H.loc, 'nsv13/sound/effects/realitywhoosh.ogg', 75, 1) //Still going to nearly kill them if not tho
			return BULLET_ACT_FORCE_PIERCE //The bullet should pass on by.
			if(prob(50)) //Probability of mood drain or boost after success roll.
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "probdodgeplus", /datum/mood_event/probdodgeplus)
			else //Ironically this resembles a sanity & mood based magic system, neat huh.
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "probdodgenegative", /datum/mood_event/probdodgenegative)
	return ..() //Fleshed out, it'd be beyond a good rp element as overuse leads to insanity unless...
//people who act selfish, hedonistically in character boosting mood drawing from a greater pool.

//Elf species on gain n shiet
/datum/species/elf/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()

	if(ishuman(C)) //two chunks of copy and pasted code. thanks felinids
		var/mob/living/carbon/human/H = C 
		if(H.dna.features["ears"] == "Elf") //This inserts a object into the mob
			var/obj/item/organ/ears/elf/ears = new //Technically the dna is handled on the organ obj too.
			ears.Insert(H, drop_if_replaced = FALSE) 
		else
			mutantears = /obj/item/organ/ears

		if(C?.client?.prefs.real_name == C?.real_name) //Random name if this isnt their chosen name
			return
		if(C.client.prefs.real_name == C.real_name) //Random name if this isnt their chosen name
			return
	var/new_name = random_name()
	C.real_name = new_name
	C.name = new_name

	RegisterSignal(C, COMSIG_MOB_SAY, .proc/handle_speech) //We register handle_speech is being used.

	C.faction |= "Trees" //A faction of trees.

//Elf species on loss n shiet
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
	
	UnregisterSignal(H, COMSIG_MOB_SAY) //We register handle_speech is not being used.

	H.faction -= "Trees" //Bye tree faction

//Elf Speech handling - Basically a filter/forces them to say things. The IC helper
/datum/species/elf/proc/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = " [message] "
		message = replacetext(message," syndicate "," insurrectionists ") //WHY NOT.
		message = replacetext(message," nanotrasen ", " glorious nanotrasen ") //Can't think of more atm.
		message = replacetext(message," ork ", " trog ") //Oh wait yes i can
		message = replacetext(message," orc ", " trog ")
		message = replacetext(message," troll ", " trog ")
		message = replacetext(message," dwarf ", " squat ")
		message = replacetext(message," lizard ", " lower-lifeform ")
		message = replacetext(message," plasmaman ", " flaming buffoon ")

		if(prob(2))
			message += pick("Gaze upon the future.")
		speech_args[SPEECH_MESSAGE] = trim(message)

//The fucking thing it draws onto the elf, holy fuck fuck this dumb shit.
/datum/sprite_accessory/ears/elf
	name = "Elf"
	icon_state = "elf"
	color_src = MUTCOLORS //Their color is handled thru mutantcolor, which is currently fixed.
	icon = 'nsv13/icons/mob/mutantbodyparts.dmi'

//gay elf ears
/obj/item/organ/ears/elf
	name = "elf ears" // They only come in one color ok?
	desc = "The torn ears off a elf metahuman variant."
	icon = 'nsv13/icons/obj/surgery.dmi' //obj icon when removed, made in 5 mins.
	icon_state = "elf" //and their state, handled classic style aka it uses statename to assess handling.
	damage_multiplier = 2 // And they take more hearing damage.
	var/obj/effect/proc_holder/spell/targeted/drainmood/drainmood //Technically putting ears on grants you this.

//We grant elven dna on insertion
/obj/item/organ/ears/elf/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		H.dna.species.mutant_bodyparts |= "ears"
		H.dna.features["ears"] = "Elf" //Funny how the dna setting part is here huh.
		H.update_body()
	var/obj/effect/proc_holder/spell/targeted/drainmood/DM = new //My DM coding effects on ur mood realized
	H.AddSpell(DM)
	drainmood = DM

//And we take it away on removal
/obj/item/organ/ears/elf/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	if(istype(H))
		H.dna.features["ears"] = "None"
		H.dna.species.mutant_bodyparts -= "ears"
		H.update_body()
	if(drainmood)
		H.RemoveSpell(drainmood)

//The gimmick of draining moods out around you.
/obj/effect/proc_holder/spell/targeted/drainmood //You could say they are emotional vampires.
	name = "Drain Mood"
	desc = "The magical ability to drain any moods around you."

	school = "evocation" //THE POWERFUL SCHOOL OF EVOCATION
	charge_max = 300 //The CD in deciseconds, so should be 30.
	clothes_req = FALSE //No wizard clothes required, only pointy ass ears
	invocation_emote_self = "<span class='notice'>You drain the emotions from everyone around you.</span>"//Self text
	invocation_type = "emote" //We say its a emote, alas theres no way to get user in this holder.
	max_targets = 0 //Everyone 2 turfs in our range is now in a bad mood. 0 = unlimited targets
	range = 2 //Grand range of two
	action_icon = 'nsv13/icons/mob/actions/actionbuttonicons.dmi' //Custom icon
	action_icon_state = "drainmood" //I CAST DRAIN MOOD
	action_background_icon_state = "bg_demon" //simply demonic

//What occurs on cast. You aren't going to abuse this on braindeads or other lesser creatures.
/obj/effect/proc_holder/spell/targeted/drainmood/cast(list/targets, mob/living/user = usr)
	for(var/mob/living/carbon/human/H in targets)
		if(!H.mind)
			continue //This only fires if you actually effect people anyways so no free moodboosts.
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "drainmoodreceiver", /datum/mood_event/drainmoodreceiver)
		SEND_SIGNAL(usr, COMSIG_ADD_MOOD_EVENT, "drainmoodtaker", /datum/mood_event/drainmoodtaker)

//We click it and the invocation is set, grabbing usr for the emote name
/obj/effect/proc_holder/spell/targeted/drainmood/Click()
	if(usr && usr.mind)
		invocation = "<B>[usr.real_name]</B> openly sneers with disdain." //Grabs the users name.
	..() //Otherwise there would be no good clues as to why the moods shifted.


//Elf Sanity and mood power system drains and boost values.
/datum/mood_event/drainmoodreceiver //Target of drainmood
	description = "<span class='warning'>Why do I suddenly feel so bad?</span>\n"
	mood_change = -5 //Only the elf is in on the joke.
	timeout = 6 MINUTES //The crew shouldn't like this one too much.

/datum/mood_event/drainmoodtaker //User of drainmood
	description = "<span class='nicegreen'>So many strong emotions... A true feast!</span>\n"
	mood_change = 5 //Lasts vastly less, due to them gaining a probability to dodge projectiles.
	timeout = 1 MINUTES //In combination with other moodboosts that is.

/datum/mood_event/probdodgeplus //Dodge after-effect boost
	description = "<span class='nicegreen'>AHAHAHA! I'm AMAZING, I FEEL AMAZING, NOTHING WILL STOP ME!</span>\n"
	mood_change = 10 //Success roll, riding the motherfuckin lightning to hell and back.
	timeout = 1 MINUTES //Highs last way less long

/datum/mood_event/probdodgenegative //Dodge after-effect negative
	description = "<span class='warning'>I could have died to that bullet....</span>\n"
	mood_change = -10 //Failure roll, fragility of life is pushing back in, for the short time they stay alive.
	timeout = 5 MINUTES //Life lessons stay with you a while
