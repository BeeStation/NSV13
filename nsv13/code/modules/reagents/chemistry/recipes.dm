/datum/chemical_reaction/hydrocarbon
	name = "Hydrocarbon"
	id = /datum/reagent/hydrocarbon
	results = list(/datum/reagent/hydrocarbon = 5)
	required_reagents = list(/datum/reagent/hydrogen = 1, /datum/reagent/carbon = 1)
	required_temp = 333

/datum/reagent/hydrocarbon
	name = "Hydrocarbon"
	description = "A gunky mixture of hydrogen and carbon molecules, most often used in the production of cryogenic fuel."
	reagent_state = LIQUID
	color = "#e3f5f9"
	taste_description = "oily water"

/datum/reagent/cryogenic_fuel
	name = "Cryogenic Tyrosene" // implies there's normal Tyrosene but it sounds cooler
	description = "High performance cryogenic fuel used in small fighter craft, created by enhancing standard fuel with extra hydrocarbons."
	reagent_state = LIQUID
	color = "#170B28"
	taste_description = "spicy ice water"

/datum/chemical_reaction/cryogenic_fuel
	name = "Cryogenic Tyrosene"
	id = /datum/reagent/cryogenic_fuel
	results = list(/datum/reagent/cryogenic_fuel = 5)
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/hydrocarbon = 5)
	is_cold_recipe = TRUE
	required_temp = 40

/datum/chemical_reaction/reagent_explosion/cryogenic_overheat
	name = "Tyrosene Explosion"
	required_reagents = list(/datum/reagent/cryogenic_fuel = 1)
	required_temp = 130
	strengthdiv = 9
