/datum/reagent/consumable/ethanol/gender_fluid
	name = "Gender Fluid"
	description = "This fluid seems to defy genetics, the mere act of looking at it makes you question your gender."
	color = "#eebc17"
	boozepwr = 50
	taste_description = "fluidic gender"
	glass_icon_state = "gender_fluid"
	glass_name = "glass of Gender Fluid"
	glass_desc = "What the fuck is this shit?!"
	var/gender = null

/datum/reagent/consumable/ethanol/gender_fluid/on_mob_add(mob/living/L)
	gender = L.gender
	return ..()

/datum/reagent/consumable/ethanol/gender_fluid/on_mob_life(mob/living/carbon/M)
	if(M.gender == MALE)
		M.gender = FEMALE //UwU
		M.visible_message("<span class='boldnotice'>[M] suddenly looks more feminine!</span>", "<span class='boldwarning'>You suddenly feel more feminine!</span>")
	else
		M.gender = MALE //OwO
		M.visible_message("<span class='boldnotice'>[M] suddenly looks more masculine!</span>", "<span class='boldwarning'>You suddenly feel more masculine!</span>")
	M.regenerate_icons()
	..()

/datum/reagent/consumable/ethanol/gender_fluid/on_mob_end_metabolize(mob/living/M)
	M.gender = gender
	M.visible_message("<span class='boldnotice'>[M] seems to have gotten over their gender confusion!</span>", "<span class='boldwarning'>Your head suddenly clears and you remember what you define yourself as!</span>")
	M.regenerate_icons()
	return ..()
