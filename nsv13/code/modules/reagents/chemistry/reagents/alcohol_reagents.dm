/datum/reagent/consumable/ethanol/gender_fluid
	name = "Gender Fluid"
	description = "This fluid seems to defy genetics, the mere act of looking at it makes you question your gender."
	color = "#eebc17"
	boozepwr = -50 //Changing ones gender rampantly is one hell of a shock to the system I'd say.
	taste_description = "fluidic gender"
	glass_icon_state = "gender_fluid"
	glass_name = "glass of Gender Fluid"
	glass_desc = "Recordkeepers nightmare"
	var/gender = null
	var/trans_boundry = 5

/datum/reagent/consumable/ethanol/gender_fluid/on_mob_add(mob/living/carbon/L)
	gender = L.gender
	return ..()

/datum/reagent/consumable/ethanol/gender_fluid/on_mob_life(mob/living/carbon/M)
	if(current_cycle == trans_boundry)
		if(M.gender == MALE)
			if(CheckSignal(M, COMSIG_MOB_SAY))
				UnregisterSignal(M, COMSIG_MOB_SAY)
				M.dna.add_mutation(CHAV) //FOR THE QUEEN
			M.gender = FEMALE //UwU
			M.visible_message("<span class='boldnotice'>[M] suddenly looks more feminine!</span>", "<span class='boldwarning'>You suddenly feel more feminine!</span>")
		else
			if(!(CheckSignal(M, COMSIG_MOB_SAY)))
				if(M.dna.check_mutation(CHAV))
					M.dna.remove_mutation(CHAV)
				RegisterSignal(M, COMSIG_MOB_SAY, .proc/handle_owo_speech)
			M.gender = MALE //OwO
			M.visible_message("<span class='boldnotice'>[M] suddenly looks more masculine!</span>", "<span class='boldwarning'>You suddenly feel more masculine!</span>")
		M.regenerate_icons()
		trans_boundry += 5
	..()

/datum/reagent/consumable/ethanol/gender_fluid/on_mob_end_metabolize(mob/living/carbon/human/M)
	M.gender = gender
	if(M.dna.check_mutation(CHAV) && CheckSignal(M, COMSIG_MOB_SAY))
		M.dna.remove_mutation(CHAV)
		UnregisterSignal(M, COMSIG_MOB_SAY)
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)
	M.visible_message("<span class='boldnotice'>[M] seems to have gotten over their gender confusion!</span>", "<span class='boldwarning'>Your head suddenly clears and you remember what you define yourself as!</span>")
	M.regenerate_icons()
	return ..()

/datum/reagent/consumable/ethanol/gender_fluid/proc/CheckSignal(datum/target, sig_type_or_types)
	var/list/lookup = target.comp_lookup
	if(!signal_procs || !signal_procs[target] || !lookup)
		return
	if(!islist(sig_type_or_types))
		sig_type_or_types = list(sig_type_or_types)
	for(var/sig in sig_type_or_types)
		if(!signal_procs[target][sig])
			continue
		if(lookup[sig] == src)
			return TRUE
	return FALSE

/datum/reagent/consumable/ethanol/gender_fluid/proc/handle_owo_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/whole_words = strings("owo_talk.json", "wowds")
		var/list/owo_sounds = strings("owo_talk.json", "sounds")

		for(var/key in whole_words)
			var/value = whole_words[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]")

		for(var/key in owo_sounds)
			var/value = owo_sounds[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, "[uppertext(key)]", "[uppertext(value)]")
			message = replacetextEx(message, "[capitalize(key)]", "[capitalize(value)]")
			message = replacetextEx(message, "[key]", "[value]")

		if(prob(3))
			message += pick(" Nya!"," Meow!"," OwO!!", " Nya-nya!")
	speech_args[SPEECH_MESSAGE] = trim(message)

/datum/reagent/consumable/ethanol/gender_bender
	name = "Gender Bender"
	description = "This fluid seems to defy genetics, a mere sip is enough to transform a person."
	color = "#eebc17"
	boozepwr = -50 //Changing ones gender rampantly is one hell of a shock to the system I'd say.
	taste_description = "gender confusion"
	glass_icon_state = "gender_bender"
	glass_name = "glass of Gender Bender"
	glass_desc = "A death sentence for Recordkeepers"

/datum/reagent/consumable/ethanol/gender_bender/on_mob_add(mob/living/carbon/L)
	switch(L.gender)
		if(MALE)
			L.gender = FEMALE
		if(FEMALE)
			L.gender = NEUTER
		if(NEUTER)
			L.gender = PLURAL
		else
			L.gender = MALE
	return ..()
