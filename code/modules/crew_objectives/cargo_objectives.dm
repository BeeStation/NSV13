/*				CARGO OBJECTIVES				*/

/datum/objective/crew/petsplosion
	explanation_text = "Upewnij się, że na stacji jest przynajmniej (If you see this, yell on GitHub) zwierząt przed końcem zmiany. Zinterpretuj to sobie jak chcesz ( ͡° ͜ʖ ͡°)."
	jobs = "quartermaster,cargotechnician"

/datum/objective/crew/petsplosion/New()
	. = ..()
	target_amount = rand(10,30)
	update_explanation_text()

/datum/objective/crew/petsplosion/update_explanation_text()
	. = ..()
	explanation_text = "Upewnij się, że na stacji jest przynajmniej [target_amount] zwierząt przed końcem zmiany. Zinterpretuj to sobie jak chcesz ( ͡° ͜ʖ ͡°)."

/datum/objective/crew/petsplosion/check_completion()
	var/petcount = target_amount
	for(var/mob/living/simple_animal/pet/P in GLOB.mob_list)
		if(!(P.stat == DEAD))
			if((P.z in SSmapping.levels_by_trait(ZTRAIT_STATION)) || SSshuttle.emergency.shuttle_areas[get_area(P)])
				petcount--
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(!(H.stat == DEAD))
			if((H.z in SSmapping.levels_by_trait(ZTRAIT_STATION)) || SSshuttle.emergency.shuttle_areas[get_area(H)])
				if(istype(H.wear_neck, /obj/item/clothing/neck/petcollar))
					petcount--
	if(petcount <= 0)
		return TRUE
	else
		return ..()

/datum/objective/crew/points //ported from old hippie
	explanation_text = "Make sure the station has at least (Something broke, yell on GitHub) station credits at the end of the shift."
	jobs = "quartermaster,cargotechnician"

/datum/objective/crew/points/New()
	. = ..()
	target_amount = rand(25000,100000)
	update_explanation_text()

/datum/objective/crew/points/update_explanation_text()
	. = ..()
	explanation_text = "Upewnij się, że na stacji jest przynajmniej [target_amount] kredytów przed końcem zmiany."

/datum/objective/crew/points/check_completion()
	if(SSshuttle.points >= target_amount)
		return TRUE
	else
		return ..()

/* NSV13 - we don't have bubblegum as a boss
/datum/objective/crew/bubblegum
	explanation_text = "Ensure Bubblegum is dead at the end of the shift."
	jobs = "shaftminer"

/datum/objective/crew/bubblegum/check_completion()
	for(var/mob/living/simple_animal/hostile/megafauna/bubblegum/B in GLOB.mob_list)
		if(!(B.stat == DEAD))
			return ..()
	return TRUE
*/

/datum/objective/crew/fatstacks //ported from old hippie
	explanation_text = "Have at least (something broke, report this on GitHub) mining points on your ID at the end of the shift."
	jobs = "shaftminer"

/datum/objective/crew/fatstacks/New()
	. = ..()
	target_amount = rand(15000,50000)
	update_explanation_text()

/datum/objective/crew/fatstacks/update_explanation_text()
	. = ..()
	explanation_text = "Miej przynajmniej [target_amount] punktów górniczych na swoim koncie ID przed końcem zmiany."

/datum/objective/crew/fatstacks/check_completion()
	if(owner?.current)
		var/mob/living/carbon/human/H = owner.current
		var/obj/item/card/id/theID = H.get_idcard()
		if(istype(theID))
			if(theID.mining_points >= target_amount)
				return TRUE
	return ..()
