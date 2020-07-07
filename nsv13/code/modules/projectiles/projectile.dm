/obj/item/projectile
	var/datum/shape/collider2d = null //Our box collider. See the collision module for explanation
	var/datum/vector2d/position = null //Positional vector, used exclusively for collisions with overmaps
	var/list/collision_positions = null //The bounding box of this projectile.
	var/obj/structure/overmap/overmap_firer = null

/obj/item/projectile/proc/setup_collider()
	collision_positions = list(new /datum/vector2d(-2,16),\
										new /datum/vector2d(2,16),\
										new /datum/vector2d(2,-15),\
										new /datum/vector2d(-2,-15))
	position = new /datum/vector2d(x*32,y*32)
	collider2d = new /datum/shape(position, collision_positions, Angle) // -TORADIANS(src.angle-90)

/**

Method to check for whether this bullet should be colliding with an overmap object.


*/

/obj/item/projectile/proc/check_overmap_collisions()
	collider2d.set_angle(Angle) //Turn the box collider
	position._set(x * 32 + pixel_x, y * 32 + pixel_y)
	collider2d._set(position.x, position.y)
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.z == z && OM.collider2d)
			if(src.collider2d?.collides(OM.collider2d))
				if(!faction || faction != OM.faction) //Allow bullets to pass through friendlies
					var/datum/vector2d/point_of_collision = OM.collider2d.get_collision_point(src.collider2d)
					OM.check_quadrant(point_of_collision)
					Bump(OM) //Bang.


/obj/structure/overmap/proc/coll_test()
	new /obj/structure/overmap/syndicate/ai(get_turf(pick(orange(10, src))))

//Thank you once again to qwerty for writing the directional calc for this.
/obj/structure/overmap/proc/check_quadrant(datum/vector2d/point_of_collision)
	if(!point_of_collision)
		return
	var/datum/vector2d/diff = point_of_collision - position
	var/shield_angle_hit = SIMPLIFY_DEGREES(diff.angle()) - SIMPLIFY_DEGREES(angle)
	switch(SIMPLIFY_DEGREES(shield_angle_hit))
		if(0 to 89) //0 - 90 deg is the first right quarter of the circle, it's like dividing up a pizza!
			add_overlay(image(icon = icon, icon_state = "northeast", dir=SOUTH))
			return NORTHEAST
		if(90 to 179)
			add_overlay(image(icon = icon, icon_state = "southeast", dir=SOUTH))
			return SOUTHEAST
		if(180 to 269)
			add_overlay(image(icon = icon, icon_state = "southwest", dir=SOUTH))
			return SOUTHWEST
		if(270 to 360) //Then this represents the last quadrant of the circle, the northwest one
			add_overlay(image(icon = icon, icon_state = "northwest", dir=SOUTH))
			return NORTHWEST