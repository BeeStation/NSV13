/datum/component/swimming/felinid/enter_pool()
	var/mob/living/L = parent
	L.emote("scream")
	to_chat(parent, "<span class='userdanger'>You get covered in water and start panicking!</span>")

/datum/component/swimming/felinid/process()
	..()
	var/mob/living/L = parent
	switch(rand(1, 100))
		if(1 to 8)
			to_chat(parent, "<span class='userdanger'>You can't touch the bottom!</span>")
			L.emote("scream")
		if(9 to 20)
			if(L.confused < 5)
				L.confused += 1
		if(21 to 60)
			L.shake_animation()
		if(61 to 68)
			shake_camera(L, 15, 1)
			L.emote("whimper")
			L.Paralyze(10)
			to_chat(parent, "<span class='userdanger'>You feel like you are never going to get out...</span>")
