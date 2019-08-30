/obj/machinery/door/airlock/ship
	name = "Airtight hatch"
	icon = 'nsv13/icons/obj/machinery/doors/standard.dmi'
	desc = "A durasteel bulkhead which opens and closes. Hope you're good at hatch hopping"
	icon_state = "closed"
//	doorOpen = 'DS13/sound/effects/tng_airlock.ogg'
//	doorClose = 'DS13/sound/effects/tng_airlock.ogg'
//	doorDeni = 'DS13/sound/effects/denybeep.ogg'

/obj/machinery/door/poddoor/ship
	name = "Double reinforced durasteel blast door"
	icon = 'nsv13/goonstation/icons/blastdoor.dmi'
	desc = "A titanic hunk of durasteel which is designed to absorb high velocity rounds, explosive forces and general impacts. It's equipped with a triple deadlock seal, preventing anyone from getting past it."

/obj/machinery/door/poddoor/ship/preopen
	icon_state = "open"
	density = FALSE
	opacity = 0

/obj/machinery/door/airlock/ship/command
	name = "Command"
	icon = 'nsv13/goonstation/icons/command.dmi'
	req_one_access_txt = "19"

/obj/machinery/door/airlock/ship/engineering
	name = "Engineering wing"
	icon = 'nsv13/goonstation/icons/engineering.dmi'
	req_one_access_txt = "10"

/obj/machinery/door/airlock/ship/external
	name = "External airlock"
	icon = 'nsv13/goonstation/icons/external.dmi'
	req_one_access_txt = "13"

/obj/machinery/door/airlock/ship/maintenance
	name = "Maintenance tunnels"
	icon = 'nsv13/goonstation/icons/maintenance.dmi'
	req_one_access_txt = "12"

/obj/machinery/door/airlock/ship/public
	name = "Public airlock"
	icon = 'nsv13/goonstation/icons/public.dmi'

/obj/machinery/door/airlock/ship/medical
	name = "Infirmary"
	icon = 'nsv13/goonstation/icons/medical.dmi'
	req_one_access_txt = "5"

/obj/machinery/door/airlock/ship/security
	name = "Brig"
	icon = 'nsv13/goonstation/icons/security.dmi'
	req_one_access_txt = "63"

/obj/machinery/door/airlock/ship/cargo
	name = "Cargo bay"
	req_one_access_txt = "31"