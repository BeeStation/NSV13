/obj/item/projectile/missile
	var/valid_angle = 0
	var/maximum_speed = 0
	var/acceleration_rate = 0
	var/shotdown_effect_type = /obj/effect/temp_visual/impact_effect/torpedo

/obj/item/projectile/missile/process_homing(atom/A)
	.=..()
	var/simplify_Angle = SIMPLIFY_DEGREES(Angle)
	var/simplify_targetAngle = SIMPLIFY_DEGREES(targetAngle)
	message_admins("Angle: [Angle], simplify_Angle: [simplify_Angle], targetAngle: [targetAngle], simplify_targetAngle: [simplify_targetAngle]")
	var/target_bearing = SIMPLIFY_DEGREES(Angle) - SIMPLIFY_DEGREES(targetAngle)
	if(target_bearing > valid_angle)
		homing = FALSE
		message_admins("Target Bearing: [target_bearing], Valid Angle: [valid_angle], Lock Broken")

/*
/obj/item/projectile/missile/process()
	.=..()
	if(range % 10 == 0)
		if(speed <= maximum_speed)
			var/new_speed = speed + acceleration_rate
			set_pixel_speed(new_speed)
*/