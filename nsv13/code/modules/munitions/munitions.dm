#define MSTATE_CLOSED 0
#define MSTATE_UNSCREWED 1
#define MSTATE_UNBOLTED 2
#define MSTATE_PRIEDOUT 3

/obj/structure/munition/CtrlClick(mob/user)
	. = ..()
	to_chat(user,"<span class='warning'>[src] is far too cumbersome to carry, and dragging it around might set it off! Load it onto a munitions trolley.</span>")

/obj/structure/munition/examine(mob/user)
	. = ..()
	. += "<span class='warning'>It's far too cumbersome to carry, and dragging it around might set it off!</span>"

/obj/structure/munitions_trolley
	name = "Munitions trolley"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "trolley"
	desc = "A large trolley designed for ferrying munitions around. It has slots for traditional ammo magazines as well as a rack for loading torpedoes. To load it, click and drag the desired munition onto the rack."
	anchored = FALSE
	density = TRUE
	layer = 3
	var/capacity = 0 //Current number of munitions we have loaded
	var/max_capacity = 4//Maximum number of munitions we can load at once
	var/loading = FALSE //stop you loading the same torp over and over

/obj/structure/munitions_trolley/Moved()
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, 1)

/obj/structure/munitions_trolley/AltClick(mob/user)
	. = ..()
	add_fingerprint(user)
	if(!anchored)
		to_chat(user, "<span class='notice'>You toggle the brakes on [src], fixing it in place.</span>")
		anchored = TRUE
	else
		to_chat(user, "<span class='notice'>You toggle the brakes on [src], allowing it to move freely.</span>")
		anchored = FALSE

/obj/structure/munitions_trolley/examine(mob/user)
	. = ..()
	if(anchored)
		. += "<span class='notice'>[src]'s brakes are enabled!</span>"

/obj/structure/munitions_trolley/MouseDrop_T(obj/structure/A, mob/user)
	. = ..()
	if(istype(A, /obj/structure/munition))
		if(loading)
			to_chat(user, "<span class='notice'>You're already loading something onto [src]!.</span>")
			return
		if(capacity < max_capacity)
			to_chat(user, "<span class='notice'>You start to load [A] onto [src]...</span>")
			loading = TRUE
			if(do_after(user,20, target = src))
				load_trolley(A, src)
				to_chat(user, "<span class='notice'>You load [A] onto [src].</span>")
				loading = FALSE
			loading = FALSE
		else
			to_chat(user, "<span class='warning'>[src] is fully loaded!</span>")

/obj/structure/munitions_trolley/proc/load_trolley(atom/movable/A, mob/user)
//	if(istype(A, /obj/item))
	//	if(!user.transferItemToLoc(A, src))
	//		return
	playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	if(istype(A, /obj/structure/munition))
		A.forceMove(src)
		A.pixel_y = 10+(capacity*10)
		vis_contents += A
		capacity ++
		A.layer = ABOVE_MOB_LAYER
		return

/obj/structure/munitions_trolley/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(capacity <= 0)
		return
	user.set_machine(src)
	var/dat
	if(contents.len)
		for(var/X in contents) //Allows you to remove things individually
			var/atom/content = X
			dat += "<a href='?src=[REF(src)];removeitem=\ref[content]'>[content.name]</a><br>"
	dat += "<a href='?src=[REF(src)];unloadall=1'>Unload All</a>"
	var/datum/browser/popup = new(user, "munitions trolley", name, 300, 200)
	popup.set_content(dat)
	popup.open()

/obj/structure/munitions_trolley/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	var/atom/whattoremove = locate(href_list["removeitem"])
	if(whattoremove && whattoremove.loc == src)
		unload_munition(whattoremove)
	if(href_list["unloadall"])
		for(var/atom/movable/A in src)
			unload_munition(A)
	attack_hand(usr)

/obj/structure/munitions_trolley/proc/unload_munition(atom/movable/A)
	vis_contents -= A
	A.forceMove(get_turf(src))
	A.pixel_y = initial(A.pixel_y) //Remove our offset
	A.layer = initial(A.layer)
	to_chat(usr, "<span class='notice'>You unload [A] from [src].</span>")
	if(istype(A, /obj/structure/munition)) //If a munition, allow them to load other munitions onto us.
		capacity --
	if(contents.len)
		var/count = capacity
		for(var/X in contents)
			var/atom/movable/AM = X
			if(istype(AM, /obj/structure/munition))
				AM.pixel_y = count*10
				count --

#define STATE_NOTLOADED 1
#define STATE_LOADED 2
#define STATE_CHAMBERED 3
#define STATE_READY 4
#define STATE_FIRING 5

/obj/structure/ship_weapon //CREDIT TO CM FOR THE SPRITES!
	name = "A ship weapon"
	desc = "Don't use this, use the subtypes"
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "OBC"
	density = TRUE
	anchored = TRUE
	bound_width = 128
	bound_height = 64
	pixel_y = -64
	layer = BELOW_OBJ_LAYER
	var/fire_sound = 'nsv13/sound/effects/ship/mac_fire.ogg'
	var/load_sound = 'nsv13/sound/effects/ship/reload.ogg'
	var/safety = TRUE //Can only fire when safeties are off
	var/loading = FALSE
	var/state = STATE_NOTLOADED
	var/obj/structure/overmap/linked = null
	var/maint_state = MSTATE_CLOSED
	var/maint_req = 0 //Number of times a weapon can fire until a maintenance cycle is required. This will countdown to 0.
	var/malfunction = FALSE
	var/obj/structure/munition/chambered //What have we got loaded? Extrapolate ammo type from this

/obj/structure/ship_weapon/Initialize()
	. = ..()
	get_ship()
	maint_req = rand(15,25) //Setting initial number of cycles until maintenance is required
	create_reagents(50)

/obj/structure/ship_weapon/proc/get_ship()
	var/area/AR = get_area(src)
	if(AR.linked_overmap)
		linked = AR.linked_overmap
		set_position(linked)

/obj/structure/ship_weapon/proc/set_position(obj/structure/overmap/OM) //Use this to tell your ship what weapon category this belongs in
	return

/obj/structure/ship_weapon/railgun/set_position(obj/structure/overmap/OM)
	OM.railguns += src

/obj/structure/ship_weapon/torpedo_launcher/set_position(obj/structure/overmap/OM)
	OM.torpedo_tubes += src

/obj/structure/ship_weapon/torpedo_launcher //heavily modified CM sprite
	name = "M4-B Torpedo tube"
	desc = "A weapon system that's employed by nigh on all modern ships. It's capable of delivering a self-propelling warhead with pinpoint accuracy to utterly annihilate a target."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "torpedo"
	bound_height = 32
	bound_width = 96
	pixel_y = -72
	pixel_x = -32
	fire_sound = 'nsv13/sound/effects/ship/plasma.ogg'
	load_sound = 'nsv13/sound/effects/ship/freespace2/m_load.wav'

/obj/machinery/computer/ship/munitions_computer
	name = "munitions control computer"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "munitions_console"
	density = TRUE
	anchored = TRUE
	req_access = list(ACCESS_MUNITIONS)
	var/obj/structure/ship_weapon/railgun //The one we're firing

/obj/machinery/computer/ship/munitions_computer/Initialize()
	. = ..()
	var/atom/adjacent = locate(/obj/structure/ship_weapon) in get_turf(get_step(src, dir)) //Look at what dir we're facing, find a gun in that turf
	if(adjacent && istype(adjacent, /obj/structure/ship_weapon))
		railgun = adjacent

/obj/machinery/computer/ship/munitions_computer/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/munitions_computer/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/munitions_computer/attack_hand(mob/user)
	. = ..()
	if(!railgun)
		return
	if(!railgun.linked)
		railgun.get_ship()
	var/dat
	if(railgun.malfunction)
		dat += "<p><b><font color='#FF0000'>MALFUNCTION DETECTED!</font></p>"
	dat += "<h2> Tray: </h2>"
	if(railgun.state <= STATE_LOADED)
		dat += "<A href='?src=\ref[src];load_tray=1'>Load Tray</font></A><BR>" //STEP 1: Move the tray into the railgun
	else
		dat += "<A href='?src=\ref[src];unload_tray=1'>Unload Tray</font></A><BR>" //OPTIONAL: Cancel loading
	dat += "<h2> Firing chamber: </h2>"
	if(railgun.state != STATE_READY)
		dat += "<A href='?src=\ref[src];chamber_tray=1'>Chamber Tray Payload</font></A><BR>" //Step 2: Chamber the round
	else
		dat += "<A href='?src=\ref[src];tray_notif=1'>'[railgun.chambered.name]' is ready for deployment</font></A><BR>" //Tell them that theyve chambered something
	dat += "<h2> Safeties: </h2>"
	if(railgun.safety)
		dat += "<A href='?src=\ref[src];disengage_safeties=1'>Disengage safeties</font></A><BR>" //Step 3: Disengage safeties. This allows the helm to fire the weapon.
	else
		dat += "<A href='?src=\ref[src];engage_safeties=1'>Engage safeties</font></A><BR>" //OPTIONAL: Re-engage safeties. Use this if some disaster happens in the tubes, and you need to forbid the helm from firing
	var/datum/browser/popup = new(user, "Fire control systems", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/ship/munitions_computer/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!railgun)
		return
	if(href_list["load_tray"])
		railgun.load()
	if(href_list["unload_tray"])
		railgun.unload()
	if(href_list["chamber_tray"])
		railgun.chamber()
	if(href_list["disengage_safeties"])
		railgun.safety = FALSE
	if(href_list["engage_safeties"])
		railgun.safety = TRUE

	attack_hand(usr) //Refresh window

/obj/structure/ship_weapon/MouseDrop_T(obj/structure/A, mob/user)
	. = ..()
	if(istype(A, /obj/structure/munition))
		if(loading)
			to_chat(user, "<span class='notice'>You're already loading a round into [src]!.</span>")
		if(!chambered || state == STATE_NOTLOADED)
			to_chat(user, "<span class='notice'>You start to load [A] into [src]...</span>")
			loading = TRUE
			if(do_after(user,20, target = src))
				to_chat(user, "<span class='notice'>You load [A] into [src].</span>")
				loading = FALSE
				A.forceMove(src)
				playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
				chambered = A
				state = STATE_LOADED
			loading = FALSE
		else
			to_chat(user, "<span class='warning'>[src] already has a round loaded!</span>")

/obj/structure/ship_weapon/proc/load()
	if(state != STATE_LOADED)
		return
	flick("[initial(icon_state)]_loading",src)
	playsound(src, 'nsv13/sound/effects/ship/freespace2/crane_short.ogg', 100, 1)
	sleep(20)
	playsound(src, load_sound, 100, 1)
	icon_state = "[initial(icon_state)]_loaded"
	state = STATE_CHAMBERED

/obj/structure/ship_weapon/proc/unload()
	if(state < STATE_LOADED)
		return
	flick("[initial(icon_state)]_unloading",src)
	playsound(src, 'nsv13/sound/effects/ship/freespace2/crane_short.ogg', 100, 1)
	sleep(20)
	chambered.forceMove(get_turf(src))
	chambered = null //Cancel fire
	state = STATE_NOTLOADED
	icon_state = initial(icon_state)

/obj/structure/ship_weapon/proc/chamber(rapidfire = FALSE) //Rapidfire is used for when you want to reload rapidly. This is done for the railgun autoloader so that you can "volley" shots quickly.
	if(state != STATE_CHAMBERED)
		return
	flick("[initial(icon_state)]_chambering",src)
	if(rapidfire)
		sleep(2)
	else
		sleep(10)
	icon_state = "[initial(icon_state)]_chambered"
	playsound(src, 'nsv13/sound/weapons/railgun/ready.ogg', 100, 1)
	state = STATE_READY

/obj/structure/ship_weapon/proc/fire()
	if(!can_fire())
		return
	var/atom/projectile = null
	if(maint_req <= 0)
		weapon_malfunction()
		return
	spawn(0) //Branch so that there isnt a fire delay for the helm.
		do_animation()
	state = STATE_FIRING
	playsound(src, fire_sound, 100, 1)
	for(var/mob/living/M in get_hearers_in_view(10, get_turf(src))) //Burst unprotected eardrums
		if(M.stat == DEAD || !isliving(M))
			continue
		M.soundbang_act(1,200,10,15)
	projectile = new chambered.type() //Dummy munition in nullspace so we can get its attributes for the ship to fire it.
	qdel(chambered)
	chambered = null
	state = STATE_NOTLOADED
	maint_req --
	after_fire()
	if(projectile) //Looks like we were able to fire a projectile, let's tell the ship what kind of bullet to shoot.
		return projectile

/obj/structure/ship_weapon/proc/after_fire()
	return

/obj/structure/ship_weapon/proc/can_fire()
	if(state < STATE_READY || state >= STATE_FIRING || !chambered || malfunction || maint_state != MSTATE_CLOSED)
		return FALSE
	else
		return TRUE

/obj/structure/ship_weapon/proc/do_animation()
	flick("[initial(icon_state)]_firing",src)
	sleep(5)
	flick("[initial(icon_state)]_unloading",src)
	sleep(5)
	icon_state = initial(icon_state)

/obj/structure/ship_weapon/proc/weapon_malfunction()
	malfunction = TRUE
	playsound(src, 'sound/effects/alert.ogg', 100, TRUE) //replace this with appropriate sound
	visible_message("<span class=userdanger>Malfunction detected in [src]! Firing sequence aborted!</span>") //perhaps additional flavour text of a non angry red kind?
	for(var/mob/living/M in range(10, get_turf(src)))
		shake_camera(M, 2, 1)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(6, 0, src)
	s.start()
	light_color = LIGHT_COLOR_RED
	set_light(3)

/obj/structure/ship_weapon/railgun
	name = "NT-STC4 Ship mounted railgun chamber"
	desc = "A powerful ship-to-ship weapon which uses a localized magnetic field accelerate a projectile through a spinally mounted railgun with a 360 degree rotation axis. This particular model has an effective range of 20,000KM."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "OBC"
	var/list/autoloader_contents = list() //All the shit that the autoloader has ready. This means multiple munitions!
	var/max_autoloader_mag = 3 //Until you have to manually load it back up again. Battleships IRL have 3-4 shots before you need to reload the rack

/obj/structure/ship_weapon/railgun/after_fire()
	if(!autoloader_contents.len)
		say("Autoloader has depleted all ammunition sources. Reload required.")
		return
	var/obj/item/ammo = pick(autoloader_contents)
	playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	chambered = ammo
	state = STATE_CHAMBERED
	visible_message("<span class='warning'>[src]'s autoloader rack slams down into [src]!</span>")
	autoloader_contents -= ammo
	chamber(rapidfire = TRUE)

/obj/structure/ship_weapon/railgun/unload()
	if(state < STATE_LOADED)
		return
	flick("[initial(icon_state)]_unloading",src)
	playsound(src, 'nsv13/sound/effects/ship/freespace2/crane_short.ogg', 100, 1)
	sleep(20)
	chambered.forceMove(get_turf(src))
	chambered = null //Cancel fire
	state = STATE_NOTLOADED
	icon_state = initial(icon_state)
	if(autoloader_contents.len)
		for(var/obj/ammo in autoloader_contents)
			ammo.forceMove(get_turf(src))
			autoloader_contents -= ammo

/obj/structure/ship_weapon/railgun/MouseDrop_T(obj/structure/A, mob/user)
	return

/obj/item/twohanded/required/railgun_ammo //The big slugs that you load into the railgun. These are able to be carried...one at a time
	name = "M4 NTRS '30mm' teflon coated tungsten round"
	desc = "A gigantic slug that's designed to be fired out of a railgun. It's extremely heavy, but doesn't actually contain any volatile components, so it's safe to manhandle."
	icon_state = "railgun_ammo"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'
	icon = 'nsv13/icons/obj/munitions.dmi'
	w_class = 4
	var/proj_type = /obj/item/projectile/bullet/railgun_slug

/obj/structure/ship_weapon/railgun/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/twohanded/required/railgun_ammo))
		if(loading)
			to_chat(user, "<span class='notice'>You're already loading a round into [src]!.</span>")
			return
		if(maint_state != MSTATE_CLOSED)
			to_chat(user, "<span class='notice'>You can't load a round into [src] while the maintenance panel is open!.</span>")
			return
		if(state == STATE_NOTLOADED)
			to_chat(user, "<span class='notice'>You start to load [I] into [src]...</span>")
			loading = TRUE
			if(do_after(user,20, target = src))
				to_chat(user, "<span class='notice'>You load [I] into [src].</span>")
				loading = FALSE
				I.forceMove(src)
				playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
				chambered = I
				state = STATE_LOADED
				return FALSE
			loading = FALSE
		else
			if(autoloader_contents.len < max_autoloader_mag && state == STATE_LOADED)
				to_chat(user, "<span class='notice'>You start to load [I] into [src]'s autoloader magazine...</span>")
				if(do_after(user,20, target = src))
					to_chat(user, "<span class='notice'>You load [I] into [src]'s autoloader magazine.</span>")
					loading = FALSE
					I.forceMove(src)
					playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
					autoloader_contents += I
					return FALSE
			to_chat(user, "<span class='warning'>[src] already has a round loaded!</span>")
	. = ..()

// Ship Weapon Maintenance
/obj/structure/ship_weapon/screwdriver_act(mob/user, obj/item/tool)
	. = FALSE
	if(state >= STATE_LOADED && maint_state == MSTATE_CLOSED)
		to_chat(user, "<span class='warning'>You cannot open the maintence panel while [src] is loaded!</span>")
		return TRUE
	else if(state < STATE_LOADED && maint_state == MSTATE_CLOSED)
		to_chat(user, "<span class='notice'>You begin unfastening the maintenance panel on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'> You unfasten the maintenance panel on [src].</span>")
			maint_state = MSTATE_UNSCREWED
			update_overlay()
			return TRUE
	else if(maint_state == MSTATE_UNSCREWED)
		to_chat(user, "<span class='notice'>You begin fastening the maintenance panel on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'> You fasten the maintenance panel on [src].</span>")
			maint_state = MSTATE_CLOSED
			update_overlay()
			return TRUE

/obj/structure/ship_weapon/wrench_act(mob/user, obj/item/tool)
	. = FALSE
	if(maint_state == MSTATE_UNSCREWED)
		to_chat(user, "<span class='notice'>You begin unfastening the inner casing bolts on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You unfasten the inner case bolts on [src].</span>")
			maint_state = MSTATE_UNBOLTED
			update_overlay()
			return TRUE
	else if(maint_state == MSTATE_UNBOLTED)
		to_chat(user, "<span class='notice'>You begin fastening the inner casing bolts on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You fasten the inner case bolts on [src].</span>")
			maint_state = MSTATE_UNSCREWED
			update_overlay()
			return TRUE

/obj/structure/ship_weapon/crowbar_act(mob/user, obj/item/tool)
	. = FALSE
	if(maint_state == MSTATE_UNBOLTED)
		to_chat(user, "<span class='notice'>You begin prying the inner casing off [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You pry the inner casing off [src].</span>")
			maint_state = MSTATE_PRIEDOUT
			update_overlay()
			if(prob(50))
				to_chat(user, "<span class='warning'>Oil spurts out of the exposed machinery!</span>")
				new /obj/effect/decal/cleanable/oil(user.loc)
				reagents.clear_reagents()
			return TRUE
	if(maint_state == MSTATE_PRIEDOUT)
		to_chat(user, "<span class='notice'>You begin slotting the inner casing back in [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You slot the inner casing back in [src].</span>")
			maint_state = MSTATE_UNBOLTED
			update_overlay()
			return TRUE

/obj/structure/ship_weapon/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers))
		if(maint_state != MSTATE_PRIEDOUT)
			to_chat(user, "<span class='notice'>You require access to the inner workings of [src].</span>")
			return
		else if(maint_state == MSTATE_PRIEDOUT)
			if(I.reagents.has_reagent(/datum/reagent/oil, 10))
				to_chat(user, "<span class='notice'>You start lubricating the inner workings of [src]...</span>")
				if(!do_after(user, 2 SECONDS, target=src))
					return
				to_chat(user, "<span class='notice'>You lubricate the inner workings of [src].</span>")
				if(malfunction)
					malfunction = FALSE
					visible_message("<span class='notice'>The red warning lights on [src] fade away.</span>")
					set_light(0)
				maint_req = rand(15,25)
				I.reagents.trans_to(src, 10)
				reagents.clear_reagents()
				return
			else if(I.reagents.has_reagent(/datum/reagent/oil))
				to_chat(user, "<span class='notice'>You need at least 10 units of oil to lubricate [src]!</span>")
				return
			else if(!I.reagents.has_reagent(/datum/reagent/oil))
				visible_message("<span class=warning>Warning: Contaminants detected, flushing systems.</span>")
				new /obj/effect/decal/cleanable/oil(user.loc)
				I.reagents.trans_to(src, 10)
				reagents.clear_reagents()
				return

/obj/structure/ship_weapon/proc/update_overlay()
	cut_overlays()
	switch(maint_state)
		if(MSTATE_UNSCREWED)
			add_overlay("[initial(icon_state)]_screwdriver")
		if(MSTATE_UNBOLTED)
			add_overlay("[initial(icon_state)]_wrench")
		if(MSTATE_PRIEDOUT)
			add_overlay("[initial(icon_state)]_crowbar")


//PDCs

/obj/structure/pdc_mount
	name = "PDC loading rack"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "pdc"
	desc = "Seegson's all-in-one PDC targeting computer, ammunition loader, and human interface has proven extremely popular in recent times. It's rare to see a ship without one of these."
	anchored = TRUE
	density = FALSE
	pixel_y = 26
	var/obj/item/ammo_box/magazine/pdc/magazine = null
	var/obj/structure/overmap/linked = null

/obj/structure/pdc_mount/attack_hand(mob/user)
	. = ..()
	if(magazine)
		to_chat(user, "<span class='notice'>You start to unload [magazine] from [src].</span>")
		if(do_after(user,50, target = src))
			user.put_in_hands(magazine)
			magazine = null
			update_icon()
			playsound(src, 'sound/weapons/autoguninsert.ogg', 100, 1)

/obj/structure/pdc_mount/attackby(obj/item/I, mob/user)
	if(!linked)
		var/area/AR = get_area(src)
		if(AR.linked_overmap)
			linked = AR.linked_overmap
			linked?.pdcs += src
	if(istype(I, /obj/item/ammo_box/magazine/pdc))
		to_chat(user, "<span class='notice'>You start to load [I] into [src].</span>")
		if(do_after(user,50, target = src))
			to_chat(user, "<span class='notice'>You load [I] into [src].</span>")
			playsound(src, 'sound/weapons/autoguninsert.ogg', 100, 1)
			if(magazine)
				user.put_in_hands(magazine)
				magazine = null
			I.forceMove(src)
			magazine = I
			update_icon()
	else
		. = ..()

/obj/structure/pdc_mount/update_icon()
	if(!magazine)
		icon_state = "[initial(icon_state)]_0"
		return
	var/progress = magazine.ammo_count() //How damaged is this shield? We examine the position of index "I" in the for loop to check which directional we want to check
	var/goal = magazine.max_ammo //How much is the max hp of the shield? This is constant through all of them
	progress = CLAMP(progress, 0, goal)
	progress = round(((progress / goal) * 100), 20)//Round it down to 20%. We now apply visual damage
	icon_state = "[initial(icon_state)]_[progress]"

/obj/structure/pdc_mount/proc/can_fire(shots) //We need to fire 3 shots. Can we do that?
	if(magazine?.ammo_count() > shots)
		return TRUE
	else
		return FALSE

/obj/structure/pdc_mount/proc/fire(shots)
	if(can_fire(shots))
		for(var/i = 0, i < shots, i++)
			var/obj/item/projectile/P = magazine.get_round(FALSE)
			qdel(P)
			update_icon()
		return TRUE
	else
		return FALSE

/obj/item/ammo_box/magazine/pdc
	name = "Point defense cannon ammo (30.12x82mm)"
	desc = "A box of .30 caliber rounds which can be loaded into a ship's point defense emplacements. These are typically used to shoot down oncoming missiles, and provide close quarters combat relief for large ships."
	icon_state = "pdc"
	ammo_type = /obj/item/ammo_casing/pdc
	caliber = "mm30.12"
	max_ammo = 100

/obj/item/ammo_box/magazine/pdc/update_icon()
	if(ammo_count() > 10)
		icon_state = "pdc"
	else
		icon_state = "pdc_empty"

/obj/item/ammo_casing/pdc
	name = "30.12x82mm bullet casing"
	desc = "A 30.12x82mm bullet casing."
	projectile_type = /obj/item/projectile/bullet/pdc_round


#undef MSTATE_CLOSED
#undef MSTATE_UNSCREWED
#undef MSTATE_UNBOLTED
#undef MSTATE_PRIEDOUT

#undef STATE_NOTLOADED
#undef STATE_LOADED
#undef STATE_CHAMBERED
#undef STATE_READY
#undef STATE_FIRING