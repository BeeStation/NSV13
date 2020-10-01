/client
	var/overmap_zoomout = 0

/client/MouseWheel(src,delta_x,delta_y,location,control,params) //This lets you zoom in / out with your mouse
	if(!mob?.overmap_ship) //If they're not in an overmap ship, shortcut to standard behavior.
		return ..()
	var/list/modifier = params2list(params)
	if(modifier["ctrl"])
		if(delta_y > 0)
			overmap_zoomout--
		else
			overmap_zoomout++


		overmap_zoomout = CLAMP(overmap_zoomout, 0, 15)
		rescale_view(overmap_zoomout, 0, ((40*2)+1)-15)

/* //Oh my god KMC all of this is A W F U L - I know, right? ~K
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
			*/
