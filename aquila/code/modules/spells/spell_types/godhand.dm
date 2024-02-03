/obj/item/melee/touch_attack/sex
	name = "questionable touch"
	desc = "Oh god, why."
	catchphrase = null
	on_use_sound = null
	icon_state = "disintegrate"
	item_state = "disintegrate"
	var/list/top_speech = list(
		"UwU a to co?",
		"Spokojnie, nie jestem lingiem",
		"Patrz jak fajnie się świecą dinozaury",
		"Hehe ruchańsko stosunek hehe",
	)
	var/list/bottom_speech = list(
		"Co to jest proboscis",
		"Weź mnie horyzontalnie",
		"Wbij tą rurkę już",
		"Tylko użyj dobrej intencji"
		)

	var/list/ipc_exclusive = list(
		"Pokaż kod QR.",
		"Pokaż port USB.",
		"Tylko mi wirusa nie wgraj.",
		"Tylko mi dysku nie wyczyść."
	)

/obj/item/melee/touch_attack/sex/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || !iscarbon(target) || !iscarbon(user) || user.handcuffed)
		return

	var/mob/living/carbon/M = target
	if (!M.key)
		to_chat(user, "<span class='notice'>Your partner needs to have a soul in order to procreate.</span>")
		return

	to_chat(user,"<span class='notice'>You ask [M] to have sex with you.</span>")
	if(alert(M, "[user] wants to have sex with you. Do you accept?", "Sex on button","Yes", "No") == "No")
		to_chat(user, "[M] didn't want to have sex.")
		return

	if(!in_range(M,user))
		to_chat(user, "<span class='notice'>You are too far away!</span>")
		to_chat(M, "<span class='notice'>You are too far away!</span>")
		return

	M.set_resting(TRUE)
	M.forceMove(user.loc)
	user.Jitter(15)
	M.Jitter(15)

	to_chat(user, "<span class='notice'>You have sex with [M].</span>")
	to_chat(M, "<span class='notice'>You have sex with [user].</span>")

	addtimer(CALLBACK(src, PROC_REF(erpSay), user, FALSE), 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(erpSay), M, FALSE), 2 SECONDS)
	addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living/, set_resting), FALSE), 5 SECONDS)
	charges--
	if(charges <= 0)
		qdel(src)

/obj/item/melee/touch_attack/sex/proc/erpSay(mob/living/carbon/speaker, victim)
	var/list/picklist = victim == TRUE ? bottom_speech : top_speech
	if (isipc(speaker))
		picklist += ipc_exclusive
	speaker.say(pick(picklist), forced = "spell")
