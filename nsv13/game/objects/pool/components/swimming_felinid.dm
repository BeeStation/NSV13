/datum/component/swimming/felinid/enter_pool()
	var/mob/living/L = parent
	L.emote("scream")
	to_chat(parent, "<span class='userdanger'>You get covered in water and start panicking!</span>")

/datum/component/swimming/felinid/process()
	..()
	var/mob/living/L = parent
	if(prob(8))
		to_chat(parent, "<span class='userdanger'>You can't touch the bottom!</span>")
		L.emote("scream")
	else if(prob(16))
		if(L.confused < 5)
			L.confused += 1
	else if(prob(40))
		L.shake_animation()
	else if(prob(8))
		shake_camera(L, 15, 1)
		L.emote("whimper")
		L.Paralyze(10)
		to_chat(parent, "<span class='userdanger'>You feel like you are never going to get out!</span>")
