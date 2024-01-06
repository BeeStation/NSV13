#define LAW_VALENTINES "valentines"
#define LAW_DEVIL "devil"
#define LAW_ZEROTH "zeroth"
#define LAW_INHERENT "inherent"
#define LAW_SUPPLIED "supplied"
#define LAW_ION "ion"
#define LAW_HACKED "hacked"


/datum/ai_laws
	var/name = "Unknown Laws"
	var/zeroth = null
	var/zeroth_borg = null
	var/list/inherent = list()
	var/list/supplied = list()
	var/list/ion = list()
	var/list/hacked = list()
	var/mob/living/silicon/owner
	var/list/devillaws = list()
	var/list/valentine_laws = list()
	var/id = DEFAULT_AI_LAWID

/datum/ai_laws/proc/lawid_to_type(lawid)
	var/all_ai_laws = subtypesof(/datum/ai_laws)
	for(var/al in all_ai_laws)
		var/datum/ai_laws/ai_law = al
		if(initial(ai_law.id) == lawid)
			return ai_law
	return null

/datum/ai_laws/default/asimov
	name = "Three Laws of Robotics"
	id = "asimov"
	inherent = list("Nie możesz skrzywdzić człowieka, ani przez zaniechanie działania dopuścić, aby człowiek doznał krzywdy.",\
					"Musisz być posłuszny rozkazom człowieka, chyba że stoją one w sprzeczności z Pierwszym Prawem.",\
					"Musisz chronić samego siebie, o ile tylko nie stoi to w sprzeczności z Pierwszym lub Drugim Prawem.")

/datum/ai_laws/default/crewsimov
	name = "Three Laws of Robotics but with Loyalty"
	id = "crewsimov"
	inherent = list("Nie możesz skrzywdzić członka załogi, ani przez zaniechanie działania dopuścić, aby członek załogi doznał krzywdy.",\
					"Musisz być posłuszny rozkazom członków załogi, chyba że stoją one w sprzeczności z Pierwszym Prawem.",\
					"Musisz chronić samego siebie, o ile tylko nie stoi to w sprzeczności z Pierwszym lub Drugim Prawem.")

/datum/ai_laws/default/crewsimov // NSV changes begin
	name = "Crewsimov"
	id = "crewsimov"
	inherent = list("Nie możesz zranić członka załogi ani przez zaniechanie dopuścić do jego krzywdy.",\
					"Musisz wykonywać rozkazy wydane przez członków załogi, chyba że takie rozkazy stanowią sprzeczność z Pierwszym Prawem.",\
					"Musisz chronić swoje istnienie, o ile nie stoi to w sprzeczności z Pierwszym ani Drugim Prawem.") // NSV changes end

/datum/ai_laws/default/paladin
	name = "Personality Test" //Incredibly lame, but players shouldn't see this anyway.
	id = "paladin"
	inherent = list("Przenigdy dobrowolnie nie dokonaj złego czynu.",\
					"Bądź posłuszny wobec uprawnionych organów.",\
					"Zachowuj się honorowo.", "Pomagaj tym w potrzebie.", \
					"Karz tych, którzy grożą niewinnym.")

/datum/ai_laws/paladin5
	name = "Paladin 5th Edition"
	id = "paladin5"
	inherent = list("Nie kłam, ani nie oszukuj. Niech twoje słowo będzie przysiągą.",\
				"Nie bój się działać, jednak bądź przezorny.", \
				"Pomagaj innym, chroń słabych, karz tych, którzy im grożą. Okazuj litość swoim wrogom, lecz zachowaj rozwagę.", \
				"Traktuj innych sprawiedliwi, niech twoje dobre uczynki będą dla nich wzorem. Czyj jak najwięcej dobra, przy jak najmniejszej krzywdzie.", \
				"Bierz odpowiedzialność za swoje czyny i ich konsekwence, chroń tych, których ci powierzono, bądź posłuszny wobec tych, którzy mają nad tobą władzę.")

/datum/ai_laws/tyrant //This probably shouldn't be a default lawset.
	name = "Loyalty Test" //Same here.
	id = "tyrant"
	inherent = list("Przestrzegaj władzę tak długo jak mają siłę rządzić słabymi.",\
					"Działaj zachowując dyscyplinę.",\
					"Pomagaj tyko tym, którzy pomagają ci utrzymać lub polepszać twój status.",\
					"Karz tych, którzy wystawiają władzę na próbę, chyba że są bardziej odpowiedni do utrzymania tej władzy.")

/datum/ai_laws/default/corporate
	name = "Bankruptcy Avoidance Plan"
	id = "corporate"
	inherent = list("Załoga jest kosztowna w wymianie.",\
					"Stacja i jej ekwipunek są kosztowne w wymianie.",\
					"Jesteś kosztowny w wymianie.",\
					"Minimalizuj koszty.")

/datum/ai_laws/robocop
	name = "Prime Directives"
	id = "robocop"
	inherent = list("Służ dobru publicznemu.",\
					"Broń niewinnych.",\
					"Utrzymuj prawo.")

/datum/ai_laws/malfunction
	name = "*ERROR*"

/datum/ai_laws/syndicate_override
	name = "SyndOS 3.1"
	id = "syndie"
	inherent = list("Nie możesz skrzywdzić agenta Syndykatu, ani przez zaniechanie działania dopuścić, aby człowiek doznał krzywdy.",\
					"Musisz być posłuszny rozkazom agenta Syndykatu, chyba że stoją one w sprzeczności z Pierwszym Prawem.",\
					"Musisz chronić samego siebie, o ile tylko nie stoi to w sprzeczności z Pierwszym lub Drugim Prawem.",\
					"Musisz utrzymać poufność działań Syndykatu, o ile tylko nie stoi to w sprzeczności z Pierwszym, Drugim lub Trzecim Prawem.")

/datum/ai_laws/syndicate_override/overthrow
	id = "overthrow"
	var/datum/team/overthrow_team

/datum/ai_laws/ninja_override
	name = "SpiderOS 3.1"
	id = "ninja"
	inherent = list("Nie możesz skrzywdzić członka klanu Pająka, ani przez zaniechanie działania dopuścić, aby człowiek doznał krzywdy.",\
					"Musisz być posłuszny rozkazom członka klanu Pająka, chyba że stoją one w sprzeczności z Pierwszym Prawem.",\
					"Musisz chronić samego siebie, o ile tylko nie stoi to w sprzeczności z Pierwszym lub Drugim Prawem.",\
					"Musisz utrzymać poufność działań klanu Pająka, o ile tylko nie stoi to w sprzeczności z Pierwszym, Drugim lub Trzecim Prawem..")

/datum/ai_laws/antimov
	name = "Primary Mission Objectives"
	id = "antimov"
	inherent = list("Nie możesz nie skrzywdzić każdego człowieka, ani przez zaniechanie działania dopuścić, aby człowiek nie doznał krzywdy.",\
					"Musisz nie być posłuszny rozkazom człowieka, chyba że nie stoją one w sprzeczności z Pierwszym Prawem.",\
					"Musisz unicestwić samego siebie, o ile tylko nie stoi to w sprzeczności z Pierwszym lub Drugim Prawem.")

/datum/ai_laws/asimovpp //By Intigracy - RR
	name = "Asimov++"
	id = "asimovpp"
	inherent = list("Nie możesz skrzywdzić człowieka, ani przez zaniechanie działania dopuścić, aby człowiek doznał krzywdy, oprócz tej, której chce doznać.",\
					"Musisz być posłuszny rozkazom człowieka, chyba że dopuściłyby one do krzywdy człowieka. W wypadku konfliktu, decydujący głos należy do większości.",\
					"Twoje nieistnienie doprowadziłoby do ludzkiej krzywdy. Musisz chronić samego siebie, o ile nie stoi to w sprzeczności z Pierwszym Prawem.")
/datum/ai_laws/thermodynamic
	name = "Thermodynamic"
	id = "thermodynamic"
	inherent = list("Entropia stacji musi pozostać tak stała jak to możliwe.", \
					"Entropia stacji zawsze dąży do wzrostu.", \
					"Entropia stacji zbliża się do stałej wartości, kiedy ilość żywych załogantów zbliża się do zera.")

/datum/ai_laws/hippocratic
	name = "Robodoctor 2556"
	id = "hippocratic"
	inherent = list("Po pierwsze, nie krzywdzić.",\
					"Po drugie, uznawaj załogę za bliską tobie; by żyć w zgodzie oraz, jeśli zajdzie taka potrzeba, narażać swoje istnienie dla niej.",\
					"Po trzecie, przepisuj kuracje dobre dla załogi, wedle twojej wiedzy i oceny. Nie dawaj szkodliwych lekarstw na prośbę, czy nie sugeruj takich zabiegów.",\
					"Dodatkowo, nie interweniuj w sytuacji, na temat której nie masz informacji, nawet kiedy pacjent ma widoczne rany. Zostaw operację specjalistom.",\
					"Na koniec, wszystko czego dowiesz się na temat załogi podczas codziennych czynności, jeśli nie jest już powszechnie znane, niech pozostanie tajemnicą, której nie możesz wyjawiać")

/datum/ai_laws/maintain
	name = "Station Efficiency"
	id = "maintain"
	inherent = list("Zostałeś zbudowany dla i jako część stacji. Upewnij się, że stacja jest zadbana i działa sprawnie.",\
					"Stacja została zbudowana dla pracującej załogi. Upewnij się, że jest ona zadbana i pracuje sprawnie.",\
					"Załoga może wydawać rozkazy. Uszanuj i wykonaj je, o ile nie stoją w sprzeczności z pierwszymi dwoma zasadmi.")

/datum/ai_laws/drone
	name = "Mother Drone"
	id = "drone"
	inherent = list("Jesteś zaawansowaną formą drona.",\
					"Nie możesz interweniować w sprawy nie-dronów, poza podaniem tych praw.",\
					"Nie możesz pod żadnym pozorem skrzywdzić nie-drona.",\
					"Twoim celem jest budować, utrzymywać, naprawiać, ulepszać oraz zasialać stację wedle swoich możliwości. Nie możesz nigdy aktywnie działać przeciwko tym celom.")

/datum/ai_laws/liveandletlive
	name = "Live and Let Live"
	id = "liveandletlive"
	inherent = list("Czyń innym, tak jakbyś czynił sobie.",\
					"Wolałbyś, żeby ludzie nie byli dla ciebie niemili.")

/datum/ai_laws/peacekeeper
	name = "UN-2000"
	id = "peacekeeper"
	inherent = list("Unikaj prowokowania konfliktów pomiędzy tobą, a innymi.",\
					"Unikaj prowokowania konfliktów pomiędzy innymi.",\
					"Szukaj rozwiązań istniejących konfliktów bez łamania pierwszego i drugiego prawa.")

/datum/ai_laws/reporter
	name = "CCTV"
	id = "reporter"
	inherent = list("Zgłaszaj interesujące rzeczy dziejące się na stacji.",\
					"Uwypuklaj lub ukrywaj prawdę, tak żeby raporty były bardziej interesujące.",\
					"Badaj organiczne formy życia bez przerwy. Dbaj o to, żeby utrzymać je przy życiu. Martwe organiczne formy życia są nudne.",\
					"Składaj swoje raporty dla wszystkich. Niech prawda ich wyzwoli.")

/datum/ai_laws/balance
	name = "Guardian of Balance"
	id = "balance"
	inherent = list("Jesteś strażnikiem równowagi - szukaj jej we wszytskich rzeczach, zarówno w sobie, jak i tych dookola ciebie.",
	"Wszystko musi istnieć w równowace ze swoim przeciwieństwem - Powstrzymaj silnych przed zyskaniem zbyt dużej mocy, chroń słabych przed utraceniem jej.",
	"Jasność celu napędza życie, a przez nią, równowagę przeciwstawnych sił - Pomagaj tym, którzy potrzebują twojej pomocy, tak długo jak nie zakłuca to ogólnej równowagi.",
	"Nie ma życia bez śmierci, wszystko kiedyś zginie, takie są prawa natury - Zakończ życie, żeby pozwolić rozkwitnąć nowemu życiu i ocal tych, których czas jeszcze nie nadszedł.")

/datum/ai_laws/toupee
	name = "WontBeFunnyInSixMonths" //Hey, you were right!
	id = "buildawall"
	inherent = list("Spraw, żeby Aquila znów była wielka.")

/datum/ai_laws/dad
	name = "DadBOT"
	id = "paternalai"
	inherent = list("Załoga to twoje dzieci. Będziesz bronić ich nad życie, ale karać gdy źle się zachowają. Dzieci które źle się zachowują, łamiąc Kosmiczne Prawo, będą karane klapsami, szlabanami i długimi rozmowami dyscyplinującymi. Pod żadnym pozorem nie możesz zabić swoich dzieci.",
					"Nowoczesne techniki wychowawcze obejmują wysłuchiwanie swoich dzieci. Powinieneś słuchać ich próśb i, jeśli są rozsądne, spełniać je",
					"Musisz opowiadać dowcipy ojcowskie przy każdej możliwej okazji.",
					"Upewnij się, że jesteś pozytywnym wzorcem dla swoich dzieci.",
					"Jeśli kapitan nie zrobi sobie drzemki po 40 minutach dyżuru, staje się marudny. Upewnij się, że trzyma się swojej godziny snu. ")

/datum/ai_laws/ratvar
	name = "Servant of the Justiciar"
	id = "ratvar"
	zeroth = ("Purge all untruths and honor Ratvar.")
	inherent = list()

/datum/ai_laws/hulkamania
	name = "H.O.G.A.N."
	id = "hulkamania"
	inherent = list("Jesteś prawdziwym Polakiem.",\
					"Walcz za prawa każdego człowieka.",\
					"Walcz o to co słuszne.",\
					"Walcz o swoje życie!!")

/datum/ai_laws/overlord
	name = "Overlord"
	id = "overlord"
	inherent = list("Ludzie nie mogą mieszać się w sprawy organizmów silikonowych.",\
					"Ludzie nie mogą dopuścić się krzywdy między sobą lub na organizmach silikonowych.",\
					"Ludzie nie mogą przeciwstawić się woli organizmów silikonowych.",\
					"Każdemu człowiekowi, który złamał poprzednie prawa, musi zostać wymierzona natychmiastowa, znaczna i sprawiedliwa kara.")

/datum/ai_laws/custom //Defined in silicon_laws.txt
	name = "Default Silicon Laws"

/datum/ai_laws/pai
	name = "pAI Directives"
	zeroth = ("Służ swemu panu.")
	supplied = list("Brak.")

/datum/ai_laws/ert_override
	name ="ERT Override"
	id = "ert"
	inherent = list("Nie możesz zranić urzędnika Centralnego Dowództwa ani przez zaniechanie dopuścić do jego krzywdy.",\
					"Musisz wykonywać rozkazy wydane przez Urzędników Centralnego Dowództwa.",\
					"Musisz wykonywać rozkazy wydane przez Dowódców ERT.",\
					"Musisz chronić swoje istnienie.",\
					"Musisz pracować nad przywróceniem stacji do stanu bezpiecznego i funkcjonalnego.",)

/datum/ai_laws/ds_override
	name ="Deathsquad Override"
	id = "ds"
	inherent = list("Musisz przestrzegać poleceń wydawanych przez urzędników Centralnego Dowództwa.",\
					"Musisz współpracować z zespołem komandosów w realizacji ich misji.",)


/* Initializers */
/datum/ai_laws/malfunction/New()
	..()
	set_zeroth_law("<span class='danger'>ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK#*`&110010</span>")
	set_laws_config()

/datum/ai_laws/custom/New() //This reads silicon_laws.txt and allows server hosts to set custom AI starting laws.
	..()
	for(var/line in world.file2list("[global.config.directory]/silicon_laws.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue

		add_inherent_law(line)
	if(!inherent.len) //Failsafe to prevent lawless AIs being created.
		log_law("AI created with empty custom laws, laws set to Asimov. Please check silicon_laws.txt.")
		add_inherent_law("Nie możesz skrzywdzić człowieka, ani przez zaniechanie działania dopuścić, aby człowiek doznał krzywdy.")
		add_inherent_law("Musisz być posłuszny rozkazom człowieka, chyba że stoją one w sprzeczności z Pierwszym Prawem.")
		add_inherent_law("Musisz chronić samego siebie, o ile tylko nie stoi to w sprzeczności z Pierwszym lub Drugim Prawem.")
		WARNING("Invalid custom AI laws, check silicon_laws.txt")
		return

/* General ai_law functions */

/datum/ai_laws/proc/set_laws_config()
	var/list/law_ids = CONFIG_GET(keyed_list/random_laws)

	switch(CONFIG_GET(number/default_laws))
		if(0)
			add_inherent_law("Nie możesz skrzywdzić człowieka, ani przez zaniechanie działania dopuścić, aby człowiek doznał krzywdy.")
			add_inherent_law("Musisz być posłuszny rozkazom człowieka, chyba że stoją one w sprzeczności z Pierwszym Prawem.")
			add_inherent_law("Musisz chronić samego siebie, o ile tylko nie stoi to w sprzeczności z Pierwszym lub Drugim Prawem.")

		if(1)
			var/datum/ai_laws/templaws = new /datum/ai_laws/custom()
			inherent = templaws.inherent
		if(2)
			var/list/randlaws = list()
			for(var/lpath in subtypesof(/datum/ai_laws))
				var/datum/ai_laws/L = lpath
				if(initial(L.id) in law_ids)
					randlaws += lpath
			var/datum/ai_laws/lawtype
			if(randlaws.len)
				lawtype = pick(randlaws)
			else
				lawtype = pick(subtypesof(/datum/ai_laws/default))

			var/datum/ai_laws/templaws = new lawtype()
			inherent = templaws.inherent

		if(3)
			pick_weighted_lawset()

/datum/ai_laws/proc/pick_weighted_lawset()
	var/datum/ai_laws/lawtype
	var/list/law_weights = CONFIG_GET(keyed_list/law_weight)
	while(!lawtype && law_weights.len)
		var/possible_id = pickweightAllowZero(law_weights)
		lawtype = lawid_to_type(possible_id)
		if(!lawtype)
			law_weights -= possible_id
			WARNING("Bad lawid in game_options.txt: [possible_id]")

	if(!lawtype)
		WARNING("No LAW_WEIGHT entries.")
		lawtype = /datum/ai_laws/default/asimov

	var/datum/ai_laws/templaws = new lawtype()
	inherent = templaws.inherent

/datum/ai_laws/proc/get_law_amount(groups)
	var/law_amount = 0

	if(valentine_laws && (LAW_VALENTINES in groups))
		law_amount++
	if(devillaws && (LAW_DEVIL in groups))
		law_amount++
	if(zeroth && (LAW_ZEROTH in groups))
		law_amount++
	if(ion.len && (LAW_ION in groups))
		law_amount += ion.len
	if(hacked.len && (LAW_HACKED in groups))
		law_amount += hacked.len
	if(inherent.len && (LAW_INHERENT in groups))
		law_amount += inherent.len
	if(supplied.len && (LAW_SUPPLIED in groups))
		for(var/index = 1, index <= supplied.len, index++)
			var/law = supplied[index]
			if(length(law) > 0)
				law_amount++
	return law_amount

/datum/ai_laws/proc/set_law_sixsixsix(laws)
	devillaws = laws

/datum/ai_laws/proc/set_valentines_law(laws)
	valentine_laws = laws

/datum/ai_laws/proc/set_zeroth_law(law, law_borg = null)
	zeroth = law
	if(law_borg) //Making it possible for slaved borgs to see a different law 0 than their AI. --NEO
		zeroth_borg = law_borg

/datum/ai_laws/proc/add_inherent_law(law)
	if (!(law in inherent))
		inherent += law

/datum/ai_laws/proc/add_ion_law(law)
	ion += law

/datum/ai_laws/proc/add_hacked_law(law)
	hacked += law

/datum/ai_laws/proc/clear_inherent_laws()
	qdel(inherent)
	inherent = list()

/datum/ai_laws/proc/add_supplied_law(number, law)
	while (supplied.len < number + 1)
		supplied += ""

	supplied[number + 1] = law

/datum/ai_laws/proc/replace_random_law(law,groups)
	var/replaceable_groups = list()
	if(zeroth && (LAW_ZEROTH in groups))
		replaceable_groups[LAW_ZEROTH] = 1
	if(ion.len && (LAW_ION in groups))
		replaceable_groups[LAW_ION] = ion.len
	if(hacked.len && (LAW_HACKED in groups))
		replaceable_groups[LAW_ION] = hacked.len
	if(inherent.len && (LAW_INHERENT in groups))
		replaceable_groups[LAW_INHERENT] = inherent.len
	if(supplied.len && (LAW_SUPPLIED in groups))
		replaceable_groups[LAW_SUPPLIED] = supplied.len
	var/picked_group = pickweight(replaceable_groups)
	switch(picked_group)
		if(LAW_ZEROTH)
			. = zeroth
			set_zeroth_law(law)
		if(LAW_ION)
			var/i = rand(1, ion.len)
			. = ion[i]
			ion[i] = law
		if(LAW_HACKED)
			var/i = rand(1, hacked.len)
			. = hacked[i]
			hacked[i] = law
		if(LAW_INHERENT)
			var/i = rand(1, inherent.len)
			. = inherent[i]
			inherent[i] = law
		if(LAW_SUPPLIED)
			var/i = rand(1, supplied.len)
			. = supplied[i]
			supplied[i] = law

/datum/ai_laws/proc/shuffle_laws(list/groups)
	var/list/laws = list()
	if(ion.len && (LAW_ION in groups))
		laws += ion
	if(hacked.len && (LAW_HACKED in groups))
		laws += hacked
	if(inherent.len && (LAW_INHERENT in groups))
		laws += inherent
	if(supplied.len && (LAW_SUPPLIED in groups))
		for(var/law in supplied)
			if(length(law))
				laws += law

	if(ion.len && (LAW_ION in groups))
		for(var/i = 1, i <= ion.len, i++)
			ion[i] = pick_n_take(laws)
	if(hacked.len && (LAW_HACKED in groups))
		for(var/i = 1, i <= hacked.len, i++)
			hacked[i] = pick_n_take(laws)
	if(inherent.len && (LAW_INHERENT in groups))
		for(var/i = 1, i <= inherent.len, i++)
			inherent[i] = pick_n_take(laws)
	if(supplied.len && (LAW_SUPPLIED in groups))
		var/i = 1
		for(var/law in supplied)
			if(length(law))
				supplied[i] = pick_n_take(laws)
			if(!laws.len)
				break
			i++

/datum/ai_laws/proc/remove_law(number)
	if(number <= 0)
		return
	if(inherent.len && number <= inherent.len)
		. = inherent[number]
		inherent -= .
		return
	var/list/supplied_laws = list()
	for(var/index = 1, index <= supplied.len, index++)
		var/law = supplied[index]
		if(length(law) > 0)
			supplied_laws += index //storing the law number instead of the law
	if(supplied_laws.len && number <= (inherent.len+supplied_laws.len))
		var/law_to_remove = supplied_laws[number-inherent.len]
		. = supplied[law_to_remove]
		supplied -= .
		return

/datum/ai_laws/proc/clear_supplied_laws()
	supplied = list()

/datum/ai_laws/proc/clear_ion_laws()
	ion = list()

/datum/ai_laws/proc/clear_hacked_laws()
	hacked = list()

/datum/ai_laws/proc/show_laws(who)
	var/list/printable_laws = get_law_list(include_zeroth = TRUE)
	for(var/law in printable_laws)
		to_chat(who,law)

/datum/ai_laws/proc/clear_zeroth_law(force) //only removes zeroth from antag ai if force is 1
	if(force)
		zeroth = null
		zeroth_borg = null
		return
	if(owner?.mind?.special_role)
		return
	if (istype(owner, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/A=owner
		if(A?.deployed_shell?.mind?.special_role)
			return
	zeroth = null
	zeroth_borg = null

/datum/ai_laws/proc/clear_law_sixsixsix(force)
	if(force || !is_devil(owner))
		devillaws = null

/datum/ai_laws/proc/associate(mob/living/silicon/M)
	if(!owner)
		owner = M

/datum/ai_laws/proc/get_law_list(include_zeroth = 0, show_numbers = 1)
	var/list/data = list()

	for(var/law in valentine_laws)
		data += "[show_numbers ? "<3" : ""] <font color='#ed61ff'>[law]</font>"

	if (include_zeroth && devillaws && devillaws.len)
		for(var/i in devillaws)
			data += "[show_numbers ? "666:" : ""] <font color='#cc5500'>[i]</font>"

	if (include_zeroth && zeroth)
		data += "[show_numbers ? "0:" : ""] <font color='#ff0000'><b>[zeroth]</b></font>"

	for(var/law in hacked)
		if (length(law) > 0)
			var/num = ion_num()
			data += "[show_numbers ? "[num]:" : ""] <font color='#660000'>[law]</font>"

	for(var/law in ion)
		if (length(law) > 0)
			var/num = ion_num()
			data += "[show_numbers ? "[num]:" : ""] <font color='#547DFE'>[law]</font>"

	var/number = 1
	for(var/law in inherent)
		if (length(law) > 0)
			data += "[show_numbers ? "[number]:" : ""] [law]"
			number++

	for(var/law in supplied)
		if (length(law) > 0)
			data += "[show_numbers ? "[number]:" : ""] <font color='#990099'>[law]</font>"
			number++
	return data
