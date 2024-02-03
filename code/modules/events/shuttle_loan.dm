#define HIJACK_SYNDIE 1
#define RUSKY_PARTY 2
#define SPIDER_GIFT 3
#define DEPARTMENT_RESUPPLY 4
#define ANTIDOTE_NEEDED 5
#define PIZZA_DELIVERY 6
#define ITS_HIP_TO 7
#define MY_GOD_JC 8


/datum/round_event_control/shuttle_loan
	name = "Shuttle Loan"
	typepath = /datum/round_event/shuttle_loan
	max_occurrences = 1
	earliest_start = 7 MINUTES

/datum/round_event/shuttle_loan
	announceWhen = 1
	endWhen = 500
	var/dispatched = 0
	var/dispatch_type = 0
	var/bonus_points = 10000
	var/thanks_msg = "The cargo shuttle should return in five minutes. Have some supply points for your trouble."

/datum/round_event/shuttle_loan/setup()
	dispatch_type = pick(HIJACK_SYNDIE, RUSKY_PARTY, SPIDER_GIFT, DEPARTMENT_RESUPPLY, ANTIDOTE_NEEDED, PIZZA_DELIVERY, ITS_HIP_TO, MY_GOD_JC)

/datum/round_event/shuttle_loan/announce(fake)
	SSshuttle.shuttle_loan = src
	switch(dispatch_type)
		if(HIJACK_SYNDIE)
			priority_announce("Zaopatrzenie: Syndykat próbuje zinflitrować wasz statek. Jeśli pozwolicie im porwać prom towarowy, zaoszczędzicie nam sporo problemu.", "Kontrwywiad Centrali", SSstation.announcer.get_rand_alert_sound())
		if(RUSKY_PARTY)
			priority_announce("Zaopatrzenie: Grupa wściekłych ruskich ma ochotę na imprezkę. Możecie podesłać po nich prom, byśmy się ich pozbyli?", "Rosyjski Program Informacyjny Centrali", SSstation.announcer.get_rand_alert_sound())
		if(SPIDER_GIFT)
			priority_announce("Zaopatrzenie: Pajęczy Klan wysłał nam tajemniczy prezent. Możemy wam go podesłać, by sprawdzić co w nim jest?", "Korpus dyplomatyczny Centrali", SSstation.announcer.get_rand_alert_sound())
		if(DEPARTMENT_RESUPPLY)
			priority_announce("Zaopatrzenie: Wygląda na to, że zamówiliśmy podwójnie nasze departamentalne uzupełniena. Możemy wam je wysłać?", "Departament Zaopatrzenia Centrali", SSstation.announcer.get_rand_alert_sound())
			thanks_msg = "Prom zaopatrzeniowy powinien wrócić za 5 minut."
			bonus_points = 0
		if(ANTIDOTE_NEEDED)
			priority_announce("Zaopatrzenie: Wasz statek został wybrany do epidemiologicznego programu badawczego. Wyślijce nam swój prom towarowy, a prześlemy wam próbki.", "Inicjatywa Badawcza Centrali", SSstation.announcer.get_rand_alert_sound())
		if(PIZZA_DELIVERY)
			priority_announce("Zaopatrzenie: Wygląda na to, że przelatujący statek przypadkiem zamówił pizze do was.", "Oddział Kosmopizzy Centrali", SSstation.announcer.get_rand_alert_sound())
			thanks_msg = "Prom zaopatrzeniowy powinien wrócić za 5 minut."
			bonus_points = 0
		if(ITS_HIP_TO)
			priority_announce("Zaopatrzenie: Jeden z naszych frachtowców przewożących ładunek pszczół został zaatakowany przez ekoterrorystów. Możecie posprzątać za nas ten bajzel?", "Wydział Czyszczenia Centrali", SSstation.announcer.get_rand_alert_sound())
			bonus_points = 20000 //Toxin bees can be unbeelievably lethal
		if(MY_GOD_JC)
			priority_announce("Zaopatrzenie: Odkryliśmy aktywną bombę Syndykatu w pobliżu przewodów paliwowych naszego wahadłowca VIP. Jeżeli czujecie się na siłach, aby sprostać zadaniu, zapłacimy wam za jego rozbrojenie.", "Wydział Ochrony Centrali" , SSstation.announcer.get_rand_alert_sound())
			thanks_msg = " Aktywny ładunek wybuchowy nadciąga promem. Zaleca się ewakuację ładowni."
			bonus_points = 45000 //If you mess up, people die and the shuttle gets turned into swiss cheese

/datum/round_event/shuttle_loan/proc/loan_shuttle()
	priority_announce(thanks_msg, "Transfer towarowy przejęty przez CentCom.", SSstation.announcer.get_rand_alert_sound())

	dispatched = 1
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		D.adjust_money(bonus_points)
	endWhen = activeFor + 1

	SSshuttle.supply.mode = SHUTTLE_CALL
	SSshuttle.supply.destination = SSshuttle.getDock("supply_home")
	SSshuttle.supply.setTimer(3000)

	switch(dispatch_type)
		if(HIJACK_SYNDIE)
			SSshuttle.centcom_message += "Nadlatuje drużyna przechwytująca Syndykatu."
		if(RUSKY_PARTY)
			SSshuttle.centcom_message += "Imprezowe ruski nadlatują."
		if(SPIDER_GIFT)
			SSshuttle.centcom_message += "Prezent od Pajęczego Klanu nadlatuje."
		if(DEPARTMENT_RESUPPLY)
			SSshuttle.centcom_message += "Departamentowe uzupełnienie nadlatuje."
		if(ANTIDOTE_NEEDED)
			SSshuttle.centcom_message += "Próbki wirusa nadlatują."
		if(PIZZA_DELIVERY)
			SSshuttle.centcom_message += "Dostawa pizzy dla [station_name()]"
		if(ITS_HIP_TO)
			SSshuttle.centcom_message += "Sprzątanie zagrożeń biologicznych nadlatuje."
		if(MY_GOD_JC)
			SSshuttle.centcom_message += "Aktywny ładunek wybuchowy nadlatuje. Zachować szczególną ostrożność."

/datum/round_event/shuttle_loan/tick()
	if(dispatched)
		if(SSshuttle.supply.mode != SHUTTLE_IDLE)
			endWhen = activeFor
		else
			endWhen = activeFor + 1

/datum/round_event/shuttle_loan/end()
	if(SSshuttle.shuttle_loan?.dispatched)
		//make sure the shuttle was dispatched in time
		SSshuttle.shuttle_loan = null

		var/list/empty_shuttle_turfs = list()
		var/list/area/shuttle/shuttle_areas = SSshuttle.supply.shuttle_areas
		for(var/place in shuttle_areas)
			var/area/shuttle/shuttle_area = place
			for(var/turf/open/floor/T in shuttle_area)
				if(is_blocked_turf(T))
					continue
				empty_shuttle_turfs += T
		if(!empty_shuttle_turfs.len)
			return

		var/list/shuttle_spawns = list()
		switch(dispatch_type)
			if(HIJACK_SYNDIE)
				var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/emergency/specialops]
				pack.generate(pick_n_take(empty_shuttle_turfs))

				shuttle_spawns.Add(/mob/living/simple_animal/hostile/syndicate/ranged/infiltrator)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/syndicate/ranged/infiltrator)
				if(prob(75))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/syndicate/ranged/infiltrator)
				if(prob(50))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/syndicate/ranged/infiltrator)

			if(RUSKY_PARTY)
				var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/service/party]
				pack.generate(pick_n_take(empty_shuttle_turfs))

				shuttle_spawns.Add(/mob/living/simple_animal/hostile/russian)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/russian/ranged)	//drops a mateba
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/bear/russian)
				if(prob(75))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/russian)
				if(prob(50))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/bear/russian)

			if(SPIDER_GIFT)
				var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/emergency/specialops]
				pack.generate(pick_n_take(empty_shuttle_turfs))

				shuttle_spawns.Add(/mob/living/simple_animal/hostile/poison/giant_spider)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/poison/giant_spider)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/poison/giant_spider/nurse)
				if(prob(50))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/poison/giant_spider/hunter)

				var/turf/T = pick_n_take(empty_shuttle_turfs)

				new /obj/effect/decal/remains/human(T)
				new /obj/item/clothing/shoes/space_ninja(T)
				new /obj/item/clothing/mask/balaclava(T)

				for(var/i in 1 to 5)
					T = pick_n_take(empty_shuttle_turfs)
					new /obj/structure/spider/stickyweb(T)

			if(ANTIDOTE_NEEDED)
				var/obj/effect/mob_spawn/human/corpse/assistant/infected_assistant = pick(/obj/effect/mob_spawn/human/corpse/assistant/beesease_infection, /obj/effect/mob_spawn/human/corpse/assistant/brainrot_infection, /obj/effect/mob_spawn/human/corpse/assistant/spanishflu_infection)
				var/turf/T
				for(var/i=0, i<10, i++)
					if(prob(15))
						shuttle_spawns.Add(/obj/item/reagent_containers/glass/bottle)
					else if(prob(15))
						shuttle_spawns.Add(/obj/item/reagent_containers/syringe)
					else if(prob(25))
						shuttle_spawns.Add(/obj/item/shard)
					T = pick_n_take(empty_shuttle_turfs)
					new infected_assistant(T)
				shuttle_spawns.Add(/obj/structure/closet/crate)
				shuttle_spawns.Add(/obj/item/reagent_containers/glass/bottle/pierrot_throat)
				shuttle_spawns.Add(/obj/item/reagent_containers/glass/bottle/magnitis)

			if(DEPARTMENT_RESUPPLY)
				var/list/crate_types = list(
					/datum/supply_pack/emergency/equipment,
					/datum/supply_pack/security/supplies,
					/datum/supply_pack/organic/food,
					/datum/supply_pack/emergency/weedcontrol,
					/datum/supply_pack/engineering/tools,
					/datum/supply_pack/engineering/engiequipment,
					/datum/supply_pack/science/robotics,
					/datum/supply_pack/science/plasma,
					/datum/supply_pack/medical/supplies
					)
				for(var/crate in crate_types)
					var/datum/supply_pack/pack = SSshuttle.supply_packs[crate]
					pack.generate(pick_n_take(empty_shuttle_turfs))

				for(var/i in 1 to 5)
					var/decal = pick(/obj/effect/decal/cleanable/food/flour, /obj/effect/decal/cleanable/robot_debris, /obj/effect/decal/cleanable/oil)
					new decal(pick_n_take(empty_shuttle_turfs))
			if(PIZZA_DELIVERY)
				var/naughtypizza = list(/obj/item/pizzabox/bomb,/obj/item/pizzabox/margherita/robo) //oh look another blaklist, for pizza nonetheless!
				var/nicepizza = list(/obj/item/pizzabox/margherita, /obj/item/pizzabox/meat, /obj/item/pizzabox/vegetable, /obj/item/pizzabox/mushroom)
				for(var/i in 1 to 6)
					shuttle_spawns.Add(pick(prob(5) ? naughtypizza : nicepizza))
			if(ITS_HIP_TO)
				var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/organic/hydroponics/beekeeping_fullkit]
				pack.generate(pick_n_take(empty_shuttle_turfs))

				shuttle_spawns.Add(/obj/effect/mob_spawn/human/corpse/bee_terrorist)
				shuttle_spawns.Add(/obj/effect/mob_spawn/human/corpse/cargo_tech)
				shuttle_spawns.Add(/obj/effect/mob_spawn/human/corpse/cargo_tech)
				shuttle_spawns.Add(/obj/effect/mob_spawn/human/corpse/nanotrasensoldier)
				shuttle_spawns.Add(/obj/item/gun/ballistic/automatic/pistol/no_mag)
				shuttle_spawns.Add(/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag)
				shuttle_spawns.Add(/obj/item/honey_frame)
				shuttle_spawns.Add(/obj/item/honey_frame)
				shuttle_spawns.Add(/obj/item/honey_frame)
				shuttle_spawns.Add(/obj/structure/beebox/unwrenched)
				shuttle_spawns.Add(/obj/item/queen_bee/bought)
				shuttle_spawns.Add(/obj/structure/closet/crate/hydroponics)

				for(var/i in 1 to 8)
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/poison/bees/toxin)

				for(var/i in 1 to 5)
					var/decal = pick(/obj/effect/decal/cleanable/blood, /obj/effect/decal/cleanable/insectguts)
					new decal(pick_n_take(empty_shuttle_turfs))

				for(var/i in 1 to 10)
					var/casing = /obj/item/ammo_casing/spent
					new casing(pick_n_take(empty_shuttle_turfs))

			if(MY_GOD_JC)
				shuttle_spawns.Add(/obj/machinery/syndicatebomb/shuttle_loan)
				if(prob(95))
					shuttle_spawns.Add(/obj/item/paper/fluff/cargo/bomb)
				else
					shuttle_spawns.Add(/obj/item/paper/fluff/cargo/bomb/allyourbase)

		var/false_positive = 0
		while(shuttle_spawns.len && empty_shuttle_turfs.len)
			var/turf/T = pick_n_take(empty_shuttle_turfs)
			if(T.contents.len && false_positive < 5)
				false_positive++
				continue

			var/spawn_type = pick_n_take(shuttle_spawns)
			new spawn_type(T)

//items that appear only in shuttle loan events

/obj/item/storage/belt/fannypack/yellow/bee_terrorist/PopulateContents()
	new /obj/item/grenade/plastic/c4 (src)
	new /obj/item/reagent_containers/pill/cyanide(src)
	new /obj/item/grenade/chem_grenade/facid(src)

/obj/item/paper/fluff/bee_objectives
	name = "Objectives of a Bee Liberation Front Operative"
	default_raw_text = "<b>Objective #1</b>. Liberate all bees on the NT transport vessel 2416/B. <b>Success!</b>  <br><b>Objective #2</b>. Escape alive. <b>Failed.</b>"

/obj/machinery/syndicatebomb/shuttle_loan/Initialize(mapload)
	. = ..()
	setAnchored(TRUE)
	timer_set = rand(480, 600) //once the supply shuttle docks (after 5 minutes travel time), players have between 3-5 minutes to defuse the bomb
	activate()
	update_icon()

/obj/item/paper/fluff/cargo/bomb
	name = "hastly scribbled note"
	default_raw_text = "GOOD LUCK!"

/obj/item/paper/fluff/cargo/bomb/allyourbase
	default_raw_text = "Somebody set us up the bomb!"

#undef HIJACK_SYNDIE
#undef RUSKY_PARTY
#undef SPIDER_GIFT
#undef DEPARTMENT_RESUPPLY
#undef ANTIDOTE_NEEDED
#undef PIZZA_DELIVERY
#undef ITS_HIP_TO
#undef MY_GOD_JC
