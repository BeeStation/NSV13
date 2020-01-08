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