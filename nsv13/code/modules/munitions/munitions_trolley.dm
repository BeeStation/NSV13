/obj/structure/munitions_trolley
	name = "Munitions trolley"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "trolley"
	desc = "A large trolley designed for ferrying munitions around. It has slots for traditional ammo magazines as well as a rack for loading torpedoes. To load it, click and drag the desired munition onto the rack."
	anchored = FALSE
	density = TRUE
	layer = 3
	var/capacity = 0 //Current number of munitions we have loaded
	var/max_capacity = 6//Maximum number of munitions we can load at once
	var/loading = FALSE //stop you loading the same torp over and over

/obj/structure/munitions_trolley/Moved()
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, 1)

/obj/structure/munitions_trolley/AltClick(mob/user)
	. = ..()
	if(!in_range(src, usr))
		return
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

/obj/structure/munitions_trolley/Bumped(atom/movable/AM)
	. = ..()
	load_trolley(AM)

/obj/structure/munitions_trolley/MouseDrop_T(obj/structure/A, mob/user)
	. = ..()
	if(istype(A, /obj/item/ship_weapon/ammunition))
		if(loading)
			to_chat(user, "<span class='notice'>You're already loading something onto [src]!.</span>")
			return
		to_chat(user, "<span class='notice'>You start to load [A] onto [src]...</span>")
		loading = TRUE
		if(do_after(user,20, target = src))
			load_trolley(A, user)
			to_chat(user, "<span class='notice'>You load [A] onto [src].</span>")
		loading = FALSE

/obj/structure/munitions_trolley/proc/load_trolley(atom/movable/A, mob/user)
	if(capacity >= max_capacity)
		if(user)
			to_chat(user, "<span class='warning'>[src] is fully loaded!</span>")
		return FALSE
	if(istype(A, /obj/item/ship_weapon/ammunition))
		playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
		A.forceMove(src)
		A.pixel_y = 5+(capacity*5)
		vis_contents += A
		capacity ++
		A.layer = ABOVE_MOB_LAYER
		return

/obj/structure/munitions_trolley/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MunitionsTrolley")
		ui.open()

/obj/structure/munitions_trolley/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	var/obj/item/ship_weapon/ammunition/A = locate(params["id"])
	switch(action)
		if("unload")
			if(!A)
				return
			unload_munition(A)
		if("unload_all")
			for(var/atom/movable/AM in contents)
				unload_munition(AM)

/obj/structure/munitions_trolley/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	var/list/loaded = list()
	for(var/atom/movable/AS in contents)
		loaded[++loaded.len] = list("name"=AS.name, "id"="\ref[AS]")
	data["loaded"] = loaded
	return data

/obj/structure/munitions_trolley/proc/unload_munition(atom/movable/A)
	vis_contents -= A
	A.forceMove(get_turf(src))
	A.pixel_y = initial(A.pixel_y) //Remove our offset
	A.layer = initial(A.layer)
	if(usr)
		to_chat(usr, "<span class='notice'>You unload [A] from [src].</span>")
	playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	if(istype(A, /obj/item/ship_weapon/ammunition)) //If a munition, allow them to load other munitions onto us.
		capacity --
	if(contents.len)
		var/count = capacity
		for(var/X in contents)
			var/atom/movable/AM = X
			if(istype(AM, /obj/item/ship_weapon/ammunition))
				AM.pixel_y = count*5
				count --
