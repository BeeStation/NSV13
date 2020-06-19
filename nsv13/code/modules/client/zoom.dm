/client
	var/current_view_size = 15
	var/next_zoomout_time = 0

/client/MouseWheel(src,delta_x,delta_y,location,control,params) //This lets you zoom in / out with your mouse
	if(mob)
		if(!mob.overmap_ship) //If theyre not in an overmap ship, don't let them zoom.
			return ..()
	if(usr.client && control =="mapwindow.map")
		if(world.time < next_zoomout_time)
			return
		next_zoomout_time = world.time + 0.3 SECONDS //To prevent crashing from viewspam.
		if(delta_y>=1)
			current_view_size -= 10
			if(current_view_size <= 15)
				current_view_size = 15
				change_view(getScreenSize(prefs.widescreenpref)) //Reset our view back if we go below the default view setting
		if(delta_y<=-1)
			current_view_size += 10
			if(current_view_size >= 40) //Any further than this, and byond start to lag.
				current_view_size = 40
	if(current_view_size > 15) //Bigger than default
		if(prefs.widescreenpref && CONFIG_GET(flag/widescreen))
			change_view("[current_view_size+17]x[current_view_size+9]") //Widescreen aspect ratio is 21:9. So we just make every ratio 21:9 so that you dont get C I N E M A T I C black bars whenever you zoom out.
		else
			change_view("[current_view_size]x[current_view_size]") //if theyre not a widescreen user, it's a simple case of just zooming them out