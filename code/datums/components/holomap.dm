/**
 * An attempt at figuring out how to make holomaps into a component.
 */
/datum/action/toggle_holomap
	name = "Toggle Holomap"
	desc = "Toggles the holomap on or off."
	icon_icon = 'icons/obj/decals.dmi'
	button_icon_state = "map-pubby"
	var/atom/holder = null
	var/datum/component/holomap/holo = null

/datum/action/toggle_holomap/proc/can_use(mob/living/user)
	return (user && user.mind && user.stat == CONSCIOUS)

/datum/action/toggle_holomap/Trigger()
	action(holder)

/datum/action/toggle_holomap/proc/action(mob/living/user)
	if(!holo)
		return FALSE
	if(isliving(user))
		if(!can_use(user))
			to_chat(user, "<span class='warning'>You can't do that right now...</span>")
			return FALSE
	else
		user = holder.loc //Alright, seems like they clicked the item's action instead.
	holo.summon_holomap(user)

/datum/component/holomap
	var/datum/action/toggle_holomap/holobutton = new
	/// The various images and icons for the map are stored in here, as well as the actual big map itself.
	var/datum/station_holomap/holomap_datum
	/// The mob that is currently watching the holomap.
	var/mob/watching_mob
	// zLevel which the pda is showing a map for.
	var/current_z_level
	var/holomap_visible = FALSE // Whether the holomap is visible or not.
	/// This set to FALSE when the station map is initialized on a zLevel that has its own icon formatted for use by station holomaps.
	var/bogus = TRUE

/datum/component/holomap/proc/get_user()
	RETURN_TYPE(/mob/living)
	var/atom/movable/holder = parent
	return (isliving(holder) || !isatom(holder)) ? holder : holder.loc

/datum/component/holomap/Initialize()
	. = ..()
	if(isatom(parent))
		holobutton.holder = parent
		holobutton.holo = src

	if(isliving(parent))
		holobutton.Grant(parent)
		return

	if(istype(parent, /obj/item))
		var/obj/item/holder = parent
		RegisterSignal(holder, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
		RegisterSignal(holder, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
		if(isliving(holder.loc)) //Account for items pre-spawned on people...
			on_equip(holder, holder.loc, null)
		return
	qdel(holobutton)

/datum/component/holomap/proc/on_equip(datum/source, mob/equipper, slot)
	if(slot && slot == ITEM_SLOT_BACKPACK)
		on_drop(source, equipper)
		return
	if(has_use_permission(source, equipper))
		holobutton.Grant(equipper)

/datum/component/holomap/proc/has_use_permission(datum/source, mob/equipper)
	return TRUE

/datum/component/holomap/proc/on_drop(datum/source, mob/user)
	holobutton.Remove(user)

/datum/component/holomap/Destroy(force, silent)
	//if(holobutton)
	//	holobutton.Remove(get_user())
	//	qdel(holobutton)
	. = ..()

/datum/component/holomap/proc/summon_holomap(datum/user)
	if(holomap_visible)
		deactivate_holomap(user)
	else
		activate_holomap(user)

/datum/component/holomap/proc/handle_overlays()
	// Each entry in this list contains the text for the legend, and the icon and icon_state use. Null or non-existent icon_state ignore hiding logic.
	// If an entry contains an icon,
	var/list/legend = list() + GLOB.holomap_default_legend

	var/list/z_transitions = SSholomaps.holomap_z_transitions["[current_z_level]"]
	if(length(z_transitions))
		legend += z_transitions

	return legend

/datum/component/holomap/proc/activate_holomap(mob/user)
	current_z_level = user.z
	holomap_datum = new()
	bogus = FALSE
	var/turf/current_turf = get_turf(user)
	if(!("[HOLOMAP_EXTRA_STATIONMAP]_[current_z_level]" in SSholomaps.extra_holomaps))
		bogus = TRUE
		holomap_datum.initialize_holomap_bogus()
		return

	holomap_datum.initialize_holomap(current_turf.x, current_turf.y, current_z_level, reinit_base_map = TRUE, extra_overlays = handle_overlays())

	holomap_datum.update_map(handle_overlays())

	var/datum/hud/human/user_hud = user.hud_used
	holomap_datum.base_map.loc = user_hud.holomap  // Put the image on the holomap hud

	user.hud_used.holomap.used_station_map = src
	user.hud_used.holomap.mouse_opacity = MOUSE_OPACITY_ICON
	user.client.screen |= user.hud_used.holomap
	user.client.images |= holomap_datum.base_map

	watching_mob = user
	holomap_visible = TRUE
	to_chat(user, "<span class='warning'>A hologram of the ship appears before your eyes.</span>")
	return TRUE

/datum/component/holomap/proc/deactivate_holomap(mob/user)
	holomap_visible = FALSE
	if(watching_mob?.client)
		watching_mob.client?.screen -= watching_mob.hud_used.holomap
		watching_mob.client?.images -= holomap_datum.base_map
		watching_mob.hud_used.holomap.used_station_map = null
		watching_mob = null
