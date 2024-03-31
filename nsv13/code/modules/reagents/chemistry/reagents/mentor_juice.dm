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
	chem_flags = CHEMICAL_RNG_FUN|CHEMICAL_GOAL_CHEMIST_BLOODSTREAM|CHEMICAL_GOAL_CHEMIST_DRUG
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
				var/list/seen = oview(7, M) //Sound and sight checkers
				for(var/victim in seen)
					if(isanimal(victim) || !isliving(victim))
						seen -= victim
				if(LAZYLEN(seen))
					to_chat(M, "You notice [pick(seen)]'s bulge [pick("OwO!", "uwu!")]")
		if(16)
			T = M.getorganslot(ORGAN_SLOT_TONGUE)
			if(!istype(T, /obj/item/organ/tongue/fluffy))
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
				var/list/seen = oview(7, M)//Sound and sight checkers
				for(var/victim in seen)
					if(isanimal(victim) || !isliving(victim))
						seen -= victim
				if(LAZYLEN(seen))
					to_chat(M, "You notice [pick(seen)]'s bulge [pick("OwO!", "uwu!")]")
	..()

/datum/reagent/furranium/on_mob_delete(mob/living/carbon/M)
	if(current_cycle < 45 && T) //Better get that out of you quick!
		nT = M.getorganslot(ORGAN_SLOT_TONGUE)
		nT.Remove(M)
		qdel(nT)
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


//My escape from this madness
/datum/emote/living/weh
	key = "weh"
	key_third_person = "lets out a weh"
	message = "lets out a weh!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/weh/can_run_emote(mob/user, status_check = TRUE, intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(intentional && !istype(C.getorganslot(ORGAN_SLOT_TONGUE), /obj/item/organ/tongue/fluffy) && !islizard(C))
			return FALSE
		return !C.silent

/datum/emote/living/weh/get_sound(mob/living/user)
	return 'nsv13/sound/voice/cursed/weh.ogg'


//On today's menu, bioweapons.

/obj/item/projectile/guided_munition/torpedo/biohazard_one
	relay_projectile_type = /obj/item/projectile/bullet/delayed_prime/relayed_biohazard_torpedo/one
	damage = 150
	obj_integrity = 80
	max_integrity = 80

/obj/item/projectile/guided_munition/torpedo/biohazard_two
	relay_projectile_type = /obj/item/projectile/bullet/delayed_prime/relayed_biohazard_torpedo/two
	damage = 150
	obj_integrity = 80
	max_integrity = 80

/obj/item/projectile/bullet/delayed_prime/relayed_biohazard_torpedo
	icon_state = "torpedo"
	name = "torpedo"
	penetration_fuze = 3
	damage = 25
	var/decal_type = null

/obj/item/projectile/bullet/delayed_prime/relayed_biohazard_torpedo/fuze_trigger_value(atom/target)
	if(isclosedturf(target))
		return 1
	return 0

/obj/item/projectile/bullet/delayed_prime/relayed_biohazard_torpedo/is_valid_to_release(atom/newloc)
	if(penetration_fuze > 0 || !isopenturf(newloc))
		return FALSE
	return TRUE

/obj/item/projectile/bullet/delayed_prime/relayed_biohazard_torpedo/one
	decal_type = /obj/effect/decal/cleanable/blood/infected

/obj/item/projectile/bullet/delayed_prime/relayed_biohazard_torpedo/two
	decal_type = /obj/effect/decal/cleanable/greenglow/fun_trust_me

/obj/item/projectile/bullet/delayed_prime/relayed_biohazard_torpedo/release_payload(atom/detonation_location)
	var/turf/detonation_turf = get_turf(detonation_location)
	explosion(detonation_turf, 0, 0, 5, 8)
	var/list/inrange_turfs = RANGE_TURFS(4, detonation_turf)
	for(var/turf/T as() in inrange_turfs)
		if(isgroundlessturf(T))	//Should those kinds of turfs be able to get waste from this? Hmm, I dunno.
			continue
		if(isclosedturf(T) || is_blocked_turf(T, TRUE))	//Definitely not on closed turfs, for now also not on ones blocked by stuff to not make it agonizing.. unless?
			continue
		if(locate(decal_type) in T)	//No stacking.
			continue
		if(!prob(70))
			continue
		new decal_type(T)

/obj/effect/decal/cleanable/blood/infected

/obj/effect/decal/cleanable/blood/infected/Initialize(mapload, list/datum/disease/diseases)
	var/datum/disease/pain = new /datum/disease/transformation/felinid/contagious/bioweapon()
	. = ..(mapload, list(pain)) //We love dreammaker.

/obj/effect/decal/cleanable/blood/infected/ex_act(severity, target)
	if(severity != EXPLODE_DEVASTATE)
		return
	qdel(src)

/datum/disease/transformation/felinid/contagious/bioweapon
	name = "Unshackled Nano-Feline Assimilative Toxoplasmosis"
	spread_text = "On contact, Bloodborne"
	stage_prob = 3
	spread_flags = DISEASE_SPREAD_BLOOD|DISEASE_SPREAD_CONTACT_FLUIDS|DISEASE_SPREAD_CONTACT_SKIN
	bypasses_immunity = TRUE //Nyanomachines, son.
	is_mutagenic = TRUE

/obj/effect/decal/cleanable/greenglow/fun_trust_me

/obj/effect/decal/cleanable/greenglow/fun_trust_me/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	reagents.add_reagent(/datum/reagent/furranium, 25)

//Override
/obj/effect/decal/cleanable/greenglow/fun_trust_me/on_entered(datum/source, atom/movable/AM)
	if(!iscarbon(AM))
		return
	var/mob/living/carbon/C = AM
	reagents.trans_to(C, 1, 5, method = TOUCH, round_robin = TRUE)

/obj/effect/decal/cleanable/greenglow/fun_trust_me/ex_act(severity, target)
	if(severity != EXPLODE_DEVASTATE)
		return
	qdel(src)
