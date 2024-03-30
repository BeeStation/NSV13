/obj/effect/spawner/structure/shield_generator
	name = "Shield Generator Spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_room"

/obj/effect/spawner/structure/shield_generator/Initialize()
	if(prob(1))
		spawn_list = list(/obj/machinery/shield_generator)
	. = ..()
