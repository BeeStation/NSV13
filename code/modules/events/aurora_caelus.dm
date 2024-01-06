/datum/round_event_control/aurora_caelus
	name = "Aurora Caelus"
	typepath = /datum/round_event/aurora_caelus
	max_occurrences = 1
	weight = 10
	earliest_start = 5 MINUTES

/datum/round_event_control/aurora_caelus/canSpawnEvent(players, gamemode)
	if(!CONFIG_GET(flag/starlight))
		return FALSE
	return ..()

/datum/round_event/aurora_caelus
	announceWhen = 1
	startWhen = 9
	endWhen = 50
	var/list/aurora_colors = list("#A2FF80", "#A2FF8B", "#A2FF96", "#A2FFA5", "#A2FFB6", "#A2FFC7", "#A2FFDE", "#A2FFEE")
	var/aurora_progress = 0 //this cycles from 1 to 8, slowly changing colors from gentle green to gentle blue

/datum/round_event/aurora_caelus/announce()
	priority_announce("[station_name()]: Nieszkodliwa chmura jonowa zbliża się do stacji i spowoduje wyładowania swojej energii obijając się o kadłub. Nanotrasen zezwala na krótką przerwę dla wszystkich pracowników by odprężyć się i obserwować to rzadkie wydarzenie. Podczas jego trwania jasne gwiezdne światło będzie mienić się kolorami niebieskim i zielonym. Personel chcący oglądać światła, może chcieć udać się do miejsc z których kosmos widoczny jest najbardziej. Życzymy wspaniałych wrażeń",
	sound = 'sound/misc/notice2.ogg',
	sender_override = "Nanotrasen Meteorology Division")
	for(var/V in GLOB.player_list)
		var/mob/M = V
		if((M.client.prefs.toggles & PREFTOGGLE_SOUND_MIDI) && is_station_level(M.z))
			M.playsound_local(M, 'sound/ambience/aurora_caelus.ogg', 20, FALSE, pressure_affected = FALSE)

/datum/round_event/aurora_caelus/start()
	for(var/area in GLOB.sortedAreas)
		var/area/A = area
		if(initial(A.dynamic_lighting) == DYNAMIC_LIGHTING_IFSTARLIGHT)
			for(var/turf/open/space/S in A)
				S.set_light(S.light_range * 3, S.light_power * 0.5)

/datum/round_event/aurora_caelus/tick()
	if(activeFor % 5 == 0)
		aurora_progress++
		var/aurora_color = aurora_colors[aurora_progress]
		for(var/area in GLOB.sortedAreas)
			var/area/A = area
			if(initial(A.dynamic_lighting) == DYNAMIC_LIGHTING_IFSTARLIGHT)
				for(var/turf/open/space/S in A)
					S.set_light(l_color = aurora_color)

/datum/round_event/aurora_caelus/end()
	for(var/area in GLOB.sortedAreas)
		var/area/A = area
		if(initial(A.dynamic_lighting) == DYNAMIC_LIGHTING_IFSTARLIGHT)
			for(var/turf/open/space/S in A)
				fade_to_black(S)
	priority_announce("Zorza kosmiczna właśnie się kończy. Właściwości światła gwiezdnego będą powoli wracać do normy. Gdy tak się stanie, prosimy powrócić do swoich miejsc pracy i kontynuować wykonywanie obowiązków. Życzymy udanej zmiany, [station_name()], i dziękujemy za wspólny seans.",
	sound = 'sound/misc/notice2.ogg',
	sender_override = "Nanotrasen Meteorology Division")

/datum/round_event/aurora_caelus/proc/fade_to_black(turf/open/space/S)
	set waitfor = FALSE
	var/new_light = initial(S.light_range)
	while(S.light_range > new_light)
		S.set_light(S.light_range - 0.2)
		sleep(30)
	S.set_light(new_light, initial(S.light_power), initial(S.light_color))
