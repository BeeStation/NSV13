/obj/structure/chair/fancy/sofa/mono
	color = rgb(76, 78, 82)
	name = "old ratty sofa"
	desc = "An old design, but it still does the job of being a sofa."
	icon_state = "sofa_middle"
	colorable = TRUE
	item_chair = null

/obj/structure/chair/fancy/sofa/mono/left
	icon_state = "sofa_end_left"

/obj/structure/chair/fancy/sofa/mono/right
	icon_state = "sofa_end_right"

/obj/structure/chair/fancy/sofa/mono/corner
	name = "impossible old sofa corner"
	desc = "This kind of sofa shouldn't even exist at all. If you see this non-euclidean specimen, contact your station's Anti-Couch Surfing Department."
	icon_state = "sofa_cursed"

/obj/structure/chair/fancy/sofa/mono/corner/handle_layer() //only the armrest/back of this chair should cover the mob.
	return

/obj/structure/chair/fancy/sofa/mono/corner/concave
	icon_state = "sofa_corner_in"
	name = "old ratty sofa"
	desc = "An old design, but it still does the job of being a sofa, this one is concave."

/obj/structure/chair/fancy/sofa/mono/corner/convex
	icon_state = "sofa_corner_out"
	name = "old ratty sofa"
	desc = "An old design, but it still does the job of being a sofa, this one is convex."
