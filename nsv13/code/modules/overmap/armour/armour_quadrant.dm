/obj/structure/overmap/proc/coll_test()
	new /obj/structure/overmap/syndicate/ai(get_turf(pick(orange(10, src))))

//Thank you once again to qwerty for writing the directional calc for this.
/obj/structure/overmap/proc/check_quadrant(datum/vector2d/point_of_collision)
	if(!point_of_collision)
		return
	var/datum/vector2d/diff = point_of_collision - position
	diff.x /= 32 //Scale it down so that the math isn't off.
	diff.y /= 32
	var/shield_angle_hit = SIMPLIFY_DEGREES(diff.angle() - angle)
	switch(shield_angle_hit)
		if(0 to 89) //0 - 90 deg is the first right quarter of the circle, it's like dividing up a pizza!
			return ARMOUR_FORWARD_PORT
		if(90 to 179)
			return ARMOUR_AFT_PORT
		if(180 to 269)
			return ARMOUR_AFT_STARBOARD
		if(270 to 360) //Then this represents the last quadrant of the circle, the northwest one
			return ARMOUR_FORWARD_STARBOARD

/* UNUSED
/obj/screen/alert/overmap_integrity
	name = "Ship integrity"
	icon = 'nsv13/icons/overmap/armour_quadrants.dmi'
	icon_state = "base"
*/

#define ARMOUR_DING pick('nsv13/sound/effects/ship/freespace2/ding1.wav', 'nsv13/sound/effects/ship/freespace2/ding2.wav', 'nsv13/sound/effects/ship/freespace2/ding3.wav', 'nsv13/sound/effects/ship/freespace2/ding4.wav', 'nsv13/sound/effects/ship/freespace2/ding5.wav')

/obj/structure/overmap/proc/take_quadrant_hit(damage, quadrant)
	if(!quadrant)
		return //No.
	if(!armour_quadrants[quadrant])
		return //Nonexistent quadrant. Work on your quads bro.
	var/list/quad = armour_quadrants[quadrant] //Should be a string define in format. Get the quadrant that we seek.
	//Time for some witchcraft that I stole from obj_defense.dm
	var/delta = damage-quad["current_armour"]
	quad["current_armour"] = max(quad["current_armour"] - damage, 0)
	if(delta <= 0) //Woo! We absorbed the hit fully.
		relay(ARMOUR_DING)
		if(!impact_sound_cooldown)
			if(damage >= 15) //Flak begone
				shake_everyone(5)
			impact_sound_cooldown = TRUE
			addtimer(VARSET_CALLBACK(src, impact_sound_cooldown, FALSE), 0.35 SECONDS)
	else //Yikes, we didn't absorb it fully. Take it as superstructural damage.
		take_damage(delta)
	update_quadrants()

/obj/structure/overmap/proc/test()
	var/list/L = armour_quadrants[ARMOUR_FORWARD_PORT]
	L["current_armour"] = 0
	update_quadrants()

/obj/structure/overmap/proc/update_quadrants()
	for(var/X in armour_quadrants)
		var/list/L = armour_quadrants[X]
		if(!islist(L))
			continue
		cut_overlay(L["name"])
		if(L["current_armour"] <= L["max_armour"]/10) //Very close to buckling
			add_overlay(L["name"])

#undef ARMOUR_DING

//Repair Procs

/obj/structure/overmap/proc/full_repair() //Admin Override
	obj_integrity = max_integrity //Full structural integrity
	if(structure_crit) //Cancel SScrit if we are in it
		stop_relay(channel=CHANNEL_SHIP_FX)
		priority_announce("Ship structural integrity restored to acceptable levels. ","Automated announcement ([src])")
		structure_crit = FALSE
		structure_crit_no_return = FALSE //Even override this
	if(use_armour_quadrants) //Full armour plates
		armour_quadrants["forward_port"]["current_armour"] = armour_quadrants["forward_port"]["max_armour"]
		armour_quadrants["forward_starboard"]["current_armour"] = armour_quadrants["forward_starboard"]["max_armour"]
		armour_quadrants["aft_port"]["current_armour"] = armour_quadrants["aft_port"]["max_armour"]
		armour_quadrants["aft_starboard"]["current_armour"] = armour_quadrants["aft_starboard"]["max_armour"]

/obj/structure/overmap/proc/repair_structure(var/input, var/failure = 0) //Input is the amount you want repaired per call of this proc, failure is the chance the repair will go wrong
	var/percentile = input / 100

	if(prob(failure)) //Botched repairs end up in Z-level damage
		var/name = pick(GLOB.teleportlocs)
		var/area/target = GLOB.teleportlocs[name]
		var/turf/T = pick(get_area_turfs(target))
		new /obj/effect/temp_visual/explosion_telegraph(T)
		return

	obj_integrity += max_integrity * percentile
	if(obj_integrity > max_integrity)
		obj_integrity = max_integrity
	if(structure_crit) //Check for structural crit
		if(obj_integrity >= max_integrity * 0.2) //End structural crit if high enough
			stop_relay(channel=CHANNEL_SHIP_FX)
			priority_announce("Ship structural integrity restored to acceptable levels. ","Automated announcement ([src])")
			structure_crit = FALSE

/obj/structure/overmap/proc/repair_quadrant(var/input, var/failure = 0, var/bias = 50, var/quadrant) //Input is the amount you want repaired per call of this proc, failure is the chance the repair will go wrong, bias is the favour for structure damage vs armour damage
	var/percentile = input / 100
	if(use_armour_quadrants)
		if(prob(failure))
			if(prob(bias)) //Botched repairs end up in either structural damage or armour damage
				var/misrepair_amount = max_integrity * percentile
				if(obj_integrity - misrepair_amount < 10)
					obj_integrity = 10
					handle_crit(misrepair_amount)
				else
					obj_integrity -= max_integrity * percentile
				return
			else
				var/misrepair_quadrant = pick("forward_port", "forward_starboard", "aft_port", "aft_starboard")
				armour_quadrants[misrepair_quadrant]["current_armour"] -= armour_quadrants[misrepair_quadrant]["max_armour"] * percentile
				if(armour_quadrants[misrepair_quadrant]["current_armour"] < 0)
					armour_quadrants[misrepair_quadrant]["current_armour"] = 0

		armour_quadrants[quadrant]["current_armour"] += armour_quadrants[quadrant]["max_armour"] * percentile
		if(armour_quadrants[quadrant]["current_armour"] > armour_quadrants[quadrant]["max_armour"])
			armour_quadrants[quadrant]["current_armour"] = armour_quadrants[quadrant]["max_armour"]

/obj/structure/overmap/proc/repair_all_quadrants(var/input, var/failure = 0, var/bias = 50) //Input is the amount you want repaired per call of this proc, failure is the chance the repair will go wrong, bias is the favour for structure damage vs armour damage
	var/percentile = input / 100
	if(use_armour_quadrants)
		var/list/quadrant_list = list("forward_port", "forward_starboard", "aft_port", "aft_starboard")
		if(prob(failure))
			if(prob(bias)) //Botched repairs end up in either structural damage or armour damage
				var/misrepair_amount = max_integrity * percentile
				if(obj_integrity - misrepair_amount < 10)
					obj_integrity = 10
					handle_crit(misrepair_amount)
				else
					obj_integrity -= max_integrity * percentile
				return
			else
				var/misrepair = pick_n_take(quadrant_list)
				armour_quadrants[misrepair]["current_armour"] -= armour_quadrants[misrepair]["max_armour"] * percentile
				if(armour_quadrants[misrepair]["current_armour"] < 0)
					armour_quadrants[misrepair]["current_armour"] = 0

		for(var/quad in quadrant_list)
			armour_quadrants[quad]["current_armour"] += armour_quadrants[quad]["max_armour"] * percentile
			if(armour_quadrants[quad]["current_armour"] > armour_quadrants[quad]["max_armour"])
				armour_quadrants[quad]["current_armour"] = armour_quadrants[quad]["max_armour"]

#define VV_HK_FULL_REPAIR "FullRepair"

/obj/structure/overmap/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_FULL_REPAIR, "Full Repair")

/obj/structure/overmap/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_FULL_REPAIR])
		if(!check_rights(R_DEBUG)) //Hmm?
			return
		full_repair()
		message_admins("Admin [key_name_admin(usr)] has fully repaired [src].")
