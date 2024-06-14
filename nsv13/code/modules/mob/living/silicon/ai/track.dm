GLOBAL_DATUM_INIT(tracking_menu, /datum/track_menu, new)

/datum/track_menu
	/// List of user -> UI source
	var/list/ui_sources = list()

	var/static/list/mob_allowed_typecache

/datum/track_menu/ui_state(mob/user)
	return GLOB.default_state

/datum/track_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Tracking")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/track_menu/proc/show(mob/user, source)
	ui_sources[WEAKREF(user)] = source
	ui_interact(user)

/datum/track_menu/ui_host(mob/user)
	return ui_sources[WEAKREF(user)]

/datum/track_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if (..())
		return

	switch(action)
		if("track")
			var/ref = params["name"]
			var/mob/living/silicon/ai/AI = usr
			for(var/target in AI.trackable_mobs())
				if(target == ref)
					AI.ai_camera_track(target)
					return TRUE
		if("refresh")
			update_static_data(usr, ui)
			return TRUE

/datum/track_menu/ui_static_data(mob/user)
	var/list/carbon = list()
	var/list/simple_mob = list()

	var/mob/living/silicon/ai/AI = user
	var/list/pois = AI.trackable_mobs()
	for(var/name in pois)
		var/list/serialized = list()
		serialized["name"] = name

		var/poi = pois[name]

		serialized["ref"] = REF(poi)

		var/datum/weakref/target = poi
		var/mob/mob_poi = target?.resolve()
		if(istype(mob_poi))
			if(mob_poi.mind == null)
				simple_mob += list(serialized)
			else if(istype(mob_poi, /mob/living/carbon/human))
				var/mob/living/carbon/human/player = mob_poi
				var/nanite_sensors = HAS_TRAIT(player, TRAIT_NANITE_SENSORS)
				var/obj/item/clothing/under/uniform = player.w_uniform
				if(nanite_sensors || (uniform && uniform.sensor_mode >= SENSOR_VITALS))
					serialized["health"] = FLOOR((player.health / player.maxHealth * 100), 1)

				var/obj/item/card/id/identification_card = mob_poi.get_idcard()
				if(identification_card)
					serialized["job"] = identification_card.assignment
					serialized["role_icon"] = "hud[ckey(identification_card.GetJobIcon())]"

				carbon += list(serialized)

	return list(
		"carbon" = carbon,
		"simple_mob" = simple_mob,
	)

/datum/track_menu/ui_assets()
	. = ..() || list()
	. += get_asset_datum(/datum/asset/simple/orbit)
	. += get_asset_datum(/datum/asset/spritesheet/job_icons)
