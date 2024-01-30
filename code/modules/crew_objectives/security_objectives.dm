/*				SECURITY OBJECTIVES				*/

/datum/objective/crew/enjoyyourstay
	explanation_text = "Witamy na pokładzie. Miłego pobytu."
	jobs = "headofsecurity,securityofficer,warden,detective"
	var/list/edglines = list("Witamy na pokładzie. Miłego pobytu.", "Pisałeś się na to.", "Porzuć nadzieję.", "Fala kiedyś się w końcu zatrzyma.", "Hej, ktoś to musi robić.", "Nie, nie możesz zrezygnować.", "Ochrona to misja. Nie do obijania permisja.")

/datum/objective/crew/enjoyyourstay/New()
	. = ..()
	update_explanation_text()

/datum/objective/crew/enjoyyourstay/update_explanation_text()
	. = ..()
	explanation_text = "Egzekwuj kosmiczne prawo tak dobrze, jak potrafisz i przetrwaj. [pick(edglines)]"

/datum/objective/crew/enjoyyourstay/check_completion()
	if(owner?.current)
		if(owner.current.stat != DEAD)
			return TRUE
	return ..()

/datum/objective/crew/nomanleftbehind
	explanation_text = "Upewnij się, że żaden więzień nie został w skrzydle więziennym do końca zmiany."
	jobs = "warden,securityofficer"

/datum/objective/crew/nomanleftbehind/check_completion()
	for(var/mob/living/carbon/M in GLOB.alive_mob_list)
		if(!M.mind)
			continue
		if(!(M.mind.assigned_role in GLOB.security_positions) && istype(get_area(M), /area/security/prison)) //there's no list of incarcerated players, so we just assume any non-security people in prison are prisoners, and assume that any security people aren't prisoners
			return ..()
	return TRUE

/datum/objective/crew/justicemed
	explanation_text = "Upewnij się, że w skrzydle Ochrony nie ma żadnych zwłok do końca zmiany."
	jobs = "brigphysician"

/datum/objective/crew/justicemed/check_completion()
	var/list/security_areas = typecacheof(list(/area/security, /area/security/brig, /area/security/main, /area/security/prison, /area/security/processing))
	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		var/area/A = get_area(H)
		if(H.stat == DEAD && is_station_level(H.z) && is_type_in_typecache(A, security_areas)) // If person is dead and corpse is in one of these areas
			return ..()
	return TRUE
