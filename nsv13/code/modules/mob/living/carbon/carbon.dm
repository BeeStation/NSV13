// harmlev -- value between 1-3, higher values have higher chances for something bad to happened.
// resides in it's own proc just in case we've already got a trait checked list
/mob/living/proc/gravity_crush(gravity, harmlev = 1)
	var/range
	switch(harmlev)
		if(1) // high G (i.e hacked gravity generator)
			range = rand(1, 25)
		if(2) // Very high G (i.e fighter high G burns)
			range = rand(1, 16)
			adjustBruteLoss(gravity / 2)
		if(3) // PREPARE SHIP FOR LUDICROUS SPEED
			range = rand(1, 12)
			losebreath += 0.3 * gravity
			adjustBruteLoss(gravity * 2)
	switch(range)
		if(1 to 2)
			losebreath += 0.8 + gravity/3
		if(3 to 4)
			Sleeping(10 + losebreath * 3)
		if(5 to 7)
			if(!IsKnockdown())
				Knockdown(gravity * 5)
		if(8 to 9)
			adjust_blurriness(gravity)
		if(10)
			adjustOrganLoss(ORGAN_SLOT_BRAIN, gravity * 2)
		if(11 to 12)
			to_chat(src, "<span class='danger'>Your whole body aches.</span>")
			adjustOrganLoss(ORGAN_SLOT_HEART, gravity * 2)
		if(13)
			to_chat(src, "<span class='warning'>Everything caves into a dark blur.</span>")
		if(14)
			to_chat(src,  "<span class='danger'>You feel your diaphragm getting crushed under your own weight.</span>")
			losebreath++
		if(15)
			to_chat(src, "<span class='warning'>You struggle to stay conscious!</span>")
		if(16)
			to_chat(src, "<span class='danger'>You struggle to catch a breath.</span>")


/mob/living/carbon/handle_high_gravity(gravity)
	if(HAS_TRAIT(src, TRAIT_GFORCE_WEAKNESS))
		gravity_crush(gravity)
	..()
