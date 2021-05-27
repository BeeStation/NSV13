/turf/closed/wall
	icon_state = "solid"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	canSmoothWith = list(/turf/closed/wall,/obj/machinery/door,/obj/structure/window/fulltile,/obj/structure/window/reinforced/fulltile, /obj/structure/window/plasma/fulltile, /obj/structure/falsewall)
	var/list/wall_connections = list("0", "0", "0", "0")
	var/list/other_connections = list("0", "0", "0", "0")
	var/image/texture = null //EG: Concrete. Lets you texture a wall with one texture tile rather than making a new wall..every..single...time
	var/texture_state = null

/turf/closed/wall/Initialize()
	. = ..()
	if(texture_state)
		texture = image(icon, texture_state)
		texture.blend_mode = BLEND_MULTIPLY

/turf/closed/wall/steel
	color = "#787878"

/obj/structure/falsewall
	icon_state = "solid"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	canSmoothWith = list(/turf/closed/wall,/obj/machinery/door,/obj/structure/window/fulltile,/obj/structure/window/reinforced/fulltile, /obj/structure/window/plasma/fulltile, /obj/structure/falsewall)
	var/list/wall_connections = list("0", "0", "0", "0")
	var/list/other_connections = list("0", "0", "0", "0")
	var/image/texture = null //EG: Concrete. Lets you texture a wall with one texture tile rather than making a new wall..every..single...time
	var/texture_state = null

/obj/structure/falsewall/Initialize()
	. = ..()
	if(texture_state)
		texture = image(icon, texture_state)
		texture.blend_mode = BLEND_MULTIPLY

/turf/closed/wall/r_wall
	icon_state = "reinf"
	texture = "reinf_over"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	color = "#787878"

/obj/structure/falsewall/reinforced
	icon_state = "reinf"
	texture = "reinf_over"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	color = "#787878"

/turf/closed/wall/mineral
	icon_state = "mineral"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/cult
	icon_state = "cult"
	color = "#4C4343"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/gold
	color = "#FFD700"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	icon_state = "metal"

/obj/structure/falsewall/gold
	color = "#FFD700"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	icon_state = "metal"

/turf/closed/wall/mineral/silver
	icon_state = "metal"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/obj/structure/falsewall/silver
	icon_state = "metal"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/snow
	icon_state = "metal"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/copper
	icon_state = "metal"
	color = "#b87333"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/obj/structure/falsewall/copper
	icon_state = "metal"
	color = "#b87333"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/diamond
	icon_state = "metal"
	color = "#b9f2ff"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/obj/structure/falsewall/diamond
	icon_state = "metal"
	color = "#b9f2ff"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/sandstone
	icon_state = "metal"
	color = "#AA9F91"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	texture_state = "concrete"

/obj/structure/falsewall/sandstone
	icon_state = "metal"
	color = "#AA9F91"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	texture_state = "concrete"

/turf/closed/wall/mineral/bananium
	icon_state = "metal"
	color = "#FFFF33"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/obj/structure/falsewall/bananium
	icon_state = "metal"
	color = "#FFFF33"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/uranium
	icon_state = "metal"
	color = "#228B22"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	texture_state = "concrete"

/obj/structure/falsewall/uranium
	icon_state = "metal"
	color = "#228B22"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	texture_state = "concrete"

/turf/closed/wall/mineral/plasma
	icon_state = "metal"
	color = "#EE82EE"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/obj/structure/falsewall/plasma
	icon_state = "metal"
	color = "#EE82EE"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/iron
	icon_state = "metal"
	color = "#808080"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/obj/structure/falsewall/iron
	icon_state = "metal"
	color = "#808080"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/wood
	icon_state = "wood"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	color = "#654D31"

/obj/structure/falsewall/wood
	icon_state = "wood"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	color = "#654D31"

//Turfs that are still oblique. Fix these later.

/turf/closed/wall/mineral/titanium
	legacy_smooth = FALSE

/turf/closed/wall/mineral/plastitanium
	legacy_smooth = FALSE

/turf/closed/wall/mineral/abductor
	legacy_smooth = FALSE
