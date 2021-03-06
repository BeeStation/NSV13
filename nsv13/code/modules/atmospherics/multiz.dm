/obj/machinery/atmospherics/pipe/simple/multiz
	name = "multi deck pipe adapter"
	desc = "An adapter which allows pipes to connect to other pipenets on different decks."
	icon_state = "pipe11-2"
	icon = 'nsv13/icons/obj/atmos.dmi'

/obj/machinery/atmospherics/pipe/simple/multiz/update_icon()
	. = ..()
	cut_overlays() //This adds the overlay showing it's a multiz pipe. This should go above turfs and such
	var/image/multiz_overlay_node = new(src) //If we have a firing state, light em up!
	multiz_overlay_node.icon = 'nsv13/icons/obj/atmos.dmi'
	multiz_overlay_node.icon_state = "multiz_pipe"
	multiz_overlay_node.layer = HIGH_OBJ_LAYER
	add_overlay(multiz_overlay_node)

/obj/machinery/atmospherics/pipe/simple/multiz/pipeline_expansion()
	icon = 'nsv13/icons/obj/atmos.dmi' //Just to refresh.
	var/turf/T = get_turf(src)
	var/obj/machinery/atmospherics/pipe/simple/multiz/above = locate(/obj/machinery/atmospherics/pipe/simple/multiz) in(SSmapping.get_turf_above(T))
	if(above)
		nodes += above
		above.nodes += src //Two way travel :)
		return ..()
	else
		return ..()