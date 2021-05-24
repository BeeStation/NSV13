//Ship piloting console, most of the code is already in ship.dm
/obj/machinery/computer/ship/helm
	name = "Seegson model HLM flight control console"
	desc = "A computerized ship piloting package which allows a user to set a ship's speed, attitude, bearing and more!"
	icon_screen = "helm"
	position = "pilot"
	circuit = /obj/item/circuitboard/computer/ship/helm

/obj/machinery/computer/ship/helm/set_position(obj/structure/overmap/OM)
	OM.helm = src
	return
