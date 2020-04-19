/obj/item/projectile
	var/datum/shape/collider2d = null //Our box collider. See the collision module for explanation
	var/datum/vector2d/position = null //Positional vector, used exclusively for collisions with overmaps
	var/list/collision_positions = null //The bounding box of this projectile.

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
			if(src.collider2d.collides(OM.collider2d))
				if(!faction || faction != OM.faction) //Allow bullets to pass through friendlies
					Bump(OM) //Bang.