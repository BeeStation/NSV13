
/atom/movable/screen/overheat
	name = "Heat"
	icon = 'nsv13/icons/overmap/gui/overheat_gauge.dmi'
	icon_state = "gauge"
	screen_loc = "WEST:64,CENTER-1:15"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/filterprogress = 50


/atom/movable/screen/overheat/Initialize(mapload)
	transform *= 4
	cut_overlay()
	var/image/progressbar = image('nsv13/icons/overmap/gui/overheat_gauge.dmi', icon_state= "8" )
	progressbar.filters += filter(type = "alpha", y = filterprogress , flags = MASK_INVERSE , icon =  'icons/obj/doors/airlocks/mask_32x32_airlocks.dmi',  name = "progressbarmask")
	//alpha_mask_filter, alpha_mask_filter(0 , 100, 'icons/obj/doors/airlocks/mask_32x32_airlocks.dmi')
	add_overlay(progressbar)

//	/atom/movable/screen/alien/plasma_display

/datum/hud/overheat


/*
/datum/hud/revenant/New(mob/owner)
	..()

	healths = new /atom/movable/screen/healths/revenant()
	healths.hud = src
	infodisplay += healths



	alien_plasma_display = new /atom/movable/screen/alien/plasma_display()
	alien_plasma_display.hud = src
	infodisplay += alien_plasma_display


/mob/living/carbon/alien/proc/updatePlasmaDisplay()
	if(!hud_used) //clientless aliens
		return
	hud_used.alien_plasma_display.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='magenta'>[round(getPlasma())]</font></div>")
*/
