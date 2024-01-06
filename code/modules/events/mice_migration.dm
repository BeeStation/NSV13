/datum/round_event_control/mice_migration
	name = "Mice Migration"
	typepath = /datum/round_event/mice_migration
	weight = 10
	max_occurrences = 1

/datum/round_event/mice_migration
	var/minimum_mice = 5
	var/maximum_mice = 15

/datum/round_event/mice_migration/announce(fake)
	var/cause = pick("kosmicznej zimy", "cięć budżetowych", "Ragnaroku",
		"kosmosu jako nieprzyjaznego miejsca", "\[UKRYTE\]", "zmiany klimatu",
		"niefartu")
	var/plural = pick("kilka", "horda", "grupka", "rój",
		"cholernie dużo", "nie więcej niż [maximum_mice]")
	var/name = pick("szkodników", "myszy", "piszczących żyjątek",
		"kablożernych ssaków", "\[UKRYTE\]", "żywiących się elektrycznością pasożytów")
	var/movement = pick("migrowało", "zaprosiło się", "wkroczyło", "przeprowadziło się")
	var/location = pick("korytarzy serwisowych", "pomieszczeń serwisowych",
		"\[UKRYTE\]", "miejsc z soczystymi kablami")

	priority_announce("Z powodu [cause], [plural] [name] [movement] \
		do[location].", "Alarm migracyjny",
		'sound/effects/mousesqueek.ogg')

/datum/round_event/mice_migration/start()
	SSminor_mapping.trigger_migration(rand(minimum_mice, maximum_mice))
