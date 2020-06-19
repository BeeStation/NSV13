GLOBAL_LIST_EMPTY(sechailers)

/datum/action/item_action/dispatch
	name = "Signal dispatch"
	desc = "Opens up a quick select wheel for reporting crimes, including your current location, to your fellow security officers."
	button_icon_state = "dispatch"
	icon_icon = 'nsv13/icons/mob/actions/actions.dmi'

/obj/item/clothing/mask/gas/sechailer
	var/obj/item/radio/radio //For engineering alerts.
	var/radio_key = /obj/item/encryptionkey/headset_sec
	var/radio_channel = "Security"
	var/dispatch_cooldown = 20 SECONDS
	var/last_dispatch = 0

/obj/item/clothing/mask/gas/sechailer/Destroy()
	QDEL_NULL(radio)
	QDEL_NULL(radio_key)
	GLOB.sechailers -= src
	. = ..()

/obj/item/clothing/mask/gas/sechailer/Initialize()
	. = ..()
	GLOB.sechailers += src
	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = FALSE
	radio.recalculateChannels()

/obj/item/clothing/mask/gas/sechailer/proc/dispatch(mob/user)
	if(world.time < last_dispatch + dispatch_cooldown)
		to_chat(user, "<span class='notice'>Dispatch radio broadcasting systems are recharging.</span>")
		return FALSE
	var/list/options = list()
	for(var/option in list("401 (murder)", "101 (resisting arrest)", "210 (breaking and entering)", "206 (riot)", "302 (assault on an officer)")) //Just hardcoded for now!
		options[option] = image(icon = 'nsv13/icons/effects/aiming.dmi', icon_state = option)
	var/message = show_radial_menu(user, user, options)
	if(!message)
		return FALSE
	radio.talk_into(src, "Dispatch, code [message] in progress in [get_area(user)], requesting assistance.", radio_channel)
	last_dispatch = world.time
	for(var/atom/movable/hailer in GLOB.sechailers)
		if(hailer.loc &&ismob(hailer.loc))
			playsound(hailer.loc, "nsv13/sound/voice/sechailer/dispatch_please_respond.ogg", 100, FALSE)