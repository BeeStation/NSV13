/obj/machinery/door/airlock/ship
	name = "Airtight hatch"
	icon = 'nsv13/icons/obj/machinery/doors/standard.dmi'
	desc = "A durasteel bulkhead which opens and closes. Hope you're good at hatch hopping"
	icon_state = "closed"
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays.dmi'
//	doorOpen = 'DS13/sound/effects/tng_airlock.ogg'
//	doorClose = 'DS13/sound/effects/tng_airlock.ogg'
//	doorDeni = 'DS13/sound/effects/denybeep.ogg'

/obj/machinery/door/airlock/ship/Initialize()
	. = ..()
	set_smooth_dir()


/*

This proc looks like it makes no sense. Bear with me...


Assuming:

X = wall
[] = airlock:


X
[]
X
odir = SOUTH / NORTH. We need it to face sideways so you can get through

X[]X
odir = EAST / WEST. We need it to face forwards so you can get through


*/

/obj/machinery/door/airlock/proc/set_smooth_dir() //I fucking hate this code and so should you :)
//	for(var/atom/obstacle in view(1, src)) //Ghetto ass icon smooth
	var/odir = 0
	var/atom/found = null
	var/turf/north = get_turf(get_step(src,NORTH))
	if(north.density)
		found = north
		odir = NORTH
	var/turf/south = get_turf(get_step(src,SOUTH))
	if(south.density)
		found = south
		odir = SOUTH
	var/turf/east = get_turf(get_step(src,EAST))
	if(east.density)
		found = east
		odir = EAST
	var/turf/west = get_turf(get_step(src,WEST))
	if(west.density)
		found = west
		odir = WEST
	if(!found)
		for(var/atom/foo in get_step(src,NORTH))
			if(foo?.density)
				found = foo
				odir = NORTH
				break
		for(var/atom/foo in get_step(src,SOUTH))
			if(foo?.density)
				found = foo
				odir = SOUTH
				break
		for(var/atom/foo in get_step(src,EAST))
			if(foo?.density)
				found = foo
				odir = EAST
				break
		for(var/atom/foo in get_step(src,WEST))
			if(foo?.density)
				found = foo
				odir = WEST
				break
	if(odir == NORTH || odir == SOUTH)
		dir = EAST
	else
		dir = SOUTH
	return odir

/obj/machinery/door/airlock/ship/station
	name = "Standard airlock"
	icon = 'nsv13/icons/obj/machinery/doors/station.dmi'

/obj/machinery/door/airlock/ship/station/glass
	name = "Standard airlock"
	icon = 'nsv13/icons/obj/machinery/doors/station_glass.dmi'
	density = FALSE
	opacity = 0

/obj/machinery/door/airlock/ship/station/mining
	name = "Mining airlock"
	color = "#b88a3d"

/obj/machinery/door/airlock/ship/station/research
	name = "Research airlock"

/obj/machinery/door/airlock/ship/hatch
	name = "airtight hatch"
	icon = 'nsv13/icons/obj/machinery/doors/hatch.dmi'

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

/obj/machinery/door/airlock/highsecurity/ship
	icon = 'nsv13/icons/obj/machinery/doors/vault.dmi'

/obj/machinery/door/airlock/highsecurity/ship/Initialize()
	. = ..()
	set_smooth_dir()

/obj/machinery/door/airlock/wood
	icon = 'nsv13/goonstation/icons/airlock_wood.dmi'

/obj/machinery/door/airlock/ship/command/glass
	icon = 'nsv13/goonstation/icons/command_glass.dmi'
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/vault/ship
	icon = 'nsv13/icons/obj/machinery/doors/vault.dmi'
	desc = "A durasteel bulkhead which opens and closes. Hope you're good at hatch hopping"
	icon_state = "closed"

/obj/machinery/door/airlock/vault/ship/Initialize()
	. = ..()
	set_smooth_dir()

/obj/machinery/door/airlock/ship/engineering
	name = "Engineering wing"
	icon = 'nsv13/goonstation/icons/engineering.dmi'

/obj/machinery/door/airlock/ship/engineering/glass
	icon = 'nsv13/goonstation/icons/engineering_glass.dmi'
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/ship/external
	name = "External airlock"
	icon = 'nsv13/goonstation/icons/external.dmi'

/obj/machinery/door/airlock/ship/external/glass
	name = "External airlock"
	icon = 'nsv13/goonstation/icons/external.dmi'
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/ship/maintenance
	name = "Maintenance tunnels"
	icon = 'nsv13/goonstation/icons/maintenance.dmi'

/obj/machinery/door/airlock/ship/public
	name = "Public airlock"
	icon = 'nsv13/goonstation/icons/public.dmi'

/obj/machinery/door/airlock/ship/public/glass
	icon = 'nsv13/goonstation/icons/airlock_glass.dmi'
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/glass_large/ship
	icon = 'nsv13/icons/obj/machinery/doors/double.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays_large.dmi'

/obj/machinery/door/airlock/ship/medical
	name = "Infirmary"
	icon = 'nsv13/goonstation/icons/medical.dmi'

/obj/machinery/door/airlock/ship/security
	name = "Brig"
	icon = 'nsv13/goonstation/icons/security.dmi'

/obj/machinery/door/airlock/ship/security/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/ship/cargo
	name = "Cargo bay"