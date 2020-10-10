/obj/item/projectile/guided_munition
	var/valid_angle = 0 //Angle the projectile can track at
	var/shotdown_effect_type = /obj/effect/temp_visual/impact_effect/torpedo

/obj/item/projectile/guided_munition/process_homing(atom/A)
	.=..()
	var/simplify_Angle = SIMPLIFY_DEGREES(Angle)
	var/simplify_targetAngle = SIMPLIFY_DEGREES(targetAngle)
	if(simplify_targetAngle > simplify_Angle + valid_angle)
		homing = FALSE