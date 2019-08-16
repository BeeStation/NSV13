/obj/machinery/computer/ship
	name = "A ship component"
	icon_keyboard = "helm_key"
	var/obj/structure/overmap/linked
	var/position = null

/obj/machinery/computer/ship/proc/has_overmap()
	var/area/AR = get_area(src)
	if(AR.linked_overmap)
		linked = AR.linked_overmap
	if(linked)
		return TRUE
	else
		return FALSE

/obj/machinery/computer/ship/attack_hand(mob/user)
	if(!has_overmap())
		to_chat(user, "<span class='warning'>A warning flashes across [src]'s screen: Unable to locate thrust parameters, no registered ship stored in microprocessor.</span>")
		return
	if(!position)
		return
	return linked.start_piloting(user, position)

/obj/machinery/computer/ship/helm
	name = "Siegford model HLM flight control console"
	desc = "A computerized ship piloting package which allows a user to set a ship's speed, attitude, bearing and more!"
	icon_screen = "helm"
	position = "pilot"

/obj/machinery/computer/ship/tactical
	name = "Siegford model TAC tactical systems control console"
	desc = "In ship-to-ship combat, most ship systems are digitalized. This console is networked with every weapon system that its ship has to offer, allowing for easy control. There's a section on the screen showing an exterior gun camera view with a rangefinder."
	icon_screen = "tactical"
	position = "gunner"