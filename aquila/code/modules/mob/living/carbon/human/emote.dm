/datum/emote/living/carbon/human/fart
	key = "fart"
	key_third_person = "farts"

/datum/emote/living/carbon/human/fart/run_emote(mob/user, params, type_override, intentional)
	if(!..())
		return
	. = TRUE
	var/mob/living/carbon/human/C = user
	var/turf/T = get_turf(user)

	if(HAS_TRAIT(user, TRAIT_MEGAFART) && HAS_TRAIT(user, TRAIT_TOXICFART))
		user.visible_message("<span class = 'warning'>[user] hunches down and grits [user.p_their()] teeth!</span>","<span class = 'warning'>You hunch down and grit your teeth. Stand still!</span>")
		to_chat(user, "<span class = 'userdanger'>You have a very bad feeling about this!</span>")
		if(do_mob(user, user, 3.5 SECONDS))
			explosion(T, -1, 0, 0, 0, 0, flame_range = 2)
			C.Knockdown(2 SECONDS)
			C.adjust_fire_stacks(2)
			C.IgniteMob()
			C.apply_damage(15, BRUTE, BODY_ZONE_CHEST)

	else if(HAS_TRAIT(user, TRAIT_MEGAFART))
		user.visible_message("<span class = 'warning'>[user] hunches down and grits [user.p_their()] teeth!</span>","<span class = 'warning'>You hunch down and grit your teeth. Stand still!</span>")
		if(do_mob(user, user, 2.5 SECONDS))
			for(var/mob/M in urange(3, user))
				if(!M.stat)
					shake_camera(M, 1, 1)
			goonchem_vortex(T, 1, 2)
			C.Knockdown(1 SECONDS)
			C.apply_damage(20, BRUTE, BODY_ZONE_CHEST)
			//why are we still here? just to suffer?

	else if(HAS_TRAIT(user, TRAIT_TOXICFART))
		user.visible_message("<span class = 'warning'>[user] hunches down and grits [user.p_their()] teeth!</span>","<span class = 'warning'>You hunch down and grit your teeth. Stand still!</span>")
		if(do_mob(user, user, 1.5 SECONDS))
			if(istype(T, /turf/open))
				T.atmos_spawn_air("plasma=3")
			C.Knockdown(0.5 SECONDS)
			C.apply_damage(20, TOX)

	/*	jeśli ktoś ma pomysł jak to ładniej zakodować, to dajcie znać na discordzie (b4cku#1372).
		miałem do wyboru albo przepisać WSZYSTKIE checki na początku i na końcu zostawić ..(), które by wykonało słyszalną akcję i dźwięk
		albo sprawić żeby ..() wykonało checki na początku, a skutki wklepać ręcznie na koniec.*/

	user.audible_message("<span class='emote'><b>[user]</b> farts!</span>")
	playsound(user, 'sound/misc/fart1.ogg', 50, TRUE)
