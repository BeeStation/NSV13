#define NAC_MIN_POWDER_LOAD 0.5 // Min powder, equivelant to 25%
#define NAC_NORMAL_POWDER_LOAD 2 // "100%" powder
#define NAC_MAX_POWDER_LOAD 10 // Max powder, or 500%

/obj/machinery/ship_weapon/deck_turret
	name = "\improper M4-15 'Hood' deck turret"
	desc = "A huge naval gun which uses chemical accelerants to propel rounds. Inspired by the classics, this gun packs a major punch and is quite easy to reload. Use a multitool on it to re-register loading aparatus."
	icon = 'nsv13/icons/obj/munitions/deck_turret.dmi'
	icon_state = "deck_turret"
	fire_mode = FIRE_MODE_MAC
	ammo_type = /obj/item/ship_weapon/ammunition/naval_artillery
	pixel_x = -43
	pixel_y = -64
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32
	semi_auto = TRUE
	max_ammo = 1
	obj_integrity = 500
	max_integrity = 500
	component_parts = list()
	safety = FALSE
	maintainable = FALSE //This just makes them brick.
	load_sound = 'nsv13/sound/effects/ship/freespace2/crane_short.ogg'
	interaction_flags_machine = INTERACT_MACHINE_OPEN | INTERACT_MACHINE_OFFLINE | INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_SET_MACHINE
	var/obj/machinery/deck_turret/core
	var/id = null //N.B. This is NOT intended to allow them to manual link deck guns. This is for certain boarding maps and is thus a UNIQUE CONSTRAINT for this one case. ~KMC
	circuit = /obj/item/circuitboard/machine/deck_turret

/obj/machinery/ship_weapon/deck_turret/Topic(href, href_list)
	. = ..() //Sanity checks.
	if(.)
		return

	if(href_list["fire_button"])
		if(maint_state == MSTATE_UNSCREWED)
			fire()

/obj/machinery/ship_weapon/deck_turret/examine()
	. = ..()
	switch(maint_state)
		if(MSTATE_UNSCREWED)
			. += "There is a button labelled \"<A href='?src=[REF(src)];fire_button=1'>Force Eject Shell</A>\"."
		if(MSTATE_UNBOLTED)
			pop(.)// this is the laziest way I know of to change an examine line
			. += "The inner casing has been <b>unbolted</b>, and the loading tray can be <i>pried out</i>."//deconstruction hint

/obj/machinery/ship_weapon/deck_turret/crowbar_act(mob/user, obj/item/tool)
	if(maint_state == MSTATE_UNBOLTED)
		to_chat(user, "<span class='notice'>You start removing the loading tray from the [src].</span>")
		if(!do_after(user, 4 SECONDS, target=src))
			return
		var/obj/item/ship_weapon/parts/loading_tray/W = locate() in component_parts
		if(W)
			W.forceMove(user.loc)
			component_parts -= W
		spawn_frame(TRUE)
		qdel(src)

/obj/machinery/ship_weapon/deck_turret/spawn_frame(disassembled)
	if(!disassembled)
		QDEL_LIST(component_parts)
		return ..(disassembled)

	circuit.moveToNullspace()//if you can't delete it...
	circuit = null
	var/obj/structure/ship_weapon/artillery_frame/M = new(get_turf(src))

	for(var/obj/O as() in component_parts)
		O.forceMove(M)
	component_parts.Cut()

	. = M
	M.setAnchored(anchored)
	M.setDir(dir)
	M.set_final_state()
	M.max_barrels = max_ammo
	M.lazy_icon()
	transfer_fingerprints_to(M)


/obj/machinery/ship_weapon/deck_turret/lazyload()
	. = ..()
	//Ensure that the lazyloaded shells come pre-packed
	for(var/obj/item/ship_weapon/ammunition/naval_artillery/shell in ammo)
		shell.speed = NAC_NORMAL_POWDER_LOAD

/obj/machinery/ship_weapon/deck_turret/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	core = locate(/obj/machinery/deck_turret) in SSmapping.get_turf_below(src)
	if(!core)
		link_via_id()
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
		var/obj/item/projectile/proj = linked.fire_projectile(T.projectile_type, target,speed=T.speed, lateral=weapon_type.lateral)
		T.handle_shell_modifiers(proj)

/obj/machinery/ship_weapon/deck_turret/proc/rack_load(atom/movable/A)
	if(length(ammo) < max_ammo && istype(A, ammo_type))
		if(state in GLOB.busy_states)
			visible_message("<span class='warning'>Unable to perform operation right now, please wait.</span>")
			return FALSE
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

/obj/machinery/computer/deckgun/Destroy(force=FALSE)
	if(circuit && !ispath(circuit))
		if(!force)
			circuit.forceMove(loc)
		else
			qdel(circuit, force)
		circuit = null
	. = ..()

/obj/machinery/computer/deckgun/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DeckGun")
		ui.open()
		ui.set_autoupdate(TRUE) // Loading delay, firing updates

/obj/machinery/computer/deckgun/ui_data(mob/user)
	var/list/data = list()
	var/list/parts = list()
	if(!core)
		return data
	if(get_dist(core.payload_gate, core) > 1)
		core.update_parts()
	if(core.payload_gate)
		data["id"] = (core.payload_gate)
		if(core.payload_gate.shell)
			data["can_pack"] = TRUE
			data["loaded"] = core.payload_gate.shell.name || "Nothing"
			data["speed"] = core.payload_gate.shell.speed || 0
		else
			data["can_pack"] = FALSE
			data["loaded"] = "Nothing"
			data["speed"] = 0
	else
		data["id"] = null
		data["can_pack"] = FALSE
		data["loaded"] = "Nothing"
		data["speed"] = 0
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
	data["can_load"] = core.turret?.ammo?.len < core.turret?.max_ammo || FALSE
	data["ammo"] = core.turret?.ammo?.len || 0
	data["max_ammo"] = core.turret?.max_ammo || 0
	data["max_speed"] = 2
	return data

/obj/machinery/computer/deckgun/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/obj/machinery/deck_turret/powder_gate/target = locate(params["target"])
	switch(action)
		if("load")
			if(core.turret.maint_state > MSTATE_CLOSED)//Can't load a shell if we're doing maintenance
				to_chat(usr, "<span class='notice'>Cannot feed shell while undergoing maintenance!</span>")
				return
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
	var/id = null
	var/obj/machinery/ship_weapon/deck_turret/turret = null
	var/list/powder_gates = list()
	var/obj/machinery/deck_turret/payload_gate/payload_gate
	var/obj/machinery/computer/deckgun/computer

/obj/machinery/deck_turret/Destroy(force=FALSE)
	if(circuit && !ispath(circuit))
		if(!force)
			circuit.forceMove(loc)
		else
			qdel(circuit, force)
		circuit = null
	for(var/obj/O in component_parts)
		if(!force)
			O.forceMove(loc)
		else
			qdel(circuit, force)
	return ..()

/obj/machinery/deck_turret/multitool_act(mob/living/user, obj/item/I)
	..()
	update_parts()
	return TRUE

/obj/machinery/deck_turret/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return
	return ..()

/obj/machinery/deck_turret/crowbar_act(mob/living/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE

/obj/machinery/deck_turret/proc/update_parts()
	payload_gate = locate(/obj/machinery/deck_turret/payload_gate) in orange(1, src)
	powder_gates = list()
	computer = locate(/obj/machinery/computer/deckgun) in orange(1, src)
	computer.core = src
	turret?.get_ship()
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
	var/load_delay = 6.4 SECONDS

/obj/machinery/deck_turret/powder_gate/Destroy(force=FALSE)
	if(circuit && !ispath(circuit))
		if(!force)
			circuit.forceMove(loc)
		else
			qdel(circuit, force)
		circuit = null
	. = ..()

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

/obj/item/powder_bag/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)
	AddComponent(/datum/component/volatile, volatility, TRUE)

/obj/item/powder_bag/plasma
	name = "plasma-based projectile accelerant"
	desc = "An extremely powerful 'bomb waiting to happen' which can propel naval artillery shells to high speeds with half the amount of regular powder!"
	icon_state = "spicypowder"
	power = 1
	volatility = 3 //DANGEROUSLY VOLATILE. Can send the entire magazine up in smoke.

/obj/item/powder_bag/hungry
	name = "gunpowder bag" // full name is built in update_name()
	desc = "Cute!"
	icon_state  = "hungrypowder"
	power = 1
	volatility = 3
	var/is_evolving = FALSE // async my beloved
	var/Elevel = 1
	var/energy = 0
	var/next_evolve = 15
	var/devour_chance = 0 // chance to eat feeder, increases with each evolution level
	var/devouring = FALSE
	// enraged related variables
	var/enraged = FALSE
	var/mob/living/target
	var/satisfied_until // we don't attack anyone until we've passed this timestamp
	var/satisfaction_duration = 5 MINUTES

/obj/item/powder_bag/hungry/Initialize(mapload)
	. = ..()
	if(!mapload)
		playsound(src, 'sound/items/eatfood.ogg', 100, 1)
	update_state()

	var/datum/component/volatile/VC = GetComponent(/datum/component/volatile)
	VC.explosion_scale = 0.5

/obj/item/powder_bag/hungry/proc/update_state()
	var/prefix
	switch(Elevel)
		if(0 to 3)
			prefix = "famished"
		if(4 to 6)
			prefix = "ravenous"
			icon_state = "hungrypowder_wobble"
		if(7 to 9)
			prefix = "starving"
		if(10 to 12)
			prefix = "malnourished"
			icon_state = "hungrypowder_fastwobble"
		if(13 to 15)
			prefix = "hungry"
		if(16 to 18)
			prefix = "peckish"
		if(19 to 21)
			prefix = "well-fed"
			icon_state = "hungrypowder_shake"
		if(22 to 24)
			prefix = "stuffed"
		if(25 to 27)
			prefix = "gluttonized"
		else
			prefix = "enraged"
			icon_state = "hungrypowder_shakeflash"
			SpinAnimation(20, 1, pick(0, 1))
			if(!enraged)
				enraged = TRUE
				START_PROCESSING(SSobj, src)
	name = "[prefix] [initial(name)]"

/obj/item/powder_bag/hungry/attackby(obj/item/I, mob/living/user)
	if(!istype(I, /obj/item/reagent_containers/food/snacks))
		return ..()
	if(!istype(user, /mob/living/carbon/human))
		to_chat(user, "<span class='info'>\The [src] is too lonely to eat right now.</span>")
		return
	if(!do_after(user, 7, TRUE, src))
		return
	if(is_evolving || devouring)
		to_chat(user, "<span class='info'>\The [src] can't eat right now.</span>")
		return
	var/obj/item/reagent_containers/food/snacks/F = I
	var/list/food_reagents = F.reagents.reagent_list + F.bonus_reagents
	var/datum/reagent/toxin/plasma/plasma = locate() in food_reagents
	if(plasma)
		// Too spicy for Mr Bag's taste
		playsound(loc, 'sound/items/eatfood.ogg', 100, 1)
		visible_message("<span class='danger'>\The [src] begins to expand!</span>")
		var/delay = max(50 - plasma.volume, 5)
		var/datum/component/volatile/VC = GetComponent(/datum/component/volatile)
		addtimer(CALLBACK(VC, TYPE_PROC_REF(/datum/component/volatile/, explode)), delay)
		Shake(10, 10, delay)
		return
	var/nutri = 0
	// loop instead of locate() so we can catch subtypes too
	for(var/datum/reagent/consumable/nutriment/N in food_reagents)
		nutri += N.volume
	if(!nutri)
		to_chat(user, "<span class='info'>\The [F] is not nutritious enough!</span>")
		return
	visible_message("<span class='notice'>\The [src] takes a huge bite out of [F]!</span>")
	energy += nutri * 2
	qdel(F)
	if(energy >= next_evolve)
		evolve(user)
	playsound(loc, 'sound/items/eatfood.ogg', 100, 1)

/obj/item/powder_bag/hungry/proc/evolve(mob/living/feeder)
	set waitfor = FALSE
	is_evolving = TRUE
	while(energy >= next_evolve)
		Elevel++
		power += 2
		volatility += 2
		next_evolve = max(round(next_evolve ** 1.015, 1), next_evolve + initial(next_evolve))

		update_state() // we update state on every iteration so we can't jump over any switch ranges

		devour_chance++
		if(feeder && prob(devour_chance))
			devour_chance = max(devour_chance - 10, 1)
			playsound(feeder, 'sound/effects/tendril_destroyed.ogg', 100, 0)
			visible_message("<span class='danger'>\The [src] twitches violently as it begins to rapidly roll towards [feeder]!</span>")
			sleep(20)
			var/turf/T = get_turf(src)
			if(T != loc)
				forceMove(T)
			var/dist = rand(3, 5)
			var/turf/FT
			for(var/i in 1 to dist)
				T = get_turf(src)
				FT = get_turf(feeder)
				if(FT.z != z)
					break
				if(get_dist(T, FT) < 2)
					devour(feeder, 5, FALSE)
					feeder = null
					sleep(10)
					break
				else
					var/turf/step = get_step_towards(T, FT)
					Move(step, get_dir(T, step))
					var/static/list/messagepool = list("HELLO", "HI!!", "HENLO!", "PERSON", "YAY", "HUNGRY", "FOOD", "MMMMM", "YES", "PLAY") // (HE IS A VERY GOOD BOY)
					say(pick(messagepool))
					sleep(1)
			if(feeder) // How could be so naive? There is no escape
				say("SAD")
				playsound(feeder, 'sound/effects/tendril_destroyed.ogg', 100, 0)
				feeder = null
	// update our component
	var/datum/component/volatile/VC = GetComponent(/datum/component/volatile)
	VC.volatility = volatility

	visible_message("<span class='warning'>\The [src] gurgles happily.</span>")
	new /obj/effect/temp_visual/heart(loc) // :)
	is_evolving = FALSE

/// Keep in mind that this is a blocking call by default
/obj/item/powder_bag/hungry/proc/devour(mob/living/target, consumeTime = 26, checkEvolve = TRUE, growSize = TRUE)
	devouring = TRUE
	forceMove(get_turf(target))
	visible_message("<span class='danger'>\The [src] wraps around and begins to devour [target]. Cute!</span>")
	target.Stun(100 + consumeTime, TRUE, TRUE)
	target.notransform = TRUE
	target.anchored = TRUE
	if(target.stat != DEAD)
		INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, emote), "scream")
	SpinAnimation(20, 1, pick(0, 1), parallel = FALSE) // he does tricks!
	var/segsleep = consumeTime * 0.5
	sleep(segsleep)
	say("NOM")
	sleep(segsleep)
	energy = max((next_evolve - energy) * 2, energy)
	if(isplasmaman(target))
		visible_message("<span class='danger'>\The [src] doesn't look very well..</span>")
		var/datum/component/volatile/VC = GetComponent(/datum/component/volatile)
		addtimer(CALLBACK(VC, TYPE_PROC_REF(/datum/component/volatile/, explode)), 20)
		Shake(10, 10, 20)
	var/list/inventoryItems = target.get_equipped_items(TRUE)
	target.unequip_everything()
	target.gib(TRUE, TRUE, TRUE)
	for(var/atom/movable/AM as() in inventoryItems)
		var/throwdir = pick(GLOB.alldirs)
		AM.throw_at(get_step(src, throwdir), rand(1, 3), 2)
	if(growSize)
		transform.Scale(1.1)
	devouring = FALSE
	if(checkEvolve)
		evolve()

/obj/item/powder_bag/hungry/process(delta_time)
	if(!enraged)
		return PROCESS_KILL
	if(satisfied_until > world.time || devouring)
		return
	if(target)
		if(target.z != z || get_dist(src, target) > 8)
			target = null
	else
		var/closest_dist = 100
		for(var/mob/living/L in orange(8, src))
			var/dist = get_dist(src, L)
			if(dist < closest_dist || (target.stat == DEAD && L.stat != DEAD)) // Pick the closest ALIVE mob to us, otherwise pick the closest dead one
				target = L
				closest_dist = dist
		if(!target)
			return
	if(get_dist(src, target) <= 1)
		INVOKE_ASYNC(src, PROC_REF(devour), target)
		satisfied_until = world.time + satisfaction_duration
	else if(!throwing)
		throw_at(target, 10, 2)

/obj/item/powder_bag/hungry/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!enraged)
		return ..()
	if(target && hit_atom == target && !devouring)
		INVOKE_ASYNC(src, PROC_REF(devour), target)
		satisfied_until = world.time + satisfaction_duration
		return
	return ..()

/obj/item/powder_bag/hungry/examine(mob/user)
	. = ..()
	if(enraged)
		. += "<span class='notice'>It appears to be <font color=red><i><b>very</b></i></font> agitated.</span>"

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

/obj/item/ship_weapon/ammunition/naval_artillery/armed //This is literally just for mail.
	armed = TRUE

// Handles shell powder load damage modifiers
/obj/item/ship_weapon/ammunition/naval_artillery/proc/handle_shell_modifiers(obj/item/projectile/proj)
	return

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

/obj/item/ship_weapon/ammunition/naval_artillery/cannonball/admin
	desc = "This cannon ball seems to be so comically large it's impossible to scale!"
	anchored = TRUE
	no_trolley = TRUE //Can still be loaded into a gun if you're really dedicated.
	projectile_type = /obj/item/projectile/bullet/mac_round/cannonshot/admin
	climb_time = 600
	climb_stun = 10
	obj_integrity = 1000
	max_integrity = 1000

/obj/item/ship_weapon/ammunition/naval_artillery/ap
	name = "\improper TX-101 Armour Penetrating Naval Artillery Round"
	desc = "A massive diamond-tipped round which can slice through armour plating with ease to deliver a lethal impact. Best suited for targets with heavy armour such as destroyers and up."
	icon_state = "torpedo_ap"
	projectile_type = /obj/item/projectile/bullet/mac_round/ap


/obj/item/ship_weapon/ammunition/naval_artillery/ap/handle_shell_modifiers(obj/item/projectile/proj)
	if(speed >= NAC_NORMAL_POWDER_LOAD)
		proj.damage = proj.damage * CLAMP(log(10, speed * 5), 1, 2) // at 2 speed (or 100% powder load), damage mod is 1, logarithmically scaling up/down based on powder load
	proj.armour_penetration = proj.armour_penetration * CLAMP(sqrt(speed * 0.5), 0.5, 3)

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

/obj/item/ship_weapon/ammunition/naval_artillery/attack_hand(mob/user)
	return FALSE

/obj/machinery/deck_turret/payload_gate
	name = "payload loading gate"
	desc = "A chamber for loading a gun shell to be packed with gunpowder, ensure the payload is securely loaded before attempting to chamber!"
	icon_state = "payloadgate"
	circuit = /obj/item/circuitboard/machine/deck_gun/payload
	var/loaded = FALSE
	var/obj/item/ship_weapon/ammunition/naval_artillery/shell = null
	var/ammo_type = /obj/item/ship_weapon/ammunition/naval_artillery
	var/loading = FALSE
	var/load_delay = 8 SECONDS

/obj/machinery/deck_turret/payload_gate/MouseDrop_T(obj/item/A, mob/user)
	. = ..()
	if(!isliving(user))
		return FALSE
	if(get_dist(user, src) > 1)
		return FALSE
	if(shell)
		to_chat(user, "<span class='notice'>[src] is already loaded with [shell].</span>")
		return FALSE
	if(loading)
		to_chat(user, "<span class='notice'>[src] is already being loaded...</span>")
		return FALSE
	if(!ammo_type || !istype(A, ammo_type))
		return FALSE
	if(get_dist(A, src) > 1)
		load_delay = 10.4 SECONDS
	load(A, user)
	load_delay = 7.2 SECONDS

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

///Updates state if the moved out obj was the loaded shell
/obj/machinery/deck_turret/payload_gate/Exited(src)
	. = ..()
	if(src == shell)
		icon_state = initial(icon_state)
		loaded = FALSE
		shell = null

///Shorthand for moving shell to turf
/obj/machinery/deck_turret/payload_gate/proc/unload()
	if(!shell)
		return FALSE
	//Will call payload_gate.Exited which handles the actual unloading
	return shell.forceMove(get_turf(src))

/obj/machinery/deck_turret/payload_gate/proc/feed()
	if(!shell)
		return FALSE
	icon_state = "[initial(icon_state)]_sealed"
	loaded = TRUE
	playsound(src.loc, 'nsv13/sound/effects/ship/freespace2/m_load.wav', 100, 1)

/obj/machinery/deck_turret/payload_gate/proc/chamber(obj/machinery/deck_turret/powder_gate/source)
	if(!shell || !source?.bag)
		return FALSE
	shell.speed += source.bag.power
	shell.name = "Packed [initial(shell.name)]"
	shell.speed = CLAMP(shell.speed, NAC_MIN_POWDER_LOAD, NAC_MAX_POWDER_LOAD)
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
			shake_with_inertia(M, 1, 1)

/obj/machinery/ship_weapon/deck_turret/overmap_fire(atom/target)
	linked.shake_animation()
	return ..()

/obj/machinery/ship_weapon/deck_turret/north
	dir = NORTH
	pixel_x = -43
	pixel_y = -32
	bound_x = -32
	bound_y = -32

/obj/machinery/ship_weapon/deck_turret/east
	dir = EAST
	pixel_x = -30
	pixel_y = -42
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32

/obj/machinery/ship_weapon/deck_turret/west
	dir = WEST
	pixel_x = -63
	pixel_y = -42
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32

//MEGADETH TURRET
/obj/machinery/ship_weapon/deck_turret/_3
	name = "M4-16 'Yamato' Triple Barrel Deck Gun"
	desc = "This is perhaps a bit excessive..."
	icon_state = "deck_turret_dual"
	max_ammo = 3

/obj/machinery/ship_weapon/deck_turret/_3/north
	dir = NORTH
	pixel_x = -43
	pixel_y = -32
	bound_x = -32
	bound_y = -32

/obj/machinery/ship_weapon/deck_turret/_3/east
	dir = EAST
	pixel_x = -30
	pixel_y = -42
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32

/obj/machinery/ship_weapon/deck_turret/_3/west
	dir = WEST
	pixel_x = -63
	pixel_y = -42
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32

/obj/machinery/ship_weapon/deck_turret/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(RefreshParts)), world.tick_lag)

	core = locate(/obj/machinery/deck_turret) in SSmapping.get_turf_below(src)
	if(!core)
		message_admins("Deck turret has no gun core! [src.x], [src.y], [src.z])")
		return
	core.turret = src
	core.update_parts()
	if(id)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/ship_weapon/deck_turret/LateInitialize()
	. = ..()
	link_via_id()

/obj/machinery/ship_weapon/deck_turret/RefreshParts()//using this proc to create the parts instead
	. = ..()//because otherwise you'd need to put them in the machine frame to rebuild using a board
	if(length(component_parts) <= 1) //because circuit boards
		component_parts += new /obj/item/ship_weapon/parts/firing_electronics
		component_parts += new /obj/item/ship_weapon/parts/loading_tray
		if(max_ammo == 3)
			component_parts += new /obj/item/circuitboard/multibarrel_upgrade/_3
		else if(max_ammo != 1) //this should really never happen unless some major tomfoolery goes on (or someone forgets to add a new upgrade to the switch)
			var/obj/item/circuitboard/multibarrel_upgrade/M = new()
			M.barrels = max_ammo
			M.desc = "An upgrade that allows you to add [max_ammo] barrels to a Naval Artillery Cannon. You must partially deconstruct the cannon to install this."
			component_parts += M
		for(var/i in 1 to max_ammo)
			component_parts += new /obj/item/ship_weapon/parts/mac_barrel
			component_parts += new /obj/item/assembly/igniter

/obj/machinery/ship_weapon/deck_turret/proc/link_via_id()
	for(var/obj/machinery/deck_turret/C in GLOB.machines)
		if(istype(C) && C?.id == id)
			C.turret = src
			core = C
			C.update_parts()

/obj/machinery/ship_weapon/deck_turret/setDir()
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_x = -43
			pixel_y = -32
			bound_width = 96
			bound_height = 96
			bound_x = -32
			bound_y = -32
		if(SOUTH)
			pixel_x = -43
			pixel_y = -64
			bound_width = 96
			bound_height = 96
			bound_x = -32
			bound_y = -32
		if(EAST)
			pixel_x = -30
			pixel_y = -42
			bound_width = 96
			bound_height = 96
			bound_x = -32
			bound_y = -32
		if(WEST)
			pixel_x = -63
			pixel_y = -42
			bound_width = 96
			bound_height = 96
			bound_x = -32
			bound_y = -32
