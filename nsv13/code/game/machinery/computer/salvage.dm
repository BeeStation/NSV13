//Salvaging computer to allow salvaging of other ships
/obj/machinery/computer/ship/salvage
	name = "Seegson model EWAR telemetry scrambler"
	desc = "An advanced computer which can temporarily distract ship point defense systems, allowing allied strike teams to board and claim the vessel. <b>IT CAN ONLY MAINTAIN ONE SHIP AT ONCE</b>"
	icon_screen = "salvage"
	circuit = /obj/item/circuitboard/computer/salvage
	var/max_salvage_range = 20 //must stay within N tiles of range to salvage a ship.
	var/required_damage_percentage = 50
	var/obj/structure/overmap/salvage_target = null //What are we currently salvaging?
	var/static/can_salvage = TRUE //Cooldown
	var/salvage_cooldown = 5 MINUTES
	var/obj/item/radio/radio //For alerts.
	var/radio_key = /obj/item/encryptionkey/headset_sec
	var/radio_channel = RADIO_CHANNEL_SECURITY

/obj/machinery/computer/ship/salvage/mining
	radio_key = /obj/item/encryptionkey/headset_cargo
	radio_channel = RADIO_CHANNEL_SUPPLY
	circuit = /obj/item/circuitboard/computer/salvage/mining

/obj/item/circuitboard/computer/salvage
	name = "EWAR Telemetry Scrambler (Circuit Board)"
	build_path = /obj/machinery/computer/ship/salvage

/obj/item/circuitboard/computer/salvage/mining
	name = "Mining EWAR Telemetry Scrambler (Circuit Board)"
	build_path = /obj/machinery/computer/ship/salvage/mining

/obj/machinery/computer/ship/salvage/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = 0
	radio.recalculateChannels()

/obj/machinery/computer/ship/salvage/Destroy()
	QDEL_NULL(radio)
	. = ..()

/obj/machinery/computer/ship/salvage/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SalvageConsole")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/ship/salvage/ui_data(mob/user)
	if(!linked)
		linked = get_overmap()
	var/list/data = list()
	data["salvage_target"] = (linked.active_boarding_target) ? "\ref[linked.active_boarding_target]" : null
	data["salvage_target_name"] = (linked.active_boarding_target) ? linked.active_boarding_target.name  : "Nothing"
	data["salvage_target_integrity"] = (linked.active_boarding_target) ? linked.active_boarding_target.obj_integrity  : 0
	data["salvage_target_max_integrity"] = (linked.active_boarding_target) ? linked.active_boarding_target.max_integrity  : 100
	var/list/ships = list()
	if(!linked?.current_system)
		data["ships"] = ships
		return data
	for(var/obj/structure/overmap/OM in linked.current_system.system_contents)
		if(OM.z != linked?.z || OM.interior_mode != INTERIOR_EXCLUSIVE || OM.is_sensor_visible(linked) <= SENSOR_VISIBILITY_FAINT || OM == linked.active_boarding_target)
			continue
		ships[++ships.len] = list("name"=OM.name, "desc"=OM.desc, "id"="\ref[OM]")
	data["ships"] = ships
	return data

/obj/machinery/computer/ship/salvage/ui_act(action, params)
	if(..())
		return
	if(!linked)
		linked = get_overmap()
	//So you can't brasil yourselves if boarding with the DS.
	if(!linked || !(SSmapping.level_trait(linked.z, ZTRAIT_OVERMAP)))
		return FALSE
	switch(action)
		if("salvage")
			var/obj/structure/overmap/OM = locate(params["target"])
			if(!linked)
				radio.talk_into(src, "This console is not attached to the ship's EWAR scrambling systems.", radio_channel)
				return FALSE
			if(!OM)
				radio.talk_into(src, "Detection of target systems failed.", radio_channel)
				return FALSE
			if(OM.ghost_controlled)
				radio.talk_into(src, "EWAR scrambling unable to achieve positive lock, aborting process.", radio_channel)
				return FALSE
			if(!can_salvage)
				radio.talk_into(src, "EWAR scrambling equipment is starting up or shutting down. Try again later.", radio_channel)
				return FALSE
			if((linked.active_boarding_target && !QDELETED(linked.active_boarding_target)))
				playsound(pick('nsv13/sound/effects/computer/alarm.ogg','nsv13/sound/effects/computer/alarm_2.ogg'), 100, 1)
				radio.talk_into(src, "WARNING: This console is already maintaining EWAR scrambling on [linked.active_boarding_target]. Confirmation required to proceed.", radio_channel)
				return FALSE
			if((OM.obj_integrity * 100 / initial(OM.obj_integrity)) > required_damage_percentage)
				radio.talk_into(src, "Target is not sufficiently compromised for EWAR scrambling.", radio_channel)
				return FALSE
			radio.talk_into(src, "Electronic countermeasure deployment in progress.", radio_channel)
			can_salvage = FALSE
			DISABLE_BITFIELD(OM.overmap_deletion_traits, DAMAGE_DELETES_UNOCCUPIED) // Simplemobs don't count, so don't let this explode before we're ready
			if(OM.ai_load_interior(linked))
				linked.active_boarding_target = OM
				addtimer(VARSET_CALLBACK(src, can_salvage, TRUE), salvage_cooldown)
				OM.ai_controlled = FALSE
				OM.apply_weapons()
				radio.talk_into(src, "Enemy point defense systems scrambled. Bluefor strike teams cleared for approach.", radio_channel)
			else
				radio.talk_into(src, "Unable to scramble enemy point defense systems. Aborting...", radio_channel)
				linked.active_boarding_target.kill_boarding_level(linked)
				linked.active_boarding_target = null
				addtimer(VARSET_CALLBACK(src, can_salvage, TRUE), salvage_cooldown/2)

		if("stop_salvage")
			if(!linked)
				radio.talk_into(src, "This console is not attached to the ship's EWAR scrambling systems.", radio_channel)
				return FALSE
			if(!linked.active_boarding_target)
				radio.talk_into(src, "EWAR scambling not currently engaged.", radio_channel)
				return FALSE
			if(!can_salvage)
				radio.talk_into(src, "EWAR scrambling equipment is starting up or shutting down. Try again later.", radio_channel)
				return FALSE
			if(SEND_SIGNAL(linked.active_boarding_target, COMSIG_SHIP_RELEASE_BOARDING))
				radio.talk_into(src, "Target is mission critical. Cannot cancel EWAR scrambling on [linked.active_boarding_target].", radio_channel)
				return FALSE // Something blocked this
			if(alert("Are you sure? (ALL BOARDERS WILL BE KILLED)",name,"Release Hammerlock","Cancel") == "Cancel")
				return FALSE
			radio.talk_into(src, "EWAR scrambling on [linked.active_boarding_target] cancelled.", radio_channel)
			//They REALLY NEED TO NOT SPAM THIS
			can_salvage = FALSE
			message_admins("[usr] released boarding/salvage lock on [linked.active_boarding_target]")
			linked.active_boarding_target.kill_boarding_level(linked)
			linked.active_boarding_target.overmap_deletion_traits = initial(linked.active_boarding_target.overmap_deletion_traits)
			linked.active_boarding_target = null
			addtimer(VARSET_CALLBACK(src, can_salvage, TRUE), salvage_cooldown/2)
