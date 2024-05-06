/obj/machinery/ship_weapon/torpedo_launcher/cargo //heavily modified CM sprite
	name = "\improper M4-C Cargo freight launcher"
	desc = "A transport system that's employed by nigh on all modern ships. It's capable of delivering a self-propelling payload with pinpoint accuracy to deliver freight."
	color = "#f5d1b0" // I have better things to do than to modify 100+ sprite frames just to add funny orange stripes
	var/obj/machinery/computer/ship/dradis/minor/cargo/linked_dradis = null
	ammo_type = /obj/item/ship_weapon/ammunition/torpedo/freight
	var/launcher_id = null

/obj/machinery/ship_weapon/torpedo_launcher/cargo/north
	dir = NORTH
	pixel_x = -16
	pixel_y = -32
	bound_height = 96
	bound_width = 32

/obj/machinery/ship_weapon/torpedo_launcher/cargo/south
	dir = SOUTH
	pixel_x = -16
	pixel_y = -64
	bound_height = 96
	bound_width = 32
	bound_y = -64

/obj/machinery/ship_weapon/torpedo_launcher/cargo/east
	dir = EAST

/obj/machinery/ship_weapon/torpedo_launcher/cargo/west
	dir = WEST
	pixel_x = -64
	pixel_y = -74
	bound_x = -64

/obj/machinery/ship_weapon/torpedo_launcher/cargo/Initialize(mapload)
	. = ..()
	if(!linked_dradis)
		if(launcher_id) //If mappers set an ID
			for(var/obj/machinery/computer/ship/dradis/minor/cargo/W in GLOB.machines)
				if(W.dradis_id == launcher_id && W.z == z)
					linked_dradis = W
					W.linked_launcher = src

/obj/machinery/ship_weapon/torpedo_launcher/cargo/set_position()
	// Don't register cargo torpedo tube for weapons fire by tactical console
