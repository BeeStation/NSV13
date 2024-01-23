//predominantly positive traits
//this file is named weirdly so that positive traits are listed above negative ones

/datum/quirk/alcohol_tolerance
	name = "Tolerancja Alkoholowa"
	desc = "Upijasz się wolniej i masz mniej skutków negatywnych z picia alkoholu."
	value = 1
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = "<span class='notice'>Czujesz jakbyś mógł wypić wannę amareny!</span>"
	lose_text = "<span class='danger'>Nie czujesz się już tak samo odporny na alkohol. Jakimś cudem.</span>"
	medical_record_text = "Pacjent wykazuje niespotykaną tolerancję na alkohol."

/datum/quirk/apathetic
	name = "Apatyczny"
	desc = "Po prostu nie przejmujesz się tak bardzo jak inni. To chyba dobrze, w takim miejscu jak to."
	value = 1
	mood_quirk = TRUE
	medical_record_text = "Pacjentowi podano Test Ewaluacji Apatii, jednak nie przejął się nim na tyle, żeby go uzupełnić."

/datum/quirk/apathetic/add()
	var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
	if(mood)
		mood.mood_modifier -= 0.2

/datum/quirk/apathetic/remove()
	var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
	if(mood)
		mood.mood_modifier += 0.2

/datum/quirk/drunkhealing
	name = "Zdrowie Żula"
	desc = "Nie ma nic lepszego do postawienia cię na nogi, niż szklaneczka czegoś mocnego. Kiedy jesteś pijany powoli odzyskujesz zdrowie."
	value = 2
	mob_trait = TRAIT_DRUNK_HEALING
	gain_text = "<span class='notice'>Czujesz, że napicie się czegoś nie byłoby takim złym pomysłem.</span>"
	lose_text = "<span class='danger'>Czujesz, że alkohol nie jest rozwiązaniem.</span>"
	medical_record_text = "Pacjent ma zaskakująco wydajny metabolizm i potafi powoli leczyć swoje rany poprzez spożywanie trunków alkoholowych."

/datum/quirk/empath
	name = "Empatia"
	desc = "Czy to przez szósty zmysł, czy dokładną obserwację języka ciała, jesteś w stanie określić jak się ktoś czuje zaledwie poprzez szybkie spojrzenie."
	value = 2
	mob_trait = TRAIT_EMPATH
	gain_text = "<span class='notice'>Zaczynasz rozumieć otaczających cię ludzi.</span>"
	lose_text = "<span class='danger'>Przestałeś rozumieć emocje innych.</span>"
	medical_record_text = "Pacjent zwraca wiele uwagi i jest wrażliwy na cudze uczucia lub choruje na ESP. Potrzebne więcej badań."

/datum/quirk/freerunning
	name = "Mistrz Parkour"
	desc = "Jesteś mistrzem zręczności i szybkości! Wspinasz się na stoły szybciej."
	value = 2
	mob_trait = TRAIT_FREERUNNING
	gain_text = "<span class='notice'>Czujesz, że mógłbyś zrobić salto!</span>"
	lose_text = "<span class='danger'>Czujesz się niezdarnie.</span>"
	medical_record_text = "Pacjent zdał testy sprawnościowe celująco."

/datum/quirk/friendly
	name = "Przyjacielski"
	desc = "Dajesz najlepsze przytulasy, zwłaszcza gdy sam czujesz się świetnie."
	value = 1
	mob_trait = TRAIT_FRIENDLY
	gain_text = "<span class='notice'>Chcesz kogoś przytulić.</span>"
	lose_text = "<span class='danger'>Nie ciągnie cię już do przytulania innych.</span>"
	mood_quirk = TRUE
	medical_record_text = "Pacjent wykazuje tendencję do przyjaznych kontaktów fizycznych oraz posiada rozwinięte kończyny górne. Wnoszę o przeniesienie przypadku do innego doktora."

/datum/quirk/jolly
	name = "Wesoły"
	desc = "Czasami czujesz się szczęśliwszy bez powodu."
	value = 1
	mob_trait = TRAIT_JOLLY
	mood_quirk = TRUE
	process = TRUE
	medical_record_text = "Pacjent produkuje endorfiny w ilościach zbyt dużych jak na aktualne warunki."

/datum/quirk/jolly/on_process(delta_time)
	if(DT_PROB(0.05, delta_time))
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "jolly", /datum/mood_event/jolly)

/datum/quirk/light_step
	name = "Lekki krok"
	desc = "Suniesz gładko po ziemi; kroki i chodzenie po szkle są cichsze oraz mniej bolesne."
	value = 1
	mob_trait = TRAIT_LIGHT_STEP
	gain_text = "<span class='notice'>Twoje stopy wydają się być lekkie jak piórko.</span>"
	lose_text = "<span class='danger'>Stompasz ciężko po ziemi jak barbarzyńca.</span>"
	medical_record_text = "Pacjent wykazuje znaczną zręczność i umiejętności skradania."

/datum/quirk/musician
	name = "Muzyk"
	desc = "Potrafisz grać dźwięki, które leczą niektóre rany na duszy."
	value = 1
	mob_trait = TRAIT_MUSICIAN
	gain_text = "<span class='notice'>Wiesz wszystko o instrumentach muzycznych.</span>"
	lose_text = "<span class='danger'>Zapomniałeś jak działają instrumenty muzyczne.</span>"
	medical_record_text = "Skany mózgu pacjenta wykazały znaczne rozwinięcie płatu odpowiedzialnego za poczucie rytmu."

/datum/quirk/musician/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/choice_beacon/music/B = new(get_turf(H))
	var/list/slots = list (
		"backpack" = ITEM_SLOT_BACKPACK,
		"hands" = ITEM_SLOT_HANDS,
	)
	H.equip_in_one_of_slots(B, slots , qdel_on_fail = TRUE)

/datum/quirk/multilingual
	name = "Poliglota"
	desc = "Spędziłeś część swojego życia na nauce rozumienia dodatkowego języka. Możesz lub nie posługiwać się nim w zależności od twojej anatomii."
	value = 1
	mob_trait = TRAIT_MULTILINGUAL
	gain_text = "<span class='notice'>Nauczyłeś się rozumieć dodatkowy język.</span>"
	lose_text = "<span class='danger'>Zapomniałeś jak rozumieć język.</span>"

/datum/quirk/multilingual/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	if(H.job == JOB_NAME_CURATOR)
		return
	var/obj/item/organ/tongue/T = H.getorganslot(ORGAN_SLOT_TONGUE)
	var/list/languages_possible = T.languages_possible
	languages_possible = languages_possible - typecacheof(/datum/language/codespeak) - typecacheof(/datum/language/narsie) - typecacheof(/datum/language/ratvar)
	languages_possible = languages_possible - H.language_holder.understood_languages
	languages_possible = languages_possible - H.language_holder.spoken_languages
	languages_possible = languages_possible - H.language_holder.blocked_languages
	if(length(languages_possible))
		var/datum/language/random_language = pick(languages_possible)
		H.grant_language(random_language, TRUE, TRUE, LANGUAGE_MULTILINGUAL)
//Credit To Yowii/Yoworii/Yorii for a much more streamlined method of language library building

/datum/quirk/night_vision
	name = "Noktowizja"
	desc = "Widzisz w ciemności lepiej niż większość osób."
	value = 1
	mob_trait = TRAIT_NIGHT_VISION
	gain_text = "<span class='notice'>Cienie wydają się mniej ciemne.</span>"
	lose_text = "<span class='danger'>Wszystko wydaje się nagle bardziej przyciemnione.</span>"
	medical_record_text = "Oczy pacjenta wykazują przystosowanie do ciemniejszego środowiska."

/datum/quirk/night_vision/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/eyes/eyes = H.getorgan(/obj/item/organ/eyes)
	if(!eyes || eyes.lighting_alpha)
		return
	eyes.Insert(H) //refresh their eyesight and vision

/datum/quirk/photographer
	name = "Fotograf"
	desc = "Wszędzie nosisz ze sobą swój aparat i album na zdjęcia, które potrafisz robić szybciej niż większość"
	value = 1
	mob_trait = TRAIT_PHOTOGRAPHER
	gain_text = "<span class='notice'>Wiesz wszystko o fotografii.</span>"
	lose_text = "<span class='danger'>Zapomniałeś jak działa aparat.</span>"
	medical_record_text = "Pacjent wskazał fotografię jako swój ulubiony sposób na odstresowanie."

/datum/quirk/photographer/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/camera/camera = new(get_turf(H))
	var/list/camera_slots = list (
		"neck" = ITEM_SLOT_NECK,
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET,
		"backpack" = ITEM_SLOT_BACKPACK,
		"hands" = ITEM_SLOT_HANDS
	)
	H.equip_in_one_of_slots(camera, camera_slots , qdel_on_fail = TRUE)
	H.regenerate_icons()

/datum/quirk/selfaware
	name = "Samoświadomy"
	desc = "Dobrze znasz swoje ciało i potrafisz dokładnie stwierdzić rozmiar swoich urazów."
	value = 2
	mob_trait = TRAIT_SELF_AWARE
	medical_record_text = "Pacjent wykazuje niepokojąco dokładne zdolności samodiagnostyczne."

/datum/quirk/skittish
	name = "Płochliwy"
	desc = "Potrafisz szybko odciąć się od zagrożenia. Kliknij na zamkniętą szafkę przytrzymując ctrl + shift, żeby do niej wskoczyć, jeśli posiadasz do niej dostęp."
	value = 2
	mob_trait = TRAIT_SKITTISH
	medical_record_text = "Pacjent wykazuje znaczną obawę przed zagrożeniem i często ze strachu ukrywa się w różnych pojemnikach."

/datum/quirk/spiritual
	name = "Uduchowiony"
	desc = "Jesteś głęboko wierzący, czy to w Boga, czy prawa rządzące wszechświatem. Czujesz się komfortowo w otoczeniu świętych osób, a twoje modlitwy są częściej wysłuchiwane."
	value = 1
	mob_trait = TRAIT_SPIRITUAL
	gain_text = "<span class='notice'>Wierzysz w siłę wyższą.</span>"
	lose_text = "<span class='danger'>Straciłeś wiarę!</span>"
	medical_record_text = "Pacjent wyraził wiarę w siłę wyższą."
	process = TRUE

/datum/quirk/spiritual/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	H.equip_to_slot_or_del(new /obj/item/storage/fancy/candle_box(H), ITEM_SLOT_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/matches(H), ITEM_SLOT_BACKPACK)

/datum/quirk/spiritual/on_process()
	var/comforted = FALSE
	for(var/mob/living/carbon/human/H in oview(5, quirk_holder))
		if(H.mind?.holy_role && H.stat == CONSCIOUS)
			comforted = TRUE
			break
	if(comforted)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "religious_comfort", /datum/mood_event/religiously_comforted)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "religious_comfort")

/datum/quirk/tagger
	name = "Graficiarz"
	desc = "Jesteś doświadczonym artystą. Ludziom naprawdę podobają sie twoje rysunki, twoje przybory artystyczne mają dwa razy więcej użyć."
	value = 1
	mob_trait = TRAIT_TAGGER
	gain_text = "<span class='notice'>Masz ochotę walnąć taga na ścianie.</span>"
	lose_text = "<span class='danger'>Tagowanie jednak ci się znudziło.</span>"
	medical_record_text = "Pacjent był zamieszany w incydent z wąchaniem farby."

/datum/quirk/tagger/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/toy/crayon/spraycan/spraycan = new(get_turf(H))
	H.put_in_hands(spraycan)
	H.equip_to_slot(spraycan, ITEM_SLOT_BACKPACK)
	H.regenerate_icons()

/datum/quirk/voracious
	name = "Żarłoczny"
	desc = "Nic nie może stanąć między tobą, a jedzeniem. Jesz szybciej i możesz obżerać się śmieciowym żarciem! Bycie otyłym ci pasuje."
	value = 1
	mob_trait = TRAIT_VORACIOUS
	gain_text = "<span class='notice'>Czujesz się WYGŁODNIAŁY.</span>"
	lose_text = "<span class='danger'>Już nie czujesz się WYGŁODNIAŁY.</span>"

/datum/quirk/neet
	name = "Socjals"
	desc = "Z jakiegoś powodu zakwalifikowałeś się do programu opieki społecznej i nie bardzo dbasz o własną higienę osobistą." //NSV13 - kept hygiene
	value = 1
	mob_trait = TRAIT_NEET
	gain_text = "<span class='notice'>czujesz się bezużyteczny dla społeczeństwa.</span>"
	lose_text = "<span class='danger'>Już nie czujesz się bezużyteczny dla społeczeństwa.</span>"
	mood_quirk = TRUE
	process = TRUE

/datum/quirk/neet/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/datum/bank_account/D = H.get_bank_account()
	if(!D) //if their current mob doesn't have a bank account, likely due to them being a special role (ie nuke op)
		return
	D.welfare = TRUE

// NSV13 - kept hygiene
/datum/quirk/neet/on_process()
	var/mob/living/carbon/human/H = quirk_holder
	if (H.hygiene <= HYGIENE_LEVEL_DIRTY)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "NEET", /datum/mood_event/happy_neet)
	else
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "NEET")
