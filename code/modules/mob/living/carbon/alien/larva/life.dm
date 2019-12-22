

/mob/living/carbon/alien/larva/Life()
	set invisibility = 0
	if (notransform)
		return
<<<<<<< HEAD
	if(..() && !IsInStasis()) //not dead and not in stasis
=======
	if(..() && !IS_IN_STASIS(src)) //not dead and not in stasis
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
		// GROW!
		if(amount_grown < max_grown)
			amount_grown++
			update_icons()


/mob/living/carbon/alien/larva/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health<= -maxHealth || !getorgan(/obj/item/organ/brain))
			death()
			return
		if(IsUnconscious() || IsSleeping() || getOxyLoss() > 50 || (HAS_TRAIT(src, TRAIT_DEATHCOMA)) || health <= crit_threshold)
			if(stat == CONSCIOUS)
				stat = UNCONSCIOUS
				blind_eyes(1)
				update_mobility()
		else
			if(stat == UNCONSCIOUS)
				stat = CONSCIOUS
				set_resting(FALSE)
				adjust_blindness(-1)
	update_damage_hud()
	update_health_hud()
