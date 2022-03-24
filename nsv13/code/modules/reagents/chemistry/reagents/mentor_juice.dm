////////////////////////////////////////////////////////////////////////////////////////////////////
//										FURRANIUM
///////////////////////////////////////////////////////////////////////////////////////////////////
//OwO whats this?
//Makes you nya and awoo
//At a certain amount of time in your system it gives you a fluffy tongue, if in your system long enough, it's permanent.

/datum/chemical_reaction/furranium
	name = "Furranium"
	id = /datum/reagent/furranium
	results = list(/datum/reagent/furranium = 5)
	required_reagents = list(/datum/reagent/uranium = 1, /datum/reagent/toxin/mutagen = 1, /datum/reagent/silver = 2, /datum/reagent/medicine/salglu_solution = 1)
	required_temp = 666
	mix_message = "You think you can hear a howl come from the liquid."

/datum/reagent/furranium
	name = "Furranium"
	description = "OwO whats this?"
	color = "#f9b9bc" // rgb: 98, 73, 74
	taste_description = "dewicious degenyewacy"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	var/obj/item/organ/tongue/nT
	var/obj/item/organ/tongue/T
	can_synth = TRUE
	var/old_sayverb

/datum/reagent/furranium/reaction_mob(mob/living/carbon/human/M, method=INJECT, reac_volume)
	if(method == INJECT)
		var/turf/T = get_turf(M)
		M.adjustOxyLoss(15)
		M.Knockdown(50)
		M.Stun(50)
		M.emote("cough")
		var/plush_type = pick(subtypesof(/obj/item/toy/plush))
		var/obj/item/toy/plush/P = new plush_type(T)
		M.visible_message("<span class='warning'>[M] suddenly coughs up a [P.name]!</b></span>",\
						"<span class='warning'>You feel a lump form in your throat, as you suddenly cough up what feels like a hairball?</b></span>")
		var/T2 = get_random_station_turf()
		P.throw_at(T2, 8, 1)
	..()

/datum/reagent/furranium/on_mob_life(mob/living/carbon/M)
	switch(current_cycle)
		if(1 to 9)
			if(prob(20))
				to_chat(M, "<span class='notice'>Your tongue feels... fluffy</span>")
		if(10 to 15)
			if(prob(10))
				to_chat(M, "You find yourself unable to suppress the desire to meow!")
				M.emote("nya", intentional = FALSE)
			if(prob(10))
				to_chat(M, "You find yourself unable to suppress the desire to howl!")
				M.emote("awoo", intentional = FALSE)
			if(prob(20))
				var/list/seen = view(7, M) - M //Sound and sight checkers
				for(var/victim in seen)
					if(isanimal(victim) || !isliving(victim))
						seen -= victim
				if(LAZYLEN(seen))
					to_chat(M, "You notice [pick(seen)]'s bulge [pick("OwO!", "uwu!")]")
		if(16)
			T = M.getorganslot(ORGAN_SLOT_TONGUE)
			var/obj/item/organ/tongue/nT = new /obj/item/organ/tongue/fluffy
			if(T)
				T.Remove(M)
				T.moveToNullspace()//To valhalla
			nT.Insert(M)
			to_chat(M, "<span class='big warning'>Your tongue feels... weally fwuffy!!</span>")
			old_sayverb = M.verb_say
			M.verb_say = "meows"
		if(17 to INFINITY)
			if(prob(5))
				to_chat(M, "You find yourself unable to suppress the desire to meow!")
				M.emote("nya", intentional = FALSE)
			if(prob(5))
				to_chat(M, "You find yourself unable to suppress the desire to howl!")
				M.emote("awoo", intentional = FALSE)
			if(prob(5))
				var/list/seen = view(7, M) - M //Sound and sight checkers
				for(var/victim in seen)
					if(isanimal(victim) || !isliving(victim))
						seen -= victim
				if(LAZYLEN(seen))
					to_chat(M, "You notice [pick(seen)]'s bulge [pick("OwO!", "uwu!")]")
	..()

/datum/reagent/furranium/on_mob_delete(mob/living/carbon/M)
	if(current_cycle < 45) //Better get that out of you quick!
		nT = M.getorganslot(ORGAN_SLOT_TONGUE)
		nT.Remove(M)
		qdel(nT)
		if(T)
			T.Insert(M)
		to_chat(M, "<span class='notice'>You feel your tongue.... unfluffify...?</span>")
		M.verb_say = old_sayverb
		M.say("Pleh!")
	else
		to_chat(M, "<spam class='warning'>You feel as if the condition of your tongue has become permanent...</span>")

/obj/item/organ/tongue/fluffy
	name = "fluffy tongue"
	desc = "OwO what's this?"
	icon = 'nsv13/icons/obj/tongue.dmi'
	icon_state = "tonguefluffy"
	taste_sensitivity = 10 // extra sensitive and inquisitive uwu
	maxHealth = 35 //Sensitive tongue!
	modifies_speech = TRUE

/obj/item/organ/tongue/fluffy/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = replacetext(message, "ne", "nye")
		message = replacetext(message, "nu", "nyu")
		message = replacetext(message, "na", "nya")
		message = replacetext(message, "no", "nyo")
		message = replacetext(message, "ove", "uv")
		message = replacetext(message, "l", "w")
		message = replacetext(message, "r", "w")
	speech_args[SPEECH_MESSAGE] = lowertext(message)

/datum/emote/living/nya
	key = "nya"
	key_third_person = "lets out a nya"
	message = "lets out a nya!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/nya/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(intentional && !istype(C.getorganslot(ORGAN_SLOT_TONGUE), /obj/item/organ/tongue/fluffy))
			return FALSE
		return !C.silent

/datum/emote/living/nya/get_sound(mob/living/user)
	return 'nsv13/sound/voice/cursed/nya.ogg'

/datum/emote/living/awoo
	key = "awoo"
	key_third_person = "lets out an awoo"
	message = "lets out an awoo!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/awoo/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(intentional && !istype(C.getorganslot(ORGAN_SLOT_TONGUE), /obj/item/organ/tongue/fluffy))
			return FALSE
		return !C.silent

/datum/emote/living/awoo/get_sound(mob/living/user)
	return 'nsv13/sound/voice/cursed/awoo.ogg'
