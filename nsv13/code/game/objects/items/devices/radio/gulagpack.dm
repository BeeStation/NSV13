/obj/item/storage/backpack/gulagpack
	name = "gulagpack"
	desc = "A spraypainted electropack painted in security colors to signal the wearer is serving the ship under surveillance."
	worn_icon = 'nsv13/icons/mob/back.dmi'
	icon = 'nsv13/icons/obj/gulagpack.dmi'
	icon_state = "gulagpack0"
	item_state = "gulagpack1"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	materials = list(/datum/material/iron=10000, /datum/material/glass=2500)


	var/on = TRUE
	var/code = 2
	var/frequency = FREQ_ELECTROPACK
	var/shock_cooldown = FALSE


/obj/item/storage/backpack/gulagpack/Initialize()
	. = ..()
	set_frequency(frequency)

/obj/item/storage/backpack/gulagpack/Destroy()
	SSradio.remove_object(src, frequency)
	return ..()

/obj/item/storage/backpack/gulagpack/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] hooks [user.p_them()]self to the gulagpack and spams the trigger! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (FIRELOSS)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/storage/backpack/gulagpack/attack_hand(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.back)
			to_chat(user, "<span class='warning'>You need help taking this off!</span>")
			return
	return ..()

/obj/item/storage/backpack/gulagpack/MouseDrop(atom/over_object)
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr 
		if(src == C.back)
			to_chat(C, "<span class='warning'>You need help taking this off!</span>")
			return
	return ..()

/obj/item/storage/backpack/gulagpack/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/clothing/head/helmet))
		var/obj/item/assembly/shock_kit/A = new /obj/item/assembly/shock_kit(user)
		A.icon = 'icons/obj/assemblies.dmi'

		if(!user.transferItemToLoc(W, A))
			to_chat(user, "<span class='warning'>[W] is stuck to your hand, you cannot attach it to [src]!</span>")
			return
		W.master = A
		A.helmet_part = W

		user.transferItemToLoc(src, A, TRUE)
		master = A
		A.electropack_part = src

		user.put_in_hands(A)
		A.add_fingerprint(user)
	else
		return ..()

/obj/item/storage/backpack/gulagpack/receive_signal(datum/signal/signal)
	if(!signal || signal.data["code"] != code)
		return

	if(isliving(loc) && on)
		if(shock_cooldown)
			return
		shock_cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, shock_cooldown, FALSE), 100)
		var/mob/living/L = loc
		step(L, pick(GLOB.cardinals))

		to_chat(L, "<span class='danger'>You feel a sharp shock!</span>")
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, L)
		s.start()

		L.Paralyze(100)

	if(master)
		master.receive_signal()

/obj/item/storage/backpack/gulagpack/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	SSradio.add_object(src, frequency, RADIO_SIGNALER)


/obj/item/storage/backpack/gulagpack/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/storage/backpack/gulagpack/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Electropack")
		ui.open()

/obj/item/storage/backpack/gulagpack/ui_data(mob/user)
	var/list/data = list()
	data["power"] = on
	data["frequency"] = frequency
	data["code"] = code
	data["minFrequency"] = MIN_FREE_FREQ
	data["maxFrequency"] = MAX_FREE_FREQ
	return data

/obj/item/storage/backpack/gulagpack/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("power")
			on = !on
			icon_state = "gulagpack[on]"
			. = TRUE
		if("freq")
			var/value = unformat_frequency(params["freq"])
			if(value)
				frequency = sanitize_frequency(value, TRUE)
				set_frequency(frequency)
				. = TRUE
		if("code")
			var/value = text2num(params["code"])
			if(value)
				value = round(value)
				code = clamp(value, 1, 100)
				. = TRUE
		if("reset")
			if(params["reset"] == "freq")
				frequency = initial(frequency)
				. = TRUE
			else if(params["reset"] == "code")
				code = initial(code)
				. = TRUE
