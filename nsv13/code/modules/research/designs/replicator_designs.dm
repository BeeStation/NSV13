/datum/design/replicator
	var/nutriment

/datum/design/replicator/boiledrice
	name = "Boiled Rice"
	id = "boiledrice"
	build_type = REPLICATOR
	materials = list(/datum/material/biomass = 300)
	build_path = /obj/item/reagent_containers/food/snacks/salad/boiledrice
	category = list("initial","Tier 1")
