/obj/item/projectile/guided_munition
	var/clearance_time = 7 // Deciseconds to wait after windup
	var/valid_angle = 0 //Angle the projectile can track at
	var/shotdown_effect_type = /obj/effect/temp_visual/impact_effect/torpedo

//Hey look, all this logic doesn't work! I love finding these things.
/obj/item/projectile/guided_munition/process_homing(atom/A)
	. = ..()
	var/simplify_Angle = SIMPLIFY_DEGREES(Angle)
	var/simplify_targetAngle = SIMPLIFY_DEGREES(targetAngle) //<< This var is never actually modified because [local var] supercedes [obj var] unless src is used. Personally, I'm unsure if we actually WANT it fixed. ~Delta
	if(simplify_targetAngle > simplify_Angle + valid_angle)
		homing = FALSE
