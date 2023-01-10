GLOBAL_LIST_EMPTY_TYPED(interaction_instances, /datum/interaction)

/datum/interaction
	/// The name to be displayed in the interaction menu for this interaction
	var/name = "broken interaction"
	/// The description of the interacton.
	var/description = "broken"
	/// If it can be done at a distance.
	var/distance_allowed = FALSE
	/// A list of possible messages displayed loaded by the JSON.
	var/list/message = list()
	/// A list of possible messages displayed directly to the USER.
	var/list/user_messages = list()
	/// A list of possible messages displayed directly to the TARGET.
	var/list/target_messages = list()
	/// What category this interaction will fall under in the menu.
	var/category = INTERACTION_CAT_HIDE
	/// Defines how we interact with ourselves or others.
	var/usage = INTERACTION_OTHER
	/// Does this interaction play a sound?
	var/sound_use = FALSE
	/// If it plays a sound, how far does it travel?
	var/sound_range = 1
	/// Stores the sound for later.
	var/sound_cache = null
	/// A list of possible sounds.
	var/list/sound_possible = list()
	/// What requirements does this interaction have? See defines.
	var/list/interaction_requires = list()
	/// What color should the interaction button be?
	var/color = "blue"

/datum/interaction/proc/allow_act(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(target == user && usage == INTERACTION_OTHER)
		return FALSE
	for(var/requirement in interaction_requires)
		switch(requirement)
			if(INTERACTION_REQUIRE_SELF_HAND)
				if(!user.get_active_hand())
					return FALSE
			if(INTERACTION_REQUIRE_TARGET_HAND)
				if(!target.get_active_hand())
					return FALSE
			else
				CRASH("Unimplemented interaction requirement '[requirement]'")
	return TRUE

/datum/interaction/proc/act(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!allow_act(user, target))
		return
	if(!message)
		message_admins("Interaction had a null message list. '[name]'")
		return
	if(!islist(message) && istext(message))
		message_admins("Deprecated message handling for '[name]'. Correct format is a list with one entry. This message will only show once.")
		message = list(message)
	var/msg = pick(message)
	// We replace %USER% with nothing because manual_emote already prepends it.
	msg = trim(replacetext(replacetext(msg, "%TARGET%", "[target]"), "%USER%", ""), INTERACTION_MAX_CHAR)
	user.manual_emote(msg)
	if(user_messages.len)
		var/user_msg = pick(user_messages)
		user_msg = replacetext(replacetext(user_msg, "%TARGET%", "[target]"), "%USER%", "[user]")
		to_chat(user, user_msg)
	if(target_messages.len)
		var/target_msg = pick(target_messages)
		target_msg = replacetext(replacetext(target_msg, "%TARGET%", "[target]"), "%USER%", "[user]")
		to_chat(target, target_msg)
	if(sound_use)
		if(!sound_possible)
			message_admins("Interaction has sound_use set to TRUE but does not set sound! '[name]'")
			return
		if(!islist(sound_possible) && istext(sound_possible))
			message_admins("Deprecated sound handling for '[name]'. Correct format is a list with one entry. This message will only show once.")
			sound_possible = list(sound_possible)
		sound_cache = pick(sound_possible)
		for(var/mob/mob in view(sound_range, user))
			SEND_SOUND(sound_cache, mob)

/datum/interaction/proc/load_from_json(path)
	var/fpath = path
	if(!fexists(fpath))
		message_admins("Attempted to load an interaction from json and the file does not exist")
		qdel(src)
		return FALSE
	var/file = file(fpath)
	var/list/json = json_load(file)
	name = sanitize_text(json["name"])
	description = sanitize_text(json["description"])
	distance_allowed = sanitize_integer(json["distance_allowed"], 0, 1, 0)
	message = sanitize_islist(json["message"], list("json error"))
	category = sanitize_text(json["category"])
	usage = sanitize_text(json["usage"])
	sound_use = sanitize_integer(json["sound_use"], 0, 1, 0)
	sound_range = sanitize_integer(json["sound_range"], 1, 7, 1)
	sound_possible = sanitize_islist(json["sound_possible"], list("json error"))
	interaction_requires = sanitize_islist(json["interaction_requires"], list())
	color = sanitize_text(json["color"])

	user_messages = sanitize_islist(json["user_messages"], list())
	target_messages = sanitize_islist(json["target_messages"], list())
	return TRUE

/datum/interaction/proc/json_save(path)
	var/fpath = path
	if(fexists(fpath))
		fdel(fpath)
	var/list/json = list(
		"name" = name,
		"description" = description,
		"distance_allowed" = distance_allowed,
		"message" = message,
		"category" = category,
		"usage" = usage,
		"sound_use" = sound_use,
		"sound_range" = sound_range,
		"sound_possible" = sound_possible,
		"interaction_requires" = interaction_requires,
		"color" = color,
		"user_messages" = user_messages,
		"target_messages" = target_messages,
	)
	var/file = file(fpath)
	WRITE_FILE(file, json_encode(json))
	return TRUE

/mob/living/carbon/human/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/interactable)

/// Global loading procs
/proc/populate_interaction_instances()
	for(var/spath in subtypesof(/datum/interaction))
		var/datum/interaction/interaction = new spath()
		GLOB.interaction_instances[interaction.name] = interaction
	populate_interaction_jsons(INTERACTION_JSON_FOLDER)

/proc/populate_interaction_jsons(directory)
	for(var/file in flist(directory))
		if(flist(directory + file) && !findlasttext(directory + file, ".json"))
			populate_interaction_instances(directory + file)
			continue
		if(findlasttext(directory + file, ".master.json")) // This is a master json which has special handling
			populate_interaction_jsons_master(directory + file)
			continue
		var/datum/interaction/interaction = new()
		if(interaction.load_from_json(directory + file))
			GLOB.interaction_instances[interaction.name] = interaction
		else message_admins("Error loading interaction from file: '[directory + file]'. Inform coders.")

/proc/populate_interaction_jsons_master(path)
	if(!fexists(path))
		message_admins("We are attempting to load an interaction master without the file existing! '[path]'")
		return
	var/file = file(path)
	var/list/json = json_load(file)

	for(var/iname in json)
		if(GLOB.interaction_instances[iname])
			message_admins("Interaction Master '[path]' contained a duplicate interaction! '[iname]'")
			continue

		var/list/ijson = json[iname]
		if(ijson["name"] != iname)
			message_admins("Interaction Master '[path]' contained an invalid interaction! '[iname]'")
			continue

		var/datum/interaction/interaction = new()

		interaction.distance_allowed = sanitize_integer(ijson["distance_allowed"], 0, 1, 0)
		interaction.message = sanitize_islist(ijson["message"], list("json error"))
		interaction.category = sanitize_text(ijson["category"])
		interaction.usage = sanitize_text(ijson["usage"])
		interaction.sound_use = sanitize_integer(ijson["sound_use"], 0, 1, 0)
		interaction.sound_range = sanitize_integer(ijson["sound_range"], 1, 7, 1)
		interaction.sound_possible = sanitize_islist(ijson["sound_possible"], list("json error"))
		interaction.interaction_requires = sanitize_islist(ijson["interaction_requires"], list())
		interaction.color = sanitize_text(ijson["color"])

		interaction.user_messages = sanitize_islist(ijson["user_messages"], list())
		interaction.target_messages = sanitize_islist(ijson["target_messages"], list())

		GLOB.interaction_instances[iname] = interaction

/client/proc/reload_interactions()
	set category = "Debug"
	set name = "Reload Interactions"
	set desc = "Force reload interactions"
	if(!check_rights(R_DEBUG))
		return

	populate_interaction_instances()
