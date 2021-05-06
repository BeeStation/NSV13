//NSV NOTE TO SELF: Ensure _all_ ship airlocks have a glass type!

//TODO: gap underneath door
/obj/machinery/door/airlock/ship
	name = "Airtight hatch"
	icon = 'nsv13/icons/obj/machinery/doors/standard.dmi'
	desc = "A durasteel bulkhead which opens and closes. Hope you're good at hatch hopping"
	icon_state = "closed"
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays_standard.dmi'
	assemblytype = /obj/structure/door_assembly/ship
	anim_parts = "up=0,28;fg=0,0"
	panel_attachment = "up"
	note_attachment = "up"
	// These icon_states stack from bottom to top.
	// Coordinates are x,y movement. -x = left, +x = right, -y = down, +y = up

//Failsafe for the common door type..
/obj/machinery/door/airlock/ship/glass
	opacity = 0
	glass = TRUE

//So we don't have to code in specific door assemblies...
//TODO: kill with fire
/obj/structure/door_assembly/proc/nsv_ify(obj/machinery/door/airlock/ship/target)
	if(!istype(target) && !istype(target, /obj/machinery/door/airlock/highsecurity/ship))
		return
	icon = target.icon
	dir = target.dir
	if(target.icon_state)
		icon_state = target.icon_state
	overlays_file = target.overlays_file
	airlock_type = target.type
	//Lazy way of assigning glass airlocks :)
	try
		glass_type = text2path("[target.type]/glass")
		//Douuuuble check that one chief.
		if(!glass_type)
			glass_type = /obj/structure/door_assembly/ship
	catch(var/exception/e) //Fallback.
		glass_type = /obj/machinery/door/airlock/ship/glass
		pass(e)	//suppress unused warning
		return

/obj/structure/door_assembly/ship
	name = "airlock assembly"
	icon = 'nsv13/icons/obj/machinery/doors/standard.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays_standard.dmi'
	glass_type = /obj/machinery/door/airlock/ship/glass
	airlock_type = /obj/machinery/door/airlock/ship

/obj/machinery/door/airlock/ship/Initialize()
	. = ..()
	set_smooth_dir()
	if((dir != NORTH) && (dir != SOUTH))
		LEGACY_OVERLAYS = TRUE
		anim_parts = ""
		rebuild_parts()
		update_icon()

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
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays.dmi'
	anim_parts = "left=-12,0;right=12,0"
	panel_attachment = "right"
	note_attachment = "left"

/obj/machinery/door/airlock/ship/station/glass
	name = "Standard airlock"
	icon = 'nsv13/icons/obj/machinery/doors/station_glass.dmi'
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/ship/station/mining
	name = "Mining airlock"
	color = "#b88a3d"

/obj/machinery/door/airlock/ship/station/mining/glass
	icon = 'nsv13/icons/obj/machinery/doors/station_glass.dmi'
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/ship/station/research
	name = "Research airlock"

/obj/machinery/door/airlock/ship/station/research/glass
	icon = 'nsv13/icons/obj/machinery/doors/station_glass.dmi'
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/ship/hatch
	name = "airtight hatch"
	icon = 'nsv13/icons/obj/machinery/doors/hatch.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays_hatch.dmi'
	anim_parts = "down_left=-9,-9;down_right=9,-9;up_left=-9,9;up_right=9,9;fg=0,0"
	panel_attachment = "down_right"
	note_attachment = "up_left"

/obj/machinery/door/airlock/ship/hatch/glass
	name = "airtight hatch"
	opacity = 0
	glass = TRUE

/obj/machinery/door/poddoor/ship
	name = "Double reinforced durasteel blast door"
	icon = 'nsv13/goonstation/icons/blastdoor.dmi'
	desc = "A titanic hunk of durasteel which is designed to absorb high velocity rounds, explosive forces and general impacts. It's equipped with a triple deadlock seal, preventing anyone from getting past it."

/obj/machinery/door/poddoor/ship/preopen
	icon_state = "open"
	density = FALSE
	opacity = 0

/obj/machinery/door/poddoor/shutters/ship
	icon = 'nsv13/icons/obj/machinery/doors/shutters.dmi'

/obj/machinery/door/poddoor/shutters/ship/preopen
	icon_state = "open"
	density = FALSE
	opacity = 0

/obj/machinery/door/airlock/ship/command
	name = "Command"
	icon = 'nsv13/goonstation/icons/command.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays_goon.dmi'
	anim_parts = "bg=0,0;left=-12,0;right=12,0"
	panel_attachment = "right"
	note_attachment = "left"

/obj/machinery/door/airlock/ship/command/glass
	icon = 'nsv13/goonstation/icons/command_glass.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays.dmi'
	opacity = 0
	glass = TRUE
	anim_parts = "bg=0,0;down=0,-30;fg=0,0"
	panel_attachment = "fg"
	note_attachment = "down"

/obj/machinery/door/airlock/highsecurity/ship
	icon = 'nsv13/icons/obj/machinery/doors/vault.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays.dmi'
	anim_parts = "left=-10,0;right=10,0"

/obj/machinery/door/airlock/highsecurity/ship/Initialize()
	. = ..()
	set_smooth_dir()
	if((dir != NORTH) && (dir != SOUTH))
		LEGACY_OVERLAYS = TRUE
		anim_parts = ""
		rebuild_parts()
		update_icon()

/obj/machinery/door/airlock/wood
	icon = 'nsv13/goonstation/icons/airlock_wood.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays.dmi'
	LEGACY_OVERLAYS = TRUE
	anim_parts=""

/obj/machinery/door/airlock/vault/ship
	icon = 'nsv13/icons/obj/machinery/doors/vault.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays.dmi'
	desc = "A durasteel bulkhead which opens and closes. Hope you're good at hatch hopping"
	icon_state = "closed"
	anim_parts = "left=-10,0;right=10,0"

/obj/machinery/door/airlock/vault/ship/Initialize()
	. = ..()
	set_smooth_dir()
	if((dir != NORTH) && (dir != SOUTH))
		LEGACY_OVERLAYS = TRUE
		anim_parts = ""
		rebuild_parts()
		update_icon()

/obj/machinery/door/airlock/ship/engineering
	name = "Engineering wing"
	icon = 'nsv13/goonstation/icons/engineering.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays_goon.dmi'
	anim_parts = "bg=0,0;left=-12,0;right=12,0"
	panel_attachment = "right"
	note_attachment = "left"

/obj/machinery/door/airlock/ship/engineering/glass
	icon = 'nsv13/goonstation/icons/engineering_glass.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays.dmi'
	opacity = 0
	glass = TRUE
	anim_parts = "bg=0,0;down=0,-30;fg=0,0"
	panel_attachment = "fg"
	note_attachment = "down"

/obj/machinery/door/airlock/ship/external
	name = "External airlock"
	icon = 'nsv13/goonstation/icons/external.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays.dmi'
	anim_parts = "bg=0,0;left=-12,0;right=15,0"
	panel_attachment = "right"
	note_attachment = "left"

/obj/machinery/door/airlock/ship/external/glass
	name = "External airlock"
	icon = 'nsv13/goonstation/icons/external_glass.dmi'
	opacity = 0
	glass = TRUE
	anim_parts = "bg=0,0;left=-12,0;right=15,0"

/obj/machinery/door/airlock/ship/maintenance
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays_goon.dmi'
	name = "Maintenance tunnels"
	icon = 'nsv13/goonstation/icons/maintenance.dmi'
	anim_parts = "bg=0,0;left=-12,0;right=12,0"
	panel_attachment = "right"
	note_attachment = "left"

/obj/machinery/door/airlock/ship/maintenance/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/ship/maintenance/defaultaccess //Default maint door if you don't want to set up departmental maint access.
	req_one_access_txt = "12"

/obj/machinery/door/airlock/ship/public
	name = "Public airlock"
	icon = 'nsv13/goonstation/icons/public.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays_goon.dmi'
	anim_parts = "bg=0,0;left=-12,0;right=12,0"
	panel_attachment = "right"
	note_attachment = "left"

/obj/machinery/door/airlock/ship/public/glass
	icon = 'nsv13/goonstation/icons/airlock_glass.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays.dmi'
	opacity = 0
	glass = TRUE
	anim_parts = "bg=0,0;down=0,-30;fg=0,0"
	panel_attachment = "fg"
	note_attachment = "down"

/obj/machinery/door/airlock/glass_large/ship
	icon = 'nsv13/icons/obj/machinery/doors/double.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays_large.dmi'
	anim_parts=""
	LEGACY_OVERLAYS = TRUE

/obj/machinery/door/airlock/ship/medical
	name = "Infirmary"
	icon = 'nsv13/goonstation/icons/medical.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays_goon.dmi'
	anim_parts = "bg=0,0;left=-12,0;right=12,0"
	panel_attachment = "right"
	note_attachment = "left"

/obj/machinery/door/airlock/ship/medical/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/ship/security
	name = "Brig"
	icon = 'nsv13/goonstation/icons/security.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays_goon.dmi'
	anim_parts = "bg=0,0;left=-12,0;right=12,0"
	panel_attachment = "right"
	note_attachment = "left"

/obj/machinery/door/airlock/ship/security/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/ship/cargo
	name = "Cargo bay"


/obj/machinery/door/airlock/ship/cargo/glass
	opacity = 0
	glass = TRUE