/obj/machinery/ship_weapon/gauss_gun
	name = "NT-BSG Gauss Turret"
	desc = "A large ship to ship weapon designed to provide a constant barrage of fire over a long distance. It has a small cockpit for a gunner to control it manually."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "gauss"
	bound_width = 96
	bound_height = 96
	pixel_x = -44
	obj_integrity = 500
	max_integrity = 500

	fire_mode = FIRE_MODE_GAUSS
	ammo_type = /obj/item/ship_weapon/ammunition/gauss

	semi_auto = TRUE
	max_ammo = 6 //Until you have to manually load it back up again. Battleships IRL have 3-4 shots before you need to reload the rack

	fire_animation_length = 1 SECONDS
	maintainable = FALSE //Due to the amount of rounds that this thing fires, this would just get suuuper irritating.
	var/mob/living/carbon/human/gunner = null
	var/next_sound = 0
	var/obj/structure/chair/comfy/gauss/gunner_chair = null
	var/obj/structure/gauss_rack/ammo_rack
	var/datum/gas_mixture/cabin_air //Cabin air mix used for small ships like fighters (see overmap/fighters/fighters.dm)
	var/climbing_in = FALSE //Stop it. Just stop.
	var/obj/machinery/portable_atmospherics/canister/internal_tank //Internal air tank reference. Used mostly in small ships. If you want to sabotage a fighter, load a plasma tank into its cockpit :)
	var/pdc_mode = FALSE
	var/last_pdc_fire = 0 //Pdc cooldown
	var/BeingLoaded //Used for gunner load

#define VV_HK_REMOVE_GAUSS_GUNNER "getOutOfMyGunIdiot"

/obj/machinery/ship_weapon/gauss_gun/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_REMOVE_GAUSS_GUNNER, "Remove Gunner")

/obj/machinery/ship_weapon/gauss_gun/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_REMOVE_GAUSS_GUNNER])
		if(!check_rights(NONE))
			return
		remove_gunner()

/obj/machinery/ship_weapon/gauss_gun/powered(chan)
	if(!loc)
		return FALSE
	if(!use_power)
		return TRUE

	var/area/A = get_area(src)		// make sure it's in an area
	if(ammo_rack) //Ammo racks go below in the bit that's actually powered.
		A = get_area(ammo_rack)
	if(!A)
		return FALSE					// if not, then not powered
	if(chan == -1)
		chan = power_channel
	return A.powered(chan)	// return power status of the area

//Verbs//

/obj/machinery/ship_weapon/gauss_gun/verb/show_computer()
	set name = "Access internal computer"
	set category = "Gauss gun"
	set src = usr.loc

	if(gunner.incapacitated() || !isliving(gunner))
		return
	ui_interact(gunner)
	to_chat(gunner, "<span class='notice'>You reach for [src]'s control panel.</span>")

/obj/machinery/ship_weapon/gauss_gun/verb/show_view()
	set name = "Access gun camera"
	set category = "Gauss gun"
	set src = usr.loc

	if(usr.incapacitated())
		return
	set_gunner(usr)
	to_chat(gunner, "<span class='notice'>You reach for [src]'s gun camera controls.</span>")

/obj/machinery/ship_weapon/gauss_gun/verb/exit()
	set name = "Exit"
	set category = "Gauss gun"
	set src = usr.loc

	if(gunner.incapacitated() || !isliving(gunner))
		return
	remove_gunner()

/obj/machinery/ship_weapon/gauss_gun/verb/swap_firemode()
	set name = "Cycle firemode"
	set category = "Gauss gun"
	set src = usr.loc

	if(gunner.incapacitated() || !isliving(gunner))
		return
	cycle_firemode()

/obj/machinery/ship_weapon/gauss_gun/proc/cycle_firemode()
	to_chat(gunner, "<span class='warning'>[pdc_mode ? "You swap back to gauss mode" : "You swap to point defense mode"]</span>")
	pdc_mode = !pdc_mode

//Overrides

/obj/machinery/ship_weapon/gauss_gun/Initialize()
	. = ..()
	cabin_air = new
	cabin_air.set_temperature(T20C)
	cabin_air.set_volume(200)
	cabin_air.set_moles(/datum/gas/oxygen, O2STANDARD*cabin_air.return_volume()/(R_IDEAL_GAS_EQUATION*cabin_air.return_temperature()))
	cabin_air.set_moles(/datum/gas/nitrogen, N2STANDARD*cabin_air.return_volume()/(R_IDEAL_GAS_EQUATION*cabin_air.return_temperature()))
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	ammo_rack = new /obj/structure/gauss_rack(src)
	ammo_rack.gun = src
	START_PROCESSING(SSobj, src)
	lower_rack()

/obj/machinery/ship_weapon/gauss_gun/Destroy() //Yeet them out before we die.
	remove_gunner()
	QDEL_NULL(gunner_chair)
	QDEL_NULL(ammo_rack)
	QDEL_NULL(cabin_air)
	QDEL_NULL(internal_tank)
	. = ..()

/obj/machinery/ship_weapon/gauss_gun/attack_hand(mob/user)
	if(climbing_in)
		return FALSE
	if(gunner)
		if(gunner != user)
			to_chat(user, "<span class='notice'>Someone is already in this turret!</span>")
			return FALSE
		else
			to_chat(user, "<span class='notice'>You start to climb out of [src]...</span>")
			remove_gunner()
			return FALSE
	if(gunner_chair)
		to_chat(user, "<span class='notice'>[src]'s hatch is locked. Try using its gunner chair on the deck below?</span>")
		return FALSE
	climbing_in = TRUE //Stop it. Just stop.
	to_chat(user, "<span class='notice'>You start to climb into [src]...</span>")
	if(do_after(user, 3 SECONDS, target=src))
		set_gunner(user)
	climbing_in = FALSE //Stop it. Just stop.

/obj/machinery/ship_weapon/gauss_gun/do_animation()
	shake_camera(gunner, 2, 1)
	flick("[initial(icon_state)]_firing0",src)
	sleep(0.3 SECONDS)
	shake_camera(gunner, 2, 1)
	flick("[initial(icon_state)]_firing1",src)
	sleep(0.3 SECONDS)
	flick("[initial(icon_state)]_unloading",src)
	sleep(fire_animation_length)
	icon_state = initial(icon_state)

//Gunner handling

/obj/machinery/ship_weapon/gauss_gun/proc/set_gunner(mob/user)
	user.forceMove(src)
	gunner = user
	gunner.AddComponent(/datum/component/overmap_gunning, src)
	ui_interact(user)

/obj/machinery/ship_weapon/gauss_gun/proc/remove_gunner()
	if(gunner_chair)
		lower_chair()
		return FALSE
	gunner.unfuck_overmap() //Just in case they didn't cancel camera view or whatever.
	gunner.forceMove(get_turf(src))
	gunner = null

//Directional subtypes

/obj/machinery/ship_weapon/gauss_gun/north
	dir = NORTH

/obj/machinery/ship_weapon/gauss_gun/east
	dir = EAST

/obj/machinery/ship_weapon/gauss_gun/west
	dir = WEST

/obj/machinery/ship_weapon/gauss_gun/proc/GunnerLoad()
	if(BeingLoaded)
		to_chat(gunner, "<span class='notice'>[src]'s loading systems are on cooldown!</span>")
		return
	to_chat(gunner, "<span class='notice'>Loading ammunition</span>")
	BeingLoaded = 1
	src.raise_rack()
	sleep(5 SECONDS)
	BeingLoaded = 0

/obj/machinery/ship_weapon/gauss_gun/proc/onClick(atom/target)
	if(ammo.len<1)
		src.GunnerLoad()
	if(pdc_mode && world.time >= last_pdc_fire + 2 SECONDS)
		linked.fire_weapon(target=target, mode=FIRE_MODE_PDC)
		last_pdc_fire = world.time
		return
	fire(target)

/obj/machinery/ship_weapon/gauss_gun/overmap_fire(atom/target)
	if(world.time >= next_sound) //Prevents ear destruction from soundspam
		var/sound/chosen = pick(weapon_type.overmap_firing_sounds)
		linked.relay_to_nearby(chosen)
		next_sound = world.time + 1 SECONDS
	if(overlay)
		overlay.do_animation()
	animate_projectile(target)

/**
 * Animates an overmap projectile matching whatever we're shooting.
 */
/obj/machinery/ship_weapon/gauss_gun/animate_projectile(atom/target)
	linked.fire_lateral_projectile(weapon_type.default_projectile_type, target, user_override=gunner)

//Atmos handling

/obj/machinery/ship_weapon/gauss_gun/return_air()
	return cabin_air

/obj/machinery/ship_weapon/gauss_gun/remove_air(amount)
	return cabin_air.remove(amount)

/obj/machinery/ship_weapon/gauss_gun/return_analyzable_air()
	return cabin_air

/obj/machinery/ship_weapon/gauss_gun/return_temperature()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		. = t_air.return_temperature()
	return

/obj/machinery/ship_weapon/gauss_gun/portableConnectorReturnAir()
	return return_air()

/obj/machinery/ship_weapon/gauss_gun/assume_air(datum/gas_mixture/giver)
	var/datum/gas_mixture/t_air = return_air()
	return t_air.merge(giver)

/obj/machinery/ship_weapon/gauss_gun/process()
	if(cabin_air && cabin_air.return_volume() > 0)
		var/delta = cabin_air.return_temperature() - T20C
		cabin_air.set_temperature(cabin_air.return_temperature() - max(-10, min(10, round(delta/4,0.1))))
	if(internal_tank && cabin_air)
		var/datum/gas_mixture/tank_air = internal_tank.return_air()
		var/release_pressure = ONE_ATMOSPHERE
		var/cabin_pressure = cabin_air.return_pressure()
		var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
		var/transfer_moles = 0
		if(pressure_delta > 0) //cabin pressure lower than release pressure
			if(tank_air.return_temperature() > 0)
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
				cabin_air.merge(removed)
		else if(pressure_delta < 0) //cabin pressure higher than release pressure
			var/turf/T = get_turf(src)
			var/datum/gas_mixture/t_air = T.return_air()
			pressure_delta = cabin_pressure - release_pressure
			if(t_air)
				pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
			if(pressure_delta > 0) //if location pressure is lower than cabin pressure
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
				if(T)
					T.assume_air(removed)
				else //just delete the cabin gas, we're in space or some shit
					qdel(removed)


//Rack loading

/obj/structure/gauss_rack
	name = "Deck gun loading rack"
	icon = 'nsv13/icons/obj/munitions_large.dmi'
	icon_state = "loading_rack"
	desc = "A large rack used as an ammunition feed for deck guns. The rack will automatically feed the deck gun above it with ammunition. You can load a crate with ammo and click+drag it onto the rack to speedload, or manually load it with rounds by hand."
	anchored = TRUE
	density = TRUE
	layer = 3
	var/capacity = 0
	var/max_capacity = 6//Maximum number of munitions we can load at once
	var/loading = FALSE //stop you loading the same torp over and over
	var/obj/machinery/ship_weapon/gauss_gun/gun

/obj/structure/gauss_rack/attackby(obj/item/I, mob/user)
	if(istype(I, gun.ammo_type))
		if(loading)
			to_chat(user, "<span class='notice'>You're already loading something onto [src]!.</span>")
			return FALSE
		if(capacity < max_capacity)
			to_chat(user, "<span class='notice'>You start to load [I] onto [src]...</span>")
			loading = TRUE
			if(do_after(user,10, target = src))
				load(I, src)
				to_chat(user, "<span class='notice'>You load [I] onto [src].</span>")
				loading = FALSE
			loading = FALSE
			return FALSE
		else
			to_chat(user, "<span class='warning'>[src] is fully loaded!</span>")
	. = ..()

/obj/structure/gauss_rack/MouseDrop_T(obj/structure/A, mob/user)
	. = ..()
	if(istype(A, /obj/structure/closet))
		if(!LAZYFIND(A.contents, /obj/item/ship_weapon/ammunition/gauss))
			to_chat(user, "<span class='warning'>There's nothing in [A] that can be loaded into [src]...</span>")
			return FALSE
		to_chat(user, "<span class='notice'>You start to load [src] with the contents of [A]...</span>")
		if(do_after(user, 6 SECONDS , target = src))
			for(var/obj/item/ship_weapon/ammunition/gauss/G in A)
				if(load(G, user))
					continue
				else
					break

/obj/structure/gauss_rack/proc/load(atom/movable/A, mob/user)
	playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	if(capacity >= max_capacity)
		to_chat(user, "<span class='warning'>[src] is full!</span>")
		loading = FALSE
		return FALSE
	if(istype(A, gun.ammo_type))
		A.forceMove(src)
		A.pixel_y = 10+(capacity*10)
		vis_contents += A
		capacity ++
		A.layer = ABOVE_MOB_LAYER
		A.mouse_opacity = FALSE //Nope, not letting you pick this up :)
		loading = FALSE
		return TRUE
	else
		loading = FALSE
		return FALSE


/obj/structure/gauss_rack/proc/unload(atom/movable/A)
	vis_contents -= A
	A.forceMove(get_turf(src))
	A.pixel_y = initial(A.pixel_y) //Remove our offset
	A.layer = initial(A.layer)
	A.mouse_opacity = TRUE
	if(istype(A, gun.ammo_type)) //If a munition, allow them to load other munitions onto us.
		capacity --
	if(contents.len)
		var/count = capacity
		for(var/X in contents)
			var/atom/movable/AM = X
			if(istype(AM, gun.ammo_type))
				AM.pixel_y = count*10
				count --

/obj/structure/gauss_rack/attack_hand(mob/user)
	. = ..()
	ui_interact(user)

/obj/structure/gauss_rack/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "GaussRack", name, 560, 600, master_ui, state)
		ui.open()

/obj/structure/gauss_rack/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	playsound(src.loc,'nsv13/sound/effects/fighters/switch.ogg', 50, FALSE)
	var/atom/movable/BB = locate(params["id"])
	switch(action)
		if("unload")
			if(!BB)
				return
			unload(BB)
		if("unload_all")
			for(var/atom/movable/A in src)
				unload(A)
			return
		if("load")
			gun.raise_rack()

/obj/structure/gauss_rack/ui_data(mob/user)
	var/list/data = list()
	data["capacity"] = capacity
	data["max_capacity"] = max_capacity
	var/list/bullets_info = list()
	for(var/atom/movable/AM in contents)
		var/list/bullet_info = list()
		bullet_info["name"] = AM.name
		bullet_info["id"] = "\ref[AM]"
		bullets_info[++bullets_info.len] = bullet_info
	data["bullets_info"] = bullets_info
	data["loading"] = loading
	return data

/*

Chair + rack handling

*/

/obj/machinery/ship_weapon/gauss_gun/proc/add_chair(obj/structure/chair/comfy/gauss/chair)
	gunner_chair = chair

/obj/structure/chair/comfy/gauss
	name = "Gunner chair"
	desc = "A chair which can be lowered down from the ceiling to feed into a gauss gun, allowing for easy access to the gun's cockpit."
	icon = 'nsv13/icons/obj/chairs.dmi'
	icon_state = "shuttle_chair"
	var/locked = FALSE
	var/obj/machinery/ship_weapon/gauss_gun/gun
	var/mob/living/carbon/occupant
	var/feed_direction = SOUTH //Where does the ammo feed drop down to? By default, south of the chair by one tile.

/obj/structure/chair/comfy/gauss/north
	feed_direction = NORTH

/obj/structure/chair/comfy/gauss/east
	feed_direction = EAST

/obj/structure/chair/comfy/gauss/west
	feed_direction = WEST

/obj/structure/chair/comfy/gauss/unbuckle_mob(mob/living/buckled_mob, force=FALSE)
	if(locked)
		to_chat(buckled_mob, "<span class='warning'>[src]'s restraints are clamped down onto you!</span>")
		return FALSE
	. = ..()
	occupant = null

/obj/structure/chair/comfy/gauss/user_unbuckle_mob(mob/living/buckled_mob, mob/living/carbon/human/user)
	if(locked)
		to_chat(buckled_mob, "<span class='warning'>[src]'s restraints are clamped down onto you!</span>")
		return FALSE
	. = ..()
	occupant = null

/obj/structure/chair/comfy/gauss/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	if((gun && !gun.allowed(M)) || !M.client)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(M.loc != src.loc || user != M)
		return
	to_chat(M, "<span class='warning'>[src]'s restraints clamp down onto you!</span>")
	occupant = M
	. = ..()
	update_armrest()
	gun?.raise_chair()

/obj/structure/chair/comfy/gauss/Initialize()
	. = ..()
	add_overlay(armrest)
	var/turf/above = SSmapping.get_turf_above(src)
	var/obj/machinery/ship_weapon/gauss_gun/gun = locate(/obj/machinery/ship_weapon/gauss_gun) in above
	if(gun && istype(gun))
		gun.add_chair(src)
		src.gun = gun //GUN IS GUN.

/obj/structure/chair/comfy/gauss/GetArmrest()
	return mutable_appearance(src.icon, "[initial(icon_state)]_[has_buckled_mobs() ? "closed" : "open"]")

/obj/structure/chair/comfy/gauss/update_armrest()
	cut_overlay(armrest)
	QDEL_NULL(armrest)
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER
	add_overlay(armrest)

/obj/machinery/ship_weapon/gauss_gun/proc/raise_chair()
	if(!gunner_chair || gunner_chair.loc == src)
		return FALSE
	var/mob/M = gunner_chair.occupant //Arrays start at 1 in byond. Grr.
	if(gunner)
		to_chat(M, "<span class='warning'>Someone else is already manning this turret!</span>")
		return FALSE
	gunner_chair.locked = TRUE //No escape.
	playsound(gunner_chair.loc, 'nsv13/sound/effects/ship/freespace2/crane_2.wav', 100, FALSE)
	gunner_chair.visible_message("<span class='notice'>[gunner_chair] starts to raise into the ceiling!</span>")
	animate(gunner_chair, pixel_y = 60, time = 4 SECONDS)
	animate(M, pixel_y = 60, time = 4 SECONDS)
	sleep(2 SECONDS)
	gunner_chair.animate_swivel(NORTH)
	sleep(2 SECONDS)
	gunner_chair.pixel_y = 0
	M.pixel_y = 0
	if(M.loc != gunner_chair.loc) //They got out of the chair somehow. Probably admin fuckery.
		return FALSE
	set_gunner(M) //Up we go!
	gunner_chair.forceMove(src)

/obj/machinery/ship_weapon/gauss_gun/proc/lower_chair()
	if(!gunner_chair || gunner_chair.loc != src)
		return FALSE
	gunner.unfuck_overmap() //Just in case they didn't cancel camera view or whatever.
	var/mob/M = gunner
	var/turf/below = SSmapping.get_turf_below(src)
	gunner_chair.forceMove(below)
	gunner_chair.locked = TRUE
	gunner.forceMove(below)
	gunner_chair.buckle_mob(gunner)
	playsound(below, 'nsv13/sound/effects/ship/freespace2/crane_2.wav', 100, FALSE)
	below.visible_message("<span class='notice'>[gunner_chair] starts to descend!</span>")
	M.pixel_y = 60
	gunner_chair.pixel_y = 60
	M.alpha = 0
	gunner_chair.alpha = 0
	animate(M, alpha = 255, time = 2 SECONDS, easing = EASE_OUT)
	animate(gunner_chair, alpha = 255, time = 2 SECONDS, easing = EASE_OUT)
	animate(M, pixel_y = 0, time = 4 SECONDS)
	animate(gunner_chair, pixel_y = 0, time = 4 SECONDS)
	sleep(3 SECONDS)
	gunner_chair.animate_swivel(SOUTH)
	sleep(1 SECONDS)
	gunner_chair.locked = FALSE //Ok. Feel free to move again.
	gunner_chair.visible_message("<span class='notice'>[gunner_chair] clunks into place!</span>")
	playsound(gunner_chair, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	gunner = null

/obj/machinery/ship_weapon/gauss_gun/proc/raise_rack()
	if(!ammo_rack || ammo?.len >= max_ammo)
		return
	playsound(ammo_rack.loc, 'nsv13/sound/effects/ship/freespace2/crane_2.wav', 100, FALSE)
	ammo_rack.pixel_y = 0
	ammo_rack.loading = TRUE
	animate(ammo_rack, pixel_y = 60, time = 4 SECONDS)
	sleep(4 SECONDS)
	ammo_rack.forceMove(src)
	rackLoad()

/obj/machinery/ship_weapon/gauss_gun/proc/rackLoad()
	loading = TRUE
	for(var/obj/item/ship_weapon/ammunition/A in ammo_rack.contents)
		if(ammo?.len < max_ammo)
			ammo_rack.unload(A)
			A.forceMove(src)
			ammo += A
	if(load_sound)
		playsound(src, load_sound, 100, 1)
	state = 2
	loading = FALSE
	sleep(3 SECONDS)
	lower_rack()

/obj/machinery/ship_weapon/gauss_gun/proc/lower_rack()
	if(!ammo_rack)
		return
	ammo_rack.loading = FALSE
	var/turf/below = get_turf(get_step(SSmapping.get_turf_below(src), gunner_chair.feed_direction))
	playsound(below, 'nsv13/sound/effects/ship/freespace2/crane_2.wav', 100, FALSE)
	ammo_rack.forceMove(below)
	ammo_rack.pixel_y = 60
	animate(ammo_rack, pixel_y = 0, time = 4 SECONDS)
	sleep(4 SECONDS)
	ammo_rack.visible_message("<span class='notice'>[ammo_rack] clunks into place!</span>")
	playsound(ammo_rack, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)

///Makes the gunner chair swivel forwards/backwards slowly, just like in {{redacted movie name}}

/obj/structure/chair/comfy/gauss/proc/animate_swivel(dir)
	set waitfor = FALSE //Animation proc. Don't wait for it.
	if(dir == NORTH)
		setDir(EAST)
		sleep(0.1 SECONDS)
		setDir(NORTH)
	else
		setDir(WEST)
		sleep(0.1 SECONDS)
		setDir(SOUTH)
