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
			add_overlay(image(icon = icon, icon_state = "northeast", dir=SOUTH))
			return ARMOUR_FORWARD_PORT
		if(90 to 179)
			add_overlay(image(icon = icon, icon_state = "southeast", dir=SOUTH))
			return ARMOUR_AFT_PORT
		if(180 to 269)
			add_overlay(image(icon = icon, icon_state = "southwest", dir=SOUTH))
			return ARMOUR_AFT_STARBOARD
		if(270 to 360) //Then this represents the last quadrant of the circle, the northwest one
			add_overlay(image(icon = icon, icon_state = "northwest", dir=SOUTH))
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