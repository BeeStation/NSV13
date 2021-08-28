/obj/machinery/ship_weapon/torpedo_launcher/cargo //heavily modified CM sprite
	name = "M4-C Cargo freight tube"
	desc = "A transport system that's employed by nigh on all modern ships. It's capable of delivering a self-propelling payload with pinpoint accuracy to deliver freight."
	color = "#f5d1b0" // I have better things to do than to modify 100+ sprite frames just to add funny orange stripes 

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

/obj/machinery/ship_weapon/torpedo_launcher/cargo/Initialize()
	// ..() // Don't run any ship weapon related procs 

	component_parts = list()
	component_parts += new/obj/item/ship_weapon/parts/firing_electronics
