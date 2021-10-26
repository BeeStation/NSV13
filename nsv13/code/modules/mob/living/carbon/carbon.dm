// harmlev -- value between 1-3, higher values have higher chances for extra something bad to happen.
// resides in it's own proc just in case we've already got a trait checked list
/mob/living/proc/gravity_crush(gravity, harmlev = 1)
	var/range
	var/Oloss = gravity * rand(1, 1.3)
	switch(harmlev)
		if(1) // high G (i.e hacked gravity generator)
			range = rand(1, 25)
		if(2) // Very high G (i.e fighter high G burns)
			range = rand(1, 16)
			Oloss *= 0.5
		if(3) // PREPARE SHIP FOR LUDICROUS SPEED
			range = rand(1, 13)
			losebreath += 0.3 * gravity
			adjustOrganLoss(ORGAN_SLOT_BRAIN, gravity)
			Oloss *= 2

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
			to_chat(src,  "<span class='danger'>You feel your diaphragm getting crushed under your own weight!</span>")
			adjustOrganLoss(ORGAN_SLOT_LUNGS, gravity * 2)
			losebreath++
		if(14 to 100)
			var/pslot = pick(ORGAN_SLOT_BRAIN, ORGAN_SLOT_STOMACH, ORGAN_SLOT_HEART, ORGAN_SLOT_LIVER, ORGAN_SLOT_EYES, ORGAN_SLOT_LUNGS)
			adjustOrganLoss(pslot, Oloss) // damage a random organ
			switch(range)
				if(15)
					to_chat(src, "<span class='warning'>You struggle to stay conscious!</span>")
				if(14)
					to_chat(src, "<span class='warning'>Your sight caves into a dark blur.</span>")
				if(16)
					to_chat(src, "<span class='danger'>You struggle to catch a breath.</span>")

/mob/living/carbon/handle_high_gravity(gravity)
	if(HAS_TRAIT(src, TRAIT_GFORCE_WEAKNESS))
		gravity_crush(gravity)
	..()
