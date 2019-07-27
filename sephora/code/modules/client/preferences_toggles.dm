/client/verb/toggle_widescreen_pref()
	set name = "Toggle widescreen"
	set category = "Preferences"
	set desc = "Enable / disable widescreen mode, NOT RECOMMENDED FOR ASPECT RATIOS LOWER THAN 21:9! (Ultrawide users only)"
	prefs.toggles ^= WIDESCREEN
	prefs.save_preferences()
	to_chat(usr, "Widescreen mode [(usr.client.prefs.toggles & WIDESCREEN) ? "Enabled" : "Disabled"]")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle widescreen", "[prefs.toggles & WIDESCREEN ? "Enabled" : "Disabled"]"))
	check_view()

/client/proc/check_view()//Set our default view back to normal if we're not a widescreen user, or set it to widescreen if we are. As an ultrawide user I advocate this :) ~Kmc
	current_view_size = 15 //Reset zoom
	if(prefs.toggles & WIDESCREEN && CONFIG_GET(flag/widescreen))
		change_view("21x15") //If you're not a widescreen user then I don't recommend doing this!
	else
		change_view(CONFIG_GET(string/default_view))