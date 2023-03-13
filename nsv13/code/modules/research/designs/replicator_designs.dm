/datum/design/replicator
	var/nutriment
	var/list/alt_names = null

/datum/design/replicator/boiledegg
	name = "Boiled egg"
	id = "boiledegg"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/boiledegg
	category = list("initial","Tier 1")

/datum/design/replicator/boiledrice
	name = "Boiled rice"
	id = "boiledrice"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/salad/boiledrice
	category = list("initial","Tier 1")

/datum/design/replicator/rationpack
	name = "Ration pack"
	id = "rationpack"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/rationpack
	category = list("initial","Tier 1")

/datum/design/replicator/drinkingglass
	name = "Drinking glass"
	id = "drinkingglass"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/drinks/drinkingglass
	category = list("initial","Tier 1")

/datum/design/replicator/tea
	name = "Tea Earl Grey"
	id = "tea"
	build_type = REPLICATOR
	category = list("initial","Tier 1")
