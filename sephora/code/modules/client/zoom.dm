/client
	var/current_view_size = 15

/client/MouseWheel(src,delta_x,delta_y,location,control,params) //This lets you zoom in / out with your mouse
	if(mob)
		if(!mob.overmap_ship) //If theyre not in an overmap ship, don't let them zoom.
			return ..()
	if(usr.client && control =="mapwindow.map")
		if(delta_y>=1)
			current_view_size --
			if(current_view_size <= 15)
				current_view_size = 15
				check_view() //Reset our view back if we go below the default view setting
		if(delta_y<=-1)
			current_view_size ++
			if(current_view_size >= 40) //Any further than this, and byond start to lag.
				current_view_size = 40
	if(current_view_size > 15) //Bigger than default
		if(prefs.toggles & WIDESCREEN && CONFIG_GET(flag/widescreen))
			change_view("[current_view_size+21]x[current_view_size+9]") //Widescreen aspect ratio is 21:9. So we just make every ratio 21:9 so that you dont get C I N E M A T I C black bars whenever you zoom out.
		else
			change_view("[current_view_size]x[current_view_size]") //if theyre not a widescreen user, it's a simple case of just zooming them out