/datum/map_template/nsvrooms/shield001
	name = "Accidental Shield Generator"
	mappath = "_maps/RandomRooms/NSVRooms/shield_gen_serendipity.dmm"
	width = 5
	height = 4

/obj/effect/spawner/room/shieldgen
	name = "5x4 Shieldgen Roomspawner"
	var/datum/map_template/template2 = /datum/map_template/nsvrooms/shield001
	room_width = 5
	room_height = 4

/obj/effect/spawner/room/shieldgen/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/spawner/room/shieldgen/LateInitialize()
	return template2.load(get_turf(src))
	//else
	//	new /obj/effect/spawner/room/fivexfour
