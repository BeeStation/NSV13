/datum/reagent/drug/highjack
	name = "Highjack"
	description = "Creates effects akin to mind-altering substances when processed by synthetics."
	color = "#271509"
	taste_description = "metallic"
	process_flags = SYNTHETIC
	overdose_threshold = 30


/datum/reagent/drug/highjack/on_mob_life(mob/living/carbon/M)
	M.set_drugginess(15)
	if(prob(7))
		M.emote(pick("buzz","beep","ping","buzz2"))
	..()

/datum/reagent/drug/highjack/overdose_process(mob/living/carbon/M)
	var/obj/item/bodypart/head/head = M.get_bodypart("head")
	if(prob(30))
		if(head)
			to_chat(M, "<span class='userdanger'>You feel really lightheaded...</span>")
			head.dismember()
		else
			to_chat(M,"<span class='userdanger'>You can feel oil leaking from your headless neck.</span>")
			M.bleed(20) //effectively bleed 2 due to robot physiology bleed mod being 0.1.
