/obj/machinery/ship_weapon/deck_turret
	name = "\improper M4-15 'Hood' deck turret"
	desc = "A huge naval gun which uses chemical accelerants to propel rounds. Inspired by the classics, this gun packs a major punch and is quite easy to reload. Use a multitool on it to re-register loading aparatus."
	icon = 'nsv13/icons/obj/munitions/deck_turret.dmi'
	icon_state = "deck_turret"
	fire_mode = FIRE_MODE_MAC
	ammo_type = /obj/item/ship_weapon/ammunition/naval_artillery
	pixel_x = -45
	pixel_y = -63
	bound_width = 64
	bound_height = 128
	semi_auto = TRUE
	max_ammo = 1
	obj_integrity = 500
	max_integrity = 500
	safety = FALSE
	maintainable = FALSE //This just makes them brick.
	load_sound = 'nsv13/sound/effects/ship/freespace2/crane_short.ogg'
	var/obj/machinery/deck_turret/core

/obj/machinery/ship_weapon/deck_turret/lazyload()
	. = ..()
	//Ensure that the lazyloaded shells come pre-packed
	for(var/obj/item/ship_weapon/ammunition/naval_artillery/shell in ammo)
		shell.speed = 2

/obj/machinery/ship_weapon/deck_turret/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	core = locate(/obj/machinery/deck_turret) in SSmapping.get_turf_below(src)
	if(!core)
		to_chat(user, "<span class='warning'>No gun core detected to link to. Ensure one is placed directly below the turret. </span>")
		return
	core.turret = src
	to_chat(user, "<span class='notice'>Successfully linked to gun core below deck.</span>")
	core.update_parts()

//No cheating! You need to load it from below...
/obj/machinery/ship_weapon/deck_turret/MouseDrop_T(obj/item/A, mob/user)
	return FALSE

/obj/machinery/ship_weapon/deck_turret/animate_projectile(atom/target, lateral=TRUE)
	var/obj/item/ship_weapon/ammunition/naval_artillery/T = chambered
	if(T)
		linked.fire_projectile(T.projectile_type, target,speed=T.speed, homing=TRUE, lateral=weapon_type.lateral)

/obj/machinery/ship_weapon/deck_turret/proc/rack_load(atom/movable/A)
	if(ammo?.len < max_ammo && istype(A, ammo_type))
		loading = TRUE
		if(load_sound)
			playsound(A.loc, load_sound, 100, 1)
		playsound(A.loc, 'sound/machines/click.ogg', 50, 1)
		A.forceMove(src)
		ammo += A
		if(state < STATE_LOADED)
			state = STATE_LOADED
		if(state < STATE_FED)
			feed()
			chamber()
		return TRUE
	loading = FALSE
	return FALSE

/obj/machinery/computer/deckgun
	icon = 'nsv13/icons/obj/munitions/deck_gun.dmi'
	icon_state = "gun_control"
	icon_screen = "screen_guncontrol"
	circuit = /obj/item/circuitboard/computer/deckgun
	var/obj/machinery/deck_turret/core = null

/obj/machinery/computer/deckgun/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	if(!core)
		core = locate(/obj/machinery/deck_turret) in orange(1, src)

/obj/machinery/computer/deckgun/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DeckGun")
		ui.open()

/obj/machinery/computer/deckgun/ui_data(mob/user)
	var/list/data = list()
	var/list/parts = list()
	if(!core)
		return data
	if(get_dist(core.payload_gate, core) > 1)
		core.update_parts()
	data["id"] = (core.payload_gate) ? "\ref[core.payload_gate]" : null
	if(!core.powder_gates?.len)
		core.update_parts()
	for(var/obj/machinery/deck_turret/powder_gate/MOREPOWDER in core.powder_gates)
		if(get_dist(MOREPOWDER, core) < 1 || !MOREPOWDER || QDELETED(MOREPOWDER))
			core.update_parts()
			continue
		var/list/part = list()
		part["loaded"] = (MOREPOWDER.bag) ? TRUE : FALSE
		part["id"] = "\ref[MOREPOWDER]"
		parts[++parts.len] = part
	data["parts"] = parts
	data["can_pack"] = core.payload_gate.shell ? TRUE : FALSE
	data["can_load"] = core.turret?.ammo?.len < core.turret?.max_ammo || FALSE
	data["ammo"] = core.turret?.ammo?.len || 0
	data["max_ammo"] = core.turret?.max_ammo || 0
	data["loaded"] = core.payload_gate?.shell?.name || "Nothing"
	data["speed"] = core.payload_gate?.shell?.speed || 0
	data["max_speed"] = 2
	return data

/obj/machinery/computer/deckgun/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/obj/machinery/deck_turret/powder_gate/target = locate(params["target"])
	switch(action)
		if("load")
			if(!core.turret.rack_load(core.payload_gate.shell))
				return
			core.payload_gate.shell = null
			core.payload_gate.unload()
			if(locate(/obj/machinery/deck_turret/autorepair) in orange(1, core))
				core.turret.maint_req ++
				core.turret.maint_req = CLAMP(core.turret.maint_req, 0, 25)
				new /obj/effect/temp_visual/heal(get_turf(core), "#375637")
		if("load_powder")
			core.payload_gate.chamber(target)

/obj/machinery/deck_turret
	name = "deck turret core"
	desc = "The central mounting core for naval guns. Use a multitool on it to rescan parts."
	icon = 'nsv13/icons/obj/munitions/deck_gun.dmi'
	icon_state = "core"
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/machine/deck_gun
	var/obj/machinery/ship_weapon/deck_turret/turret = null
	var/list/powder_gates = list()
	var/obj/machinery/deck_turret/payload_gate/payload_gate
	var/obj/machinery/computer/deckgun/computer

/obj/machinery/deck_turret/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	update_parts()

/obj/machinery/deck_turret/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return
	. = ..()

/obj/machinery/deck_turret/crowbar_act(mob/living/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE

/obj/machinery/deck_turret/proc/update_parts()
	payload_gate = locate(/obj/machinery/deck_turret/payload_gate) in orange(1, src)
	powder_gates = list()
	computer = locate(/obj/machinery/computer/deckgun) in orange(1, src)
	computer.core = src
	for(var/turf/T in orange(1, src))
		var/obj/machinery/deck_turret/powder_gate/powder_gate = locate(/obj/machinery/deck_turret/powder_gate) in T
		if(powder_gate && istype(powder_gate))
			powder_gates += powder_gate

/obj/machinery/deck_turret/powder_gate
	name = "powder loading gate"
	desc = "One of three gates which pack a shell with powder as they enter the gun core. Ensure that each one is secured before attempting to fire!"
	icon_state = "powdergate"
	circuit = /obj/item/circuitboard/machine/deck_gun/powder
	var/obj/item/powder_bag/bag = null
	var/ammo_type = /obj/item/powder_bag
	var/loading = FALSE
	var/load_delay = 8 SECONDS

/obj/machinery/deck_turret/powder_gate/proc/pack()
	set waitfor = FALSE
	playsound(src.loc, 'nsv13/sound/effects/ship/freespace2/m_lock.wav', 100, 1)
	icon_state = "[initial(icon_state)]_sealed"
	qdel(bag)
	bag = null
	sleep(1 SECONDS)
	icon_state = initial(icon_state)

/obj/machinery/deck_turret/powder_gate/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(get_dist(I, src) > 1)
		return FALSE
	if(bag)
		to_chat(user, "<span class='notice'>[src] is already loaded with [bag].</span>")
		return FALSE
	if(loading)
		to_chat(user, "<span class='notice'>[src] is already being loaded...</span>")
		return FALSE
	if(ammo_type && istype(I, ammo_type))
		load(I, user)

/obj/machinery/deck_turret/powder_gate/proc/unload()
	if(!bag)
		return
	icon_state = initial(icon_state)
	bag.forceMove(get_turf(src))
	bag = null

/obj/machinery/deck_turret/powder_gate/proc/load(obj/item/A, mob/user)
	loading = TRUE
	if(!istype(A, ammo_type))
		return FALSE
	var/temp = load_delay
	if(locate(/obj/machinery/deck_turret/autoelevator) in orange(2, src))
		temp /= 2
	if(do_after(user, temp, target = src))
		if(user)
			to_chat(user, "<span class='notice'>You load [A] into [src].</span>")
			bag = A
			bag.forceMove(src)
			icon_state = "[initial(icon_state)]_loaded"
			playsound(src.loc, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	loading = FALSE

/obj/item/powder_bag
	name = "gunpowder bag"
	desc = "A highly flammable bag of gunpowder which is used in naval artillery systems."
	icon = 'nsv13/icons/obj/munitions/deck_gun.dmi'
	icon_state = "powder"
	density = TRUE
	w_class = WEIGHT_CLASS_HUGE // Bag is big
	var/volatility = 1 //Gunpowder is volatile...
	var/power = 0.5

/obj/item/powder_bag/Initialize()
	. = ..()
	AddComponent(/datum/component/twohanded/required)
	AddComponent(/datum/component/volatile, volatility)

/obj/item/powder_bag/plasma
	name = "plasma-based projectile accelerant"
	desc = "An extremely powerful 'bomb waiting to happen' which can propel naval artillery shells to high speeds with half the amount of regular powder!"
	icon_state = "spicypowder"
	power = 1
	volatility = 3 //DANGEROUSLY VOLATILE. Can send the entire magazine up in smoke.

/obj/item/ship_weapon/ammunition/naval_artillery //Huh gee this sure looks familiar don't it...
	name = "\improper FTL-13 Naval Artillery Round"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "torpedo"
	desc = "A large shell designed to deliver a high-yield warhead upon high-speed impact with solid objects. You need to arm it with a multitool before firing."
	anchored = FALSE
	w_class = WEIGHT_CLASS_HUGE
	move_resist = MOVE_FORCE_EXTREMELY_STRONG //Possible to pick up with two hands
	density = TRUE
	projectile_type = /obj/item/projectile/bullet/mac_round //What torpedo type we fire
	obj_integrity = 300 //Beefy, relatively hard to use as a grief tool.
	max_integrity = 300
	volatility = 3 //Majorly explosive
	var/explosive = TRUE
	var/armed = FALSE //Do it do the big boom?
	var/speed = 0.5 //Needs powder to increase speed.

/obj/item/ship_weapon/ammunition/naval_artillery/attack_hand(mob/user)
	return FALSE

/obj/item/ship_weapon/ammunition/torpedo/attack_hand(mob/user)
	return FALSE

/obj/item/ship_weapon/ammunition/missile/attack_hand(mob/user)
	return FALSE

/obj/item/ship_weapon/ammunition/naval_artillery/cannonball
	name = "cannon ball"
	desc = "The QM blew the cargo budget on corgis, the clown stole all our ammo, we've got half a tank of plasma and are halfway to Dolos. Hit it."
	icon_state = "torpedo_ball"
	projectile_type = /obj/item/projectile/bullet/mac_round/cannonshot
	obj_integrity = 100
	max_integrity = 100
	w_class = WEIGHT_CLASS_GIGANTIC
	climbable = TRUE //No ballin'
	climb_time = 25
	climb_stun = 3
	explosive = FALSE //Cannonshot is just iron
	volatility = 0
	explode_when_hit = FALSE //Literally just iron

/obj/item/ship_weapon/ammunition/naval_artillery/ap
	name = "\improper TX-101 Armour Penetrating Naval Artillery Round"
	desc = "A massive diamond-tipped round which can slice through armour plating with ease to deliver a lethal impact. Best suited for targets with heavy armour such as destroyers and up."
	icon_state = "torpedo_ap"
	projectile_type = /obj/item/projectile/bullet/mac_round/ap

/obj/item/ship_weapon/ammunition/naval_artillery/homing
	name = "FTL-1301 Magneton Naval Artillery Round"
	desc = "A specialist artillery shell which can home in on a target using its hull's innate magnetism, while less accurate than torpedoes, these shells are still a very viable option."
	icon_state = "torpedo_homing"
	projectile_type = /obj/item/projectile/bullet/mac_round/magneton

/obj/item/ship_weapon/ammunition/naval_artillery/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(!do_after(user, 2 SECONDS, target = src))
		return
	playsound(src, 'sound/machines/click.ogg', 50, 1)
	armed = !armed
	var/datum/component/volatile/kaboom = GetComponent(/datum/component/volatile)
	kaboom.set_volatile_when_hit(armed) //Shells only go up when they're armed.
	icon_state = (armed) ? "[initial(icon_state)]_armed" : initial(icon_state)

/obj/item/ship_weapon/ammunition/naval_artillery/examine(mob/user)
	. = ..()
	. += "[(armed) ? "<span class='userdanger'>The shell is currently armed and ready to fire. </span>" : "<span class ='notice'>The shell must be armed before firing. </span>"]"

/obj/item/ship_weapon/ammunition/missile/CtrlClick(mob/user)
	. = ..()
	to_chat(user,"<span class='warning'>[src] is far too cumbersome to carry, and dragging it around might set it off! Load it onto a munitions trolley.</span>")

/obj/machinery/deck_turret/payload_gate
	name = "payload loading gate"
	desc = "A chamber for loading a gun shell to be packed with gunpowder, ensure the payload is securely loaded before attempting to chamber!"
	icon_state = "payloadgate"
	circuit = /obj/item/circuitboard/machine/deck_gun/payload
	var/loaded = FALSE
	var/obj/item/ship_weapon/ammunition/naval_artillery/shell = null
	var/ammo_type = /obj/item/ship_weapon/ammunition/naval_artillery
	var/loading = FALSE
	var/load_delay = 10 SECONDS

/obj/machinery/deck_turret/payload_gate/MouseDrop_T(obj/item/A, mob/user)
	. = ..()
	if(get_dist(user, src) > 1)
		return FALSE
	if(shell)
		to_chat(user, "<span class='notice'>[src] is already loaded with [shell].</span>")
		return FALSE
	if(loading)
		to_chat(user, "<span class='notice'>[src] is already being loaded...</span>")
		return FALSE
	if(ammo_type && istype(A, ammo_type))
		if(get_dist(A, src) > 1)
			load_delay = 13 SECONDS
		load(A, user)
		load_delay = 9 SECONDS

/obj/machinery/deck_turret/payload_gate/proc/load(obj/item/A, mob/user)
	var/temp = load_delay
	var/obj/item/ship_weapon/ammunition/naval_artillery/NA = A
	if(!NA.armed)
		to_chat(user, "<span class='warning'>[A] is not armed!</span>")
		return FALSE
	loading = TRUE
	if(locate(/obj/machinery/deck_turret/autoelevator) in orange(2, src))
		temp /= 2
	if(do_after(user, temp, target = src))
		if(user)
			to_chat(user, "<span class='notice'>You load [A] into [src].</span>")
			shell = A
			shell.forceMove(src)
			icon_state = "[initial(icon_state)]_loaded"
			playsound(src.loc, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	loading = FALSE

/obj/machinery/deck_turret/payload_gate/proc/unload()
	icon_state = initial(icon_state)
	loaded = FALSE
	if(!shell)
		return
	shell.forceMove(get_turf(src))
	shell = null

/obj/machinery/deck_turret/payload_gate/proc/feed()
	if(!shell)
		return FALSE
	icon_state = "[initial(icon_state)]_sealed"
	loaded = TRUE
	playsound(src.loc, 'nsv13/sound/effects/ship/freespace2/m_load.wav', 100, 1)

/obj/machinery/deck_turret/payload_gate/proc/chamber(obj/machinery/deck_turret/powder_gate/source)
	if(!shell)
		return FALSE
	shell.speed += source.bag.power
	shell.name = "Packed [initial(shell.name)]"
	shell.speed = CLAMP(shell.speed, 0, 10)
	source.pack()
	return TRUE

/obj/machinery/deck_turret/calibrator
	name = "deck gun calibration module"
	desc = "A module which allows you to calibrate deck guns. Required to ensure an accurate shot."
	icon_state = "autocalibrator"

/obj/machinery/deck_turret/autoelevator
	name = "auto elevator module"
	desc = "A module which greatly decreases load times on deck guns."
	icon_state = "autoelevator"
	circuit = /obj/item/circuitboard/machine/deck_gun/autoelevator

/obj/machinery/deck_turret/autorepair
	name = "deck gun auto-repair module"
	desc = "A module which periodically injects repair nanites into a linked deck turret above it, removing the need for maintenance entirely."
	icon_state = "autorepair"
	circuit = /obj/item/circuitboard/machine/deck_gun/autorepair

/obj/machinery/ship_weapon/deck_turret/local_fire()
	. = ..()
	var/obj/structure/overmap/OM = get_overmap()
	for(var/mob/M in OM.mobs_in_ship)
		if(OM.z == z)
			shake_camera(M, 1, 1)

/obj/machinery/ship_weapon/deck_turret/north
	dir = NORTH
	pixel_x = -43
	pixel_y = -32

/obj/machinery/ship_weapon/deck_turret/east
	dir = EAST
	pixel_x = -30
	pixel_y = -42
	bound_width = 128
	bound_height = 64

/obj/machinery/ship_weapon/deck_turret/west
	dir = WEST
	pixel_x = -63
	pixel_y = -42
	bound_width = 128
	bound_height = 64

//MEGADETH TURRET
/obj/machinery/ship_weapon/deck_turret/mega
	name = "M4-16 'Yamato' Triple Barrel Deck Gun"
	desc = "This is perhaps a bit excessive..."
	icon_state = "deck_turret_dual"
	max_ammo = 3

/obj/machinery/ship_weapon/deck_turret/mega/north
	dir = NORTH
	pixel_x = -43
	pixel_y = -32

/obj/machinery/ship_weapon/deck_turret/mega/east
	dir = EAST
	pixel_x = -30
	pixel_y = -42
	bound_width = 128
	bound_height = 64

/obj/machinery/ship_weapon/deck_turret/mega/west
	dir = WEST
	pixel_x = -63
	pixel_y = -42
	bound_width = 128
	bound_height = 64

/obj/structure/ship_weapon/mac_assembly/artillery_frame/mega
	name = "M4-16 'Yamato' Triple Barrel Naval Artillery Frame"
	desc = "The beginnings of a huge deck gun, internals notwithstanding."
	icon = 'nsv13/icons/obj/munitions/deck_turret.dmi'
	icon_state = "platform_dual"
	output_path = /obj/machinery/ship_weapon/deck_turret/mega


/obj/machinery/ship_weapon/deck_turret/Initialize()
	. = ..()
	core = locate(/obj/machinery/deck_turret) in SSmapping.get_turf_below(src)
	if(!core)
		message_admins("Deck turret has no gun core! [src.x], [src.y], [src.z])")
		return
	core.turret = src
	core.update_parts()

//The actual gun assembly.
/obj/structure/ship_weapon/mac_assembly/artillery_frame
	name = "naval artillery frame"
	desc = "The beginnings of a huge deck gun, internals notwithstanding."
	icon = 'nsv13/icons/obj/munitions/deck_turret.dmi'
	icon_state = "platform"
	bound_width = 128
	bound_height = 64
	pixel_y = -64
	anchored = TRUE
	density = TRUE
	output_path = /obj/machinery/ship_weapon/deck_turret

/obj/structure/ship_weapon/mac_assembly/artillery_frame/AltClick(mob/user)
	. = ..()
	setDir(turn(dir, 90))
	switch(dir)
		if(NORTH)
			output_path = text2path("[initial(output_path)]/north")
			pixel_x = -43
			pixel_y = -32
			bound_width = 64
			bound_height = 128
		if(SOUTH)
			output_path = initial(output_path)
			pixel_y = -64
			pixel_x = 0
			bound_width = 64
			bound_height = 128
		if(EAST)
			output_path = text2path("[initial(output_path)]/east")
			pixel_x = -30
			pixel_y = -42
			bound_width = 128
			bound_height = 64
		if(WEST)
			output_path = text2path("[initial(output_path)]/west")
			pixel_x = -63
			pixel_y = -42
			bound_width = 128
			bound_height = 64
