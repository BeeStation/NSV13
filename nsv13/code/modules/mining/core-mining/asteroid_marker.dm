/obj/effect/landmark/asteroid_spawn
	name = "Asteroid Spawn"

/obj/effect/landmark/asteroid_spawn/New()
	..()
	GLOB.asteroid_spawn_markers += src

/obj/effect/landmark/asteroid_spawn/Destroy()
	GLOB.asteroid_spawn_markers -= src
	return ..()