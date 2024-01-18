/// Creates and sorts all the keybinding datums
/proc/init_keybindings()
	for(var/KB in subtypesof(/datum/keybinding))
		var/datum/keybinding/keybinding = KB
		if(!initial(keybinding.key))
			continue
		add_keybinding(new keybinding)
	init_emote_keybinds()
	for(var/key in GLOB.keybinding_list_by_key)
		GLOB.keybinding_list_by_key[key] = sortList(GLOB.keybinding_list_by_key[key])

/// Adds an instanced keybinding to the global tracker
/proc/add_keybinding(datum/keybinding/instance)
	GLOB.keybindings_by_name[instance.name] = instance

	if(!(instance.key in GLOB.keybinding_list_by_key))
		GLOB.keybinding_list_by_key[instance.key] = list()
	GLOB.keybinding_list_by_key[instance.key] += instance.name

/proc/init_emote_keybinds()
	for(var/i in subtypesof(/datum/emote))
		var/datum/emote/faketype = i
		if(!initial(faketype.key))
			continue
		var/datum/keybinding/emote/emote_kb = new
		emote_kb.link_to_emote(faketype)
		add_keybinding(emote_kb)
