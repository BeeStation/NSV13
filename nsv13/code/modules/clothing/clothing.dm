//parent append extra vars here
/obj/item/clothing

var/list/species_restricted //Added variable to it, basically a restriction list.
//Basically syntax is species_restricted = list("Species Name","Species Name")
//Add a "EXCLUDE" string to do the opposite, making it only only species listed that can wear it.
//You append this to clothing objects.


//NSV13: Species-restricted clothing check. - Thanks Oraclestation, BS13, etc.
/obj/item/clothing/mob_can_equip(mob/M, slot, disable_warning = TRUE)

	//if we can't equip the item anyway, don't bother with species_restricted (also cuts down on spam)
	if(!..())
		return FALSE

	// Skip species restriction checks on non-equipment slots
	if(slot in list(SLOT_IN_BACKPACK, SLOT_L_STORE, SLOT_R_STORE))
		return TRUE

	if(species_restricted && ishuman(M))

		var/wearable = null
		var/exclusive = null
		var/mob/living/carbon/human/H = M

		if("EXCLUDE" in species_restricted) //TURNS IT INTO A WHITELIST
			exclusive = TRUE

		if(H.dna.species)
			if(exclusive)
				if(!(H.dna.species.name in species_restricted))
					wearable = TRUE
			else
				if(H.dna.species.name in species_restricted)
					wearable = TRUE

			if(!wearable)
				to_chat(M, "<span class='warning'>Your species cannot wear [src].</span>")
				return FALSE

	return TRUE

// ???????? RECHECK THIS.
/obj/item/clothing/proc/refit_for_species(var/target_species)
	//Set species_restricted list
	switch(target_species)
		if("Human")//humanoid bodytypes
			species_restricted = list("exclude","Unathi","Ash Walker", "Ethari")
		else
			species_restricted = list(target_species)

	//Set icon
	if(sprite_sheets && (target_species in sprite_sheets))
		icon_override = sprite_sheets[target_species]
	else
		icon_override = initial(icon_override)

	if(sprite_sheets_obj && (target_species in sprite_sheets_obj))
		icon = sprite_sheets_obj[target_species]
	else
		icon = initial(icon)