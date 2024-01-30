/*				MEDICAL OBJECTIVES				*/

/datum/objective/crew/morgue //Ported from old Hippie
	explanation_text = "Upewnij się, że Medbay został oczyszczony ze wszystkich zwłok do końca zmiany."
	jobs = "chiefmedicalofficer,geneticist,medicaldoctor"

/datum/objective/crew/morgue/check_completion()
	var/list/medical_areas = typecacheof(list(/area/medical/cryo, /area/medical/genetics/cloning, /area/medical/exam_room,
		/area/medical/medbay/aft, /area/medical/medbay/central, /area/medical/medbay/lobby, /area/medical/patients_rooms,
		/area/medical/sleeper, /area/medical/storage))
	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		var/area/A = get_area(H)
		if(H.stat == DEAD && is_station_level(H.z) && is_type_in_typecache(A, medical_areas)) // If person is dead and corpse is in one of these areas
			return ..()
	return TRUE

/datum/objective/crew/paramedicmorgue
	explanation_text = "Upewnij się, że żadne zwłoki nie leżą poza Medbayem pod koniec zmiany."
	jobs = "paramedic"

/datum/objective/crew/paramedicmorgue/check_completion()
	var/list/medical_areas_morgue = typecacheof(list(/area/medical/cryo, /area/medical/genetics/cloning, /area/medical/exam_room,
		/area/medical/medbay/aft, /area/medical/medbay/central, /area/medical/medbay/lobby, /area/medical/patients_rooms,
		/area/medical/sleeper, /area/medical/storage, /area/medical/morgue))
	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		var/area/A = get_area(H)
		if(H.stat == DEAD && is_station_level(H.z) && !is_type_in_typecache(A, medical_areas_morgue)) // If person is dead and corpse is NOT in one of these areas
			return ..()
	return TRUE

/datum/objective/crew/chems //Ported from old Hippie
	var/targetchem = "none"
	var/datum/reagent/chempath
	explanation_text = "Have (yell about this on GitHub, something broke) in your bloodstream when the shift ends."
	jobs = "chiefmedicalofficer,chemist"

/datum/objective/crew/chems/New()
	. = ..()
	chempath = get_random_reagent_id(CHEMICAL_GOAL_CHEMIST_BLOODSTREAM)
	targetchem = chempath
	update_explanation_text()

/datum/objective/crew/chems/update_explanation_text()
	. = ..()
	explanation_text = "Miej [initial(chempath.name)] w swoim krwioobiegu pod koniec rundy."

/datum/objective/crew/chems/check_completion()
	if(owner.current)
		if(!owner.current.stat == DEAD && owner.current.reagents)
			if(owner.current.reagents.has_reagent(targetchem))
				return TRUE
	return ..()

/datum/objective/crew/druglordchem //ported from old Hippie with adjustments
	var/targetchem = "none"
	var/datum/reagent/chempath
	var/chemamount = 0
	explanation_text = "Have at least (something broke here) pills containing at least (like really broke) units of (yell on GitHub) when the shift ends."
	jobs = "chemist"

/datum/objective/crew/druglordchem/New()
	. = ..()
	target_amount = rand(5,50)
	chemamount = rand(1,20)
	chempath = get_random_reagent_id(CHEMICAL_GOAL_CHEMIST_DRUG)
	targetchem = chempath
	update_explanation_text()

/datum/objective/crew/druglordchem/update_explanation_text()
	. = ..()
	explanation_text = "Posiadaj [target_amount] tabletek zawierających przynajmniej [chemamount] jednostek [initial(chempath.name)] kiedy skończy się zmiana."

/datum/objective/crew/druglordchem/check_completion()
	var/pillcount = target_amount
	if(owner.current)
		if(owner.current.contents)
			for(var/obj/item/reagent_containers/pill/P in owner.current.get_contents())
				if(P.reagents.has_reagent(targetchem, chemamount))
					pillcount--
	if(pillcount <= 0)
		return TRUE
	else
		return ..()

/datum/objective/crew/noinfections
	explanation_text = "Upewnij się, że pod koniec zmiany nie ma członków załogi zarażonych szkodliwymi chorobami."
	jobs = "virologist"

/datum/objective/crew/noinfections/check_completion()
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(!H.stat == DEAD)
			if((H.z in SSmapping.levels_by_trait(ZTRAIT_STATION)) || SSshuttle.emergency.shuttle_areas[get_area(H)])
				if(H.check_virus() == 2) //Harmful viruses only
					return ..()
	return TRUE
