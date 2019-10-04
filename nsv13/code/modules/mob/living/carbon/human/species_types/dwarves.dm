#define isdwarf(A) (is_species(A, /datum/species/dwarf))

GLOBAL_LIST_INIT(dwarf_first, world.file2list("strings/names/dwarf_first.txt"))
GLOBAL_LIST_INIT(dwarf_last, world.file2list("strings/names/dwarf_last.txt"))

//These guys have double the life-span of a human.
//They also feel really familiar, due to the fact they are close to being a basic midget.
//Regardless, they are hardy, industrious, and clearly capable of engineering.

//lavaland dwarves make a return, in the form of space dwarves. FULL CIRCLE MOTHERFUCKER
/datum/species/dwarf //not to be confused with the genetic manlets
	name = "Dwarf"
	id = "dwarf" //Also called Homo sapiens pumilionis
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,NO_UNDERWEAR)
	//Their livers won't fail, they can grab burning objects and get hurt, and jump straight to aggro grab.
	inherent_traits = list(TRAIT_STABLELIVER,TRAIT_RESISTHEATHANDS,TRAIT_STRONG_GRABBER) 
	default_features = list("mcolor" = "FFF", "wings" = "None")
	limbs_id = "human"
	use_skintones = 1
	damage_overlay_type = "human" //fits surprisngly well, so why add more icons?
	skinned_type = /obj/item/stack/sheet/animalhide/human
	liked_food = ALCOHOL | MEAT | DAIRY //Dwarves like alcohol, meat, and dairy products.
	disliked_food = JUNKFOOD | FRIED //Dwarves hate foods that have no nutrition other than alcohol.
	brutemod = 0.85 //Take slightly less damage than a human.
	burnmod = 0.85 //Less laser damage too.
	coldmod = 0.5 //Handle cold better too, but not their forte in life.
	heatmod = 0.3 //Of course heat also, resistant thanks to being dwarves but not invulnerable.
	speedmod = 1.5 //Slower than a human who is at a base of 0, short legs slowest race.
	punchdamagelow = 2 // Their min roll is 1 higher than a base human
	punchdamagehigh = 14 //They do more damage and have a higher chance to stunpunch since its at 10.
	mutanteyes = /obj/item/organ/eyes/night_vision //And they have night vision.
	mutantstomach = /obj/item/organ/stomach/dwarf //Dwarven Alcohol Vessel
	
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
		OFFSET_FACE = list(0,0), 
		OFFSET_BELT = list(0,0), 
		OFFSET_BACK = list(0,0), 
		OFFSET_SUIT = list(0,0), 
		OFFSET_NECK = list(0,0)
		)

/mob/living/carbon/human/species/dwarf //species spawn path
	race = /datum/species/dwarf //and the race the path is set to.

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
	H.transform = H.transform.Scale(1, 0.8) //We use scale.

	var/obj/item/organ/stomach/dwarf/dwarf //The dwarven alcohol organ
	dwarf = H.getorganslot(ORGAN_SLOT_STOMACH) //We get it
	if(!dwarf) //If its not there
		dwarf = new()
		dwarf.Insert(H) //We insert it

/datum/species/dwarf/on_species_loss(mob/living/carbon/H, datum/species/new_species)
	. = ..()
	H.transform = H.transform.Scale(1, 1.25) //And we undo it.


//Dwarf Name stuff
/proc/dwarf_name() //hello caller: my name is urist mcuristurister
	return "[pick(GLOB.dwarf_first)] [pick(GLOB.dwarf_last)]"

/datum/species/dwarf/random_name(gender,unique,lastname)
	return dwarf_name() //hello, ill return the value from dwarf_name proc to you when called.

/obj/item/organ/stomach/dwarf //alcohol stomach
	name = "dwarven stomach"
	icon_state = "plasma"
	w_class = WEIGHT_CLASS_NORMAL
	var/stored_alcohol = 250
	var/max_alcohol = 500
	var/heal_rate = 0.5
	var/alcohol_rate = 10
	var/cooldown = 35
	var/current_cooldown = 0

/obj/item/organ/stomach/dwarf/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("ethanol", stored_alcohol/10)
	return S


/obj/item/organ/stomach/dwarf/on_life()
	// Filth Handling - Since miasma now exists - This would be way more reactive anyways
	var/filth_counter = 0
	for(var/fuck in view(owner,7)) //Downsides, shitty byond view proc
		if(istype(fuck, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = fuck
			if(H.stat == DEAD)
				filth_counter += 10
		if(istype(fuck, /obj/effect/decal/cleanable/blood))
			if(istype(fuck, /obj/effect/decal/cleanable/blood/gibs))
				filth_counter += 1
			else
				filth_counter += 0.1
	switch(filth_counter)
		if(11 to 25)
			if(prob(5))
				to_chat(owner, "<span class = 'danger'>Someone should really clean up in here!</span>")
		if(26 to 50)
			if(prob(10))
				to_chat(owner, "<span class = 'danger'>The stench makes you queasy.</span>")
				if(prob(20))
					owner.vomit(20)
		if(51 to 75)
			if(prob(15))
				to_chat(owner, "<span class = 'danger'>By Sol! You won't be able to keep alcohol down at all!</span>")
				if(prob(25))
					owner.vomit(20)
		if(76 to 100)
			if(prob(25))
				to_chat(owner, "<span class = 'userdanger'>You can't live in such FILTH!</span>")
				if(prob(35))
					owner.adjustToxLoss(10)
					owner.vomit(20)

	// BOOZE HANDLING
	for(var/datum/reagent/R in owner.reagents.reagent_list)
		if(istype(R, /datum/reagent/consumable/ethanol))
			var/datum/reagent/consumable/ethanol/E = R
			stored_alcohol += (E.boozepwr / 50)
			if(stored_alcohol > max_alcohol)
				stored_alcohol = max_alcohol
	var/heal_amt = heal_rate
	stored_alcohol -= alcohol_rate * 0.025
	if(stored_alcohol > 400)
		owner.adjustBruteLoss(-heal_amt)
		owner.adjustFireLoss(-heal_amt)
		owner.adjustOxyLoss(-heal_amt)
		owner.adjustCloneLoss(-heal_amt)
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