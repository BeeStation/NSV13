#define MS_CLOSED 		0
#define MS_UNSECURE 	1
#define MS_OPEN	 		2

//Fighter

/obj/structure/overmap/fighter
	name = "Fighter"
	desc = "A space faring fighter craft."
	icon = 'nsv13/icons/overmap/nanotrasen/fighter.dmi'
	icon_state = "fighter-100"
	brakes = TRUE
	armor = list("melee" = 80, "bullet" = 80, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 80) //temp to stop easy destruction from small arms
	bound_width = 96 //Change this on a per ship basis
	bound_height = 96
	mass = MASS_TINY
	sprite_size = 32
	damage_states = TRUE
	var/maint_state = MS_CLOSED
	var/piloted = FALSE
	var/a_eff = 0
	var/f_eff = 0

/obj/structure/overmap/fighter/prebuilt
	var/list/components = list(/obj/item/twohanded/required/fighter_component/empennage,
								/obj/item/twohanded/required/fighter_component/wing,
								/obj/item/twohanded/required/fighter_component/wing,
								/obj/item/twohanded/required/fighter_component/landing_gear,
								/obj/item/twohanded/required/fighter_component/cockpit,
								/obj/item/twohanded/required/fighter_component/armour_plating,
								/obj/item/twohanded/required/fighter_component/fuel_tank,
								/obj/item/fighter_component/avionics,
								/obj/item/fighter_component/fuel_lines,
								/obj/item/fighter_component/targeting_sensor,
								/obj/item/twohanded/required/fighter_component/engine,
								/obj/item/twohanded/required/fighter_component/engine,
								/obj/structure/munition/fast,
								/obj/structure/munition/fast,
								/obj/item/twohanded/required/fighter_component/primary_cannon)

/obj/structure/overmap/fighter/Initialize()
	.=..()
	update_stats()
	fuel_setup()
	obj_integrity = max_integrity

/obj/structure/overmap/fighter/prebuilt/Initialize()
	.=..()
	name = new_station_name() //temp - replace this with a fighter name list
	for(var/item in components)
		new item(src)

/obj/structure/overmap/fighter/proc/update_stats() //PLACEHOLDER JANK SYSTEM
	var/obj/item/twohanded/required/fighter_component/armour_plating/sap = get_part(/obj/item/twohanded/required/fighter_component/armour_plating)
	var/obj/item/fighter_component/targeting_sensor/sts = get_part(/obj/item/fighter_component/targeting_sensor)
	var/obj/item/fighter_component/fuel_lines/sfl = get_part(/obj/item/fighter_component/fuel_lines)
	var/senc = 0
	var/sens = 0
	var/sene = 0
	for(var/obj/item/twohanded/required/fighter_component/engine/sen in contents)
		senc++
		sens = sens + sen.speed
		sene = sene + sen.consumption
	sens = sens / senc
	sene = sene / senc
	f_eff = sene + sfl.fuel_efficiency / 2
	a_eff = sts.weapon_efficiency
	max_integrity = 100 * sap.armour

/obj/structure/overmap/fighter/proc/fuel_setup()
	qdel(reagents)
	var/obj/item/twohanded/required/fighter_component/fuel_tank/sft = get_part(/obj/item/twohanded/required/fighter_component/fuel_tank)
	create_reagents(sft.capacity)

/obj/structure/overmap/fighter/slowprocess()

//Fighter Maintenance
/obj/structure/overmap/fighter/proc/get_part(type)
	if(!type)
		return
	var/atom/movable/desired = locate(type) in contents
	return desired

/obj/structure/overmap/fighter/wrench_act(mob/user, obj/item/tool) //opening hatch p1
	. = FALSE
	if(maint_state == MS_CLOSED && piloted == TRUE)
		to_chat(user, "<span class='warning'>You cannot start maintenance while a pilot is in [src]!</span>")
		return TRUE
	else if(maint_state == MS_CLOSED && piloted == FALSE)
		to_chat(user, "<span class='notice'>You start unsecuring the maintenance hatch on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You unsecure the maintenance hatch on [src].</span>")
			maint_state = MS_UNSECURE
			return TRUE
	else if(maint_state == MS_UNSECURE)
		to_chat(user, "<span class='notice'>You start securing the maintenance hatch on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You secure the maintenance hatch on [src].</span>")
			maint_state = MS_CLOSED
			return TRUE

/obj/structure/overmap/fighter/crowbar_act(mob/user, obj/item/tool) //opening hatch p2
	. = FALSE
	switch(maint_state)
		if(MS_UNSECURE)
			to_chat(user, "<span class='notice'>You start pry open the maintenance hatch on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You pry open the maintenance hatch on [src].</span>")
				maint_state = MS_OPEN
				return TRUE
		if(MS_OPEN)
			to_chat(user, "<span class='notice'>You start replace the maintenance hatch on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You replace the maintenance hatch on [src].</span>")
				maint_state = MS_UNSECURE
				return TRUE

/obj/structure/overmap/fighter/welder_act(mob/user, obj/item/tool)
	. = FALSE
	if(obj_integrity/max_integrity*100 >= 100 && user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='notice'>[src] isn't in need of repairs.</span>")
		return TRUE
	else if(maint_state != MS_OPEN && obj_integrity/max_integrity*100 >= 51 && user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='notice'>You start welding some dents out of [src]'s hull...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You weld some dents out of [src]'s hull.</span>")
			obj_integrity += min(10, max_integrity-obj_integrity)
			if(obj_integrity == max_integrity)
				to_chat(user, "<span class='notice'>[src] is fully repaired.</span>")
			return TRUE
	else if(maint_state == MS_OPEN && obj_integrity/max_integrity*100 >= 51 && user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='notice'>You need to close [src]'s maintenance panel to begin hull repairs.</span>")
		return TRUE
	else if(maint_state == MS_OPEN && obj_integrity/max_integrity*100 <= 50 && user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='notice'>You start repairing the inner components of [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You repair the inner components of [src].</span>")
			obj_integrity += min(10, max_integrity-obj_integrity)
			if(obj_integrity == max_integrity)
				to_chat(user, "<span class='notice'>[src]'s inner components are fully repaired.</span>")
			return TRUE
	else if(maint_state == MS_OPEN && obj_integrity/max_integrity*100 <= 50 && user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='notice'>You open the maintenance panel to repair the inner components of [src].</span>")
		return TRUE


/obj/structure/overmap/fighter/MouseDrop_T(obj/structure/A, mob/user)
	. = ..()
	if(istype(A, /obj/structure/munition))
		switch(maint_state)
			if(!MS_OPEN)
				to_chat(user, "<span class='notice'>You require [src] to be in maintenance mode to load munitions!.</span>")
				return
			if(MS_OPEN)
				var/tp = 0
				for(var/obj/structure/munition/mu in contents)
					tp++
				if(tp < 2)
					to_chat(user, "<span class='notice'>You start adding [A] to [src]...</span>")
					if(!do_after(user, 2 SECONDS, target=src))
						return
					to_chat(user, "<span class='notice'>You add [A] to [src].</span>")
					A.forceMove(src)
					playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)  //placeholder

/obj/structure/overmap/fighter/attackby(obj/item/W, mob/user, params)   //fueling and changing equipment
	add_fingerprint(user)
	if(maint_state == MS_OPEN)
		if(istype(W, /obj/item/fighter_component/fuel_lines) && !get_part(/obj/item/fighter_component/fuel_lines))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			update_stats()
		else if(istype(W, /obj/item/twohanded/required/fighter_component/fuel_tank) && !get_part(/obj/item/twohanded/required/fighter_component/fuel_tank))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			fuel_setup()
		else if(istype(W, /obj/item/fighter_component/targeting_sensor) && !get_part(/obj/item/fighter_component/targeting_sensor))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			update_stats()
		else if(istype(W, /obj/item/twohanded/required/fighter_component/armour_plating) && !get_part(/obj/item/twohanded/required/fighter_component/armour_plating))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			update_stats()
		else if(istype(W, /obj/item/twohanded/required/fighter_component/engine))
			var/e = 0
			for(var/obj/item/twohanded/required/fighter_component/engine/en in contents)
				e++
			if(e < 2)
				to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
				if(!do_after(user, 2 SECONDS, target=src))
					return
				to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
				W.forceMove(src)
				update_stats()
		else if(istype(W, /obj/item/reagent_containers))
			var/obj/item/reagent_containers/R = W
			if(is_refillable())
				R.reagents.trans_to(src, R.amount_per_transfer_from_this, transfered_by = user)
				to_chat(user, "<span class='notice'>You refuel [src] with [W].</span>")

/obj/structure/overmap/fighter/attack_hand(mob/user)
	.=..()
	if(maint_state == MS_OPEN)
		user.set_machine(src)
		var/dat
		dat += "<h2> Overview: </h2>"
//hp, fuel etc go here
		dat += "<p>Structural Integrity: [obj_integrity/max_integrity*(100)]%</p>"
		dat += "<p>Fuel Capacity: [reagents.total_volume/reagents.maximum_volume*(100)]%</p>"
		dat += "<h2> Payload: </h2>"
//Guns, ammo and torpedos
		var/atom/movable/pw = get_part(/obj/item/twohanded/required/fighter_component/primary_cannon)
		if(pw == null)
			dat += "<p><b>PRIMARY WEAPON NOT INSTALLED</font></p>"
		else
			dat += "<a href='?src=[REF(src)]:primary_weapon=1'>[pw?.name]</a><br>"
		dat += "<p>Ammo Capacity:</p>"
		var/t = 0
		for(var/obj/structure/munition/mu in contents)
			dat += "<a href='?src=[REF(src)];torpedo=1'>[mu?.name]</a><br>"
			t++
		switch(t)
			if(1)
				dat += "<p><b>ONE TORPEDO PYLON EMPTY</font></p>"
			if(0)
				dat += "<p><b>TWO TORPEDO PYLONS EMPTY</font></p>"
		dat += "<h2> Components: </h2>"
		var/atom/movable/ap = get_part(/obj/item/twohanded/required/fighter_component/armour_plating)
		if(ap == null)
			dat += "<p><b>ARMOUR PLATING NOT INSTALLED</font></p>"
		else
			dat += "<a href='?src=[REF(src)];armour_plating=1'>[ap?.name]</a><br>"
		var/atom/movable/ft = get_part(/obj/item/twohanded/required/fighter_component/fuel_tank)
		if(ft == null)
			dat += "<p><b>FUEL TANK NOT INSTALLED</font></p>"
		else
			dat += "<a href='?src=[REF(src)];fuel_tank=1'>[ft?.name]</a><br>"
		var/atom/movable/fl = get_part(/obj/item/fighter_component/fuel_lines)
		if(fl == null)
			dat += "<p><b>FUEL LINES NOT INSTALLED</font></p>"
		else
			dat += "<a href='?src=[REF(src)];fuel_lines=1'>[fl?.name]</a><br>"
		var/atom/movable/ts = get_part(/obj/item/fighter_component/targeting_sensor)
		if(ts == null)
			dat += "<p><b>TARGETING SENSOR NOT INSTALLED</font></p>"
		else
			dat += "<a href='?src=[REF(src)];targeting_sensor=1'>[ts?.name]</a><br>"
		var/e = 0
		for(var/obj/item/twohanded/required/fighter_component/engine/en in contents)
			dat += "<a href='?src=[REF(src)];engine=1'>[en?.name]</a><br>"
			e++
		switch(e)
			if(1)
				dat += "<p><b>ONE ENGINE NOT INSTALLED</font></p>"
			if(0)
				dat += "<p><b>TWO ENGINES NOT INSTALLED</font></p>"
		var/datum/browser/popup = new(user, "fighter", name, 400, 600)
		popup.set_content(dat)
		popup.open()
		return TRUE
	else if(maint_state != MS_OPEN && !pilot) //temp behaviour - button will break control of fighter
		if(alert(user, "Climb into [src]'s cockpit?",, "Yes", "No")!="Yes")
			return
		to_chat(user, "<span class='notice'>You begin climbing into [src]'s cockpit...</span>")
		if(!do_after(user, 5 SECONDS, target=src))
			return
		to_chat(user, "<span class='notice'>You climb into [src]'s cockpit.</span>")
		user.forceMove(src)
		piloted = TRUE
		start_piloting(user, "pilot")
		return TRUE
	else if(maint_state == !MS_OPEN && piloted == TRUE)  //temp behaviour - rework this
		if(alert(user, "Climb out of [src]'s cockpit?",, "Yes", "No")!="Yes")
			return
		to_chat(user, "<span class='notice'>You begin climbing out of [src]'s cockpit...</span>")
		if(!do_after(user, 5 SECONDS, target=src))
			return
		to_chat(user, "<span class='notice'>You climb out of [src]'s cockpit.</span>")
		user.forceMove(loc)
		piloted = FALSE
		stop_piloting(user)

/obj/structure/overmap/fighter/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr
	var/atom/movable/ap = get_part(/obj/item/twohanded/required/fighter_component/armour_plating)
	var/atom/movable/ft = get_part(/obj/item/twohanded/required/fighter_component/fuel_tank)
	var/atom/movable/fl = get_part(/obj/item/fighter_component/fuel_lines)
	var/atom/movable/ts = get_part(/obj/item/fighter_component/targeting_sensor)
	var/atom/movable/en = get_part(/obj/item/twohanded/required/fighter_component/engine)
	var/atom/movable/pw = get_part(/obj/item/twohanded/required/fighter_component/primary_cannon)
	var/atom/movable/tr = get_part(/obj/structure/munition)
	if(href_list["armour_plating"])
		if(ap)
			to_chat(user, "<span class='notice'>You start uninstalling [ap.name] from [src].</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You uninstall [ap.name] from [src].</span>")
			ap?.forceMove(get_turf(src))
			update_stats()
	if(href_list["fuel_tank"])
		if(ft)
			to_chat(user, "<span class='notice'>You start uninstalling [ft.name] from [src].</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You uninstall [ft.name] from [src].</span>")
			ft?.forceMove(get_turf(src))
			update_stats()
	if(href_list["fuel_lines"])
		if(fl)
			to_chat(user, "<span class='notice'>You start uninstalling [fl.name] from [src].</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You uninstall [fl.name] from [src].</span>")
			fl?.forceMove(get_turf(src))
			update_stats()
	if(href_list["targeting_sensor"])
		if(ts)
			to_chat(user, "<span class='notice'>You start uninstalling [ts.name] from [src].</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You uninstall [ts.name] from [src].</span>")
			ts?.forceMove(get_turf(src))
			update_stats()
	if(href_list["engine"])
		if(en)
			to_chat(user, "<span class='notice'>You start uninstalling [en.name] from [src].</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You uninstall [en.name] from [src].</span>")
			en?.forceMove(get_turf(src))
			update_stats()
	if(href_list["primary_weapon"])
		if(pw)
			to_chat(user, "<span class='notice'>You start uninstalling [pw.name] from [src].</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You uninstall [pw.name] from [src].</span>")
			pw?.forceMove(get_turf(src))
			update_stats()
	if(href_list["torpedo"])
		if(tr)
			to_chat(user, "<span class='notice'>You start uninstalling [tr.name] from [src].</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You uninstall [tr.name] from [src].</span>")
			tr?.forceMove(get_turf(src))

/obj/structure/overmap/fighter/on_reagent_change()
	if(reagents.has_reagent(!/datum/reagent/plasma_spiked_fuel))
		visible_message("<span class=warning>Warning: contaminant detected in fuel mix, dumping tank contents.</span>")
		reagents.clear_reagents()
		new /obj/effect/decal/cleanable/oil(src)

/obj/structure/overmap/fighter/Destroy() //incomplete
	.=..()
	visible_message("<span class=userdanger>EJECT! EJECT! EJECT!</span>")
	playsound(src, 'sound/effects/alert.ogg', 100, TRUE)
	var/obj/structure/overmap/escapepod/ep = new /obj/structure/overmap/escapepod (loc, 1)
	var/atom/movable/hu = get_part(/mob/living/carbon/human)
	hu.forceMove(ep)
	visible_message("<span class=userdanger>Auto-Ejection Sequence Enabled! Escape Pod Launched!</span>")
	qdel(src)

/obj/structure/overmap/escapepod
	name = "Escape Pod"
	desc = "An escape pod launched from a space faring vessel."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "smmop"

#undef MS_CLOSED
#undef MS_UNSECURE
#undef MS_OPEN
