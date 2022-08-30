/obj/effect/spawner/structure/shield_generator
	name = "Shield Generator Spawner"
	icon = 'icons/obj/structures_spawners.dmi'
	icon_state = "x4"
	spawn_list = list(/obj/effect/spawner/room/threexthree)

/obj/effect/spawner/structure/shield_generator/Initialize()
	if(prob(1))
		spawn_list = list(/obj/machinery/shield_generator)
	. = ..()

