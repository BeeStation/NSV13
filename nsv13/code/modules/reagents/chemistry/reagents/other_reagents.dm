/datum/reagent/methane
	name = "Methane"
	description = "A light, flammable hydrocarbon. Commonly used in the production of cryogenic fuel."
	reagent_state = GAS
	color = "#ccf6ff"
	taste_description = "nothing"

/datum/reagent/consumable/creamer
	name = "Coffee Creamer"
	description = "Powdered milk for cheap coffee. How delightful."
	taste_description = "milk"
	color = "#efeff0"
	nutriment_factor = 1.5 * REAGENTS_METABOLISM

/datum/reagent/consumable/navy_coffee
	name = "Naval Coffee"
	description = "The lifeblood of the Navy and Militaries everywhere, this coffee is strong enough to keep you awake for days, ruin your tastebuds and wake the freaking dead."
	color = "#241000"
	nutriment_factor = 0
	addiction_threshold = 40 //Downing two cups in one go will make you addicted to it.
	taste_description = "extreme bitterness with a hint of fuel"
	glass_icon_state = "glass_brown"
	glass_name = "glass of navy coffee"
	glass_desc = "Don't drop it, or you'll get busted back down to midshipman!"

/datum/reagent/consumable/navy_coffee/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-40, FALSE)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "navy_coffee", /datum/mood_event/drink_navy_coffee)
	..()
	. = 1
