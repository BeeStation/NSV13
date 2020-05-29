/obj/item/control_rod
	name = "Nanocarbon Reactor Control Rod"
	desc = "A standard nanocarbon reactor control rod."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	w_class = WEIGHT_CLASS_BULKY
	var/rod_integrity = 100
	var/rod_effectiveness = 1

/obj/item/control_rod/Initialize()
	.=..()
	AddComponent(/datum/component/twohanded/required)

/obj/item/control_rod/proc/rod_failure(var/obj/machinery/atmospherics/components/binary/stormdrive_reactor/R, var/obj/item/control_rod/cr)
	if(cr.rod_integrity != 0)
		return
	R.control_rods += new /obj/item/control_rod/irradiated(R)
	qdel(cr)

/obj/item/control_rod/inferior
	name = "Techfab Manufactured Reactor Control Rod"
	desc = "A Reactor Control Rod manufactured onboard, techfabs lack the resolution to completely solidify the core."
	icon_state = "mop"
	rod_integrity = 80
	rod_effectiveness = 0.8

/obj/item/control_rod/superior
	name = "Crystaline Nanocarbon Reactor Control Rod"
	desc = "A superior nanocarbon reactor control rod, a yielding a longer life time."
	icon_state = "mop"
	rod_integrity = 200

/obj/item/control_rod/plasma //Add to TC store under engineering tag
	name = "Nanocarbon Sheathed Plasma Reactor Control Rod"
	desc = "A nanocarbon sheet surrounds the plasma core of this reactor control rod."
	icon_state = "mop"
	rod_effectiveness = -0.5

/obj/item/control_rod/irradiated
	name = "Irradiated Reactor Control Rod"
	desc = "An reactor control rod saturated with radioactive particles, it is no longer effective."
	icon_state = "mop"
	rod_integrity = 0
	rod_effectiveness = 0

/obj/item/control_rod/irradiated/Initialize()
	.=..()
	AddComponent(/datum/component/radioactive, 500, src)

/datum/techweb_node/reactor_control_rods
	id = "reactor_control_rods"
	display_name = "Stormdrive Reactor Control Rod Fabrication"
	description = "Onboard fabrication of reactor control rods for the stormdrive. They'll do in a pinch."
	prereq_ids = list("engineering")
	design_ids = list("reactor_control_rods")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 1000

/datum/design/reactor_control_rods
	name = "Techfab Manufactured Reactor Control Rod"
	desc = "A Reactor Control Rod manufactured onboard, techfabs lack the resolution to completely solidify the core."
	id = "reactor_control_rods"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/titanium = 500)
	build_path = /obj/item/control_rod/inferior
	category = list("Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING