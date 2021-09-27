/datum/chemical_reaction/cryogenic_fuel
	name = "Cryogenic Tyrosene"
	id = /datum/reagent/cryogenic_fuel
	results = list(/datum/reagent/cryogenic_fuel = 5)
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/methane = 5)
	is_cold_recipe = TRUE
	required_temp = 40

/datum/chemical_reaction/reagent_explosion/cryogenic_overheat
	name = "Tyrosene Explosion"
	required_reagents = list(/datum/reagent/cryogenic_fuel = 1)
	required_temp = 130
	strengthdiv = 9
