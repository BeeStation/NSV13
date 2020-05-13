/client/proc/check_view()//Set our default view back to normal if we're not a widescreen user, or set it to widescreen if we are. As an ultrawide user I advocate this :) ~Kmc
	current_view_size = 15 //Reset zoom
	if(prefs.widescreenpref && CONFIG_GET(flag/widescreen))
		change_view("17x15") //Epic gamers get an entire extra tile of vision woa
	else
		change_view(CONFIG_GET(string/default_view))
