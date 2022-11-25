/datum/reagent/drug/highjack //NSV13
	name = "Highjack"
	description = "Repairs brain damage in synthetics."
	color = "#271509"
	taste_description = "metallic"
	process_flags = SYNTHETIC
	overdose_threshold = 30


/datum/reagent/drug/highjack/on_mob_life(mob/living/carbon/M)
	M.set_drugginess(15)
	if(prob(7))
		M.emote(pick("buzz","beep","ping","buzz2"))
	..()

/datum/reagent/drug/highjack/overdose_process(mob/living/M)
	var/obj/item/bodypart/head/head = M.get_bodypart("head")
	if(prob(30))
		to_chat(M, "<span class='userdanger'>You feel really lightheaded...</span>")
		head.dismember()
