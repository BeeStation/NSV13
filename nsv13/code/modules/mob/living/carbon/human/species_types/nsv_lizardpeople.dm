//Modular NSV file for special stuff lizards have here.

//Modular type attachment.
/datum/species/lizard
	coldmod = 1 // Lizards here have exchanged their inherent damage modifier for them being cold-blooded.
	inherent_traits = list(TRAIT_COLDBLOODED) // The aforementioned coldbloodedness
	///Controls whether lizards use their muscles to generate additional heat if very cold.
	var/cold_stacks = 0
	///Stores if we already sent them a message & adjusted stuff.
	var/fibrillating = FALSE
	///Used to store whether the signal to adjust mood due to good temperatures has been updated.
	var/is_comfy = FALSE

//Another modular type attachment.
/datum/species/lizard/ashwalker
	inherent_traits = list(TRAIT_NOGUNS,TRAIT_NOBREATH, TRAIT_COLDBLOODED) //Ashwalkers are also coldblooded [we have no lavaland so I don't have to worry about if lavaland always gens with survivable temps :) ]

/datum/species/lizard/ectotherm_thermogenesis(mob/living/carbon/human/human_holder, use_temp_diff_range_check = TRUE)
	var/temp_diff = BODYTEMP_NORMAL - human_holder.bodytemperature
	switch(temp_diff)
		if(ECTOTHERM_THERMOGENESIS_CRIT_COLDNESS to INFINITY) //Being extremely cold quickly triggers thermogenesis.
			cold_stacks = min(cold_stacks + 3, LIZARD_ECTOTHERMISM_COLD_MAX_STACKS)
		if(ECTOTHERM_THERMOGENESIS_MIN_COLDNESS to ECTOTHERM_THERMOGENESIS_CRIT_COLDNESS)
			cold_stacks = min(cold_stacks + 1, LIZARD_ECTOTHERMISM_COLD_MAX_STACKS) //Basic cold takes some time to respond to.
		else
			cold_stacks = max(cold_stacks - 1, 0) //Takes a while to calm down muscles.

	if(cold_stacks < LIZARD_THERMOGENESIS_COLD_TRIGGER_STACKS && !fibrillating)
		return ECTOTHERM_NO_THERMOGENESIS_NEEDED
	if(!fibrillating) // !fibrillating reaching this point means enough stacks exist.
		to_chat(human_holder, "<span class='warning'>You start shivering and feel the urge to find a sunny spot!</span>")
		SEND_SIGNAL(human_holder, COMSIG_ADD_MOOD_EVENT, "lizard_shivers", /datum/mood_event/lizard_shivers)
		fibrillating = TRUE
	else if(cold_stacks == 0) //We also check if we have to stop vibrating here.
		to_chat(human_holder, "<span class='notice'>You stop shivering.</span>")
		SEND_SIGNAL(human_holder, COMSIG_CLEAR_MOOD_EVENT, "lizard_shivers")
		fibrillating = FALSE
		return ECTOTHERM_NO_THERMOGENESIS_NEEDED

	return ..(human_holder, FALSE) //We already use some fancy logic for our thermoregulation triggering so we don't use the normal temp difference check save for if we would get hot.

//Modular proc attachment
/datum/species/lizard/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load) //Human variable, named C. What did they mean by this?
	SEND_SIGNAL(C, COMSIG_CLEAR_MOOD_EVENT, "lizard_shivers") //Safely remove if our species is changed.
	SEND_SIGNAL(C, COMSIG_CLEAR_MOOD_EVENT, "comfy_liz_temp")
	return ..()

//Lizards are most comfortable between 30 and 60°C. Good luck managing to stabilize at that temp, but hey if you manage to, you get a mood buff!
#define LIZARD_COMFY_TEMP_MIN 303.15
#define LIZARD_COMFY_TEMP_MAX 333.15 //From what I read some terran lizards have ~40-45°C as their upper targeted bounds, buut firstly these are space lizards, and secondly this is already hard enough to hit, so I extended it to 60°C.

/datum/species/lizard/spec_life(mob/living/carbon/human/H)
	. = ..()
	var/owner_bodytemperature = H.bodytemperature
	if(owner_bodytemperature < LIZARD_COMFY_TEMP_MIN || owner_bodytemperature > LIZARD_COMFY_TEMP_MAX) //Should be low on processing since the first condition will catch almost all the time.
		if(!is_comfy)
			return
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "comfy_liz_temp")
		is_comfy = FALSE
		return
	if(is_comfy)
		return
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "comfy_liz_temp", /datum/mood_event/comfy_lizard_temperature)
	is_comfy = TRUE

#undef LIZARD_COMFY_TEMP_MIN
#undef LIZARD_COMFY_TEMP_MAX
