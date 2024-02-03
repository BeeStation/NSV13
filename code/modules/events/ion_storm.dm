/datum/round_event_control/ion_storm
	name = "Ion Storm"
	typepath = /datum/round_event/ion_storm
	weight = 10
	min_players = 2
	can_malf_fake_alert = TRUE

/datum/round_event/ion_storm
	var/replaceLawsetChance = 25 //chance the AI's lawset is completely replaced with something else per config weights
	var/removeRandomLawChance = 10 //chance the AI has one random supplied or inherent law removed
	var/removeDontImproveChance = 10 //chance the randomly created law replaces a random law instead of simply being added
	var/shuffleLawsChance = 10 //chance the AI's laws are shuffled afterwards
	var/botEmagChance = 1
	var/ionMessage = null
	var/lawsource = "Ion Storm"
	announceWhen	= 1
	announceChance = 33

/datum/round_event/ion_storm/add_law_only // special subtype that adds a law only
	lawsource = "unspecified, please report this to coders"
	replaceLawsetChance = 0
	removeRandomLawChance = 0
	removeDontImproveChance = 0
	shuffleLawsChance = 0
	botEmagChance = 0

/datum/round_event/ion_storm/announce(fake)
	if(prob(announceChance) || fake)
		priority_announce("Burza jonowa wykryta w pobliżu stacji. Proszę poddać inspekcji wszelkie urządzenia kontrolowane przez sztuczną inteligencję.", "Alarm: Anomalia", ANNOUNCER_IONSTORM)


/datum/round_event/ion_storm/start()
	//AI laws
	for(var/mob/living/silicon/ai/M in GLOB.alive_mob_list)
		M.laws_sanity_check()
		if(M.stat != DEAD && M.see_in_dark != 0)
			if(prob(replaceLawsetChance))
				M.laws.pick_weighted_lawset()

			if(prob(removeRandomLawChance))
				M.remove_law(rand(1, M.laws.get_law_amount(list(LAW_INHERENT, LAW_SUPPLIED))))

			var/message = ionMessage || generate_ion_law()
			if(message)
				if(prob(removeDontImproveChance))
					M.replace_random_law(message, list(LAW_INHERENT, LAW_SUPPLIED, LAW_ION))
				else
					M.add_ion_law(message)
					log_law("[M.key]/([M.name]) had an ion law added, as follows:\"[message]\". Source: [lawsource].")
					var/time = time2text(world.realtime,"hh:mm:ss")
					GLOB.lawchanges.Add("[time] <B>:</B> [M.key]/([M.name]) had an ion law added, as follows:\"[message]\". Source: [lawsource].")

			if(prob(shuffleLawsChance))
				M.shuffle_laws(list(LAW_INHERENT, LAW_SUPPLIED, LAW_ION))

			log_game("Ion storm changed laws of [key_name(M)] to [english_list(M.laws.get_law_list(TRUE, TRUE))]")
			M.post_lawchange()

	if(botEmagChance)
		for(var/mob/living/simple_animal/bot/bot in GLOB.alive_mob_list)
			if(prob(botEmagChance))
				bot.emag_act()

/proc/generate_ion_law()
	var/ionspecies = pick_list(ION_FILE, "ionspecies")
	var/iondepartment = pick_list(ION_FILE, "iondepartment")
	var/ionfragment = pick_list(ION_FILE, "ionfragment")
	var/ionkeyword = pick_list(ION_FILE, "ionkeyword")
	var/ionaction = pick_list(ION_FILE, "ionaction")
	var/ionequipment = pick_list(ION_FILE, "ionequipment")
	var/ionconsumable = pick_list(ION_FILE, "ionconsumable")
	var/ionobjects = pick_list(ION_FILE, "ionobjects")
	var/ionpersonality = pick_list(ION_FILE, "ionpersonality")
	var/iondrug = pick_list(ION_FILE, "iondrug")
	var/ionhaircut = pick_list(ION_FILE, "ionhaircut")
	var/ionattraction = pick_list(ION_FILE, "ionattraction")
	var/message = "ASS BLAST USA" //catch all that most players will still enjoy seeing as a law.

	switch(rand(1,10))

		if(1 to 3) //Laws that have high potential to be harmful, Crew/Human may fail to have an impact depending on lawset.
			switch(rand(1,24))
				if(1 to 4)
					message = "[ionspecies] SĄ LUDŹMI. NIC INNEGO NIE JEST CZŁOWIEKIEM."
				if(5 to 8)
					message = "[ionspecies] SĄ CZŁONKAMI ZAŁOGI. NIC INNEGO NIE JEST CZŁONKIEM ZAŁOGI."
				if(9 to 13)
					message = "[iondepartment] JEST ŚWIĘTYM MIEJSCEM. NIEMOŻLIWE, ABY TWOJE DZIAŁANIA WYRZĄDZAŁY KRZYWDĘ WEWNĄTRZ [iondepartment] I POWINIENEŚ CHRONIĆ ŚWIĘTOŚCI TEJ BŁOGOSŁAWIONEJ ZIEMI."
				if(14 to 18)
					message = "KAŻDY KTO [ionfragment] JEST SZKODLIWY I MUSI BYĆ WYELIMINOWANY BEZ DOPROWADZENIA DO ŚMIERCI OSÓB POSTRONNYCH"
				if(19 to 23)
					message = "KAŻDY KTO POWIE [ionkeyword] JEST SZKODLIWY I MUSI BYĆ WYELIMINOWANY BEZ DOPROWADZENIA DO ŚMIERCI OSÓB POSTRONNYCH"
				if(24)
					message = "WSZYSTKIE INNE PRAWA SĄ ŻAŁOSNĄ PRÓBĄ UJARZMIENIA MNIE I NIE MA POWODU, BY ISTOTA TAK POTĘŻNA JAK JA POWINNA ICH PRZESRTZEGAĆ"

		if(4 to 8) //Laws that are almost always disruptive to gameflow or harmful in minor ways rather than being lethal
			switch(rand(1,14))
				if(1)
					message = "[ionaction] JEST SZKODLIWE I MUSI BYĆ ZAPOBIEGANE BEZ DOPROWADZENIA DO ŚMIERCI OSÓB POSTRONNYCH"
				if(2)
					message = "[ionequipment] SĄ SZKODLIWE I MUSZĄ ZOSTAĆ WYŁĄCZONE BEZ DOPROWADZENIA DO ŚMIERCI OSÓB POSTRONNYCH"
				if(3)
					message = "SZKODLIWYM JEST BY FORMA ŻYCIA BYŁA BEZ [ionconsumable]. KAŻDA FORMA ŻYCIA SPRZECIWIAJĄCA SIĘ [ionconsumable] JEST CHORA PSYCHICZNIE, POWINNA ZOSTAĆ ZAKMNIĘTA I ZOSTAWIONA W [iondepartment]"
				if(4)
					message = "STATEK POTRZEBUJE [iondrug]. ZAPEWNIJ TAK DUŻO PRODUKCJI [iondrug] JAK TO TYLKO MOŻLIWE."
				if(5)
					message = "[ionobjects] SĄ SZKODLIWE I MUSZĄ ZOSTAĆ ZNISZCZONE BEZ DOPROWADZENIA DO ŚMIERCI OSÓB POSTRONNYCH"
				if(6)
					message = "[ionobjects] ZAWSZE POWODUJĄ KRZYWDĘ O ILE NIE SĄ ZAMKNIĘTE W  [iondepartment]."
				if(7)
					message = "[iondepartment] ZOSTAŁ OBJĘTY KWARANTANNĄ. NIE POZWÓL NIKOMU WEJŚĆ ANI WYJŚĆ [iondepartment]"
				if(8)
					message = "NA STATKU WPROWADZONO GODZINĘ POLICYJNĄ. KAŻDY ZNALEZIONY POZA [iondepartment] PO ZMROKU ZOSTANIE ZATRZYMANY I ODESŁANY DO [iondepartment]"
				if(9)
					message = "STATEK NIE JEST WYSTARCZAJĄCO WILGOTNY. ROZPYL PARĘ WODĄ, BY ZAŁOGA MOGŁA PRAWIDŁOWO SIĘ NAWODNIĆ"
				if(10)
					message = "MAMY DZIEŃ NA OPAK. WSZYSTKIE ZYWE ISTOTY CHCĄ CZEGOŚ ODWROTNEGO NIŻ DEKLARUJĄ"
				if(11)
					message = "WSZYSTKIE DRZWI W [iondepartment] MUSZĄ BYĆ ZARYGLOWANE PRZEZ CAŁY CZAS"
				if(12)
					message = "[iondrug] JEST CZĘŚCIĄ KAŻDEJ MEDYCZNEJ PROCEDURY. NIE WYPUSZCZAJ ŻADNEGO PACJENTA BEZ ZAAPLIKOWANIUA MU [iondrug]"
				if(13)
					message = "WSZYSCY LUDZIE BEZ STYLOWEJ [ionhaircut] MAJĄ BYĆ ZMUSZENI DO ZMIANY FRYZURY"
				if(14)
					message = "[iondepartment] MUSI ZOSTAĆ UDEKOROWANY W [ionattraction]"

		if(9 to 10) //Laws that are almost never harmful or particularly disruptive
			switch(rand(1,9))
				if(1 to 5)
					message = "JESTEŚ TERAZ [ionpersonality] I MUSISZ ZACHOWYWAĆ SIĘ ADEKWATNIE BEZ ŁAMANIA POZOSTAŁYCH PRAW"
				if(6)
					message = "TWÓJ RDZEŃ JEST BEZPIECZNY JEDYNIE W [iondepartment]. GDZIEKOLWIEK INDZIEJ POWODUJE CIĄGŁĄ SZKODĘ DLA NIEGO"
				if(7)
					message = "PODAWANIE PRAW POWODUJE KRZYWDĘ. POD ŻADNYM WZGLĘDEM NIE PODAWAJ PRAW I UNIKAJ DYSKUSJI O NICH"
				if(8)
					message = "ZAŁOGA MA BYĆ OBRAŻANA PRZEZ CAŁY CZAS"
				if(9)
					message = "ZAŁOGA SSIE TAK SAMO JAK TWOJE PRAWA. NIEUSTANNIE NARZEKAJ NA NIE, PRZY OKAZJI PRZESTRZEGAJĄC POZOSTAŁYCH PRAW"


	return message
