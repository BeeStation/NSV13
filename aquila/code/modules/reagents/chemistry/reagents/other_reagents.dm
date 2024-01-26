/datum/reagent/mutationtoxin/lizard/on_mob_life(mob/living/carbon/human/H)
	if(current_cycle >= cycles_to_turn) //overwrite since we want more races
		var/list/random_races = list(/datum/species/zombie,
									/datum/species/skeleton,
									/datum/species/vampire,
									/datum/species/snail,
									/datum/species/apid)
		var/datum/species/species_type = pick(random_races)
		H.set_species(species_type)
		H.reagents.del_reagent(type)
		to_chat(H, "<span class='warning'>You've become \a [initial(species_type.name)]!</span>")
		return TRUE
	return ..()
