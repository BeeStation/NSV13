/datum/game_mode
	var/list/datum/mind/wizards = list()
	var/list/datum/mind/apprentices = list()

/datum/game_mode/wizard
	name = "wizard"
	config_tag = "wizard"
	report_type = "wizard"
	role_preference = /datum/role_preference/antagonist/wizard
	antag_datum = /datum/antagonist/wizard
	false_report_weight = 10
	required_players = 20
	required_enemies = 1
	recommended_enemies = 1
	round_ends_with_antag_death = 1
	announce_span = "danger"
	announce_text = "There is a space wizard attacking the station!\n\
	<span class='danger'>Wizard</span>: Accomplish your objectives and cause mayhem on the station.\n\
	<span class='notice'>Crew</span>: Eliminate the wizard before they can succeed!"
	var/finished = 0

	title_icon = "wizard"

/datum/game_mode/wizard/pre_setup()
	var/datum/mind/wizard = antag_pick(antag_candidates, /datum/role_preference/antagonist/wizard)
	wizards += wizard
	wizard.assigned_role = ROLE_WIZARD
	wizard.special_role = ROLE_WIZARD
	log_game("[key_name(wizard)] has been selected as a Wizard") //TODO: Move these to base antag datum
	if(GLOB.wizardstart.len == 0)
		setup_error = "No wizard starting location found"
		return FALSE
	for(var/datum/mind/wiz in wizards)
		wiz.current.forceMove(pick(GLOB.wizardstart))
	return TRUE


/datum/game_mode/wizard/post_setup()
	for(var/datum/mind/wizard in wizards)
		wizard.add_antag_datum(/datum/antagonist/wizard)
	return ..()

/datum/game_mode/wizard/generate_report()
	return "Bardzo niebezpieczny osobnik z Federacji Kosmicznych Czarodziejów zwący się [pick(GLOB.wizard_first)] [pick(GLOB.wizard_second)], uciekł niedawno z głęboko ukrytej placówki badawczej. Osobnik ten posiada wysokie umiejętności formowania swojego ciała oraz rzeczywistości na życzenie, niektórzy podejrzewają, że jest to sprawka magii. Jeżeli osobnik ten zaatakuje waszą stację, jego egzekucja jest wysoce zalecana, jak również zachowanie zwłok do dalszych badań."

/datum/game_mode/wizard/are_special_antags_dead()
	for(var/datum/mind/wizard in wizards)
		if(isliving(wizard.current) && wizard.current.stat!=DEAD)
			return FALSE

	for(var/obj/item/phylactery/P in GLOB.poi_list) //TODO : IsProperlyDead()
		if(P.mind && P.mind.has_antag_datum(/datum/antagonist/wizard))
			return FALSE

	if(SSevents.wizardmode) //If summon events was active, turn it off
		SSevents.toggleWizardmode()
		SSevents.resetFrequency()

	return TRUE

/datum/game_mode/wizard/set_round_result()
	..()
	if(finished)
		SSticker.mode_result = "loss - wizard killed"
		SSticker.news_report = WIZARD_KILLED

/datum/game_mode/wizard/special_report()
	if(finished)
		return "<div class='panel redborder'><span class='redtext big'>Czarodziej[(wizards.len>1)?"s":""] został zabity przez załogę! Federacja Kosmicznych Czarodziejów dostała lekcję i na pewno nie postawią tutaj nogi przez dłuższy czas!</span></div>"

//returns whether the mob is a wizard (or apprentice)
/proc/iswizard(mob/living/M)
	return M?.mind?.has_antag_datum(/datum/antagonist/wizard)

/datum/game_mode/wizard/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	round_credits += "<center><h1>federacja Kosmicznych Czaradzieji:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/wizard in wizards)
		round_credits += "<center><h2>[wizard.name] jako potężny czarodziej</h2>"
	for(var/datum/mind/apprentice in apprentices)
		round_credits += "<center><h2>[apprentice.name] jako zapalony uczeń szkoły magii</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>Czarodzieje wymazali siebie z czasu i przestrzeni!</h2>", "<center><h2>Nie mogliśmy ich znaleść!</h2>")
	round_credits += "<br>"

	round_credits += ..()
	return round_credits
