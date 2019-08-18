/obj/structure/munition //CREDIT TO CM FOR THIS SPRITE
	name = "NTP-2 530mm torpedo"
	icon = 'sephora/icons/obj/munition_types.dmi'
	icon_state = "standard"
	desc = "A fairly standard torpedo which is designed to cause massive structural damage to a target. It is fitted with a basic homing mechanism to ensure it always hits the mark."
	anchored = TRUE
	density = TRUE
	var/torpedo_type = /obj/item/projectile/bullet/torpedo //What torpedo type we fire
	pixel_x = -17
	var/speed = 1 //Placeholder, allows upgrading speed with better propulsion

/obj/structure/munition/hull_shredder //High damage torp. Use this when youve exhausted their flak.
	name = "NTP-4 'BNKR' 430mm torpedo"
	icon = 'sephora/icons/obj/munition_types.dmi'
	icon_state = "hull_shredder"
	desc = "A heavy torpedo which is packed with a high energy plasma charge, allowing it to impact a target with massive force."
	torpedo_type = /obj/item/projectile/bullet/torpedo/shredder

/obj/structure/munition/fast //Gap closer, weaker but quick.
	name = "NTP-1 'SPD' 430mm high velocity torpedo"
	icon = 'sephora/icons/obj/munition_types.dmi'
	icon_state = "highvelocity"
	desc = "A small torpedo which is fitted with an advanced propulsion system, allowing it to rapidly travel long distances. Due to its smaller frame however, it packs less of a punch."
	torpedo_type = /obj/item/projectile/bullet/torpedo/fast

/obj/structure/munition/decoy //A dud missile designed to exhaust flak
	name = "NTP-0x 'DCY' 530mm electronic countermeasure"
	icon = 'sephora/icons/obj/munition_types.dmi'
	icon_state = "decoy"
	desc = "A simple electronic countermeasure packed inside a standard torpedo casing. This model excels at diverting enemy PDC emplacements away from friendly ships, or even another barrage of missiles."
	torpedo_type = /obj/item/projectile/bullet/torpedo/decoy

/obj/structure/munition/nuke //The alpha torpedo
	name = "NTNK 'Oncoming Storm' 700mm thermonuclear warhead"
	icon = 'sephora/icons/obj/munition_types.dmi'
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
	icon = 'sephora/icons/obj/munitions.dmi'
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
	playsound(src, 'sephora/sound/effects/ship/mac_load.ogg', 100, 1)
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
	icon = 'sephora/icons/obj/railgun.dmi'
	icon_state = "OBC"
	density = TRUE
	anchored = TRUE
	bound_width = 128
	bound_height = 64
	pixel_y = -64
	layer = BELOW_OBJ_LAYER
	var/fire_sound = 'sephora/sound/effects/ship/mac_fire.ogg'
	var/load_sound = 'sephora/sound/effects/ship/reload.ogg'
	var/safety = TRUE //Can only fire when safeties are off
	var/loading = FALSE
	var/obj/structure/munition/preload = null
	var/obj/structure/munition/loaded = null
	var/obj/structure/munition/chambered = null
	var/obj/structure/overmap/linked = null
	var/firing = FALSE //If firing, disallow unloading.

/obj/structure/ship_weapon/Initialize()
	. = ..()
	get_ship()

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
	icon = 'sephora/icons/obj/railgun.dmi'
	icon_state = "torpedo"
	bound_height = 32
	bound_width = 96
	pixel_y = -72
	pixel_x = -32
	fire_sound = 'sephora/sound/effects/ship/plasma.ogg'
	load_sound = 'sephora/sound/effects/ship/freespace2/m_load.wav'

/obj/structure/ship_weapon_computer
	name = "munitions control computer"
	icon = 'sephora/icons/obj/munitions.dmi'
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
				playsound(src, 'sephora/sound/effects/ship/mac_load.ogg', 100, 1)
				preload = A
			loading = FALSE
		else
			to_chat(user, "<span class='warning'>[src] already has a round loaded!</span>")

/obj/structure/ship_weapon/proc/load()
	if(!preload || loaded)
		return
	flick("[initial(icon_state)]_loading",src)
	playsound(src, 'sephora/sound/effects/ship/freespace2/crane_short.ogg', 100, 1)
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
	playsound(src, 'sephora/sound/effects/ship/freespace2/crane_short.ogg', 100, 1)
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
	playsound(src, 'sephora/sound/weapons/railgun/ready.ogg', 100, 1)

/obj/structure/ship_weapon/proc/fire()
	if(!chambered || safety || firing)
		return
	var/proj_type
	if(istype(chambered, /obj/structure/munition))
		proj_type = chambered.torpedo_type
	if(istype(chambered, /obj/item/twohanded/required/railgun_ammo))
		var/obj/item/twohanded/required/railgun_ammo/RA = chambered
		proj_type = RA.proj_type
	firing = TRUE
	flick("[initial(icon_state)]_firing",src)
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
	if(proj_type) //Looks like we were able to fire a projectile, let's tell the ship what kind of bullet to shoot.
		return proj_type

/obj/structure/ship_weapon/railgun
	name = "NT-STC4 Ship mounted railgun chamber"
	desc = "A powerful ship-to-ship weapon which uses a localized magnetic field accelerate a projectile through a spinally mounted railgun with a 360 degree rotation axis. This particular model has an effective range of 20,000KM."
	icon = 'sephora/icons/obj/railgun.dmi'
	icon_state = "OBC"

/obj/structure/ship_weapon/railgun/MouseDrop_T(obj/structure/A, mob/user)
	return

/obj/item/twohanded/required/railgun_ammo //The big slugs that you load into the railgun. These are able to be carried...one at a time
	name = "M4 NTRS '30mm' teflon coated tungsten round"
	desc = "A gigantic slug that's designed to be fired out of a railgun. It's extremely heavy, but doesn't actually contain any volatile components, so it's safe to manhandle."
	icon_state = "railgun_ammo"
	lefthand_file = 'sephora/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'sephora/icons/mob/inhands/weapons/bombs_righthand.dmi'
	icon = 'sephora/icons/obj/munitions.dmi'
	w_class = 4
	var/proj_type = /obj/item/projectile/bullet/railgun_slug

/obj/structure/ship_weapon/railgun/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/twohanded/required/railgun_ammo))
		if(loading)
			to_chat(user, "<span class='notice'>You're already loading a round into [src]!.</span>")
			return
		if(!preload && !loaded && !chambered)
			to_chat(user, "<span class='notice'>You start to load [I] into [src]...</span>")
			loading = TRUE
			if(do_after(user,20, target = src))
				to_chat(user, "<span class='notice'>You load [I] into [src].</span>")
				loading = FALSE
				I.forceMove(src)
				playsound(src, 'sephora/sound/effects/ship/mac_load.ogg', 100, 1)
				preload = I
				return FALSE
			loading = FALSE
		else
			to_chat(user, "<span class='warning'>[src] already has a round loaded!</span>")
	. = ..()