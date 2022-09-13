/datum/chemical_reaction/gender_fluid
	name = "Gender Fluid"
	id = /datum/reagent/consumable/ethanol/gender_fluid
	results = list(/datum/reagent/consumable/ethanol/gender_fluid = 15)
	required_reagents = list(/datum/reagent/consumable/ethanol/between_the_sheets = 5, /datum/reagent/consumable/ethanol/sugar_rush = 5, /datum/reagent/consumable/ethanol/manly_dorf = 5)

/datum/chemical_reaction/gender_bender
	name = "Gender Bender"
	id = /datum/reagent/consumable/ethanol/gender_bender
	results = list(/datum/reagent/consumable/ethanol/gender_bender = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/gender_fluid = 5, /datum/reagent/stabilizing_agent = 1) //To change your gender and make it stick, you need to stabilize the drink first!
