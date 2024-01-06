/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"
	report_type = "meteor"
	false_report_weight = 1
	var/meteordelay = 2000
	var/nometeors = 0
	var/rampupdelta = 5
	required_players = 0

	announce_span = "danger"
	announce_text = "A major meteor shower is bombarding the station! The crew needs to evacuate or survive the onslaught."

	title_icon = "meteor"

/datum/game_mode/meteor/process()
	if(nometeors || meteordelay > world.time - SSticker.round_start_time)
		return

	var/list/wavetype = GLOB.meteors_normal
	var/meteorminutes = (world.time - SSticker.round_start_time - meteordelay) / 600


	if (prob(meteorminutes))
		wavetype = GLOB.meteors_threatening

	if (prob(meteorminutes/2))
		wavetype = GLOB.meteors_catastrophic

	var/ramp_up_final = CLAMP(round(meteorminutes/rampupdelta), 1, 10)

	spawn_meteors(ramp_up_final, wavetype)


/datum/game_mode/meteor/special_report()
	var/survivors = 0
	var/list/survivor_list = list()

	for(var/mob/living/player in GLOB.player_list)
		if(player.stat != DEAD)
			++survivors

			if(player.onCentCom())
				survivor_list += "<span class='greentext'>[player.real_name] uciekł/a do bezpiecznej stacji Centrali.</span>"
			else if(player.onSyndieBase())
				survivor_list += "<span class='greentext'>[player.real_name] uciekł/a do (raczej) bezpiecznej bazy Syndykatu.</span>"
			else
				survivor_list += "<span class='neutraltext'>[player.real_name] przeżył/a, ale pozostał na stacji, czekając na pomoc która nigdy nie nadejdzie.</span>"

	if(survivors)
		return "<div class='panel greenborder'><span class='header'>Poniższe osoby przeżyły deszcz meteorytów:</span><br>[survivor_list.Join("<br>")]</div>"
	else
		return "<div class='panel redborder'><span class='redtext big'>Nikt nie przeżył deszczu meteorytów!</span></div>"

/datum/game_mode/meteor/set_round_result()
	..()
	SSticker.mode_result = "end - evacuation"

/datum/game_mode/meteor/generate_report()
	return "[pick("Asteroidy", "Meteory", "Wielkie kosmiczne kamienie", "Odłamki złomu", "Duże ilości kosmicznych śmieci")] zostały wykryte w pobliżu waszej stacji, kolizja jest możliwa, lecz mało prawdopodobna. Bądźcie przygotowani na zderzenia na skalę masową. Nasze wysoko zaawansowane promy mogą mieć problem z przylotem w pobliże stacji, jeżeli dojdzie do masowej kolizji."
