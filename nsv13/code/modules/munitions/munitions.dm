/obj/structure/munition //CREDIT TO CM FOR THIS SPRITE
	name = "NTP-2 530mm torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "standard"
	desc = "A fairly standard torpedo which is designed to cause massive structural damage to a target. It is fitted with a basic homing mechanism to ensure it always hits the mark."
	anchored = TRUE
	density = TRUE
	var/torpedo_type = /obj/item/projectile/bullet/torpedo //What torpedo type we fire
	pixel_x = -17
	var/speed = 1 //Placeholder, allows upgrading speed with better propulsion

/obj/structure/munition/hull_shredder //High damage torp. Use this when youve exhausted their flak.
	name = "NTP-4 'BNKR' 430mm torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "hull_shredder"
	desc = "A heavy torpedo which is packed with a high energy plasma charge, allowing it to impact a target with massive force."
	torpedo_type = /obj/item/projectile/bullet/torpedo/shredder

/obj/structure/munition/fast //Gap closer, weaker but quick.
	name = "NTP-1 'SPD' 430mm high velocity torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "highvelocity"
	desc = "A small torpedo which is fitted with an advanced propulsion system, allowing it to rapidly travel long distances. Due to its smaller frame however, it packs less of a punch."
	torpedo_type = /obj/item/projectile/bullet/torpedo/fast

/obj/structure/munition/decoy //A dud missile designed to exhaust flak
	name = "NTP-0x 'DCY' 530mm electronic countermeasure"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "decoy"
	desc = "A simple electronic countermeasure packed inside a standard torpedo casing. This model excels at diverting enemy PDC emplacements away from friendly ships, or even another barrage of missiles."
	torpedo_type = /obj/item/projectile/bullet/torpedo/decoy

/obj/structure/munition/nuke //The alpha torpedo
	name = "NTNK 'Oncoming Storm' 700mm thermonuclear warhead"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "nuke"
	desc = "The NTX-class IV nuclear torpedo carries a radiological payload which is capable of inflicting catastrophic damage against enemy ships, stations or dense population centers. These weapons are utterly without mercy and will annihilate indiscriminately, use with EXTREME caution."
	torpedo_type = /obj/item/projectile/bullet/torpedo/nuclear

/obj/item/projectile/bullet/torpedo/shredder
	icon_state = "torpedo_shredder"
	name = "plasma charge"
	damage = 120

/obj/item/projectile/bullet/torpedo/nuclear
	icon_state = "torpedo_shredder"
	name = "thermonuclear cruise missile"
	damage = 300
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo/nuke

/obj/item/projectile/bullet/torpedo/fast
	icon_state = "torpedo_fast"
	name = "high velocity torpedo"
	damage = 40

/obj/item/projectile/bullet/torpedo/decoy
	icon_state = "torpedo"
	damage = 0

/obj/item/projectile/bullet/torpedo/dud //What you get from an incomplete torpedo.
	icon_state = "torpedo_dud"
	damage = 0

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
	var/obj/structure/munition/preload = null
	var/obj/structure/munition/loaded = null
	var/obj/structure/munition/chambered = null
	var/obj/structure/overmap/linked = null
	var/firing = FALSE //If firing, disallow unloading.
	var/maint_state = 0 //For when the maint panel is open 1 to 3, 0 for closed
	var/maint_req = null //Countdown to 0
	var/malfunction = FALSE

/obj/structure/ship_weapon/Initialize()
	. = ..()
	get_ship()
	maint_req = rand(15,25)
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

/obj/structure/ship_weapon_computer
	name = "munitions control computer"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "munitions_console"
	density = TRUE
	anchored = TRUE
	var/obj/structure/ship_weapon/railgun //The one we're firing

/obj/structure/ship_weapon_computer/Initialize()
	. = ..()
	var/atom/adjacent = locate(/obj/structure/ship_weapon) in get_turf(get_step(src, dir)) //Look at what dir we're facing, find a gun in that turf
	if(adjacent && istype(adjacent, /obj/structure/ship_weapon))
		railgun = adjacent

/obj/structure/ship_weapon_computer/attack_hand(mob/user)
	. = ..()
	if(!railgun)
		return
	if(!railgun.linked)
		railgun.get_ship()
	var/dat
	if(railgun.malfunction)
		dat += "<p><b><font color='#FF0000'>MALFUNCTION DETECTED!</font></p>"
	dat += "<h2> Tray: </h2>"
	if(!railgun.loaded)
		dat += "<A href='?src=\ref[src];load_tray=1'>Load Tray</font></A><BR>" //STEP 1: Move the tray into the railgun
	else
		dat += "<A href='?src=\ref[src];unload_tray=1'>Unload Tray</font></A><BR>" //OPTIONAL: Cancel loading
	dat += "<h2> Firing chamber: </h2>"
	if(!railgun.chambered)
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

/obj/structure/ship_weapon_computer/Topic(href, href_list)
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
		if(!preload && !loaded && !chambered)
			to_chat(user, "<span class='notice'>You start to load [A] into [src]...</span>")
			loading = TRUE
			if(do_after(user,20, target = src))
				to_chat(user, "<span class='notice'>You load [A] into [src].</span>")
				loading = FALSE
				A.forceMove(src)
				playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
				preload = A
			loading = FALSE
		else
			to_chat(user, "<span class='warning'>[src] already has a round loaded!</span>")

/obj/structure/ship_weapon/proc/load()
	if(!preload || loaded)
		return
	flick("[initial(icon_state)]_loading",src)
	playsound(src, 'nsv13/sound/effects/ship/freespace2/crane_short.ogg', 100, 1)
	var/atom/movable/temp = preload
	preload = null
	sleep(20)
	playsound(src, load_sound, 100, 1)
	icon_state = "[initial(icon_state)]_loaded"
	loaded = temp


/obj/structure/ship_weapon/proc/unload()
	if(!loaded || firing)
		return
	flick("[initial(icon_state)]_unloading",src)
	playsound(src, 'nsv13/sound/effects/ship/freespace2/crane_short.ogg', 100, 1)
	sleep(20)
	loaded.forceMove(get_turf(src))
	preload = null
	chambered = null //Cancel fire
	loaded = null
	icon_state = initial(icon_state)

/obj/structure/ship_weapon/proc/chamber()
	if(chambered || !loaded)
		return
	chambered = loaded
	flick("[initial(icon_state)]_chambering",src)
	sleep(10)
	icon_state = "[initial(icon_state)]_chambered"
	playsound(src, 'nsv13/sound/weapons/railgun/ready.ogg', 100, 1)

/obj/structure/ship_weapon/proc/fire()
	if(!chambered || safety || firing)
		return
	var/proj_type
	if(istype(chambered, /obj/structure/munition))
		proj_type = chambered.torpedo_type
	if(istype(chambered, /obj/item/twohanded/required/railgun_ammo))
		var/obj/item/twohanded/required/railgun_ammo/RA = chambered
		proj_type = RA.proj_type
	if(maint_req == 0)
		weapon_malfunction()
		return
	firing = TRUE
	flick("[initial(icon_state)]_firing",src)
	sleep(5)
	playsound(src, fire_sound, 100, 1)
	for(var/mob/living/M in get_hearers_in_view(10, get_turf(src))) //Burst unprotected eardrums
		if(M.stat == DEAD || !isliving(M))
			continue
		M.soundbang_act(1,200,10,15)
	flick("[initial(icon_state)]_unloading",src)
	sleep(5)
	icon_state = initial(icon_state)
	qdel(loaded)
	chambered = null
	loaded = null
	firing = FALSE
	maint_req = maint_req --
	if(proj_type) //Looks like we were able to fire a projectile, let's tell the ship what kind of bullet to shoot.
		return proj_type

/obj/structure/ship_weapon/proc/weapon_malfunction()
	malfunction = TRUE
	playsound(src, 'sound/effects/alert.ogg', 100, 1) //replace this with appropriate sound
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
		if(maint_state != 0)
			to_chat(user, "<span class='notice'>You can't load a round into [src] while the maintenance panel is open!.</span>")
		if(!preload && !loaded && !chambered)
			to_chat(user, "<span class='notice'>You start to load [I] into [src]...</span>")
			loading = TRUE
			if(do_after(user,20, target = src))
				to_chat(user, "<span class='notice'>You load [I] into [src].</span>")
				loading = FALSE
				I.forceMove(src)
				playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
				preload = I
				return FALSE
			loading = FALSE
		else
			to_chat(user, "<span class='warning'>[src] already has a round loaded!</span>")
	. = ..()

// Ship Weapon Maintenance
/obj/structure/ship_weapon/screwdriver_act(mob/user, obj/item/tool)
	. = FALSE
	if(loaded && maint_state == 0)
		to_chat(user, "<span class='warning'>You cannot open the maintence panel while [src] is loaded!</span>")
		return TRUE
	else if(!loaded && maint_state == 0)
		to_chat(user, "<span class='notice'>You begin unfastening the maintenance panel on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'> You unfasten the maintenance panel on [src].</span>")
			maint_state = 1
			update_overlay()
			return TRUE
	else if(maint_state == 1)
		to_chat(user, "<span class='notice'>You begin fastening the maintenance panel on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'> You fasten the maintenance panel on [src].</span>")
			maint_state = 0
			update_overlay()
			return TRUE

/obj/structure/ship_weapon/wrench_act(mob/user, obj/item/tool)
	. = FALSE
	if(maint_state == 1)
		to_chat(user, "<span class='notice'>You begin unfastening the inner casing bolts on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You unfasten the inner case bolts on [src].</span>")
			maint_state = 2
			update_overlay()
			return TRUE
	else if(maint_state == 2)
		to_chat(user, "<span class='notice'>You begin fastening the inner casing bolts on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You fasten the inner case bolts on [src].</span>")
			maint_state = 1
			update_overlay()
			return TRUE

/obj/structure/ship_weapon/crowbar_act(mob/user, obj/item/tool)
	. = FALSE
	if(maint_state == 2)
		to_chat(user, "<span class='notice'>You begin prying the inner casing off [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You pry the inner casing off [src].</span>")
			maint_state = 3
			update_overlay()
			if(prob(50))
				to_chat(user, "<span class='warning'>Oil spurts out of the exposed machinery!</span>")
				new /obj/effect/decal/cleanable/oil(user.loc)
				reagents.clear_reagents()
			return TRUE
	if(maint_state == 3)
		to_chat(user, "<span class='notice'>You begin slotting the inner casing back in [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You slot the inner casing back in [src].</span>")
			maint_state = 2
			update_overlay()
			return TRUE

/obj/structure/ship_weapon/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers))
		if(maint_state != 3)
			to_chat(user, "<span class='notice'>You require access to the inner workings of [src].</span>")
			return
		else if(maint_state == 3)
			if(I.reagents.has_reagent(/datum/reagent/oil, 10))
				to_chat(user, "<span class='notice'>You start lubricating the inner workings of [src]...</span>")
				do_after(user, 2 SECONDS, target=src)
				to_chat(user, "<span class='notice'>You lubricate the inner workings of [src].</span>")
				malfunction = FALSE
				visible_message("<span class='notice'>The red warning lights on [src] fade away.</span>")
				set_light(0)
				maint_req = rand(15,25)
				reagents.clear_reagents()
				return
			else if(!I.reagents.has_reagent(/datum/reagent/oil))
				visible_message("<span class=warning>Warning: Contaminants detected, flushing systems.</span>")
				new /obj/effect/decal/cleanable/oil(user.loc)
				reagents.clear_reagents()
				return

/obj/structure/ship_weapon/proc/update_overlay()
	cut_overlays()
	switch(maint_state)
		if(1)
			add_overlay("[initial(icon_state)]_screwdriver")
		if(2)
			add_overlay("[initial(icon_state)]_wrench")
		if(3)
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

//Torpedo construction//

/obj/structure/munition/torpedo_casing
	name = "NTB-M4A1-IB prebuilt torpedo-casing"
	icon_state = "case"
	desc = "The outer casing of a 30mm torpedo."
	anchored = TRUE
	density = TRUE
	climbable = TRUE
	var/state = 0
	var/obj/item/torpedo/warhead/wh = null
	var/obj/item/torpedo/guidance_system/gs = null
	var/obj/item/torpedo/propulsion_system/ps = null
	var/obj/item/torpedo/iff_card/iff = null
	torpedo_type = /obj/item/projectile/bullet/torpedo/dud //Forget to finish your torpedo? You get a dud torpedo that doesn't do anything

/obj/structure/munition/torpedo_casing/examine(mob/user) //No better guide than an in-game play-by-play guide
	. = ..()
	switch(state)
		if(0)
			. += "<span class='notice'>The casing is empty, awaiting the installation of a propulsion system.</span>"
		if(1)
			. += "<span class='notice'>The propulsion system is sitting loose the casing. There are bolts to secure it.</span>"
		if(2)
			. += "<span class='notice'>The propulsion system is secured in the tail half of the casing, now for the guidance system.</span>"
		if(3)
			. += "<span class='notice'>The guidance system is sitting loose in the casing next to the propulsion system. There are places for screws to secure the guidance system to the casing. </span>"
		if(4)
			. += "<span class='notice'>The propulsion and guidance systems are secured in the casing. The guidance system has a currently empty slot for an IFF card.</span>"
		if(5)
			. += "<span class='notice'>The IFF card is sitting loose in its slot in the guidance system. There are holes for screws in each corner of the slot.</span>"
		if(6)
			. += "<span class='notice'>The propulsion system, guidance system and IFF card are all secured. There is space at the nose end for a warhead.</span>"
		if(7)
			. += "<span class='notice'>The warhead is sitting snug at the nose end of the casing. The bolts could be tighter.</span>"
		if(8)
			. += "<span class='notice'>The casing contains the warhead, an IFF chip, guidance and propulsion systems. They are not yet wired together.</span>"
		if(9)
			. += "<span class='notice'>The casing has the following components installed: [wh?.name], [iff?.name], [gs?.name], [ps?.name]. It looks ready to close and bolt shut. </span>"
		if(10)
			. += "<span class='notice'>The casing has been closed and bolted shut. It only requires sealing with a welding tool to be ready for action.</span>"

/obj/structure/munition/torpedo_casing/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/torpedo/warhead))
		if(state == 6)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			do_after(user, 2 SECONDS, target=src)
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			wh = W
			state = 7
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/torpedo/guidance_system))
		if(state == 2)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			do_after(user, 2 SECONDS, target=src)
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			gs = W
			state = 3
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/torpedo/propulsion_system))
		if(state == 0)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			do_after(user, 2 SECONDS, target=src)
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			ps = W
			state = 1
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/torpedo/iff_card))
		if(state == 4)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			do_after(user, 2 SECONDS, target=src)
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			iff = W
			state = 5
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(state == 8)
			if(C.get_amount() < 3)
				to_chat(user, "<span class='notice'>You need at least three cable pieces to wire [src]!</span>") //for 'realistic' wire spaghetti
				return
			to_chat(user, "<span class='notice'>You start wiring [src]...</span>")
			do_after(user, 2 SECONDS, target=src)
			W.use(3)
			to_chat(user, "<span class='notice'>You wire [src].</span>")
			state = 9
			update_icon()
		return

/obj/structure/munition/torpedo_casing/wrench_act(mob/user, obj/item/tool)
	. = FALSE
	switch(state)
		if(1)
			to_chat(user, "<span class='notice'>You start securing [ps.name] to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You secure [ps.name] to [src]. </span>")
				state = 2
				update_icon()
			return TRUE
		if(2)
			to_chat(user, "<span class='notice'>You start unsecuring [ps.name] to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unsecure [ps.name] to [src]. </span>")
				state = 1
				update_icon()
			return TRUE
		if(7)
			to_chat(user, "<span class='notice'>You start securing [wh.name] to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You secure [wh.name] to [src]. </span>")
				state = 8
				update_icon()
			return TRUE
		if(8)
			to_chat(user, "<span class='notice'>You start unsecuring [wh.name] to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unsecure [wh.name] to [src]. </span>")
				state = 7
				update_icon()
			return TRUE
		if(9)
			to_chat(user, "<span class='notice'>You start closing the casing and securing [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You close the casing and secure [src]. </span>")
				state = 10
				update_icon()
			return TRUE
		if(10)
			to_chat(user, "<span class='notice'>You start unsecuring [src] and opening the casing...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unsecure [src] and open the casing. </span>")
				state = 9
				update_icon()
			return TRUE

/obj/structure/munition/torpedo_casing/screwdriver_act(mob/user, obj/item/tool)
	. = FALSE
	switch(state)
		if(3)
			to_chat(user, "<span class='notice'>You start securing [gs.name] to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You secure [gs.name] to [src]. </span>")
				state = 4
				update_icon()
			return TRUE
		if(4)
			to_chat(user, "<span class='notice'>You start unsecuring [gs.name] to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unsecure [gs.name] to [src]. </span>")
				state = 3
				update_icon()
			return TRUE
		if(5)
			to_chat(user, "<span class='notice'>You start securing [iff.name] to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You secure [iff.name] to [src]. </span>")
				state = 6
				update_icon()
			return TRUE
		if(6)
			to_chat(user, "<span class='notice'>You start unsecuring [iff.name] to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unsecure [iff.name] to [src]. </span>")
				state = 5
				update_icon()
			return TRUE

/obj/structure/munition/torpedo_casing/wirecutter_act(mob/user, obj/item/tool)
	. = ..()
	if(state == 9)
		to_chat(user, "<span class='notice'>You start cutting the wiring in [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You cut the wiring in [src].</span>")
			var/obj/item/stack/cable_coil/C = new (loc, 3)
			C.add_fingerprint(user)
			state = 8
			update_icon()
		return TRUE

/obj/structure/munition/torpedo_casing/welder_act(mob/user, obj/item/tool)
	. = FALSE
	switch(state)
		if(0)
			to_chat(user, "<span class='notice'>You start disassembling [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You disassmeble [src].</span>")
				var/obj/item/stack/sheet/metal/M = new (loc, 15)
				M.add_fingerprint(user)
				qdel(src)
			return TRUE
		if(10)
			to_chat(user, "<span class='notice'>You start sealing the casing on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'You seal the casing on [src].</span>")
				var/obj/structure/munition/bomb = new_torpedo(wh, gs, ps, iff)
				bomb.speed = ps.speed //Placeholder, but allows for faster torps if we ever add that
				qdel(src)
			return TRUE

/obj/structure/munition/torpedo_casing/crowbar_act(mob/user, obj/item/tool)
	. = FALSE
	switch(state)
		if(1)
			to_chat(user, "<span class='notice'>You start removing [ps.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [ps.name] from [src].</span>")
				ps = new (loc, 1)
				ps = null
				state = 0
				update_icon()
			return TRUE
		if(3)
			to_chat(user, "<span class='notice'>You start removing [gs.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [gs.name] from [src].</span>")
				gs = new (loc, 1)
				gs = null
				state = 2
				update_icon()
			return TRUE
		if(5)
			to_chat(user, "<span class='notice'>You start removing [iff.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [iff.name] from [src].</span>")
				iff = new (loc, 1)
				iff = null
				state = 4
				update_icon()
			return TRUE
		if(7)
			to_chat(user, "<span class='notice'>You start removing [wh.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [wh.name] from [src].</span>")
				wh = new (loc, 1)
				wh = null
				state = 6
				update_icon()
			return TRUE

/obj/structure/munition/torpedo_casing/update_icon()
	cut_overlays()
	switch(state)
		if(1)
			icon_state = "case_prop"
		if(2)
			icon_state = "case_prop_bolt"
		if(3)
			icon_state = "case_guide"
		if(4)
			icon_state = "case_guide_screw"
		if(5)
			icon_state = "case_iff"
		if(6)
			icon_state = "case_iff_screw"
		if(7)
			icon_state = "case_warhead"
		if(8)
			icon_state = "case_warhead_screw"
		if(9)
			icon_state = "case_warhead_wired"
		if(10)
			icon_state = "case_warhead_complete"

/obj/structure/munition/torpedo_casing/proc/new_torpedo(obj/item/torpedo/warhead, obj/item/torpedo/guidance_system, obj/item/torpedo/propulsion_system, obj/item/torpedo/iff_card)
	if(istype(warhead, /obj/item/torpedo/warhead))
		switch(warhead.type)
			if(/obj/item/torpedo/warhead)
				return new /obj/structure/munition(get_turf(src))
			if(/obj/item/torpedo/warhead/bunker_buster)
				return new /obj/structure/munition/hull_shredder(get_turf(src))
			if(/obj/item/torpedo/warhead/lightweight)
				return new /obj/structure/munition/fast(get_turf(src))
			if(/obj/item/torpedo/warhead/decoy)
				return new /obj/structure/munition/decoy(get_turf(src))
			if(/obj/item/torpedo/warhead/nuclear)
				return new /obj/structure/munition/nuke(get_turf(src))

/obj/item/torpedo/warhead
	name = "NTP-2 standard torpedo warhead"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "warhead"
	desc = "A heavy warhead designed to be fitted to a torpedo. It's currently inert."
	w_class = WEIGHT_CLASS_HUGE
	var/payload = null

/obj/item/torpedo/warhead/bunker_buster
	name = "NTP-4 'BNKR' torpedo warhead"
	desc = "a bunker buster torpedo warhead"
	icon_state = "warhead_shredder"
	desc = "An extremely heavy warhead designed to be fitted to a torpedo. This one has an inbuilt plasma charge to amplify its damage."

/obj/item/torpedo/warhead/lightweight
	name = "NTP-1 'SPD' lightweight torpedo warhead"
	desc = "a lightweight torpedo warhead"
	icon_state = "warhead_highvelocity"
	desc = "A stripped down warhead designed to be fitted to a torpedo. Due to its reduced weight, torpedoes with these equipped will travel more quickly."

/obj/item/torpedo/warhead/decoy
	name = "NTP-0x 'DCY' electronic countermeasure torpedo payload"
	desc = "a decoy torpedo warhead"
	icon_state = "warhead_decoy"
	desc = "A simple electronic countermeasure wrapped in a metal casing. While these form inert torpedoes, they can be used to distract enemy PDC emplacements to divert their flak away from other targets."

/obj/item/torpedo/warhead/nuclear
	name = "nuclear torpedo warhead"
	desc = "a nuclear torpedo warhead"
	icon_state = "warhead_nuclear"
	desc = "An advanced warhead which carries a nuclear fission explosive. Torpedoes equipped with these can quickly annihilate targets with extreme prejudice, however they are extremely costly to produce."

/obj/item/torpedo/guidance_system
	name = "torpedo guidance system"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "guidance"
	desc = "A guidance module for a torpedo which allows them to lock onto a target inside their operational range. The microcomputer inside it is capable of performing thousands of calculations a second."
	w_class = WEIGHT_CLASS_NORMAL
	var/accuracy = null

/obj/item/torpedo/propulsion_system
	name = "torpedo propulsion system"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "propulsion"
	desc = "A gimballed thruster with an attachment nozzle, designed to be mounted in torpedoes."
	w_class = WEIGHT_CLASS_BULKY
	var/speed = 1

/obj/item/torpedo/iff_card //This should be abuseable via emag
	name = "torpedo IFF card"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "iff"
	desc = "An IFF chip which allows a torpedo to distinguish friend from foe. The electronics contained herein are relatively simple, but they form a crucial part of any good torpedo."
	w_class = WEIGHT_CLASS_SMALL
	var/calibrated = FALSE

/obj/item/torpedo/iff_card/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	user.visible_message("<span class='warning'>[user] shorts out [src]!</span>",
						"<span class='notice'>You short out the IFF protocols on [src].</span>",
						"Bzzzt.")

/datum/techweb_node/basic_torpedo_components
	id = "basic_torpedo_components"
	display_name = "Basic Torpedo Components"
	description = "A how-to guide of fabricating torpedos while out in the depths of space."
	prereq_ids = list("explosive_weapons")
	design_ids = list("warhead", "bb_warhead", "lw_warhead", "decoy_warhead", "nuke_warhead", "guidance_system", "propulsion_system", "iff_card")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/design/warhead
	name = "Torpedo Warhead"
	desc = "The stock standard warhead design for torpedos"
	id = "warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/glass = 5000)
	build_path = /obj/item/torpedo/warhead
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/bb_warhead
	name = "Bunker Buster Torpedo Warhead"
	desc = "A bunker buster warhead design for torpedos"
	id = "bb_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/plasma = 5000, /datum/material/glass = 5000)
	build_path = /obj/item/torpedo/warhead/bunker_buster
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/lw_warhead
	name = "Lightweight Torpedo Warhead"
	desc = "A lightweight warhead design for torpedos"
	id = "lw_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500)
	build_path = /obj/item/torpedo/warhead/lightweight
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/decoy_warhead
	name = "Decoy Torpedo Warhead"
	desc = "A decoy warhead design for torpedos"
	id = "decoy_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000)
	build_path = /obj/item/torpedo/warhead/decoy
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/nuclear_warhead
	name = "Nuclear Torpedo Warhead"
	desc = "A nuclear warhead design for torpedos"
	id = "nuke_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/plasma = 10000, /datum/material/uranium = 5000)
	build_path = /obj/item/torpedo/warhead/nuclear
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/guidance_system
	name = "Torpedo Guidance System"
	desc = "The stock standard guidance system design for torpedos"
	id = "guidance_system"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000)
	build_path = /obj/item/torpedo/guidance_system
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/propulsion_system
	name = "Torpedo Propulsion System"
	desc = "The stock standard propulsion system design for torpedos"
	id = "propulsion_system"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000)
	build_path = /obj/item/torpedo/propulsion_system
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/iff_card
	name = "Torpedo IFF Card"
	desc = "The stock standard IFF card design for torpedos"
	id = "iff_card"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 20000, /datum/material/iron = 5000)
	build_path = /obj/item/torpedo/iff_card
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO