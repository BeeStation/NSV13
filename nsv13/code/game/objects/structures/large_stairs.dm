/**
*
* Stairs that behave like stairs actually should because /tg/ stairs are a pile of ass.
* Just place stairs facing up and down above each other.
* These stairs only go up one level. If you stack a tonne of them you won't have a good time
* Make sure theyre facing the same direction or it'll feel weird traversing them.
* MAPPERS: Please enclose your stairs with walls. Otherwise theyll feel weird.
*
*
*/

/obj/structure/stairs/large_stairs
	name = "Stairs"
	icon = 'nsv13/icons/obj/stairs_large.dmi'
	icon_state = "upstairs"
	anchored = TRUE
	density = FALSE
	force_open_above = TRUE