/*****************************\
|********** MEDICAL **********|
\*****************************/
/datum/techweb_node/experimental_cloning
	id = "experimental_cloning"
	display_name = "Experimental Cloning"
	description = "Attack of the clones."
	prereq_ids = list("adv_surgery")
	design_ids = list("clonecontrol_prototype", "clonepod_experimental")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/*****************************\
|*********** NANITE **********|
\*****************************/
/datum/techweb_node/experimental_cloning
	id = "experimental_cloning"
	display_name = "Experimental Cloning"
	description = "Attack of the clones."
	prereq_ids = list("adv_surgery")
	design_ids = list("clonecontrol_prototype", "clonepod_experimental")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/nanite_smart
	id = "nanite_smart"
	tech_tier = 2
	display_name = "Smart Nanite Programming"
	description = "Nanite programs that require nanites to perform complex actions, act independently, roam or seek targets."
	prereq_ids = list("nanite_base","robotics")
	design_ids = list("metabolic_nanites", "stealth_nanites", "memleak_nanites", "sensor_voice_nanites", "sensor_impact_nanites", "voice_nanites", "cloud_change_nanites", "nanolink_nanites") // AQUILA EDIT
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500, TECHWEB_POINT_TYPE_NANITES = 500)
	export_price = 4000

/datum/techweb_node/nanite_bio
	id = "nanite_bio"
	tech_tier = 3
	display_name = "Biological Nanite Programming"
	description = "Nanite programs that require complex biological interaction."
	prereq_ids = list("nanite_base","biotech")
	design_ids = list("regenerative_nanites", "bloodheal_nanites", "coagulating_nanites", "poison_nanites", "flesheating_nanites",\
					"sensor_crit_nanites", "sensor_death_nanites", "sensor_health_nanites", "sensor_damage_nanites", "sensor_species_nanites", "nutrition_nanites") // AQUILA EDIT
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500, TECHWEB_POINT_TYPE_NANITES = 500)
	export_price = 5000

/datum/techweb_node/nanite_neural
	id = "nanite_neural"
	tech_tier = 3
	display_name = "Neural Nanite Programming"
	description = "Nanite programs affecting nerves and brain matter."
	prereq_ids = list("nanite_bio")
	design_ids = list("nervous_nanites", "brainheal_nanites", "paralyzing_nanites", "stun_nanites", "selfscan_nanites", "good_mood_nanites", "bad_mood_nanites", "movement_nanites") //AQUILA EDIT
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000, TECHWEB_POINT_TYPE_NANITES = 1000)
	export_price = 5000

/datum/techweb_node/nanite_synaptic
	id = "nanite_synaptic"
	tech_tier = 4
	display_name = "Synaptic Nanite Programming"
	description = "Nanite programs affecting mind and thoughts."
	prereq_ids = list("nanite_neural","neural_programming")
	design_ids = list("mindshield_nanites", "pacifying_nanites", "blinding_nanites", "sleep_nanites", "mute_nanites", "speech_nanites", "hallucination_nanites", "nanojutsu_nanites") //AQUILA EDIT
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000, TECHWEB_POINT_TYPE_NANITES = 1000)
	export_price = 5000

/datum/techweb_node/nanite_harmonic
	id = "nanite_harmonic"
	tech_tier = 4
	display_name = "Harmonic Nanite Programming"
	description = "Nanite programs that require seamless integration between nanites and biology."
	prereq_ids = list("nanite_bio","nanite_smart","nanite_mesh")
	design_ids = list("fakedeath_nanites", "aggressive_nanites", "defib_nanites", "regenerative_plus_nanites", "brainheal_plus_nanites", "purging_plus_nanites", "adrenaline_nanites", "camo_nanites") //AQUILA EDIT
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000, TECHWEB_POINT_TYPE_NANITES = 2000)
	export_price = 8000

/datum/techweb_node/nanite_illegal
	id = "nanite_illegal"
	tech_tier = 5
	display_name = "Illegal Nanite Programming"
	description = "Extremely dangerous nanite programs capable of mass destruction."
	prereq_ids = list("nanite_harmonic", "syndicate_basic")
	design_ids = list("explosive_nanites", "pyro_nanites", "meltdown_nanites", "viral_nanites", "nanite_sting_nanites", "kunai_nanites", "nanoswarm_nanites")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500, TECHWEB_POINT_TYPE_NANITES = 2500)
	export_price = 12500

/datum/techweb_node/nanite_hazard
	id = "nanite_hazard"
	tech_tier = 5
	display_name = "Hazardous Nanite Programming"
	description = "Extremely advanced Nanite programs with the potential of being extremely dangerous."
	prereq_ids = list("nanite_harmonic", "alientech")
	design_ids = list("spreading_nanites", "mindcontrol_nanites", "mitosis_nanites")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000, TECHWEB_POINT_TYPE_NANITES = 4000)
	export_price = 15000

/datum/techweb_node/nanite_replication_protocols
	id = "nanite_replication_protocols"
	tech_tier = 5
	display_name = "Nanite Replication Protocols"
	description = "Advanced behaviours that allow nanites to exploit certain circumstances to replicate faster."
	prereq_ids = list("nanite_harmonic")
	design_ids = list("kickstart_nanites", "factory_nanites", "tinker_nanites", "offline_nanites", "free_range_nanites", "zip_nanites")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 4000, TECHWEB_POINT_TYPE_NANITES = 4000)
	export_price = 15000

/*******************************\
|*********** MACHINES **********|
\*******************************/
/datum/techweb_node/bluespace_mining
	id = "bluespace_mining"
	hidden = TRUE
	display_name = "Bluespace Mining Technology"
	description = "Harness the power of bluespace to make materials out of nothing. Slowly."
	prereq_ids = list("practical_bluespace", "adv_mining")
	design_ids = list("bluespace_miner")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/bluespace_mining/New() //Techweb nodes don't have an init,
	. = ..()

	hidden = !CONFIG_GET(flag/bsminer_researchable)
/*******************************\
|*********** WEAPONS  **********|
\*******************************/
//najtańsze, słabe i kosztowne
/datum/techweb_node/prototype_beam_weapons
	id = "prototype_beam_weapons"
	tech_tier = 1
	starting_node = TRUE
	display_name = "Prototype Beam Weapons"
	description = "First generation energy based weapons, they use special lenses to focus light and turn it into high-energy weapon platform, expensive with inefficient energy usage."
	design_ids = list("firstgenegun", "firstgenlasergun")
//średnia półka
/datum/techweb_node/improved_beam_weapons
	id = "improved_beam_weapons"
	tech_tier = 3
	display_name = "Advanced Energy weapons"
	description = "Improved beam weapons, using standardized alloys and better energy usage."
	prereq_ids = list("prototype_beam_weapons", "weaponry", "electronic_weapons")
	design_ids = list("lasergun", "energy_gun")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
//powrót armatki laserowej
/datum/techweb_node/powerful_beam_weapons
	id = "powerful_beam_weapons"
	tech_tier = 4
	display_name = "Heavy Laser Weapons"
	description = "Putting alloys to thier limits with improved energy entropy"
	prereq_ids = list("improved_beam_weapons", "adv_engi", "adv_weaponry")
	design_ids = list("lasercannon")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 4000)
	export_price = 9000
//taktyczny karabinek energetyczny
/datum/techweb_node/tactical_beam_weapons
	id = "tactical_beam_weapons"
	tech_tier = 4
	display_name = "Tactical Energy Weapons"
	description = "Tactical application of beam weaponry."
	prereq_ids = list("improved_beam_weapons", "adv_engi", "adv_weaponry")
	design_ids = list("tacticalegun")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)
	export_price = 5000
//bydle broni energetycznych
/datum/techweb_node/destructive_beam_weapons
	id = "destructive_beam_weapons"
	tech_tier = 5
	display_name = "High-frequency multilayered beam weapons"
	description = "This is the closest we can get in making handheld particle lance, able to destroy even thickest of alloyed armors with extreme, high-frequency pulses."
	prereq_ids = list("tactical_beam_weapons", "powerful_beam_weapons", "adv_weaponry", "explosive_weapons", "bluespace_power", "adv_beam_weapons") //gratulacje jak uda się to wynaleźć i runda dalej trwa
	design_ids = list("pulsegun")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 100 //jajko wielkanocne bo defacto Centrala i ich mało znani specjalisci od spraw wewnętrznych mają to
