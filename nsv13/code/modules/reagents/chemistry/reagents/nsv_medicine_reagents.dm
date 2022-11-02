/datum/reagent/medicine/radioactive_disinfectant
	name = "Radioactive Disinfectant"
	description = "Removes irradiation in synthetics."
	color = "#806F42"
	taste_description = "metallic"
	process_flags = SYNTHETIC

/datum/reagent/medicine/radioactive_disinfectant/on_mob_life(mob/living/carbon/M)
	// Reskinned potassium iodide for synthetics
	if(M.radiation > 0)
		M.radiation -= min(M.radiation, 8)
	..()
