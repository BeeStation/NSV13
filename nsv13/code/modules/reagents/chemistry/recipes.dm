/datum/chemical_reaction/aviation_fuel
	name = "Aviation Fuel"
	id = /datum/reagent/aviation_fuel
	results = list(/datum/reagent/aviation_fuel = 5)
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/hydrocarbon=5)
	required_temp = 333

/datum/chemical_reaction/hydrocarbon
	name = "Hydrocarbon"
	id = /datum/reagent/hydrocarbon
	results = list(/datum/reagent/hydrocarbon = 5)
	required_reagents = list(/datum/reagent/hydrogen = 1, /datum/reagent/carbon = 1)
	required_temp = 333

/datum/reagent/hydrocarbon
	name = "Hydrocarbon"
	description = "A gunky mixture of hydrogen and carbon molecules, most often used in the production of aviation fuel."
	reagent_state = LIQUID
	color = "#e3f5f9"
	taste_description = "oily water"

/datum/reagent/aviation_fuel
	name = "Tyrosene"
	description = "High performance aviation fuel used in small fighter craft, created by enhancing standard fuel with extra hydrocarbons."
	reagent_state = LIQUID
	color = "#170B28"
	taste_description = "jet fuel"