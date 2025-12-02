/obj/item/ship_weapon/ammunition/missile/cruise
	name = "MS-1 'Sparrowhawk' standard cruise missile"
	desc = "Lethally precise, terrifyingly destructive. Can only be fired from the VLS."
	icon = 'nsv13/icons/obj/munitions/missile.dmi'
	icon_state = "standard"
	bound_width = 128
	anchored = TRUE
	density = TRUE

/obj/machinery/ship_weapon/vls
	name = "M14 VLS Loader"
	desc = "A highly advanced launch platform for missiles inspired by recently discovered old-earth technology. The VLS allows for launching cruise missiles from any angle, and directly interfaces with the AMS for lethal precision."
	icon = 'nsv13/icons/obj/munitions/vls.dmi'
	icon_state = "loader"
	firing_sound = 'nsv13/sound/effects/ship/plasma.ogg'
	load_sound = 'nsv13/sound/effects/ship/freespace2/m_load.wav'
	ammo_type = list(/obj/item/ship_weapon/ammunition/missile, /obj/item/ship_weapon/ammunition/torpedo)
	CanAtmosPass = FALSE
	CanAtmosPassVertical = FALSE
	semi_auto = TRUE
	max_ammo = 2
	density = FALSE
	circuit = /obj/item/circuitboard/machine/vls
	weapon_datum_type = /datum/overmap_ship_weapon/vls

	var/obj/structure/fluff/vls_hatch/hatch = null

/obj/machinery/ship_weapon/vls/proc/on_entered(datum/source, atom/movable/torp, oldloc)
	SIGNAL_HANDLER

	if(!is_type_in_list(torp, ammo_type))
		return FALSE

	if(ammo?.len >= max_ammo)
		return FALSE
	if(loading)
		return FALSE
	if(oldloc == src)// stops torps from getting sent back in instantly
		return FALSE
	if(state >= STATE_LOADED)
		return FALSE
	load(torp)

// Handles removal of stuff
/obj/machinery/ship_weapon/vls/Exited(atom/movable/gone, direction)
	. = ..()
	if(!ammo?.Find(gone)) // Remove our ammo
		return
	ammo -= gone
	if(!length(ammo)) // Set notloaded if applicable
		state = STATE_NOTLOADED

/obj/machinery/ship_weapon/vls/PostInitialize()
	..()
	if(maintainable)
		maint_req = rand(80, 120) //They don't break down often, but keep an eye on them.

/obj/machinery/ship_weapon/vls/animate_projectile(atom/target, lateral=TRUE)
	// We have different sprites and behaviors for each torpedo
	var/obj/item/ship_weapon/ammunition/torpedo/T = chambered
	if(T)
		var/obj/item/projectile/P = linked.fire_projectile(T.projectile_type, target, firing_flags = linked_overmap_ship_weapon.weapon_firing_flags)
		if(T.contents.len)
			for(var/atom/movable/AM in T.contents)
				to_chat(AM, "<span class='warning'>You feel slightly nauseous as you're shot out into space...</span>")
				AM.forceMove(P)

/obj/machinery/ship_weapon/vls/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	var/turf/T = SSmapping.get_turf_above(src)
	if(!T)
		return
	hatch = locate(/obj/structure/fluff/vls_hatch) in T
	if(!hatch)
		return
	var/matrix/ntransform = new()
	if(dir & NORTH)
		ntransform.Turn(90)
		ntransform.Translate(-16,-16)
		hatch.transform = ntransform
		return
	if(dir & SOUTH)
		ntransform.Turn(-90)
		ntransform.Translate(-16,16)
		hatch.transform = ntransform
		return
	if(dir & EAST)
		return
	if(dir & WEST)
		ntransform.Turn(-180)
		ntransform.Translate(-32,1)
		hatch.transform = ntransform
		return

#define HT_OPEN TRUE
#define HT_CLOSED FALSE

/obj/machinery/ship_weapon/vls/feed()
	. = ..()
	if(!hatch)
		return
	hatch.toggle(HT_OPEN)

/obj/machinery/ship_weapon/vls/local_fire()
	. = ..()
	if(!hatch)
		return
	hatch.toggle(HT_CLOSED)

/obj/machinery/ship_weapon/vls/unload()
	. = ..()
	if(!hatch)
		return
	hatch.toggle(HT_CLOSED)

/obj/structure/fluff/vls_hatch
	name = "VLS Launch Hatch"
	desc = "A hatch designed to let cruise missiles out, and keep air in for the deck below."
	icon = 'nsv13/icons/obj/munitions/vls.dmi'
	icon_state = "vls_closed"
	CanAtmosPass = FALSE
	CanAtmosPassVertical = FALSE
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP
	anchored = TRUE
	obj_integrity = 1000
	max_integrity = 1000

/obj/structure/fluff/vls_hatch/proc/toggle(state)
	if(state == HT_OPEN)
		obj_flags &= ~(BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP)
		icon_state = "vls"
		density = FALSE
		return
	obj_flags |= (BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP)
	icon_state = "vls_closed"
	density = TRUE
