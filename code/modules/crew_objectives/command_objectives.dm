/*				COMMAND OBJECTIVES				*/

/datum/objective/crew/caphat //Ported from Goon
	explanation_text = "Nie zgub swojej czapki."
	jobs = "captain"

/datum/objective/crew/caphat/check_completion()
	if(owner && owner.current && owner.current.check_contents_for(/obj/item/clothing/head/caphat))
		return TRUE
	else
		return ..()

/datum/objective/crew/datfukkendisk //Ported from old Hippie
	explanation_text = "Chroń dysku nuklearnej autoryzacji za wszelką cenę i upewnij się, że zostanie dostarczony do Centrali."
	jobs = "captain" //give this to other heads at your own risk.

/datum/objective/crew/datfukkendisk/check_completion()
	if(owner?.current && owner.current.check_contents_for(/obj/item/disk/nuclear) && SSshuttle.emergency.shuttle_areas[get_area(owner.current)])
		return TRUE
	else
		return ..()

/datum/objective/crew/downwiththestation
	explanation_text = "Idź na dno ze stacją. Nie opuszczaj jej promem ani kapsułą ratunkową. Zostań na mostku."
	jobs = "captain"

/datum/objective/crew/downwiththestation/check_completion()
	if(owner?.current)
		if(istype(get_area(owner.current), /area/bridge))
			return TRUE
	return ..()

/datum/objective/crew/ian //Ported from old Hippie
	explanation_text = "Broń Iana za wszelką cenę i upewnij się, że zostanie dostarczony żywy do Centrali."
	jobs = "headofpersonnel"

/datum/objective/crew/ian/check_completion()
	if(owner?.current)
		for(var/mob/living/simple_animal/pet/dog/corgi/Ian/goodboy in GLOB.mob_list)
			if(goodboy.stat != DEAD && SSshuttle.emergency.shuttle_areas[get_area(goodboy)])
				return TRUE
	return ..()
