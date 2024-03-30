/datum/quirk/seasick
	name = "Sea-sick"
	desc = "Your body has a natural aversion to the currents and radiation produced by bluespace. You may start to feel sick when the ship performs an FTL jump."
	value = -2
	mob_trait = TRAIT_SEASICK
	gain_text = "<span class='notice'>The thought of FTL travel makes you uneasy</span>"
	lose_text = "<span class='notice'>The thought of FTL travel doesn't seem so bad anymore.</span>"
	medical_record_text = "Patient is vulnerable to bluespace currents and often gets sick during FTL travel."

/datum/quirk/junkie/coffee_addict
	name = "Coffee Addict"
	desc = "You have a strong addiction to caffeine. Probably not great in the long term."
	value = -1
	gain_text = "<span class='danger'>You feel like you could use a cup of coffee.</span>"
	lose_text = "<span class='notice'>You feel like you don't need that much caffeine anymore.</span>"
	medical_record_text = "Patient is addicted to caffeine."
	reagent_type = /datum/reagent/consumable/coffee
	drug_container_type = /obj/item/reagent_containers/food/drinks/coffee
	process = TRUE

/datum/quirk/junkie/naval_coffee_Addict
	name = "Naval Coffee Addict"
	desc = "You have a strong addiction to the paint stripper liquid that the Navy calls coffee. Probably not great in the long term for your liver, or heart."
	value = -1
	gain_text = "<span class='danger'>You feel your eyelids growing heavier, you really need a cup of navy coffee to get through this patrol.</span>"
	lose_text = "<span class='notice'>The stress of the patrol has lessened, you don't feel like you need that much caffeine anymore.</span>"
	medical_record_text = "Patient is heavily addicted to the dangerous liquid the navy calls coffee."
	reagent_type = /datum/reagent/consumable/navy_coffee
	drug_container_type = /obj/item/reagent_containers/food/drinks/coffee/navy_coffee
	process = TRUE
