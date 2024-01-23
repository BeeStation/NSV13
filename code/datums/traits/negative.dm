//predominantly negative traits

/datum/quirk/badback
	name = "Krzywy Kręgosłup"
	desc = "Przez twoją złą posturę nie pasują na ciebie żadne plecaki. Inne ciężkie przedmioty są w porządku."
	value = -2
	mood_quirk = TRUE
	gain_text = "<span class='danger'>Twoje plecy BARDZO cię bolą!</span>"
	lose_text = "<span class='notice'>Twoje plecy są wolne od bólu.</span>"
	medical_record_text = "Skany pacjenta wykazały znaczny i chroniczny ból pleców."
	process = TRUE

/datum/quirk/badback/on_process()
	var/mob/living/carbon/human/H = quirk_holder
	if(H.back && istype(H.back, /obj/item/storage/backpack))
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "back_pain", /datum/mood_event/back_pain)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "back_pain")

/datum/quirk/blooddeficiency
	name = "Niedobór Krwii"
	desc = "Twoje ciało nie jest w stanie wyprodukować wystarczająco krwii, żeby się utrzymać."
	value = -2
	gain_text = "<span class='danger'>Czujesz, że twoje siły powoli cię opuszczają.</span>"
	lose_text = "<span class='notice'>Czujesz się bardziej rześki.</span>"
	medical_record_text = "Pacjent wymaga regularnej transfuzji krwii ze względu na jej niską produkcję."
	process = TRUE

/datum/quirk/blooddeficiency/on_process(delta_time)
	var/mob/living/carbon/human/H = quirk_holder
	if(NOBLOOD in H.dna.species.species_traits) //can't lose blood if your species doesn't have any
		return
	else if(H.blood_volume > (BLOOD_VOLUME_SAFE - 25)) // just barely survivable without treatment
		H.blood_volume -= 0.275 * delta_time

/datum/quirk/blindness
	name = "Ślepota"
	desc = "Jesteś kompletnie ślepy, nic nie można na to poradzić."
	value = -4
	medical_record_text = "Patient has permanent blindness."
	gain_text = "<span class='danger'>Nic nie widzisz.</span>"
	lose_text = "<span class='notice'>Cudownie odzyskałeś wzrok.</span>"
	medical_record_text = "Pacjent jest ślepy."

/datum/quirk/blindness/add()
	quirk_holder.become_blind(ROUNDSTART_TRAIT)

/datum/quirk/blindness/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/glasses/blindfold/white/B = new(get_turf(H))
	if(!H.equip_to_slot_if_possible(B, ITEM_SLOT_EYES, bypass_equip_delay_self = TRUE)) //if you can't put it on the user's eyes, put it in their hands, otherwise put it on their eyes
		H.put_in_hands(B)
	H.regenerate_icons()

/datum/quirk/brainproblems
	name = "Guz Mózgu"
	desc = "Masz małego przyjaciela wewnątrz głowy, który powoli niszczy twój mózg. Lepiej weź ze sobą mannitol!"
	mob_trait = TRAIT_BRAIN_TUMOR
	value = -3
	gain_text = "<span class='danger'>Czujesz się gładko.</span>"
	lose_text = "<span class='notice'>Czujesz się pomarszczony.</span>"
	medical_record_text = "Pacjent ma śmiertelnego guza mózgu."
	process = TRUE
	var/where = "pod twoimi stopami"
	var/notified = FALSE

/datum/quirk/brainproblems/on_process(delta_time)
	if(!quirk_holder.reagents.has_reagent(/datum/reagent/medicine/mannitol))
		if(prob(80))
			quirk_holder.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.1 * delta_time)
	var/obj/item/organ/brain/B = quirk_holder.getorgan(/obj/item/organ/brain)
	if(B)
		if(B.damage>BRAIN_DAMAGE_MILD-1 && !notified)
			to_chat(quirk_holder, "<span class='danger'>Czujesz, że twój mózg wymyka się spod kontroli...</span>")
			notified = TRUE
		if(B.damage<1 && notified)
			to_chat(quirk_holder, "<span class='notice'>Czujesz, że twój mózg ma się całkiem dobrze.</span>")
			notified = FALSE

/datum/quirk/brainproblems/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/storage/pill_bottle/mannitol/braintumor/P = new(get_turf(H))

	var/list/slots = list(
		"w twojej lewej kieszeni" = ITEM_SLOT_LPOCKET,
		"w twojej prawej kieszeni" = ITEM_SLOT_RPOCKET,
		"w twoim plecaku" = ITEM_SLOT_BACKPACK
	)
	where = H.equip_in_one_of_slots(P, slots, FALSE)

/datum/quirk/brainproblems/post_add()
	if(where)
		to_chat(quirk_holder, "<span class='boldnotice'>Masz butelkę mannitolu [where]. Będziesz jej potrzebował.</span>")
	else
		to_chat(quirk_holder, "<span class='boldnotice'>Upuściłeś twoją butelkę mannitolu. Lepiej byłoby, gdybyś ją podniósł. Będziesz jej potrzebował.</span>")

/datum/quirk/deafness
	name = "Głuchota"
	desc = "Jesteś nieuleczalnie głuchy."
	value = -2
	mob_trait = TRAIT_DEAF
	gain_text = "<span class='danger'>Nic nie słyszysz.</span>"
	lose_text = "<span class='notice'>Twój słuch powrócił!</span>"
	medical_record_text = "Nerwy słuchowe pacjenta są uszkodzone."

/datum/quirk/depression
	name = "Depresja"
	desc = "Czasami po prostu nienawidzisz swojego życia."
	mob_trait = TRAIT_DEPRESSION
	value = -1
	gain_text = "<span class='danger'>Czujesz się przygnębiony.</span>"
	lose_text = "<span class='notice'>Twój smak życia powrócił.</span>" //if only it were that easy!
	medical_record_text = "Pacjent jest chory na depresję."
	mood_quirk = TRUE
	process = TRUE

/datum/quirk/depression/on_process(delta_time)
	if(DT_PROB(0.05, delta_time))
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "depression", /datum/mood_event/depression)

/datum/quirk/family_heirloom
	name = "Pamiątka Rodzinna"
	desc = "Jesteś w posiadaniu pamiątki przekazywanej z pokolenia na pokolenie. Musisz jej strzec!"
	value = -1
	mood_quirk = TRUE
	process = TRUE
	medical_record_text = "Pacjent przejawia nietypowe przywiązanie do pamiątki rodzinnej."
	var/obj/item/heirloom
	var/where

/datum/quirk/family_heirloom/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/heirloom_type

	if(is_species(H, /datum/species/moth) && prob(50))
		heirloom_type = /obj/item/flashlight/lantern/heirloom_moth
	else
		switch(quirk_holder.mind.assigned_role)
			//Service jobs
			if(JOB_NAME_CLOWN)
				heirloom_type = /obj/item/bikehorn/golden
			if(JOB_NAME_MIME)
				heirloom_type = /obj/item/reagent_containers/food/snacks/baguette/mime
			if(JOB_NAME_JANITOR)
				heirloom_type = pick(/obj/item/mop, /obj/item/clothing/suit/caution, /obj/item/reagent_containers/glass/bucket)
			if(JOB_NAME_COOK)
				heirloom_type = pick(/obj/item/reagent_containers/food/condiment/saltshaker, /obj/item/kitchen/rollingpin, /obj/item/clothing/head/chefhat)
			if(JOB_NAME_BOTANIST)
				heirloom_type = pick(/obj/item/cultivator, /obj/item/reagent_containers/glass/bucket, /obj/item/storage/bag/plants, /obj/item/toy/plush/beeplushie)
			if(JOB_NAME_BARTENDER)
				heirloom_type = pick(/obj/item/reagent_containers/glass/rag, /obj/item/clothing/head/that, /obj/item/reagent_containers/food/drinks/shaker)
			if(JOB_NAME_CURATOR)
				heirloom_type = pick(/obj/item/pen/fountain, /obj/item/storage/pill_bottle/dice)
			if(JOB_NAME_CHAPLAIN)
				heirloom_type = pick(/obj/item/toy/windupToolbox, /obj/item/reagent_containers/food/drinks/bottle/holywater)
			if(JOB_NAME_ASSISTANT)
				heirloom_type = pick(/obj/item/heirloomtoolbox, /obj/item/clothing/gloves/cut/heirloom)
			if(JOB_NAME_BARBER)
				heirloom_type = /obj/item/handmirror
			if(JOB_NAME_STAGEMAGICIAN)
				heirloom_type = /obj/item/gun/magic/wand
			//Security/Command
			if(JOB_NAME_CAPTAIN)
				heirloom_type = /obj/item/reagent_containers/food/drinks/flask/gold
			if(JOB_NAME_HEADOFSECURITY)
				heirloom_type = /obj/item/book/manual/wiki/security_space_law
			if(JOB_NAME_WARDEN)
				heirloom_type = /obj/item/book/manual/wiki/security_space_law
			if(JOB_NAME_SECURITYOFFICER)
				heirloom_type = pick(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)
			if(JOB_NAME_DETECTIVE)
				heirloom_type = /obj/item/reagent_containers/food/drinks/bottle/whiskey
			if(JOB_NAME_LAWYER)
				heirloom_type = pick(/obj/item/gavelhammer, /obj/item/book/manual/wiki/security_space_law)
			if(JOB_NAME_BRIGPHYSICIAN)
				heirloom_type = pick(/obj/item/clothing/neck/stethoscope, /obj/item/book/manual/wiki/security_space_law)
			//RnD
			if(JOB_NAME_RESEARCHDIRECTOR)
				heirloom_type = /obj/item/toy/plush/slimeplushie
			if(JOB_NAME_SCIENTIST)
				heirloom_type = /obj/item/toy/plush/slimeplushie
			if(JOB_NAME_ROBOTICIST)
				heirloom_type = pick(subtypesof(/obj/item/toy/prize)) //look at this nerd
			//Medical
			if(JOB_NAME_CHIEFMEDICALOFFICER)
				heirloom_type = pick(/obj/item/clothing/neck/stethoscope, /obj/item/bodybag)
			if(JOB_NAME_MEDICALDOCTOR)
				heirloom_type = pick(/obj/item/clothing/neck/stethoscope, /obj/item/bodybag)
			if(JOB_NAME_PARAMEDIC)
				heirloom_type = pick(/obj/item/bodybag)
			if(JOB_NAME_CHEMIST)
				heirloom_type = /obj/item/reagent_containers/glass/chem_heirloom
			if(JOB_NAME_VIROLOGIST)
				heirloom_type = /obj/item/reagent_containers/dropper
			if(JOB_NAME_GENETICIST)
				heirloom_type = /obj/item/clothing/under/shorts/purple
			//Engineering
			if(JOB_NAME_CHIEFENGINEER)
				heirloom_type = pick(/obj/item/clothing/head/hardhat/white, /obj/item/screwdriver, /obj/item/wrench, /obj/item/weldingtool, /obj/item/crowbar, /obj/item/wirecutters)
			if(JOB_NAME_STATIONENGINEER)
				heirloom_type = pick(/obj/item/clothing/head/hardhat, /obj/item/screwdriver, /obj/item/wrench, /obj/item/weldingtool, /obj/item/crowbar, /obj/item/wirecutters)
			if(JOB_NAME_ATMOSPHERICTECHNICIAN)
				heirloom_type = pick(/obj/item/lighter, /obj/item/lighter/greyscale, /obj/item/storage/box/matches)
			//Supply
			if(JOB_NAME_QUARTERMASTER)
				heirloom_type = pick(/obj/item/stamp, /obj/item/stamp/denied)
			if(JOB_NAME_CARGOTECHNICIAN)
				heirloom_type = /obj/item/clipboard
			if(JOB_NAME_SHAFTMINER)
				heirloom_type = pick(/obj/item/pickaxe/mini, /obj/item/shovel)
			//NSV13 Munitions
			if(JOB_NAME_MASTERATARMS)
				heirloom_type = pick(/obj/item/wrench, /obj/item/screwdriver, /obj/item/multitool, /obj/item/clothing/head/beret/ship/pilot, /obj/item/clothing/accessory/medal/bronze_heart)
			if(JOB_NAME_MUNITIONSTECHNICIAN)
				heirloom_type = pick(/obj/item/wrench, /obj/item/screwdriver, /obj/item/multitool)
			if(JOB_NAME_DECKTECHNICIAN)
				heirloom_type = pick(/obj/item/wrench, /obj/item/screwdriver, /obj/item/multitool)
			if(JOB_NAME_AIRTRAFFICCONTROLLER)
				heirloom_type = pick(/obj/item/clothing/head/beret/ship/pilot, /obj/item/reagent_containers/food/drinks/mug)
			if(JOB_NAME_PILOT)
				heirloom_type = pick(/obj/item/clothing/head/beret/ship/pilot, /obj/item/clothing/accessory/medal/bronze_heart)
			if(JOB_NAME_BRIDGESTAFF)
				heirloom_type = /obj/item/reagent_containers/food/drinks/mug

	if(!heirloom_type)
		heirloom_type = pick(
		/obj/item/toy/cards/deck,
		/obj/item/lighter,
		/obj/item/dice/d20)
	heirloom = new heirloom_type(get_turf(quirk_holder))
	var/list/slots = list(
		"in your left pocket" = ITEM_SLOT_LPOCKET,
		"in your right pocket" = ITEM_SLOT_RPOCKET,
		"in your backpack" = ITEM_SLOT_BACKPACK
	)
	where = H.equip_in_one_of_slots(heirloom, slots, FALSE) || "at your feet"

/datum/quirk/family_heirloom/post_add()
	if(where == "in your backpack")
		var/mob/living/carbon/human/H = quirk_holder
		SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)

	to_chat(quirk_holder, "<span class='boldnotice'>There is a precious family [heirloom.name] [where], passed down from generation to generation. Keep it safe!</span>")

	var/list/names = splittext(quirk_holder.real_name, " ")
	var/family_name = names[names.len]

	heirloom.AddComponent(/datum/component/heirloom, quirk_holder.mind, family_name)
	if(istype(heirloom, /obj/item/reagent_containers/glass/chem_heirloom)) //Edge case for chem_heirloom. Solution to component not being present on init.
		var/obj/item/reagent_containers/glass/chem_heirloom/H = heirloom
		H.update_name()

/datum/quirk/family_heirloom/on_process()
	if(heirloom in quirk_holder.GetAllContents())
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "family_heirloom_missing")
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "family_heirloom", /datum/mood_event/family_heirloom)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "family_heirloom")
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "family_heirloom_missing", /datum/mood_event/family_heirloom_missing)

/datum/quirk/family_heirloom/clone_data()
	return heirloom

/datum/quirk/family_heirloom/on_clone(data)
	heirloom = data

/datum/quirk/frail
	name = "Wiotki"
	desc = "Twoje kości mogłyby równie dobrze być zrobione ze szkła! Twoje kończyny wytrzymują mniej obrażeń, zanim stają się całkowicie bezużyteczne."
	value = -2
	mob_trait = TRAIT_EASYLIMBDISABLE
	gain_text = "<span class='danger'>Czujesz się słabo.</span>"
	lose_text = "<span class='notice'>Wróciła ci krzepa.</span>"
	medical_record_text = "Pacjent ma słabe kości, zalecana jest dieta bogata w białko."

/datum/quirk/foreigner
	name = "Obcokrajowiec"
	desc = "Nie jesteś stąd. Nie znasz Galaktycznego Pospolitego!"
	value = -1
	gain_text = "<span class='notice'>Słowa które mówisz nie mają sensu."
	lose_text = "<span class='notice'>Potrafisz płynnie rozmawiać w Galaktycznym Pospolitym."
	medical_record_text = "Pacjent nie zna Galaktycznego Pospolitego i potrzebuje tłumacza."

/datum/quirk/foreigner/add()
	var/mob/living/carbon/human/H = quirk_holder
	if(ishuman(H) && H.job != JOB_NAME_CURATOR)
		H.add_blocked_language(/datum/language/common)
		H.grant_language(/datum/language/uncommon)

/datum/quirk/foreigner/remove()
	var/mob/living/carbon/human/H = quirk_holder
	if(ishuman(H) && H.job != JOB_NAME_CURATOR)
		H.remove_blocked_language(/datum/language/common)
		H.remove_language(/datum/language/uncommon)

/datum/quirk/heavy_sleeper
	name = "Śpioch"
	desc = "Śpisz jak głaz! Kiedy idziesz spać lub jesteś ogłuszony potrzebujesz więcej czasu, żeby się obudzić."
	value = -1
	mob_trait = TRAIT_HEAVY_SLEEPER
	gain_text = "<span class='danger'>Jesteś senny.</span>"
	lose_text = "<span class='notice'>W końcu się wyspałeś.</span>"
	medical_record_text = "Pacjent wymaga więcej snu i ciężko mu się obudzić."

/datum/quirk/hypersensitive
	name = "Nadczuły"
	desc = "Na lepsze, czy gorsze, wszystko zdaje się bardziej wpływać na twój nastrój niż powinno."
	value = -1
	gain_text = "<span class='danger'>Zaczynasz brać wszystko do siebie.</span>"
	lose_text = "<span class='notice'>Przestałeś brać wszystko do siebie.</span>"
	medical_record_text = "Pacjent przejawia znaczną czułość emocjonalną."

/datum/quirk/hypersensitive/add()
	var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
	if(mood)
		mood.mood_modifier += 0.5

/datum/quirk/hypersensitive/remove()
	var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
	if(mood)
		mood.mood_modifier -= 0.5

/datum/quirk/light_drinker
	name = "Słaba Głowa"
	desc = "Słabo znosisz napoje alkoholowe i szybciej się upijasz."
	value = -1
	mob_trait = TRAIT_LIGHT_DRINKER
	gain_text = "<span class='notice'>Na samą myśl o alkoholu zaczyna ci się kręcić w głowie.</span>"
	lose_text = "<span class='danger'>Przestałeś być tak podatny na alkohol.</span>"
	medical_record_text = "Pacjent wykazał niską tolerancję na alkohol. (Leszcz)"

/datum/quirk/nearsighted //t. errorage
	name = "Krótkowzroczny"
	desc = "Słabo widzisz bez okularów, zaczynasz grę z parą."
	value = -1
	gain_text = "<span class='danger'>Rzeczy z daleka wydają się być rozmazane.</span>"
	lose_text = "<span class='notice'>Znów widzisz normalnie.</span>"
	medical_record_text = "Pacjent wymaga okularów, ze względu na swoją krótkowzroczność."

/datum/quirk/nearsighted/add()
	quirk_holder.become_nearsighted(ROUNDSTART_TRAIT)

/datum/quirk/nearsighted/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/glasses/regular/glasses = new(get_turf(H))
	H.put_in_hands(glasses)
	H.equip_to_slot(glasses, ITEM_SLOT_EYES)
	H.regenerate_icons() //this is to remove the inhand icon, which persists even if it's not in their hands

/datum/quirk/nyctophobia
	name = "Nyktofobia"
	desc = "Odkąd tylko pamiętasz obawiałeś się ciemności. Kiedy jesteś w ciemności, bez źródła światła, zachowujesz się ostrożniej i czujesz lęk."
	value = -1
	medical_record_text = "Pacjent wykazuje strach przed ciemnością. (Serio?)"
	process = TRUE

/datum/quirk/nyctophobia/on_process()
	var/mob/living/carbon/human/H = quirk_holder
	if(H.dna.species.id in list("shadow", "nightmare"))
		return //we're tied with the dark, so we don't get scared of it; don't cleanse outright to avoid cheese
	var/turf/T = get_turf(quirk_holder)
	if(T.get_lumcount() <= 0.2)
		if(quirk_holder.m_intent == MOVE_INTENT_RUN)
			to_chat(quirk_holder, "<span class='warning'>Spokojnie, spokojnie, powoli... jesteś w ciemności...</span>")
			quirk_holder.toggle_move_intent()
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "nyctophobia", /datum/mood_event/nyctophobia)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "nyctophobia")

/datum/quirk/nonviolent
	name = "Pacyfista"
	desc = "Myśl o przemocy przyprawia cię o mdłości. Do tego stopnia, że nie jesteś w stanie nikogo skrzywdzić."
	value = -2
	mob_trait = TRAIT_PACIFISM
	gain_text = "<span class='danger'>Odpycha cię myśl o przemocy!</span>"
	lose_text = "<span class='notice'>Uważasz, że samoobrona jest konieczna.</span>"
	medical_record_text = "Pacjent ma tendencje pacyfistyczne i nie jest w stanie wyrządzić krzywdy."

/datum/quirk/paraplegic
	name = "Sparaliżowany"
	desc = "Twoje nogi nie działają. Nic tego nie naprawi. Ale hej, darmowy wózek inwalidzki!"
	value = -3
	human_only = TRUE
	gain_text = null // Handled by trauma.
	lose_text = null
	medical_record_text = "Pacjent wykazuje nieuleczalny brak funckji motorycznych w kończynach dolnych."

/datum/quirk/paraplegic/add()
	var/datum/brain_trauma/severe/paralysis/paraplegic/T = new()
	var/mob/living/carbon/human/H = quirk_holder
	H.gain_trauma(T, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/paraplegic/on_spawn()
	if(quirk_holder.buckled) // Handle late joins being buckled to arrival shuttle chairs.
		quirk_holder.buckled.unbuckle_mob(quirk_holder)

	var/turf/T = get_turf(quirk_holder)
	var/obj/structure/chair/spawn_chair = locate() in T

	var/obj/vehicle/ridden/wheelchair/wheels = new(T)
	if(spawn_chair) // Makes spawning on the arrivals shuttle more consistent looking
		wheels.setDir(spawn_chair.dir)

	wheels.buckle_mob(quirk_holder)

	// During the spawning process, they may have dropped what they were holding, due to the paralysis
	// So put the things back in their hands.

	for(var/obj/item/I in T)
		if(I.fingerprintslast == quirk_holder.ckey)
			quirk_holder.put_in_hands(I)

/datum/quirk/poor_aim
	name = "Słaby Cel"
	desc = "Masz dwie lewe ręce do pistoletów. Karabiny całkowicie nie wchodzą w rachubę."
	value = -1
	mob_trait = TRAIT_POOR_AIM
	medical_record_text = "Pacjent wykazuje znaczne trzęsienie rąk."

/datum/quirk/prosopagnosia
	name = "Prozopagnozja"
	desc = "Masz chorobę psychiczną unimożliwiającą ci rozpoznawanie twarzy."
	value = -1
	mob_trait = TRAIT_PROSOPAGNOSIA
	medical_record_text = "Pacjent cierpi na prozopagnozję i nie potrafi rozpoznawać twarzy."

/datum/quirk/prosthetic_limb
	name = "Proteza"
	desc = "Wypadek spowodował, że straciłeś jedną z kończyn. Dlatego masz darmową protezę!"
	value = -1
	medical_record_text = "Podczas oględzin, zauważono u pacjenta protezę."
	var/slot_string = "limb"

/datum/quirk/prosthetic_limb/on_spawn()
	var/limb_slot = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/bodypart/old_part = H.get_bodypart(limb_slot)
	var/obj/item/bodypart/prosthetic
	switch(limb_slot)
		if(BODY_ZONE_L_ARM)
			prosthetic = new/obj/item/bodypart/l_arm/robot/surplus(quirk_holder)
			slot_string = "lewa ręka"
		if(BODY_ZONE_R_ARM)
			prosthetic = new/obj/item/bodypart/r_arm/robot/surplus(quirk_holder)
			slot_string = "prawa ręka"
		if(BODY_ZONE_L_LEG)
			prosthetic = new/obj/item/bodypart/l_leg/robot/surplus(quirk_holder)
			slot_string = "lewa noga"
		if(BODY_ZONE_R_LEG)
			prosthetic = new/obj/item/bodypart/r_leg/robot/surplus(quirk_holder)
			slot_string = "prawa noga"
	prosthetic.replace_limb(H)
	qdel(old_part)
	H.regenerate_icons()

/datum/quirk/prosthetic_limb/post_add()
	to_chat(quirk_holder, "<span class='boldannounce'>Twoja [slot_string] została zastąpiona tymczasową protezą. Jest delikatna i z łatwością odleci przy pierwszej okazji. \
	Oprócz tego musisz używać spawarki i przewodów, żeby ją naprawić, zamiast opatrunków i maści.</span>")

/datum/quirk/pushover
	name = "Popychadło"
	desc = "Dajesz ludziom się popychać. Opieranie się chwytom wymaga świadomego wysiłku."
	value = -2
	mob_trait = TRAIT_GRABWEAKNESS
	gain_text = "<span class='danger'>Czujesz się jak popychadło.</span>"
	lose_text = "<span class='notice'>Czujesz, że możesz się postawić.</span>"
	medical_record_text = "Pacjent jest nieasertwyny i łatwy w manipulacji."

/datum/quirk/insanity
	name = "Zaburzenia Dysocjacyjne"
	desc = "Cierpisz na chorobę psychiczną wywołującą znaczne halucynacje. Toksyna Mindbreaker może złagodzić jej efekty, jesteś odporny na halucynacje, które wywołuje <b>To nie licencja na griefowanie.</b>"
	value = -2
	//no mob trait because it's handled uniquely
	gain_text = "<span class='userdanger'>...</span>"
	lose_text = "<span class='notice'>Wracasz do rzeczywistości.</span>"
	medical_record_text = "Pacjent doświadcza poważnych zaburzeń dysocjacyjnych i ma halucynacje."
	process = TRUE

/datum/quirk/insanity/on_process(delta_time)
	if(quirk_holder.reagents.has_reagent(/datum/reagent/toxin/mindbreaker, needs_metabolizing = TRUE))
		quirk_holder.hallucination = 0
		return
	if(DT_PROB(2, delta_time)) //we'll all be mad soon enough
		madness()

/datum/quirk/insanity/proc/madness()
	quirk_holder.hallucination += rand(10, 25)

/datum/quirk/insanity/post_add() //I don't /think/ we'll need this but for newbies who think "roleplay as insane" = "license to kill" it's probably a good thing to have
	if(!quirk_holder.mind || quirk_holder.mind.special_role)
		return
	to_chat(quirk_holder, "<span class='big bold info'>Proszę weź pod uwagę, że twoja choroba psychi NIE daje ci prawa do atakowania ludzi, czy przeszkadzania w rundzie \
	Nie jesteś antagonistą, w świetle zasad jesteś zwykłym członkiem załogi.</span>")

/datum/quirk/social_anxiety
	name = "Fobia Społeczna"
	desc = "Rozmawianie z ludźmi jest dla ciebie trudne. Często się jąkasz lub nawer zamykasz."
	value = -1
	gain_text = "<span class='danger'>Zaczynasz się martwić o to co mówisz.</span>"
	lose_text = "<span class='notice'>Mówienie przychodzi ci z łatwością.</span>" //if only it were that easy!
	medical_record_text = "Pacjent jest niechętny do spotkań toważyskich i często ich unika."
	process = TRUE
	var/dumb_thing = TRUE

/datum/quirk/social_anxiety/on_process(delta_time)
	var/nearby_people = 0
	for(var/mob/living/carbon/human/stranger in oview(3, quirk_holder))
		if(stranger.client)
			nearby_people++
	var/mob/living/carbon/human/H = quirk_holder
	if(DT_PROB(2 + nearby_people, delta_time))
		H.stuttering = max(3, H.stuttering)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "anxiety", /datum/mood_event/anxiety)
	else if(DT_PROB(min(3, nearby_people), delta_time) && !H.silent)
		to_chat(H, "<span class='danger'>Zamykasz się w sobie. <i>Bardzo</i> nie czujesz się na siłach, żeby mówić.</span>")
		H.silent = max(10, H.silent)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "anxiety_mute", /datum/mood_event/anxiety_mute)
	else if(DT_PROB(0.5, delta_time) && dumb_thing)
		to_chat(H, "<span class='userdanger'>Myślisz o głupiej rzeczy, którą kiedyś powiedziałeś i krzyczysz wewnętrznie.</span>")
		dumb_thing = FALSE //only once per life
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "anxiety_dumb", /datum/mood_event/anxiety_dumb)
		if(prob(1))
			new/obj/item/reagent_containers/food/snacks/spaghetti/pastatomato(get_turf(H)) //now that's what I call spaghetti code

//If you want to make some kind of junkie variant, just extend this quirk.
/datum/quirk/junkie
	name = "Ćpun"
	desc = "Twardych narkotyków nigdy dość."
	value = -2
	gain_text = "<span class='danger'>Masz nagle ochotę na odrobinę narkotyków.</span>"
	lose_text = "<span class='notice'>Czujesz, że pora rzucić swój nałóg narkotykowy.</span>"
	medical_record_text = "Pacjent notorycznie zażywa twarde narkotyki."
	process = TRUE
	var/list/drug_list = list(/datum/reagent/drug/crank, /datum/reagent/drug/krokodil, /datum/reagent/medicine/morphine, /datum/reagent/drug/happiness, /datum/reagent/drug/methamphetamine, /datum/reagent/drug/ketamine) //List of possible IDs
	var/datum/reagent/reagent_type //!If this is defined, reagent_id will be unused and the defined reagent type will be instead.
	var/datum/reagent/reagent_instance //! actual instanced version of the reagent
	var/where_drug //! Where the drug spawned
	var/obj/item/drug_container_type //! If this is defined before pill generation, pill generation will be skipped. This is the type of the pill bottle.
	var/where_accessory //! where the accessory spawned
	var/obj/item/accessory_type //! If this is null, an accessory won't be spawned.
	var/process_interval = 30 SECONDS //! how frequently the quirk processes
	var/next_process = 0 //! ticker for processing

/datum/quirk/junkie/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	if (!reagent_type)
		reagent_type = pick(drug_list)
	reagent_instance = new reagent_type()
	H.reagents.addiction_list.Add(reagent_instance)
	var/current_turf = get_turf(quirk_holder)
	if (!drug_container_type)
		drug_container_type = /obj/item/storage/pill_bottle
	var/obj/item/drug_instance = new drug_container_type(current_turf)
	if (istype(drug_instance, /obj/item/storage/pill_bottle))
		var/pill_state = "pill[rand(1,20)]"
		for(var/i in 1 to 7)
			var/obj/item/reagent_containers/pill/P = new(drug_instance)
			P.icon_state = pill_state
			P.reagents.add_reagent(reagent_type, 1)

	var/obj/item/accessory_instance
	if (accessory_type)
		accessory_instance = new accessory_type(current_turf)
	var/list/slots = list(
		"w twojej lewej kieszeni" = ITEM_SLOT_LPOCKET,
		"w twojej prawej kieszeni" = ITEM_SLOT_RPOCKET,
		"w twoim plecaku" = ITEM_SLOT_BACKPACK
	)
	where_drug = H.equip_in_one_of_slots(drug_instance, slots, FALSE) || "pod twoimi stopami"
	if (accessory_instance)
		where_accessory = H.equip_in_one_of_slots(accessory_instance, slots, FALSE) || "pod twoimi stopami"
	announce_drugs()

/datum/quirk/junkie/post_add()
	if(where_drug == "w twoim plecaku" || where_accessory == "w twoim plecaku")
		var/mob/living/carbon/human/H = quirk_holder
		SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)

/datum/quirk/junkie/proc/announce_drugs()
	to_chat(quirk_holder, "<span class='boldnotice'>Masz [initial(drug_container_type.name)] [initial(reagent_type.name)] [where_drug]. Lepiej żeby tyle ci wsytarczyło...</span>")

/datum/quirk/junkie/on_process()
	var/mob/living/carbon/human/H = quirk_holder
	if(world.time > next_process)
		next_process = world.time + process_interval
		if(!H.reagents.addiction_list.Find(reagent_instance))
			if(QDELETED(reagent_instance))
				reagent_instance = new reagent_type()
			else
				reagent_instance.addiction_stage = 0
			H.reagents.addiction_list += reagent_instance
			to_chat(quirk_holder, "<span class='danger'>Myślałeś, że pokonałeś już nałóg, ale potzrebujesz kolejnej dawki [reagent_instance.name]...</span>")

/datum/quirk/junkie/smoker
	name = "Palacz"
	desc = "Czasami naprawdę potrzebujesz zapalić. To nie może być dobre dla twoich płuc."
	value = -1
	gain_text = "<span class='danger'>Masz ochotę zajarać.</span>"
	lose_text = "<span class='notice'>Czujesz, że pora rzucić palenie.</span>"
	medical_record_text = "Pacjent jest palaczem."
	reagent_type = /datum/reagent/drug/nicotine
	accessory_type = /obj/item/lighter/greyscale
	process = TRUE

/datum/quirk/junkie/smoker/on_spawn()
	drug_container_type = pick(/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/fancy/cigarettes/cigpack_midori,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift,
		/obj/item/storage/fancy/cigarettes/cigpack_robust,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold,
		/obj/item/storage/fancy/cigarettes/cigpack_carp)
	. = ..()

/datum/quirk/junkie/smoker/announce_drugs()
	to_chat(quirk_holder, "<span class='boldnotice'>Masz [initial(drug_container_type.name)] [where_drug], i zapalniczkę [where_accessory]. Upewnij się, że kupujesz swoją ulubioną paczkę, kiedy ta ci się skończy.</span>")


/datum/quirk/junkie/smoker/on_process()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/I = H.get_item_by_slot(ITEM_SLOT_MASK)
	if (istype(I, /obj/item/clothing/mask/cigarette))
		var/obj/item/storage/fancy/cigarettes/C = drug_container_type
		if(istype(I, initial(C.spawn_type)))
			SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "wrong_cigs")
			return
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "wrong_cigs", /datum/mood_event/wrong_brand)

/datum/quirk/alcoholic
	name = "Alcoholic"
	desc = "You can't stand being sober."
	value = -1
	gain_text = "<span class='danger'>You could really go for a drink right about now.</span>"
	lose_text = "<span class='notice'>You feel like you should quit drinking.</span>"
	medical_record_text = "Patient is an alcohol abuser."
	process = TRUE
	var/where_drink //Where the bottle spawned
	var/drink_types = list(/obj/item/reagent_containers/food/drinks/bottle/ale,
					/obj/item/reagent_containers/food/drinks/bottle/beer,
					/obj/item/reagent_containers/food/drinks/bottle/gin,
		            /obj/item/reagent_containers/food/drinks/bottle/whiskey,
					/obj/item/reagent_containers/food/drinks/bottle/vodka,
					/obj/item/reagent_containers/food/drinks/bottle/rum,
					/obj/item/reagent_containers/food/drinks/bottle/applejack)
	var/need = 0 // How much they crave alcohol at the moment
	var/tick_number = 0 // Keeping track of how many ticks have passed between a check
	var/obj/item/reagent_containers/food/drinks/bottle/drink_instance

/datum/quirk/alcoholic/on_spawn()
	drink_instance = pick(drink_types)
	drink_instance = new drink_instance()
	var/list/slots = list("in your backpack" = ITEM_SLOT_BACKPACK)
	var/mob/living/carbon/human/H = quirk_holder
	where_drink = H.equip_in_one_of_slots(drink_instance, slots, FALSE) || "at your feet"

/datum/quirk/alcoholic/post_add()
	to_chat(quirk_holder, "<span class='boldnotice'>There is a small bottle of [drink_instance] [where_drink]. You only have a single bottle, might have to find some more...</span>")

/datum/quirk/alcoholic/on_process()
	if(tick_number >= 6) // how many ticks should pass between a check
		tick_number = 0
		var/mob/living/carbon/human/H = quirk_holder
		if(H.drunkenness > 0) // If they're not drunk, need goes up. else they're satisfied
			need = -15
		else
			need++

		switch(need)
			if(1 to 10)
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "alcoholic", /datum/mood_event/withdrawal_light, "alcohol")
				if(prob(5))
					to_chat(H, "<span class='notice'>You could go for a drink right about now.</span>")
			if(10 to 20)
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "alcoholic", /datum/mood_event/withdrawal_medium, "alcohol")
				if(prob(5))
					to_chat(H, "<span class='notice'>You feel like you need alcohol. You just can't stand being sober.</span>")
			if(20 to 30)
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "alcoholic", /datum/mood_event/withdrawal_severe, "alcohol")
				if(prob(5))
					to_chat(H, "<span class='danger'>You have an intense craving for a drink.</span>")
			if(30 to INFINITY)
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "alcoholic", /datum/mood_event/withdrawal_critical, "Alcohol")
				if(prob(5))
					to_chat(H, "<span class='boldannounce'>You're not feeling good at all! You really need some alcohol.</span>")
			else
				SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "alcoholic")
	tick_number++

/datum/quirk/unstable
	name = "Niestabilny"
	desc = "Przez błędy przeszłości nie jesteś w stanie odzyskać zdrowia psychicznego, jeśli je stracisz. Dbaj o dobry nastrój!"
	value = -2
	mob_trait = TRAIT_UNSTABLE
	gain_text = "<span class='danger'>Masz sporo na głowie.</span>"
	lose_text = "<span class='notice'>W twojej głowie wreszcie zapanował spokój.</span>"
	medical_record_text = "Umysł pacjenta jest w wrażliwym stanie, musi dbać o swoje zdrowie psychiczne."

/datum/quirk/phobia
	name = "Fobia"
	desc = "Czujesz irracjonalny lęk przed czymś."
	value = -2
	gain_text = "<span class='danger'>You start feeling an irrational fear of something.</span>"
	lose_text = "<span class='notice'>You are no longer irrationally afraid.</span>"
	medical_record_text = "Pacjent odczuwa irracjonalny strach przed czymś."

/datum/quirk/phobia/add()
	var/datum/brain_trauma/mild/phobia/T = new()
	var/mob/living/carbon/human/H = quirk_holder
	H.gain_trauma(T, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/phobia/remove()
	var/mob/living/carbon/human/H = quirk_holder
	H.cure_trauma_type(/datum/brain_trauma/mild/phobia, TRAUMA_RESILIENCE_ABSOLUTE)
