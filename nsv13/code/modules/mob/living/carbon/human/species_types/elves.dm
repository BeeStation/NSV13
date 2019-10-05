#define iself(A) (is_species(A, /datum/species/elf))

GLOBAL_LIST_INIT(elf_first, world.file2list("strings/names/elf_first.txt"))
GLOBAL_LIST_INIT(elf_last, world.file2list("strings/names/elf_first.txt"))

/*
@author:JTGSZ
Elves arrive with the other close members of humanity.
Some say they have been around a long time, somewhere, some place.
Regardless, they are frail, capable of literally burning to death in 5 seconds or so.
They also feed off the emotions of everyone around them.
A cruel joke only elves are innately aware of.
Emotions bring their agility closer to the realms of pure fantasy.
They also enjoy the taste of human flesh, some say they are a ancestor to the present-day vampire.
Nanotrasen mysteriously holds them in high regards though, as they have no limit to their upward mobility.
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

/datum/species/elf/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	var/datum/component/mood/mood = H.GetComponent(/datum/component/mood)
	if(mood && mood.sanity >= SANITY_GREAT) //If their mood has been maintained...
		if(prob(50)) //They have a probability to dodge bullets with sheer speed.
			H.visible_message("<span class='danger'>[H] twists at a speed defying reality avoiding [P]!</span>")
			playsound(H.loc, 'sound/weapons/fwoosh.ogg', 75, 1) //Still going to nearly kill them if not tho
			return BULLET_ACT_FORCE_PIERCE //The bullet should pass on by.
	return ..()

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
	damage_multiplier = 2 // And they take more hearing damage?
	var/obj/effect/proc_holder/spell/targeted/drainmood/drainmood

/obj/item/organ/ears/elf/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		H.dna.species.mutant_bodyparts |= "ears"
		H.dna.features["ears"] = "Elf" //Funny how the dna setting part is here huh.
		H.update_body()
	var/obj/effect/proc_holder/spell/targeted/drainmood/DM = new //DM's effects on ur mood realized
	H.AddSpell(DM)
	drainmood = DM

/obj/item/organ/ears/elf/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	if(istype(H))
		H.dna.features["ears"] = "None"
		H.dna.species.mutant_bodyparts -= "ears"
		H.update_body()
	if(drainmood)
		H.RemoveSpell(drainmood)

/obj/effect/proc_holder/spell/targeted/drainmood //You could say they are emotional vampires.
	name = "Drain Mood"
	desc = "The magical ability to drain any good moods around you."

	school = "evocation" //THE POWERFUL SCHOOL OF EVOCATION
	charge_max = 300 //The CD in deciseconds, so should be 30.
	clothes_req = FALSE //No wizard clothes required, only pointy ass ears
	invocation_emote_self = "<span class='notice'>You drain the emotions from everyone around you.</span>"//Self text
	invocation_type = "emote" //We say its a emote
	max_targets = 0 //Everyone 2 turfs in our range is now in a bad mood. 0 = unlimited targets
	range = 2 //Grand range of two
	action_icon = 'icons/mob/actions/actions_cult.dmi' //TODO: Set these
	action_icon_state = "sintouch" //TODO: Set these
	action_background_icon_state = "bg_demon" //TODO: Set these


/obj/effect/proc_holder/spell/targeted/drainmood/cast(list/targets, mob/living/user = usr)
	for(var/mob/living/carbon/human/H in targets)
		if(!H.mind)
			continue
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "drainmoodreceiver", /datum/mood_event/drainmoodreceiver)
		SEND_SIGNAL(usr, COMSIG_ADD_MOOD_EVENT, "drainmoodtaker", /datum/mood_event/drainmoodtaker)

/obj/effect/proc_holder/spell/targeted/drainmood/Click()
	if(usr && usr.mind)
		invocation = "<B>[usr.real_name]</B> openly sneers with disdain." //Grabs the users name.
	..() //Otherwise there would be no good clues as to why the moods shifted.

/datum/mood_event/drainmoodreceiver
	description = "<span class='warning'>Why do I suddenly feel so bad?</span>\n"
	mood_change = -5 //Only the elf is in on the joke.
	timeout = 6 MINUTES

/datum/mood_event/drainmoodtaker
	description = "<span class='nicegreen'>Draining their emotions makes me feel REAL fuckin' amazing.</span>\n"
	mood_change = 5
	timeout = 1 MINUTES //Lasts vastly less, due to them gaining a probability to dodge projectiles.