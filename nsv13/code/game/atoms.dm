/atom/proc/has_material(var/datum/material/material)
	if(!istype(material))
		material = getmaterialref(material) //Get the ref if necesary
	return custom_materials[material] > 0