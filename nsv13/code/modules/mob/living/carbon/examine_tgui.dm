/datum/examine_panel
	/// Mob that the examine panel belongs to.
	var/mob/living/holder
	/// The screen containing the appearance of the mob
	var/atom/movable/screen/examine_panel_screen/examine_panel_screen

/datum/examine_panel/ui_state(mob/user)
	return GLOB.always_state


/datum/examine_panel/ui_close(mob/user)
	user.client.clear_map(examine_panel_screen.assigned_map)


/atom/movable/screen/examine_panel_screen
	name = "examine panel screen"

/datum/examine_panel/ui_interact(mob/user, datum/tgui/ui)
	if(!examine_panel_screen)
		examine_panel_screen = new
		examine_panel_screen.name = "screen"
		examine_panel_screen.assigned_map = "examine_panel_[REF(holder)]_map"
		examine_panel_screen.del_on_map_removal = FALSE
		examine_panel_screen.screen_loc = "[examine_panel_screen.assigned_map]:1,1"

	var/mutable_appearance/current_mob_appearance = new(holder)
	current_mob_appearance.setDir(SOUTH)
	current_mob_appearance.transform = matrix() // We reset their rotation, in case they're lying down.

	// In case they're pixel-shifted, we bring 'em back!
	current_mob_appearance.pixel_x = 0
	current_mob_appearance.pixel_y = 0

	examine_panel_screen.cut_overlays()
	examine_panel_screen.add_overlay(current_mob_appearance)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		user.client.register_map_obj(examine_panel_screen)
		ui = new(user, src, "ExaminePanel")
		ui.open()

/datum/examine_panel/ui_data(mob/user)
	var/list/data = list()

	var/flavor_text
	if(issilicon(holder))
		flavor_text = user.client.prefs.active_character.silicon_flavor_text
	data["character_name"] = holder.name
	data["assigned_map"] = examine_panel_screen.assigned_map
	data["flavor_text"] = flavor_text
	return data
