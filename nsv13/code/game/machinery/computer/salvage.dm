//Salvaging computer to allow salvaging of other ships
/obj/machinery/computer/ship/salvage
	name = "Seegson model SCRP salvage console"
	desc = "A relatively simple console which allows ships to dock to other ships."
	icon_screen = "salvage"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/max_salvage_range = 20 //must stay within N tiles of range to salvage a ship.
	var/obj/structure/overmap/salvage_target = null //What are we currently salvaging?
	var/can_salvage = TRUE //Cooldown
	var/salvage_cooldown = 5 MINUTES
	var/obj/item/radio/radio //For alerts.
	var/radio_key = /obj/item/encryptionkey/headset_com
	var/radio_channel = RADIO_CHANNEL_COMMAND
	var/datum/beam/current_beam = null //Salvage armatures

/obj/machinery/computer/ship/salvage/Initialize()
	. = ..()
	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = 0
	radio.recalculateChannels()

/obj/machinery/computer/ship/salvage/ui_interact(mob/user)
	if(!has_overmap())
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>A warning flashes across [src]'s screen: Unable to locate thrust parameters, no registered ship stored in microprocessor.</span>")
		return
	playsound(src, 'nsv13/sound/effects/computer/startup.ogg', 75, 1)
	var/dat = ""
	var/dist = get_dist(linked, salvage_target)
	if(!salvage_target)
		dat += "<h2>Available salvage targets:</h2><br>"
		for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
			if(get_dist(linked, OM) <= max_salvage_range && OM.wrecked)
				dat += "<A href='?src=\ref[src];salvage=\ref[OM]'>[OM]</A><BR>"
	else
		dat += "<h2> Salvage protocols: Target locked: [salvage_target].</h2><br>"
		dat += "<A href='?src=\ref[src];blank=1'>Current range: [dist]KM / [max_salvage_range]KM</A><BR>"
		dat += "<A href='?src=\ref[src];cancel_salvage=1'>Terminate salvage operations</A><BR>"
	playsound(src, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
	var/datum/browser/popup = new(user, "Salvage console", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/ship/salvage/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	var/obj/structure/overmap/salvage = locate(href_list["salvage"])
	if(salvage)
		salvage_target = salvage
		salvage()
	if(href_list["cancel_salvage"])
		cancel_salvage()
	ui_interact(usr)

/obj/effect/ebeam/chain //Blame bee disabling but not removing the guardian shit inside the mob folder
	name = "lightning chain"
	layer = LYING_MOB_LAYER

/obj/machinery/computer/ship/salvage/proc/salvage()
	if(!salvage_target || !can_salvage)
		salvage_target = null
		return
	can_salvage = FALSE
	addtimer(VARSET_CALLBACK(src, can_salvage, TRUE), salvage_cooldown)
	salvage_target.relay_to_nearby('nsv13/sound/effects/ship/boarding_pod.ogg')
	radio.talk_into(src, "Deploying structural stabilization lines...", radio_channel)
	current_beam = new(linked,salvage_target,time=INFINITY,maxdistance=max_salvage_range,beam_icon_state="salvage_beam",btype=/obj/effect/ebeam/chain)
	INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)
	if(salvage_target.load_interior())
		radio.talk_into(src, "SUCCESS: Docking tethers locking onto [salvage_target]. Structural integrity: ACCEPTABLE. Structural reinforcements are effective at close ranges only!.", radio_channel)
		salvage_target.brakes = TRUE //Lock it in place.
		RegisterSignal(linked, COMSIG_MOVABLE_MOVED, .proc/update_salvage_target) //Add a listener on ship move. If you move out of range of the salvage target, it explodes because youre not there to stabilize it anymore.
		for(var/datum/X in salvage_target.active_timers) //Cancel detonation
			qdel(X)
	else //This only ever fails if there isn't a place to spawn the interior.
		radio.talk_into(src, "WARNING: Docking tethers failed to attach to [salvage_target]. Further salvage attempts futile.", radio_channel)
		cancel_salvage()

/obj/machinery/computer/ship/salvage/proc/update_salvage_target()
	if(!salvage_target)
		return
	var/dist = get_dist(linked, salvage_target)
	if(dist >= max_salvage_range)
		radio.talk_into(src, "DANGER: Unable to maintain salvage armatures on [salvage_target]! Structural integrity failure imminent!", radio_channel)
		cancel_salvage()

/obj/machinery/computer/ship/salvage/proc/cancel_salvage()
	if(salvage_target)
		if(current_beam)
			qdel(current_beam)
			current_beam = null
		radio.talk_into(src, "Salvage armatures retracted. Aborting salvage operations.", radio_channel)
//		salvage_target.explode() //Ship loses stability. It's literally just us that's holding it together.
		UnregisterSignal(linked, COMSIG_MOVABLE_MOVED, .proc/update_salvage_target)
		salvage_target = null
