/datum/overmap_objective/cargo/transfer/specimen 
	name = "Deliver a specimen"
	desc = "Deliver a specific specimen provided by the objective"
	crate_name = "Secure Specimen Transfer"
	
/datum/overmap_objective/cargo/transfer/specimen/New() 
	var/picked = pick( list (
		// Dangerous specimens 
		/mob/living/simple_animal/slime/random,
		// /mob/living/simple_animal/hostile/zombie/hugbox,
		// /mob/living/simple_animal/hostile/alien,
		/mob/living/simple_animal/hostile/swarmer,
		// /mob/living/simple_animal/hostile/carp,

		// Benign specimens 
		/mob/living/simple_animal/hostile/lizard,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/pet/dog/bullterrier,
		/mob/living/simple_animal/pet/cat,
		/mob/living/simple_animal/pet/fox,
		/mob/living/simple_animal/pet/hamster,
		/mob/living/simple_animal/pet/penguin/emperor,
		/mob/living/simple_animal/chicken,
		/mob/living/simple_animal/parrot,
		/mob/living/simple_animal/butterfly,
		/mob/living/simple_animal/crab,
		/mob/living/simple_animal/cow
	) )

	// Bandaid fix to stop a runtime about mobs in nullspace 
	// var/obj/structure/closet/closet = new /obj/structure/closet() 
	var/datum/freight_type/specimen/C = new /datum/freight_type/specimen( picked )
	C.prepackage_item = TRUE
	C.overmap_objective = src
	freight_types += C
