/datum/nanite_program/nanojutsu
	name = "Nanojutsu Teaching Program"
	desc = "The nanites stimulate host's brain, giving them the ability to use the martial art of Nanojutsu."
	use_rate = 3.5
	rogue_types = list(/datum/nanite_program/brain_decay, /datum/nanite_program/brain_misfire)
	var/datum/martial_art/nanojutsu/martial

/datum/nanite_program/nanojutsu/enable_passive_effect()
	. = ..()
	if(!ishuman(host_mob))
		return
	var/mob/living/carbon/human/H = host_mob
	martial = new(null)
	to_chat(H, "<span class='notice'>Your mind is flooded with martial arts knowledge[martial.teach(H, TRUE)?".<br>You can learn more about your newfound art by using the Recall Teachings verb in the Nanojutsu tab":", but you manage to block it out"].</span>")

/datum/nanite_program/nanojutsu/disable_passive_effect()
	. = ..()
	if(!ishuman(host_mob))
		return
	var/mob/living/carbon/human/H = host_mob
	martial.remove(H)
	to_chat(H, "<span class='notice'>Your mind feels clear once again, as thoughts about the martial arts leave your head.</span>")
	QDEL_NULL(martial)

/datum/nanite_program/camo
	name = "Adaptive Camouflage"
	desc = "The nanites coat host with a thin, reflective layer, rendering them almost invisible."
	use_rate = 2.5
	rogue_types = list(/datum/nanite_program/skin_decay)

/datum/nanite_program/camo/enable_passive_effect()
	. = ..()
	animate(host_mob, alpha = 50,time = 15) //copypasta z ninja suita
	host_mob.visible_message("<span class='warning'>[host_mob] vanishes into thin air!</span>", \
					"<span class='notice'>You see your hands turn invisible.</span>")

/datum/nanite_program/camo/disable_passive_effect()
	. = ..()
	animate(host_mob, alpha = 255, time = 15)
	host_mob.visible_message("<span class='warning'>[host_mob] appears from thin air!</span>", \
					"<span class='notice'>You see your hands reappear.</span>")
