/datum/looping_sound/generator
	volume = 15

/datum/looping_sound/grill
	volume = 20

/datum/looping_sound/microwave
	volume = 70

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/thermal
	mid_length = 2
	mid_sounds = list('aquila/sound/machines/thermal/thermal_mid.ogg'=1)
	volume = 3

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/computer
	start_sound = 'aquila/sound/machines/electronics/computer_start.ogg'
	start_length = 5
	mid_sounds = list('aquila/sound/machines/electronics/computer_mid1.ogg'=1, 'aquila/sound/machines/electronics/computer_mid2.ogg'=1, 'aquila/sound/machines/electronics/computer_mid3.ogg'=1, 'aquila/sound/machines/electronics/computer_mid4.ogg'=1, 'aquila/sound/machines/electronics/computer_mid5.ogg'=1)
	mid_length = 5
	end_sound = 'aquila/sound/machines/electronics/computer_stop.ogg'
	volume = 3

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/lathe
	start_sound = 'aquila/sound/machines/electronics/lathe_start.ogg'
	start_length = 2
	mid_sounds = list('aquila/sound/machines/electronics/lathe_idle.ogg'=10, 'aquila/sound/machines/electronics/lathe_working.ogg'=1, 'aquila/sound/machines/electronics/lathe_working2.ogg'=1, 'aquila/sound/machines/electronics/lathe_working3.ogg'=1, 'aquila/sound/machines/electronics/lathe_working4.ogg'=1)
	mid_length = 2
	end_sound = 'aquila/sound/machines/electronics/computer_stop.ogg'
	volume = 12
	extra_range = 1

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/smes
	start_sound = 'aquila/sound/machines/electronics/transformator_start.ogg'
	start_length = 2
	mid_sounds = list('aquila/sound/machines/electronics/transformator_mid.ogg'=1)
	mid_length = 2
	end_sound = 'aquila/sound/machines/electronics/transformator_stop.ogg'
	volume = 3

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/vent
	start_sound = 'aquila/sound/machines/thermal/vent_start.ogg'
	start_length = 1
	mid_sounds = list('aquila/sound/machines/thermal/vent_mid.ogg'=1)
	mid_length = 4
	end_sound = 'aquila/sound/machines/thermal/vent_stop.ogg'
	volume = 5
