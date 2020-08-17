/datum/component/swimming/disolve
	var/start_alpha = 0

/datum/component/swimming/disolve/enter_pool()
	var/mob/living/L = parent
	start_alpha = L.alpha
	to_chat(parent, "<span class='userdanger'>You begin disolving into the pool, get out fast!</span>")

/datum/component/swimming/disolve/process()
	var/mob/living/L = parent
	L.adjustCloneLoss(1)
	L.alpha = ((L.health-HEALTH_THRESHOLD_DEAD) / (L.maxHealth - HEALTH_THRESHOLD_DEAD)) * 255
	if(L.stat == DEAD)
		L.visible_message("<span class='warning'>[L] dissolves into the pool!</span>")
		qdel(L)	//You fucked up

/datum/component/swimming/disolve/exit_pool()
	animate(parent, alpha=start_alpha, time=20)
